from pydantic import BaseModel, EmailStr, field_validator
from datetime import date
from typing import Optional

class UserCreate(BaseModel):
    gmail: EmailStr
    phonenumber: str
    name: str
    password: str
    role: str = "user"
    remember_me: bool = False

class UserLogin(BaseModel):
    gmail: EmailStr
    password: str
    remember_me: bool = False

class UserResponse(BaseModel):
    uid: int
    gmail: EmailStr
    name: str
    phonenumber: str
    role: str
    remember_me: bool = False

    class Config:
        from_attributes = True

class BorrowBookRequest(BaseModel):
    bid: int
    lid: int

class ReturnBookRequest(BaseModel):
    tid: int

class BorrowedBookResponse(BaseModel):
    tid: int
    bid: int
    lid: int
    bdate: date
    rdate: date | None


class BookResponse(BaseModel):
    bid: int
    name: str
    author: str
    genre: str
    cover: str

    @field_validator("cover", mode="before")
    def format_cover_url(cls, v):
        if v:
            return f"http://127.0.0.1:8000/static/books/{v}"
        return v

class LibraryResponse(BaseModel):
    lid: int
    name: str
    address: str
    library_pic: str

    @field_validator("library_pic", mode="before")
    def format_library_pic(cls, v):
        if v:
            return f"http://127.0.0.1:8000/static/libraries/{v}"
        return v


class BookCreate(BaseModel):
    name: str
    author: str
    genre: str
    cover: Optional[str] = None
    lid: int
    available_count: int

class MemberCreate(BaseModel):
    name: str
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    uid: Optional[str] = None

class MemberUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None
