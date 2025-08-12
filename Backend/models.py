import sqlalchemy as sa
from sqlalchemy.orm import relationship
from database import Base
from datetime import date,timedelta


book_genre = sa.Table(
    "book_genre",
    Base.metadata,
    sa.Column("bid",sa.Integer,sa.ForeignKey("book_mt.bid"),primary_key=True),
    sa.Column("gid",sa.Integer,sa.ForeignKey("genre_mt.gid"),primary_key=True)
)

class User(Base):
    __tablename__ = "users"

    uid = sa.Column(sa.Integer, primary_key=True, index=True)
    gmail = sa.Column(sa.String, unique=True, nullable=False)
    phonenumber = sa.Column(sa.String, unique=True, nullable=False)
    name = sa.Column(sa.String, nullable=False)
    profile_pic = sa.Column(sa.String, nullable=True)
    password = sa.Column(sa.String, nullable=False)
    fav_list = sa.Column(sa.String, nullable=True)
    role = sa.Column(sa.String, default="user",nullable=False)
    remember_me: bool = False
    member_of = relationship("MemberList",back_populates="user")
    borrowed_books = relationship("BorrowBooksMT", back_populates="user")
    notifications = relationship("Notification", back_populates="user")

class Librarian(Base):
    __tablename__ = "librarian"
    lbid = sa.Column(sa.Integer, primary_key=True, autoincrement=True)
    gmail = sa.Column(sa.String, unique=True, nullable=False)
    phonenumber = sa.Column(sa.String, unique=True, nullable=False)
    name = sa.Column(sa.String, nullable=False)
    role = sa.Column(sa.String, default="librarian",nullable=False)
    profile_pic = sa.Column(sa.String, nullable=True)
    password = sa.Column(sa.String, nullable=False)
    lid = sa.Column(sa.Integer, sa.ForeignKey("library_mt.lid"), nullable=False)
    library = relationship("LibraryMT", back_populates="librarians")

class LibraryMT(Base):
    __tablename__ = "library_mt"

    lid = sa.Column(sa.Integer, primary_key=True, autoincrement=True)
    name = sa.Column(sa.String, nullable=False)
    address = sa.Column(sa.String, nullable=False)
    library_pic = sa.Column(sa.String, nullable=True)
    phonenumber = sa.Column(sa.String, unique=True, nullable=False)
    gmail = sa.Column(sa.String, unique=True, nullable=False)
    penalty = sa.Column(sa.Float, nullable=False)
    default_borrow_duration = sa.Column(sa.Integer, nullable=False, default=7)
    librarians = relationship("Librarian", back_populates="library")
    books = relationship("BookMT", back_populates="library")
    borrowed_books = relationship("BorrowBooksMT", back_populates="library")
    members = relationship("MemberList",back_populates="library_mt")

class BookMT(Base):
    __tablename__ = "book_mt"

    bid = sa.Column(sa.Integer, primary_key=True, index=True)
    library_book_id = sa.Column(sa.Integer, nullable=False)
    name = sa.Column(sa.String, nullable=False)
    author = sa.Column(sa.String, nullable=False)
    cover = sa.Column(sa.String, nullable=True)
    description = sa.Column(sa.String,nullable=False)
    available_count = sa.Column(sa.Integer, nullable=False, default=1)
    lid = sa.Column(sa.Integer, sa.ForeignKey("library_mt.lid"), nullable=False)
    library = relationship("LibraryMT", back_populates="books")
    borrowed_books = relationship("BorrowBooksMT", back_populates="book")
    genres = relationship("GenreMT",secondary=book_genre,back_populates="books")
    __table_args__ = (
        sa.UniqueConstraint('lid', 'library_book_id', name='unique_library_book_id'),
    )


class BorrowBooksMT(Base):
    __tablename__ = "borrow_books"

    tid = sa.Column(sa.Integer, primary_key=True, index=True)
    uid = sa.Column(sa.Integer, sa.ForeignKey("users.uid"), nullable=False)
    bid = sa.Column(sa.Integer, sa.ForeignKey("book_mt.bid"), nullable=False)
    lid = sa.Column(sa.Integer, sa.ForeignKey("library_mt.lid"), nullable=False)
    bdate = sa.Column(sa.Date, nullable=False)
    rdate = sa.Column(sa.Date, nullable=True)
    deadline = sa.Column(sa.Date, nullable=False, default=lambda: date.today() + timedelta(days=7))
    penalty = sa.Column(sa.Float, nullable=True, default=0.0)
    returned = sa.Column(sa.Boolean,nullable=True, default=False)
    user = relationship("User", back_populates="borrowed_books")
    book = relationship("BookMT", back_populates="borrowed_books")
    library = relationship("LibraryMT", back_populates="borrowed_books")
class Notification(Base):
    __tablename__ = "notifications"

    nid = sa.Column(sa.Integer, primary_key=True, index=True)
    uid = sa.Column(sa.Integer, sa.ForeignKey("users.uid"), nullable=False)
    message = sa.Column(sa.String, nullable=False)
    created_at = sa.Column(sa.DateTime, default=sa.func.now())
    read = sa.Column(sa.Boolean, default=False)

    user = relationship("User", back_populates="notifications")

class MemberList(Base):
    __tablename__ = "memberlist"
    __table_args__ = (sa.UniqueConstraint('lid', 'mlid', name='uix_lid_mlid'),)
    
    mid = sa.Column(sa.Integer, primary_key=True, index=True, autoincrement=True)
    lid = sa.Column(sa.Integer, sa.ForeignKey("library_mt.lid"), nullable=False)
    mlid = sa.Column(sa.Integer,nullable=False)
    name = sa.Column(sa.String, nullable=False)
    email = sa.Column(sa.String, unique=True, nullable=True)
    phone = sa.Column(sa.String, nullable=False)
    uid = sa.Column(sa.Integer, sa.ForeignKey("users.uid"), nullable=True)
    joined_on = sa.Column(sa.DateTime, default=sa.func.now())
    user = relationship("User",back_populates="member_of")
    library_mt = relationship("LibraryMT", back_populates="members")

class GenreMT(Base):
    __tablename__ = "genre_mt"

    gid = sa.Column(sa.Integer, primary_key=True, index=True, autoincrement=True)
    name = sa.Column(sa.String,unique=True,nullable=False)
    books = relationship("BookMT",secondary=book_genre,back_populates="genres")