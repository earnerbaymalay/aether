#!/bin/bash
# AetherAI Nokia XR20 Single-Script Orchestrator
# Colors for the terminal
B=$'\033[1m'; BL=$'\033[34m'; GR=$'\033[32m'; R=$'\033[0m'

echo "${BL}${B}Initializing AetherAI Workspace on Nokia XR20...${R}"

# 1. Scaffold Directories
mkdir -p ~/aether/{core,agent,toolbox,models}
cd ~/aether

# 2. Check for Ollama (The local backbone)
if ! command -v ollama &>/dev/null; then
    echo "${B}Installing local Ollama...${R}"
    pkg install ollama -y
fi

# 3. Create the Python Agent (agent/chat.py)
cat << 'PY_EOF' > agent/chat.py
import os, sys, json, subprocess, requests

def run_tool(name, args=""):
    # Simple tool runner for Nokia XR20 environment
    if name == "get_battery":
        return subprocess.check_output(["termux-battery-status"]).decode()
    if name == "list_files":
        return str(os.listdir(args if args else "."))
    return "Tool not found"

def chat():
    print("\n--- AetherAI Local (Qwen 1.5B) ---")
    history = []
    while True:
        user = input("\n>> ")
        if user.lower() in ['exit', 'quit']: break
        
        # Simple Ollama Local API Call
        payload = {
            "model": "qwen2.5-coder:1.5b",
            "messages": history + [{"role": "user", "content": user}],
            "stream": False
        }
        try:
            r = requests.post("http://localhost:11434/api/chat", json=payload)
            ans = r.json()['message']['content']
            print(f"\nAI: {ans}")
            history.append({"role": "user", "content": user})
            history.append({"role": "assistant", "content": ans})
        except:
            print("Error: Is 'ollama serve' running in another tab?")

if __name__ == "__main__":
    chat()
PY_EOF

# 4. Create the Master Runner (aether.sh)
cat << 'RUN_EOF' > aether.sh
#!/bin/bash
# Launch script
echo "Starting AetherAI local services..."
# Background the ollama server if not running
pgrep ollama >/dev/null || (ollama serve & sleep 5)
# Pull the lightweight coder model for XR20
ollama pull qwen2.5-coder:1.5b
python3 agent/chat.py
RUN_EOF

chmod +x aether.sh
echo "${GR}${B}Setup Complete!${R}"
echo "Run 'bash aether.sh' to start your local coding session."
