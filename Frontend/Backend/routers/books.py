from fastapi import APIRouter, Depends, HTTPException, Query,UploadFile,File
from sqlalchemy.orm import Session
from database import get_db
from models import BorrowBooksMT, BookMT, User, LibraryMT, GenreMT,MemberList
from schemas import  BorrowedBookResponse, BookResponse, BookCreate
from typing import List
from routers.auth import get_current_user, get_current_librarian
from crud import get_user, get_book, get_user_borrowed_books, mark_book_as_returned, create_borrow_record,create_book,rate_limiter
import datetime

books_router = APIRouter()

@books_router.get("/borrowed", response_model=list[BorrowedBookResponse])
def get_borrowed_books(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    borrowed_books = db.query(BorrowBooksMT).filter(BorrowBooksMT.uid == current_user.uid).all()
    return borrowed_books

@books_router.get("/search", response_model=List[BookResponse])
def search_books(name: str = Query(None),author: str = Query(None),library: str = Query(None),db: Session = Depends(get_db),user : User = Depends(get_current_user)):
    rate_limiter(f"user_search:{user.uid}", limit=10, window=30)
    query = db.query(BookMT)

    if name:
        query = query.filter(BookMT.name.ilike(f"%{name}%"))
    if author:
        query = query.filter(BookMT.author.ilike(f"%{author}%"))
    if library:
        query = query.join(LibraryMT).filter(LibraryMT.name.ilike(f"%{library}%"))

    results = query.all()
    
    if not results:
        raise HTTPException(status_code=404, detail="No books found")

    return results

@books_router.get("/authors/search")
def search_authors(author: str, db: Session = Depends(get_db)):
    authors = db.query(BookMT.author).filter(BookMT.author.ilike(f"%{author}%")).distinct().all()
    
    if not authors:
        raise HTTPException(status_code=404, detail="No authors found")

    return {"authors": [a[0] for a in authors]}

@books_router.post("/librarian/record-borrow")
def record_borrow(uid: int, bid: int, lid: int, db: Session = Depends(get_db), current_librarian: User = Depends(get_current_librarian)):
    user = get_user(db, uid)
    book = get_book(db, bid)

    if not user or not book:
        raise HTTPException(status_code=404, detail="User or book not found")

    if book.available_count <= 0:
        raise HTTPException(status_code=400, detail="No copies available for borrowing")

    member = db.query(MemberList).filter_by(uid=uid, lid=lid).first()
    if not member:
        raise HTTPException(status_code=403, detail="User isn't a member of the library")

    borrow_entry = create_borrow_record(db, uid, bid, lid)

    book.available_count -= 1
    db.commit()
    db.refresh(book)

    return {
        "message": "Borrow record added successfully",
        "borrow_id": borrow_entry.tid,
        "book_name": book.name,
        "borrowed_by": user.name,
        "borrow_date": borrow_entry.bdate,
        "return_deadline": borrow_entry.deadline,
        "recorded_by": current_librarian.gmail
    }



@books_router.get("/my-borrowed-books")
def get_borrowed_books(db: Session = Depends(get_db),current_user: User = Depends(get_current_user)):
    borrowed_books = get_user_borrowed_books(db, current_user.uid)
    if not borrowed_books:
        return {"message": "You have not borrowed any books."}

    return borrowed_books

@books_router.put("/librarian/return-book")
def return_book(borrow_id: int, db: Session = Depends(get_db), current_librarian: User = Depends(get_current_librarian)):
    borrow_entry = db.query(BorrowBooksMT).filter(BorrowBooksMT.tid == borrow_id).first()

    if not borrow_entry:
        raise HTTPException(status_code=404, detail="Borrow record not found")
    
    if borrow_entry.rdate:
        raise HTTPException(status_code=400, detail="Book has already been returned")

    if borrow_entry.lid != current_librarian.lid:
        raise HTTPException(status_code=403, detail="Unauthorized to modify this borrow record")

    today = datetime.date.today()
    if today > borrow_entry.deadline:
        overdue_days = (today - borrow_entry.deadline).days
        library = db.query(LibraryMT).filter_by(lid=borrow_entry.lid).first()
        borrow_entry.penalty = overdue_days * library.penaltyrate

    borrow_entry.rdate = today

    book = db.query(BookMT).filter_by(bid=borrow_entry.bid).first()
    book.available_count += 1

    db.commit()
    return {"message": "Book marked as returned successfully"}

@books_router.post("/add-book")
async def add_book(book: BookCreate = Depends(),file: UploadFile = File(...),db: Session = Depends(get_db),current_librarian: User = Depends(get_current_librarian)):
    new_book = create_book(db, book, file)
    return {"message": "Book added successfully", "book": new_book}

@books_router.get("/book/genre/{genre_name}")
def get_books_by_genre(genre_name: str,db: Session = Depends(get_db)):
    genre = db.query(GenreMT).filter(GenreMT.name.ilike(f"%{genre_name}%")).first()
    if not genre:
        raise HTTPException(status_code=404,detail="Genre not found")
    return {"genre": genre.name,"books":genre.books}

@books_router.get("/books/filter")
def filter_books_by_genres(genres: List[str] = Query(...),db: Session = Depends(get_db)):
    books_query = db.query(BookMT).filter(BookMT.genres.any(GenreMT.name.in_(genres)))
    books = books_query.all()
    if not books:
        raise HTTPException(status_code=404,detail="No books found")
    return books