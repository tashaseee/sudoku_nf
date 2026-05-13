import httpx
import time

BASE_URL = "http://localhost:8080/api"

def main():
    print("1. Registering test user...")
    client = httpx.Client(base_url=BASE_URL)
    username = f"testuser_{int(time.time())}"
    res = client.post("/auth/register", json={"email": f"{username}@test.com", "password": "password123", "username": username})
    print(res.json())
    token = res.json()["access_token"]
    
    client.headers.update({"Authorization": f"Bearer {token}"})
    
    print("\n2. Getting initial achievements...")
    res = client.get("/achievements/")
    print(f"Total achievements: {len(res.json())}")
    unlocked = [a for a in res.json() if a["unlocked"]]
    print(f"Unlocked: {len(unlocked)}")
    
    print("\n3. Simulating winning 1 game (should unlock first win achievement)...")
    payload = {
        "difficulty": "easy",
        "result": "win",
        "time_elapsed": 45,
        "mistakes": 0,
        "hints_used": 0,
        "is_ai_coach": False,
        "puzzle": [],
        "solution": []
    }
    res = client.post("/games/", json=payload)
    print("Game saved! Status:", res.status_code, res.text)
    
    print("\n4. Checking achievements again...")
    res = client.get("/achievements/")
    unlocked = [a for a in res.json() if a["unlocked"]]
    print(f"Unlocked now: {len(unlocked)}")
    for a in unlocked:
        print(f" - {a['title']}")
        
    print("\n5. Checking notifications...")
    res = client.get("/notifications/")
    for n in res.json():
        print(f" - Notification: {n['title']} | {n['body']}")

if __name__ == "__main__":
    main()
