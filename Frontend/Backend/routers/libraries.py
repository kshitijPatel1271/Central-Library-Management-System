from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from database import get_db
from models import MemberList, Librarian,BookMT
from crud import search_libraries
from schemas import MemberCreate, MemberUpdate
from routers.auth import get_current_librarian

libraries_router = APIRouter()

@libraries_router.get("/search")
def search_libraries_endpoint(name: str = Query(None), db: Session = Depends(get_db)):
    results = search_libraries(db, name)
    if not results:
        raise HTTPException(status_code=404, detail="No libraries found")
    return results

@libraries_router.post("/members")
def add_member(member_data: MemberCreate,db: Session = Depends(get_db),current_librarian: Librarian = Depends(get_current_librarian)):
    """Add a new member to the librarian's library"""
    lid = current_librarian.lid

    existing_member = db.query(MemberList).filter_by(email=member_data.email, lid=lid).first()
    if existing_member:
        raise HTTPException(status_code=400, detail="Member already exists")

    new_member = MemberList(
        lid=lid,
        name=member_data.name,
        email=member_data.email,
        phone=member_data.phone
    )
    db.add(new_member)
    db.commit()
    db.refresh(new_member)

    return {"message": "Member added successfully", "member": new_member}

@libraries_router.delete("/members/{mid}")
def delete_member(mid: int,db: Session = Depends(get_db),current_librarian: Librarian = Depends(get_current_librarian)):
    """Delete a member from the librarian's library"""
    lid = current_librarian.lid

    member = db.query(MemberList).filter_by(mid=mid, lid=lid).first()
    if not member:
        raise HTTPException(status_code=404, detail="Member not found")

    db.delete(member)
    db.commit()

    return {"message": f"Member {member.name} deleted successfully"}

@libraries_router.put("/members/{mid}")
def update_member(mid: int,member_data: MemberUpdate,db: Session = Depends(get_db),current_librarian: Librarian = Depends(get_current_librarian)):
    """Update member details"""
    lid = current_librarian.lid

    member = db.query(MemberList).filter_by(mid=mid, lid=lid).first()
    if not member:
        raise HTTPException(status_code=404, detail="Member doesn't exist")

    for key, value in member_data.dict(exclude_unset=True).items():
        setattr(member, key, value)

    db.commit()
    db.refresh(member)

    return {"message": f"Member {member.name} updated successfully", "member": member}

@libraries_router.get("/search-books")
def search_book_in_lib(name: str = None,author: str = None,genre: str = None,db: Session = Depends(get_db),current_librarian: Librarian = Depends(get_current_librarian)):
    """Fn that let's librarian search books within that library"""
    lid = current_librarian.lid

    query = db.query(BookMT).filter(BookMT.lid == lid)

    if name:
        query = query.filter(BookMT.name.ilike(f"%{name}%"))
    if author:
        query = query.filter(BookMT.author.ilike(f"%{author}%"))
    if genre:
        query = query.join(BookMT.genres).filter(BookMT.genres.any(name=genre))
    
    books = query.all()
    
    if not books:
        raise HTTPException(status_code=404,detail="No books in the DB")
    
    return books