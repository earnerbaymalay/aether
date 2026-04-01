# 🌌 NEXUS: Autonomous AI Workspace
**Architect:** Deadly Sing | **Environment:** Nokia XR20 (AArch64) | **Version:** 2.3.5

NEXUS is a terminal-native, modular AI ecosystem designed for mobile data sovereignty. It bridges high-performance local LLM inference (Ollama) with automated security forensics and a persistent memory knowledge base.

---

## ⚡ Quick Start
Deploy the ecosystem and verify the environment in two commands:

```bash
nexus start
nexus health

# 1. Remove the standalone project folders from the workspace
rm -rf ~/termux-ai-workspace/tools/cypherchat
rm -rf ~/termux-ai-workspace/tools/nexus11

# 2. Ensure the nexus tool directory exists
mkdir -p ~/termux-ai-workspace/tools/nexus

pkg update && pkg upgrade -y

cd ~/termux-ai-workspace
git pull origin main

sed -i '/elif args.cmd == "sync":/i \    elif args.cmd == "update":\n        print(f"{C}🔄 Running System & Workspace Update...{NC}")\n        subprocess.run("pkg update && pkg upgrade -y", shell=True)\n        subprocess.run("git pull", shell=True, cwd=BASE)\n        print(f"{G}✓ System and Workspace are now current.{NC}")' ~/termux-ai-workspace/bin/nexus

echo "alias refresh='fuser -k 5000/tcp && nexus start && nexus health'" >> ~/.bashrc
source ~/.bashrc

ollama --version

ollama pull dolphin-phi:latest

# If not installed: pkg install htop
htop

sed -i '/elif args.cmd == "health":/i \    elif args.cmd == "version":\n        print(f"{C}📦 Workspace Core: v2.4.0{NC}")\n        subprocess.run("ollama --version", shell=True)\n        print(f"{G}✓ Model: Dolphin-Phi (Latest Quantization){NC}")' ~/termux-ai-workspace/bin/nexus

cat << 'EOF' > ~/termux-ai-workspace/tools/nexus/core/hub.py
from flask import Flask, request, jsonify
import requests, os

app = Flask(__name__)
API_TOKEN = os.environ.get("NEXUS_API_TOKEN", "nexus-dev-2026")
OLLAMA_URL = "http://127.0.0.1:11434/api/generate"
BRAIN_PATH = os.path.expanduser("~/termux-ai-workspace/tools/nexus/core/brain.md")

@app.route('/health', methods=['GET'])
def health(): return jsonify({"status": "online"}), 200

@app.route('/ai/process', methods=['POST'])
def process():
    if request.headers.get("Authorization") != f"Bearer {API_TOKEN}":
        return jsonify({"error": "Unauthorized"}), 401
    
    data = request.json
    selected_model = data.get("model", "dolphin-phi:latest")
    
    memory = ""
    if os.path.exists(BRAIN_PATH):
        with open(BRAIN_PATH, 'r') as f: memory = f"\n[CONTEXT]:\n{f.read()}\n"
    
    payload = {
        "model": selected_model,
        "prompt": f"SYSTEM: {data.get('system')}{memory}\nUSER: {data.get('input')}",
        "stream": False
    }
    
    try:
        res = requests.post(OLLAMA_URL, json=payload, timeout=300)
        return jsonify({"output": res.json().get("response")}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000)
