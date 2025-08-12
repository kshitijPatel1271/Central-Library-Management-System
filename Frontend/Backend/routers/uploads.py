from fastapi import APIRouter, UploadFile, File, Depends, HTTPException, status
from sqlalchemy.orm import Session
import shutil
import os
import uuid
from database import get_db
from models import User, Librarian,BookMT

uploads_router = APIRouter()

BASE_DIR = "static"
BOOKS_DIR = os.path.join(BASE_DIR, "books")
LIBRARIES_DIR = os.path.join(BASE_DIR, "libraries")
PROFILE_PICS_DIR = os.path.join(BASE_DIR, "profile_pics", "users")

os.makedirs(BOOKS_DIR, exist_ok=True)
os.makedirs(LIBRARIES_DIR, exist_ok=True)
os.makedirs(PROFILE_PICS_DIR, exist_ok=True)

ALLOWED_EXTENSIONS = {"jpg", "jpeg", "png"}

def save_file(file: UploadFile, save_dir: str, filename: str):
    extension = file.filename.split(".")[-1].lower()
    if extension not in ALLOWED_EXTENSIONS:
        raise HTTPException(status_code=400, detail="Unsupported file type.")

    unique_filename = f"{filename}.{extension}"
    file_path = os.path.join(save_dir, unique_filename)

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    return unique_filename

@uploads_router.post("/upload/profile-pic")
async def upload_profile_pic(user_id: int, file: UploadFile = File(...), db: Session = Depends(get_db)):
    user = db.query(User).filter(User.uid == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    filename = save_file(file, PROFILE_PICS_DIR, str(user_id))
    user.profile_pic = f"profile_pics/users/{filename}"
    db.commit()
    db.refresh(user)

    return {"profile_pic_url": f"/static/profile_pics/users/{filename}"}

@uploads_router.post("/upload/librarian-profile-pic")
async def upload_librarian_pic(librarian_id: int, file: UploadFile = File(...), db: Session = Depends(get_db)):
    librarian = db.query(Librarian).filter(Librarian.lid == librarian_id).first()
    if not librarian:
        raise HTTPException(status_code=404, detail="Librarian not found")

    filename = save_file(file, PROFILE_PICS_DIR, f"librarian_{librarian_id}")
    librarian.profile_pic = f"profile_pics/users/{filename}"
    db.commit()
    db.refresh(librarian)

    return {"profile_pic_url": f"/static/profile_pics/users/{filename}"}

@uploads_router.post("/upload/book-cover")
async def upload_book_cover(book_id: int, file: UploadFile = File(...), db: Session = Depends(get_db)):
    book = db.query(BookMT).filter(BookMT.bid == book_id).first()
    if not book:
        raise HTTPException(status_code=404, detail="Book not found")

    filename = save_file(file, BOOKS_DIR, f"book_{book_id}")
    book.cover = f"books/{filename}"
    db.commit()
    db.refresh(book)

    return {"cover_url": f"/static/books/{filename}"}

@uploads_router.post("/upload/")
async def upload_image(file: UploadFile = File(...), category: str = "books", book_id: int = None, library_id: int = None):
    if category not in ["books", "libraries"]:
        raise HTTPException(status_code=400, detail="Invalid category. Choose 'books' or 'libraries'.")

    if category == "books":
        if not book_id:
            raise HTTPException(status_code=400, detail="Book ID required for books.")
        filename = save_file(file, BOOKS_DIR, f"book_{book_id}")
    
    elif category == "libraries":
        if not library_id:
            raise HTTPException(status_code=400, detail="Library ID required for libraries.")
        filename = save_file(file, LIBRARIES_DIR, f"library_{library_id}")

    return {
        "filename": filename,
        "url": f"/static/{category}/{filename}"
    }
