from datetime import date
from sqlalchemy.orm import Session
from database import SessionLocal
from models import BorrowBooksMT, User
import asyncio
from crud import create_notification

async def check_due_dates():
    db: Session = SessionLocal()
    today = date.today()

    borrowed_books = db.query(BorrowBooksMT).all()

    for borrow in borrowed_books:
        user = db.query(User).filter(User.uid == borrow.uid).first()

        if not user:
            continue

        if not borrow.rdate:
            continue

        days_left = (borrow.rdate - today).days

        if days_left == 1:
            create_notification(db, user.uid, f"Your book (ID: {borrow.bid}) is due tomorrow.")

        if borrow.penalty and borrow.penalty > 0:
            create_notification(db, user.uid, f"Your penalty has increased to {borrow.penalty}.")
    db.commit()
    db.close()

async def start_scheduler():
    while True:
        await check_due_dates()
        await asyncio.sleep(86400)
