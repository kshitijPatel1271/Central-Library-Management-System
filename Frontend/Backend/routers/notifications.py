from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import Notification, User
from routers.auth import get_current_user
from crud import get_unread_notifications, mark_notification_as_read

notifications_router = APIRouter()

@notifications_router.get("/")
def get_notifications(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    notifications = db.query(Notification).filter(Notification.uid == current_user.uid).all()

    if not notifications:
        return {"notifications": []}

    return {"notifications": notifications}

@notifications_router.post("/read/{notification_id}")
def mark_as_read(notification_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    notification = db.query(Notification).filter(Notification.nid == notification_id, Notification.uid == current_user.uid).first()
    
    if not notification:
        raise HTTPException(status_code=404, detail="Notification not found")

    if notification.read:
        return {"message": "Notification already marked as read."}

    notification.read = True
    db.commit()
    
    return {"message": "Notification marked as read."}


@notifications_router.get("/unread-count")
def get_unread_count(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    count = get_unread_notifications(db, current_user.uid)
    return {"unread_notifications": count}
