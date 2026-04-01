import requests
import sys
import json

BASE_URL = "http://localhost:5000"
HEADERS = {"X-Nexus-Token": "deadly_sing_2026"}

def print_pulse():
    try:
        r = requests.get(f"{BASE_URL}/pulse", headers=HEADERS)
        data = r.json()
        print(f"\n--- System Pulse ---")
        print(f"🔋 Battery: {data['battery']} | 🌡️ Temp: {data['temp']}")
        print(f"🧠 RAM: {data['ram_used']} used / {data['ram_free']} free")
        print(f"--------------------\n")
    except:
        print("❌ Engine unreachable. Is 'nexus_engine.py' running?")

def ask_ai(prompt, model="qwen2.5:0.5b"):
    print(f"🤖 Thinking ({model})...")
    try:
        r = requests.post(f"{BASE_URL}/ask", 
                         headers=HEADERS, 
                         json={"model": model, "prompt": prompt})
        print(f"\nNexus: {r.json()['response']}\n")
    except:
        print("❌ Connection error.")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        if sys.argv[1] == "--pulse":
            print_pulse()
        else:
            ask_ai(" ".join(sys.argv[1:]))
    else:
        print("Usage: python nexus-cli.py [prompt] OR python nexus-cli.py --pulse")
