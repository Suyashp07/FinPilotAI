from pymongo import MongoClient

MONGO_URI = "mongodb+srv://finpilot_admin:DIeLdBxZfMQGCpMu@finpilotcluster.imgcajf.mongodb.net/?appName=FinPilotCluster"

print("Creating MongoDB client...")

client = MongoClient(
    MONGO_URI,
    serverSelectionTimeoutMS=10000
)

try:
    result = client.admin.command("ping")
    print("MongoDB connection successful!")
    print(result)

except Exception as e:
    print("MongoDB connection FAILED")
    print(type(e).__name__)
    print(e)