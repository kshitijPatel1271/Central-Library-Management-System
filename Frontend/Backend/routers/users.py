from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import User
from crud import get_user, update_user
from routers.auth import get_current_user

users_router = APIRouter()


@users_router.get("/me")
def get_current_user_info(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    user = get_user(db, current_user.uid)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return {"uid": user.uid, "gmail": user.gmail, "name": user.name, "phonenumber": user.phonenumber, "role": user.role}

@users_router.put("/update")
def update_user_info(
    name: str = None,
    phonenumber: str = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    updated_user = update_user(db, current_user.uid, name, phonenumber)
    if not updated_user:
        raise HTTPException(status_code=404, detail="User not found")
    return {"message": "User updated successfully"}
