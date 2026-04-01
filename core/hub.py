from flask import Flask, request, jsonify
import requests, os

app = Flask(__name__)
API_TOKEN = os.environ.get("NEXUS_API_TOKEN", "nexus-dev-2026")
OLLAMA_URL = "http://127.0.0.1:11434/api/generate"
BRAIN_PATH = os.path.expanduser("~/termux-ai-workspace/core/brain.md")

@app.route('/health', methods=['GET'])
def health(): return jsonify({"status": "online"}), 200

@app.route('/ai/process', methods=['POST'])
def process():
    if request.headers.get("Authorization") != f"Bearer {API_TOKEN}":
        return jsonify({"error": "Unauthorized"}), 401
    data = request.json
    memory = ""
    if os.path.exists(BRAIN_PATH):
        with open(BRAIN_PATH, 'r') as f: memory = f"\n[CONTEXT]:\n{f.read()}\n"
    payload = {
        "model": data.get("model", "dolphin-phi:latest"),
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
