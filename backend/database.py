
import os

from dotenv import load_dotenv
from pymongo import MongoClient
from pymongo.errors import PyMongoError

load_dotenv()

MONGODB_URL = os.getenv(
    "MONGODB_URL",
    "mongodb://127.0.0.1:27017",
)

DATABASE_NAME = os.getenv(
    "DATABASE_NAME",
    "caninecare",
)

client = MongoClient(
    MONGODB_URL,
    serverSelectionTimeoutMS=5000,
)

database = client[DATABASE_NAME]

users_collection = database["users"]
cases_collection = database["cases"]

users_collection.create_index("email", unique=True)
cases_collection.create_index([("user_id", 1), ("created_at", -1)])


def check_database_connection() -> bool:
    try:
        client.admin.command("ping")
        return True
    except PyMongoError:
        return False
