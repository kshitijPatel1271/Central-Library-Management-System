from sqlalchemy.orm import Session
from models import User, BookMT,BorrowBooksMT,Notification,LibraryMT,MemberList,GenreMT
from schemas import UserCreate, BookCreate
import datetime,time
from database import get_db
from routers.uploads import save_file
from passlib.context import CryptContext
from fastapi import UploadFile,HTTPException
from typing import Optional
import redis,os,dotenv

dotenv.load_dotenv()
REDIS_HOST = os.getenv("REDIS_HOST","127.0.0.1")
REDIS_PORT=os.getenv("REDIS_PORT","6379")
REDIS_DB=os.getenv("REDIS_DB","0")
REDIS_URL=f"redis://{REDIS_HOST}:{REDIS_PORT}/{REDIS_DB}"
redis_client = redis.Redis.from_url(REDIS_URL, decode_responses=True)

def get_user(db: Session, user_id: int):
    return db.query(User).filter(User.uid == user_id).first()

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
def update_password(email: str, hashed_password: str,db: Session):
    """Update Passwrd"""
    user = db.query(User).filter(User.gmail == email).first()
    if user:
        user.password = hashed_password
        db.commit()
        return True
    return False
    
def update_user(db: Session, user_id: int, name: str = None, phonenumber: str = None):
    user = get_user(db, user_id)
    if not user:
        return None
    if name:
        user.name = name
    if phonenumber:
        user.phonenumber = phonenumber

    db.commit()
    db.refresh(user)
    return user

def get_book(db: Session, book_id: int):
    return db.query(BookMT).filter(BookMT.bid == book_id).first()

def get_all_books(db: Session):
    return db.query(BookMT).all()

def create_book(db: Session, book: BookCreate, file: UploadFile):
    filename = save_file(file, "static/books")
    cover_url = f"/static/books/{filename}"

    library = db.query(LibraryMT).filter_by(lid=book.lid).first()
    if not library:
        raise HTTPException(status_code=404, detail="Library not found")

    last_book = db.query(BookMT).filter(BookMT.lid == book.lid).order_by(BookMT.library_book_id.desc()).first()
    new_library_book_id = (last_book.library_book_id + 1) if last_book else 1

    new_book = BookMT(name=book.name,author=book.author,cover=cover_url,lid=book.lid,available_count=book.available_count,library_book_id=new_library_book_id)
    db.add(new_book)
    db.commit()
    db.refresh(new_book)
    for genre_name in book.genres:
        genre = db.query(GenreMT).filter_by(name=genre_name).first()
        if not genre:
            genre = GenreMT(name=genre_name)
            db.add(genre)
            db.commit()
        new_book.genres.append(genre)

    db.commit()
    return new_book


def delete_book(db: Session, book_id: int):
    db_book = get_book(db, book_id)
    if not db_book:
        return None

    db.delete(db_book)
    db.commit()
    return db_book

def get_user_borrowed_books(db: Session, uid: int):
    today = datetime.date.today()
    borrowed_books = db.query(BorrowBooksMT).filter(BorrowBooksMT.uid == uid).all()

    if not borrowed_books:
        return []

    borrowed_data = []
    for borrow in borrowed_books:
        book = db.query(BookMT).filter(BookMT.bid == borrow.bid).first()
        is_overdue = borrow.rdate and borrow.rdate < today
        penalty_amount = borrow.penalty if is_overdue else 0.0

        borrowed_data.append({
            "book_id": borrow.bid,
            "book_name": book.name,
            "borrow_date": borrow.bdate,
            "return_date": borrow.rdate,
            "overdue": is_overdue,
            "penalty": penalty_amount
        })

    return borrowed_data

def mark_book_as_returned(db: Session, borrow_id: int):
    borrow_entry = db.query(BorrowBooksMT).filter(BorrowBooksMT.tid == borrow_id).first()
    if not borrow_entry:
        return None

    if borrow_entry.rdate:
        return "already_returned"

    borrow_entry.rdate = datetime.date.today()
    db.commit()
    db.refresh(borrow_entry)
    return borrow_entry

def create_notification(db: Session, uid: int, message: str):
    new_notification = Notification(uid=uid, message=message, created_at=datetime.utcnow())
    db.add(new_notification)
    db.commit()

def get_unread_notifications(db: Session, uid: int):
    return db.query(Notification).filter(Notification.uid == uid, Notification.read == False).all()

def mark_notification_as_read(db: Session, notification_id: int):
    notification = db.query(Notification).filter(Notification.nid == notification_id).first()
    if not notification:
        return None

    notification.read = True
    db.commit()
    return notification

def create_borrow_record(db: Session, uid: int, bid: int, lid: int):
    member = db.query(MemberList).filter_by(uid = uid,lid = lid).first()
    if not member:
        raise HTTPException(status_code=403,detail="User isn't a member of the library")
    borrow_entry = BorrowBooksMT(
        uid=uid, 
        bid=bid, 
        lid=lid, 
        bdate=datetime.date.today(), 
        rdate=None, 
        deadline=datetime.date.today() + datetime.timedelta(days=7),
        penalty=0.0
    )
    db.add(borrow_entry)
    db.commit()
    db.refresh(borrow_entry)
    return borrow_entry

def search_libraries(db: Session, name: str = None):
    query = db.query(LibraryMT)

    if name:
        query = query.filter(LibraryMT.name.ilike(f"%{name}%"))

    return query.all()

def create_notification(db: Session, uid: int, message: str):
    new_notification = Notification(uid=uid, message=message, created_at=datetime.utcnow())
    db.add(new_notification)
    db.commit()
    db.refresh(new_notification)
    return new_notification

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def add_member(db: Session, lid: int, name: str, phone: str, email: Optional[str] = None, uid: Optional[int] = None):
    """Adds a member to the library before borrowing."""
    existing_member = db.query(MemberList).filter_by(lid=lid, phone=phone).first()
    
    if existing_member:
        return existing_member

    new_member = MemberList(lid=lid, name=name, phone=phone, email=email, uid=uid)
    db.add(new_member)
    db.commit()
    db.refresh(new_member)
    return new_member

def calculate_penalty(db: Session):
    today = datetime.date.today()
    overdue_books = db.query(BorrowBooksMT).filter(BorrowBooksMT.rdate.is_(None),BorrowBooksMT.deadline < today).all()
    for borrow in overdue_books:
        library = db.query(LibraryMT).filter_by(lid=borrow.lid).first()
        if library:
            days_overdue = (today - borrow.deadline).days
            penalty = days_overdue * library.penaltyrate
            borrow.penalty = penalty
    
    db.commit()

def rate_limiter(key: str, limit: int, window: int):
    current_time = int(time.time())
    if redis_client.ping():
        print("YEP AT THE START OF LIMITER AS WELL:D\n")
    redis_key = f"rate_limit:{key}"
    if not redis_client.ping():
        raise Exception("Redis server is not connected!")
    request_count = redis_client.get(redis_key)
    print("I GOT HERE\n")
    
    if request_count is None:
        redis_client.setex(redis_key, window, 1)
    else:
        request_count = int(request_count)
        if request_count >= limit:
            raise HTTPException(status_code=429, detail="Too many requests. Try again later.")
        else:
            redis_client.incr(redis_key)

    return True