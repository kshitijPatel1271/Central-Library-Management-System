from fastapi import APIRouter, Depends, HTTPException, status, Header, BackgroundTasks,Request
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
import pytz
from utils.email_utils import send_email_background
from utils import otp_utils
from database import get_db
from models import User,Librarian
from schemas import UserCreate, UserLogin, UserResponse
from jose import jwt, JWTError
from datetime import datetime, timedelta
from crud import get_user_by_email, create_user, hash_password, verify_password,update_password,rate_limiter
import redis
import os,uuid
from dotenv import load_dotenv


IST = pytz.timezone("Asia/Kolkata")
time_now = datetime.now(IST)
load_dotenv()


SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = os.getenv("ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 10))
REFRESH_TOKEN_EXPIRE_DAYS = int(os.getenv("REFRESH_TOKEN_EXPIRE_DAYS", 30))
REFRESH_TOKEN_EXPIRE_MINUTES = int(os.getenv("REFRESH_TOKEN_EXPIRE_MINUTES",30))
REDIS_HOST = os.getenv("REDIS_HOST","127.0.0.1")
REDIS_PORT=os.getenv("REDIS_PORT","6379")
REDIS_DB=os.getenv("REDIS_DB","0")
REDIS_URL=f"redis://{REDIS_HOST}:{REDIS_PORT}/{REDIS_DB}"
redis_client = redis.Redis.from_url(REDIS_URL, decode_responses=True)

auth_router = APIRouter()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

def logout_all_sessions(user_email: str):
    """Deletes all active refresh tokens for a user"""
    keys = redis_client.keys(f"refresh:{user_email}:*")
    for key in keys:
        redis_client.delete(key)

def create_access_token(data: dict, expires_delta: timedelta):
    """Generate a new access token"""
    to_encode = data.copy()
    expire = datetime.now(IST) + expires_delta
    to_encode.update({"exp": expire.timestamp()})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


def create_refresh_token(data: dict, remember_me: bool):
    """Generate refresh token with session ID"""
    session_id = str(uuid.uuid4())
    expire_time = timedelta(days=30) if remember_me else timedelta(minutes=30)
    expire = datetime.now(IST) + expire_time
    
    token_data = data.copy()
    token_data.update({"exp": expire.timestamp(), "session_id": session_id})
    
    refresh_token = jwt.encode(token_data, SECRET_KEY, algorithm=ALGORITHM)
    redis_client.setex(f"refresh:{data['sub']}:{session_id}", int(expire_time.total_seconds()), refresh_token)
    
    return refresh_token, session_id


def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    """Verify and return current user"""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_email = payload.get("sub")
        if user_email is None:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid authentication")
        user = db.query(User).filter(User.gmail == user_email).first()
        if user is None:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")
        return user
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    
def get_current_librarian(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    """Verify if the user is a librarian using the Librarian table"""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_email = payload.get("sub")

        user = db.query(User).filter(User.gmail == user_email).first()
        if user is None:
            raise HTTPException(status_code=401, detail="Invalid authentication")

        librarian_entry = db.query(Librarian).filter(Librarian.uid == user.uid).first()
        if not librarian_entry:
            raise HTTPException(status_code=403, detail="Access denied. Librarians only.")

        return user
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

@auth_router.post("/register", response_model=UserResponse)
def register_user(user: UserCreate, db: Session = Depends(get_db)):
    """Register a new user"""
    existing_user = get_user_by_email(db, user.gmail)
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    existing_phone = db.query(User).filter(User.phonenumber == user.phonenumber).first()
    if existing_phone:
        raise HTTPException(status_code=400, detail="Phone number already in use")

    if user.role == "librarian":
        raise HTTPException(status_code=403, detail="Only librarians can create librarian accounts.")

    hashed_password = hash_password(user.password)
    new_user = create_user(db, user, hashed_password)

    return new_user

@auth_router.post("/register-librarian")
def register_librarian(user: UserCreate, db: Session = Depends(get_db), current_librarian: User = Depends(get_current_librarian)):
    """Register a new librarian (Only accessible by existing librarians)"""
    
    existing_user = get_user_by_email(db, user.gmail)
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    existing_phone = db.query(User).filter(User.phonenumber == user.phonenumber).first()
    if existing_phone:
        raise HTTPException(status_code=400, detail="Phone number already in use")

    if current_librarian.role != "librarian":
        raise HTTPException(status_code=400, detail="Invalid role for librarian registration")

    hashed_password = hash_password(user.password)
    new_user = create_user(db, user, hashed_password)

    new_librarian = Librarian(uid=new_user.uid, library_id=user.library_id)
    db.add(new_librarian)
    db.commit()

    return {"message": "Librarian registered successfully", "librarian_id": new_librarian.uid}


@auth_router.post("/login")
def login_user(user: UserLogin, db: Session = Depends(get_db)):
    """Login user and issue tokens"""
    rate_limiter(f"login:{user.gmail}", limit=5, window=600)
    db_user = db.query(User).filter(User.gmail == user.gmail).first()

    if not db_user or not verify_password(user.password, db_user.password):
        raise HTTPException(status_code=400, detail="Invalid credentials")

    if db_user.role == "librarian":
        librarian = db.query(Librarian).filter(Librarian.uid == db_user.uid).first()
        if not librarian:
            raise HTTPException(status_code=403, detail="Librarian account not fully registered")

    access_token = create_access_token(
        {"sub": db_user.gmail, "role": db_user.role},
        timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )

    refresh_token,session_id = create_refresh_token(
        {"sub": db_user.gmail, "role": db_user.role},
        remember_me=user.remember_me
    )

    redis_client.setex(f"refresh:{db_user.gmail}:{session_id}", REFRESH_TOKEN_EXPIRE_MINUTES*60,refresh_token)

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer"
    }

@auth_router.get("/protected-endpoint")
def protected_route(current_user: User = Depends(get_current_user)):
    """Protected route that requires authentication"""
    return {"message": f"Welcome, {current_user.name}! You are authenticated."}


@auth_router.post("/refresh")
def refresh_token(authorization:str = Header(...), db: Session = Depends(get_db)):
    """Generate a new access token using the refresh token"""
    try:
        print(f"Received Refresh Token: {refresh_token}")
        if not authorization.startswith("Bearer "):
            raise HTTPException(status_code=401, detail="Invalid refresh token format")
        refresh_token = authorization.split("Bearer ")[1]
        payload = jwt.decode(refresh_token, SECRET_KEY, algorithms=[ALGORITHM])
        user_email = payload.get("sub")
        role = payload.get("role")
        session_id = payload.get("session_id")
        stored_token = redis_client.get(f"refresh:{user_email}:{session_id}")
        if not stored_token or stored_token != refresh_token:
            raise HTTPException(status_code=401,detail="Invalid or expired Refresh token")
        if not user_email or not role:
            raise HTTPException(status_code=401, detail="Invalid refresh token payload")
        user = db.query(User).filter(User.gmail == user_email).first()
        if not user:
            raise HTTPException(status_code=401, detail="User not found")

        new_access_token = create_access_token(
            {"sub": user.gmail, "role": user.role},
            timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        )

        if not new_access_token:
            raise HTTPException(status_code=500, detail="Failed to generate new access token")

        print(f"New Access Token: {new_access_token}")

        return {"access_token": new_access_token, "token_type": "bearer"}

    except JWTError as e:
        print(f"JWT Error: {str(e)}")
        raise HTTPException(status_code=401, detail="Invalid refresh token")



@auth_router.post("/logout")
def logout(request: Request):
    """Logout user (Invalidate all active refresh tokens)"""
    
    refresh_token = request.headers.get("Authorization")
    if not refresh_token or not refresh_token.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Refresh token missing")

    refresh_token = refresh_token.split(" ")[1]
    try:
        payload = jwt.decode(refresh_token, SECRET_KEY, algorithms=[ALGORITHM])
        user_email = payload.get("sub")
        keys = redis_client.keys(f"refresh:{user_email}:*")
        for key in keys:
            redis_client.delete(key)
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

    return {"message": "Logged out successfully"}


@auth_router.post("/verify-otp/")
async def verify_otp(email: str,otp: str, new_password: str,db: Session = Depends(get_db)):
    stored_otp = otp_utils.get_otp(email)
    if not stored_otp:
        raise HTTPException(status_code=400,detail="OTP expired or invalid")
    if stored_otp != otp:
        raise HTTPException(status_code=400, detail="Invalid")
    hashed_password = hash_password(new_password)
    scs = update_password(email,hashed_password,db)
    if not scs:
        raise HTTPException(status_code=404, detail="User not found!")
    
    otp_utils.delete_otp(email)
    return {"message": "Password updated"}

@auth_router.post("/forgot-password/")
async def forgot_password(background_tasks: BackgroundTasks,email: str,db: Session= Depends(get_db)):
    """forgo pass"""
    rate_limiter(f"otp_request:{email}", limit=5, window=600)
    user = db.query(User).filter(User.gmail == email).first()
    if not user:
        raise HTTPException(status_code=404,detail="User not found")
    otp = otp_utils.generate_otp()
    otp_utils.store_otp(email,otp)
    subject = "OTP to change the Password"
    body = f"OTP to change the password is:{otp}\nIt will expire after 5 minutes."
    await send_email_background(background_tasks,email,subject,body)
    return{"message":"OTP SENT"}
