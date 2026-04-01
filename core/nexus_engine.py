from flask import Flask, request, jsonify
import requests, os, re

app = Flask(__name__)
API_TOKEN = os.environ.get("NEXUS_API_TOKEN", "dev-token-123")
OLLAMA_URL = "http://127.0.0.1:11434/api/generate"
LLM_MODEL = "dolphin-phi:latest" 
BLOCKLIST_FILE = os.path.expanduser("~/termux-ai-workspace/logs/nexus_blocklist.txt")

def require_auth(req):
    return req.headers.get("Authorization") == f"Bearer {API_TOKEN}"

def update_blocklist(ip):
    os.makedirs(os.path.dirname(BLOCKLIST_FILE), exist_ok=True)
    if not os.path.exists(BLOCKLIST_FILE):
        open(BLOCKLIST_FILE, 'w').close()
    with open(BLOCKLIST_FILE, 'r') as f:
        if ip in f.read(): return False
    with open(BLOCKLIST_FILE, 'a') as f:
        f.write(f"{ip}\n")
    return True

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "online", "engine": "Nexus AI Hub (Dolphin-Phi)"}), 200

@app.route('/analyze', methods=['POST'])
def analyze_data():
    try:
        if not require_auth(request): return jsonify({"error": "Unauthorized"}), 401
        data = request.json
        module, target, raw_data = data.get("module"), data.get("target"), data.get("scan_data", "")
        prompt = f"You are Sentinel-AI. Analyze this {module} data for {target}: {raw_data}"
        res = requests.post(OLLAMA_URL, json={"model": LLM_MODEL, "prompt": prompt, "stream": False}, timeout=300)
        analysis = res.json().get("response", "")
        if any(k in analysis.lower() for k in ["brute-force", "unauthorized"]):
            ip_match = re.search(r'\b(?:\d{1,3}\.){3}\d{1,3}\b', raw_data)
            if ip_match: update_blocklist(ip_match.group())
        return jsonify({"analysis": analysis}), 200
    except Exception as e:
        return jsonify({"analysis": f"Error: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000)
