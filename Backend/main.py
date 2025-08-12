from fastapi import FastAPI
from routers import auth, books, libraries, users, notifications, uploads
from database import Base, engine
from routers.notifications import start_scheduler
from fastapi.staticfiles import StaticFiles
from dotenv import load_dotenv
from contextlib import asynccontextmanager
import asyncio

load_dotenv()
Base.metadata.create_all(bind=engine)

@asynccontextmanager
async def lifespan(app: FastAPI):
    asyncio.create_task(start_scheduler())
    yield

app = FastAPI(
    title="Central Library Management System",
    lifespan=lifespan
)

app.include_router(auth.auth_router, prefix="/auth", tags=["Authentication"])
app.include_router(books.books_router, prefix="/books", tags=["Books"])
app.include_router(libraries.libraries_router, prefix="/libraries", tags=["Libraries"])
app.include_router(notifications.notifications_router, prefix="/notifications", tags=["Notifications"])
app.include_router(users.users_router, prefix="/users", tags=["Users"])
app.include_router(uploads.uploads_router, prefix="/uploads", tags=["Uploads"])
app.mount("/static", StaticFiles(directory="static"), name="static")

@app.get("/")
def root():
    return {"message": "Welcome to the Central Library API!"}
