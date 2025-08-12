from fastapi import APIRouter, Depends, HTTPException, Header, BackgroundTasks,Request
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from utils.email_utils import send_email_background
from utils import otp_utils
from database import get_db
from models import User,Librarian,LibraryMT
from schemas import UserCreate, UserLogin, UserResponse,LibrarianCreate
from jose import jwt, JWTError
from datetime import datetime, timedelta, timezone
import redis,os,uuid,hmac
from dotenv import load_dotenv
from tasks import hash_password, verify_password
load_dotenv()

SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = os.getenv("ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 60))
REFRESH_TOKEN_EXPIRE_DAYS = int(os.getenv("REFRESH_TOKEN_EXPIRE_DAYS", 30))
REFRESH_TOKEN_EXPIRE_MINUTES = int(os.getenv("REFRESH_TOKEN_EXPIRE_MINUTES",30))
REDIS_HOST = os.getenv("REDIS_HOST","127.0.0.1")
REDIS_PORT=os.getenv("REDIS_PORT","6379")
REDIS_DB=os.getenv("REDIS_DB","0")
REDIS_URL=f"redis://{REDIS_HOST}:{REDIS_PORT}/{REDIS_DB}"
redis_client = redis.Redis.from_url(REDIS_URL, decode_responses=True)
BASE_DIR = os.getenv("BASE_DIR", "static")
LIBRARIES_DIR = os.getenv("LIBRARIES_DIR", os.path.join(BASE_DIR, "libraries"))
auth_router = APIRouter()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.gmail == email).first()

def create_user(db: Session, user: UserCreate, hashed_password: str):
    new_user = User(
        gmail=user.gmail,
        phonenumber=user.phonenumber,
        name=user.name,
        password=hashed_password,
        role=user.role
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


def rate_limiter(key: str, limit: int, window: int):
    current_time = int(datetime.time())
    redis_key = f"rate_limit:{key}"
    if not redis_client.ping():
        raise Exception("Redis server is not connected!")
    request_count = redis_client.get(redis_key)
    if request_count is None:
        redis_client.setex(redis_key, window, 1)
    else:
        request_count = int(request_count)
        if request_count >= limit:
            raise HTTPException(status_code=429, detail="Too many requests. Try again later.")
        else:
            redis_client.incr(redis_key)

    return True
def verify_token(token: str, db: Session):
    """Verify JWT token and return user details."""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_email: str = payload.get("sub")
        role: str = payload.get("role")

        if not user_email or not role:
            raise HTTPException(status_code=401, detail="Invalid token")

        user = db.query(User).filter(User.gmail == user_email).first()
        if not user:
            raise HTTPException(status_code=401, detail="User not found")

        return user, role
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

def create_access_token(data: dict, expires_delta: timedelta):
    """Generate a new access token"""
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + expires_delta
    to_encode.update({"exp": expire.timestamp()})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


def create_reset_token(email: str):
    payload = {
        "sub": email,
        "purpose": "reset_password",
        "exp": datetime.now(timezone.utc) + timedelta(minutes=10)
    }
    token = jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)
    return token


def create_refresh_token(data: dict, remember_me: bool):
    """Generate refresh token with session ID"""
    session_id = str(uuid.uuid4())
    expire_time = timedelta(days=30) if remember_me else timedelta(minutes=30)
    expire = datetime.now(timezone.utc) + expire_time

    token_data = data.copy()
    token_data.update({"exp": expire.timestamp(), "session_id": session_id})

    refresh_token = jwt.encode(token_data, SECRET_KEY, algorithm=ALGORITHM)
    redis_client.setex(f"refresh:{data['sub']}:{session_id}", int(expire_time.total_seconds()), refresh_token)

    return refresh_token, session_id

@auth_router.post("/register", response_model=UserResponse)
def register_user(user: UserCreate, db: Session = Depends(get_db)):
    """Register a new user"""
    existing_user = get_user_by_email(db, user.gmail)
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    existing_phone = db.query(User).filter(User.phonenumber == user.phonenumber).first()
    if existing_phone:
        raise HTTPException(status_code=400, detail="Phone number already in use")

    hashed_password = hash_password(user.password)
    new_user = create_user(db, user, hashed_password)

    return new_user

@auth_router.post("/register-librarian")
async def register_librarian(request: LibrarianCreate, db: Session = Depends(get_db)):
    print(request.dict())
    existing_librarian = db.query(Librarian).filter(Librarian.gmail == request.gmail).first()
    if existing_librarian:
        raise HTTPException(status_code=400, detail="Librarian already registered")
    existing_library = db.query(LibraryMT).filter(LibraryMT.gmail == request.gmail).first()

    if existing_library:
        library_id = existing_library.lid
        image_path = existing_library.library_pic
    else:
        image_path = request.lib_img if request.lib_img not in (None, "", "null") else None
        new_library = LibraryMT(
            name=request.lib_name,
            address=request.lib_add,
            library_pic=image_path,
            phonenumber=request.phonenumber,
            gmail=request.gmail,
            penalty=request.penalty,
            default_borrow_duration=7
        )
        db.add(new_library)
        db.commit()
        db.refresh(new_library)
        library_id = new_library.lid
        image_path = new_library.library_pic
    new_librarian = Librarian(
        name=request.name,
        gmail=request.gmail,
        phonenumber=request.phonenumber,
        password=hash_password(request.password),
        lid=library_id
    )

    db.add(new_librarian)
    db.commit()
    db.refresh(new_librarian)

    return {
        "message": "Librarian registered successfully",
        "librarian_id": new_librarian.lbid,
        "library_image": image_path
    }



@auth_router.post("/login")
def login_user(user: UserLogin, db: Session = Depends(get_db)):
    """Login user or librarian and issue tokens"""
    rate_limiter(f"login:{user.gmail}", limit=5, window=600)
    role = "user"
    db_user = db.query(User).filter(User.gmail == user.gmail).first()
    if db_user and verify_password(user.password, db_user.password):
        role = db_user.role
        gmail = db_user.gmail
    else:
        db_librarian = db.query(Librarian).filter(Librarian.gmail == user.gmail).first()
        if db_librarian and verify_password(user.password, db_librarian.password):
            role = db_librarian.role
            gmail = db_librarian.gmail
        else:
            raise HTTPException(status_code=401, detail="Invalid credentials")

    access_token = create_access_token(
        {"sub": gmail, "role": role},
        timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    refresh_token, session_id = create_refresh_token(
        {"sub": gmail, "role": role},
        remember_me=user.remember_me
    )

    redis_client.setex(f"access:{gmail}", ACCESS_TOKEN_EXPIRE_MINUTES * 60, access_token)

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
        "role": role
    }



@auth_router.post("/refresh")
def refresh_token(authorization:str = Header(...), db: Session = Depends(get_db)):
    """Generate a new access token using the refresh token"""
    try:
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
    """Logout user (Invalidate access & refresh tokens)"""

    refresh_token = request.headers.get("Authorization")
    if not refresh_token or not refresh_token.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Refresh token missing")

    refresh_token = refresh_token.split(" ")[1]
    try:
        payload = jwt.decode(refresh_token, SECRET_KEY, algorithms=[ALGORITHM])
        user_email = payload.get("sub")
        refresh_keys = redis_client.keys(f"refresh:{user_email}:*")
        for key in refresh_keys:
            redis_client.delete(key)
        access_keys = redis_client.keys(f"access:{user_email}*")
        for key in access_keys:
            if redis_client.get(key) == user_email.encode():
                redis_client.delete(key)

    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

    return {"message": "Logged out successfully"}


@auth_router.post("/verify-otp")
async def verify_otp(request: Request):
    data = await request.json()
    email = data.get("email")
    otp = str(data.get("otp"))

    stored_otp = otp_utils.get_otp(email)
    if not stored_otp:
        raise HTTPException(status_code=400, detail="OTP expired or invalid")

    if not hmac.compare_digest(stored_otp, otp):
        raise HTTPException(status_code=400, detail="Invalid OTP")

    otp_utils.delete_otp(email)
    payload = {
        "sub": email,
        "purpose": "reset_password",
        "exp": datetime.now(timezone.utc) + timedelta(minutes=10)
    }
    reset_token = jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)

    return {"reset_token": reset_token}



@auth_router.post("/forgot-password/")
async def forgot_password(request: Request, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    """Forgot password"""
    data = await request.json()
    email = data.get("email")
    rate_limiter(f"otp_request:{email}", limit=5, window=600)

    user = db.query(User).filter(User.gmail == email).first()
    
    if not user:
        librarian = db.query(Librarian).filter(Librarian.gmail == email).first()
        if not librarian:
            raise HTTPException(status_code=404, detail="User not found")
        else:
            user = librarian

    otp = otp_utils.generate_otp()
    otp_utils.store_otp(email, otp)
    subject = "OTP to change the Password"
    body = f"OTP to change the password is: {otp}\nIt will expire after 5 minutes."
    await send_email_background(background_tasks, email, subject, body)

    return {"message": "OTP SENT"}


@auth_router.post("/ver-email")
async def send_otp_emailVer(request:Request,background_tasks: BackgroundTasks):
    """Send an OTP to verify Email"""
    data = await request.json()
    email = data.get("email")
    rate_limiter(f"otp_request:{email}",limit=5,window=300)
    otp = otp_utils.generate_otp()
    otp_utils.store_otp(email,otp)
    subject = "Email verification"
    body = f"OTP to Verify Your Email is:{otp}\nIt will expire after 5 minutes.\nDo not share it with anyone."
    await send_email_background(background_tasks,email,subject,body)
    return {"message":"OTP SENT"}

@auth_router.post("/ver-email-otp")
async def verify_otp_emailVer(request: Request):
    data = await request.json()
    email = data.get("email")
    otp = str(data.get("otp"))
    stored_otp = otp_utils.get_otp(email)
    if not stored_otp:
        raise HTTPException(status_code=400,detail="OTP expired or invalid")
    if not hmac.compare_digest(stored_otp,otp):
        raise HTTPException(status_code=400, detail="Invalid")
    otp_utils.delete_otp(email)
    return {"Success":True}