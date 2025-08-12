from pydantic import BaseModel, EmailStr, field_validator, ConfigDict,field_serializer,Field
from datetime import date
from typing import Optional,List,Any

class UserCreate(BaseModel):
    gmail: EmailStr
    phonenumber: str
    name: str
    password: str
    role: str = "user"
    remember_me: bool = False

class UserUpdate(BaseModel):
    gmail: Optional[EmailStr] = None
    name: Optional[str] = None
    phonenumber: Optional[str] = None
    profile_pic: Optional[str] = None

class LibrarianCreate(BaseModel):
    gmail: EmailStr
    phonenumber: str
    name: str
    password: str
    role: str = "librarian"
    remember_me: bool = False
    lib_name: str
    lib_add: str
    lib_img: str
    penalty: Optional[float] = 0.0

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

    model_config = ConfigDict(from_attributes=True)

class BorrowBookRequest(BaseModel):
    mlid: int
    bid: int
    borrowdate: date
    deadline: date

class ReturnBookRequest(BaseModel):
    tid: int

class BorrowedBookResponse(BaseModel):
    tid: int
    bid: int
    lid: int
    bdate: date
    deadline: date | None
    penalty: float | None = 0.0
    returned: bool | None = False

    model_config = ConfigDict(from_attributes=True)

class GenreResponse(BaseModel):
    name: str

    model_config = ConfigDict(from_attributes=True)
class BorrowedBookResponse(BaseModel):
    tid: int
    uid: int
    bid: int
    lid: int
    issue_date: date
    return_date: Optional[date]
    deadline: date
    penalty: float
    returned: Optional[bool]
    name: Optional[str]
    available_copies: Optional[int] = None
    total_copies: Optional[int] = None
    cover: str

    model_config = ConfigDict(from_attributes=True)


class BookResponse(BaseModel):
    bid: int
    name: str
    author: str
    genres: Optional[List[GenreResponse]] = []
    description: str
    cover: str

    model_config = ConfigDict(from_attributes=True)

    @field_serializer("genres", when_used="always")
    def serialize_genres(self, genres: List[GenreResponse]) -> List[str]:
        return [g.name for g in genres]

class LibraryResponse(BaseModel):
    name: str
    address: str
    library_pic: str
    phonenumber: str
    libr_name: str

class BookCreate(BaseModel):
    name: str
    author: str
    genre: Optional[str] = None
    description: str
    cover: Optional[str] = None
    lid: Optional[int] = None
    library_book_id: Optional[int] = None
    available_count: int

class MemberCreate(BaseModel):
    name: str
    mlid: int
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    uid: Optional[str] = None

class MemberUpdate(BaseModel):
    name: Optional[str] = None
    mlid: Optional[int] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None

class DashboardSummary(BaseModel):
    total_books: int
    total_members: int
    issued_today: int
    issued_week: int
    total_issued: int
    total_dues: int
    fine_collection: float
    returned_books: int

class MemberSearch(BaseModel):
    mlid: Optional[int] = None
    name: Optional[str] = None

class MemberResponse(BaseModel):
    uid: Optional[int] = None
    mlid: int
    name: str
    email: Optional[str] = None
    phone: Optional[str] = None
    joined_on: date

    model_config = ConfigDict(from_attributes=True)

class LibEdit(BaseModel):
    name: Optional[str] = None
    add: Optional[str] = None
    lib_pic: Optional[str] = None
    phone: Optional[str] = None
    penalty: Optional[float] = None

class PassVerify(BaseModel):    
    password: str
