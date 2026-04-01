from flask import Flask, request, jsonify
import requests
import subprocess
import os
import json

app = Flask(__name__)

# Config
DB_PATH = os.path.expanduser("~/termux-ai-workspace/vault/db/nexus.db")
OLLAMA_URL = "http://localhost:11434/api/generate"
VAULT_KEY = "your_vault_password" 
API_TOKEN = "deadly_sing_2026" # Your security token

def get_vault_context():
    """Fetches the last 3 interactions from the encrypted vault."""
    sql_query = f"PRAGMA key = '{VAULT_KEY}'; SELECT prompt, response FROM ai_memory ORDER BY timestamp DESC LIMIT 3;"
    try:
        res = subprocess.run(['sqlcipher', '-cmd', sql_query, DB_PATH], capture_output=True, text=True, timeout=5)
        lines = res.stdout.strip().split('\n')
        return "\n".join([f"Past Interaction: {l}" for l in lines if l])
    except:
        return ""

@app.before_request
def verify_token():
    """Security check for every request."""
    if request.headers.get("X-Nexus-Token") != API_TOKEN:
        return jsonify({"error": "Unauthorized"}), 401

@app.route('/ask', methods=['POST'])
def ask_ai():
    data = request.json or {}
    model = data.get("model", "qwen2.5:0.5b")
    user_p = data.get("prompt", "")
    
    # 1. Get Memory & Augment Prompt
    context = get_vault_context()
    full_prompt = f"Historical Context:\n{context}\n\nCurrent Prompt: {user_p}"

    try:
        # 2. Call Ollama
        r = requests.post(OLLAMA_URL, json={"model": model, "prompt": full_prompt, "stream": False}, timeout=90)
        ai_resp = r.json().get("response", "No response")
        
        # 3. Encrypted Log to Vault
        clean_p, clean_r = user_p.replace("'", "''"), ai_resp.replace("'", "''")
        sql_in = f"PRAGMA key = '{VAULT_KEY}'; INSERT INTO ai_memory (model, prompt, response) VALUES ('{model}', '{clean_p}', '{clean_r}');"
        subprocess.run(['sqlcipher', DB_PATH], input=sql_in, text=True, capture_output=True)
        
        return jsonify({"response": ai_resp})
    except Exception as e:
        return jsonify({"response": f"Engine Error: {str(e)}"}), 500

@app.route('/pulse', methods=['GET'])
def system_pulse():
    try:
        b_res = subprocess.run(['termux-battery-status'], capture_output=True, text=True)
        batt = json.loads(b_res.stdout) if b_res.returncode == 0 else {}
        r_res = subprocess.run(['free', '-m'], capture_output=True, text=True)
        ram = r_res.stdout.split('\n')[1].split() if r_res.returncode == 0 else ["0","0","0","0"]
        return jsonify({"battery": f"{batt.get('percentage', '??')}%", "temp": f"{batt.get('temperature', '??')}°C", "ram_used": f"{ram[2]}MB", "ram_free": f"{ram[3]}MB", "status": "Online"})
    except:
        return jsonify({"error": "Hardware API failed"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
