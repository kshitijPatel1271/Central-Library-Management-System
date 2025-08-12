from fastapi import FastAPI
from routers import auth, books, libraries, users, notifications,uploads
from database import Base, engine,redis_client
from tasks import start_scheduler
import asyncio
from fastapi.staticfiles import StaticFiles

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Central Library Management System")

app.include_router(auth.auth_router, prefix="/auth", tags=["Authentication"])
app.include_router(books.books_router, prefix="/books", tags=["Books"])
app.include_router(libraries.libraries_router, prefix="/libraries", tags=["Libraries"])
app.include_router(notifications.notifications_router, prefix="/notifications", tags=["Notifications"])
app.include_router(users.users_router, prefix="/users", tags=["Users"])
app.mount("/static/books", StaticFiles(directory="static/books"), name="books")
app.mount("/static/libraries", StaticFiles(directory="static/libraries"), name="libraries")

app.include_router(uploads.uploads_router, prefix="/files", tags=["Uploads"])

@app.on_event("startup")
async def start_background_tasks():
    asyncio.create_task(start_scheduler())

@app.get("/")
def root():
    return {"message": "Welcome to the Central Library API!"}
