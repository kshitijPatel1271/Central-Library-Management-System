from fastapi import APIRouter, Depends, HTTPException,Request
from sqlalchemy.orm import Session
from database import get_db
from models import User,BookMT,Librarian
from tasks import hash_password,verify_password
from schemas import UserUpdate,PassVerify,BookResponse
import jwt,os,dotenv
from typing import List
users_router = APIRouter()
dotenv.load_dotenv()
SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = os.getenv("ALGORITHM", "HS256")

@users_router.get("/me")
def get_current_user_info(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    user = get_user(db, current_user.uid)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return {"uid":user.uid,"gmail": user.gmail, "name": user.name, "phonenumber": user.phonenumber,"profile_pic":user.profile_pic}