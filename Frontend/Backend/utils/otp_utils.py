import random
import redis
import dotenv
import os

REDIS_URL = os.getenv("REDIS_URL", "redis://127.0.0.1:6379/0")
redis_client = redis.Redis.from_url(REDIS_URL,decode_responses=True)

OTP_EXPIRY = 300

def generate_otp() -> str:
    return str(random.randint(100000, 999999))

def store_otp(email: str, otp: str):
    redis_client.setex(f"otp:{email}", OTP_EXPIRY, otp)

def get_otp(email: str) -> str:
    return redis_client.get(f"otp:{email}")

def delete_otp(email: str):
    redis_client.delete(f"otp:{email}")
