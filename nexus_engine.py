from flask import Flask, request, jsonify
import requests
import os
import re

app = Flask(__name__)
API_TOKEN = os.environ.get("NEXUS_API_TOKEN", "dev-token-123")
OLLAMA_URL = "http://127.0.0.1:11434/api/generate"
LLM_MODEL = "dolphin-phi:latest" 
BLOCKLIST_FILE = "nexus_blocklist.txt"

def require_auth(req):
    return req.headers.get("Authorization") == f"Bearer {API_TOKEN}"

def update_blocklist(ip):
    """Appends an offending IP to the local blocklist."""
    if not os.path.exists(BLOCKLIST_FILE):
        open(BLOCKLIST_FILE, 'w').close()
    
    with open(BLOCKLIST_FILE, 'r') as f:
        existing = f.read()
    
    if ip not in existing:
        with open(BLOCKLIST_FILE, 'a') as f:
            f.write(f"{ip}\n")
        print(f"🚫 IPS ALERT: IP {ip} has been added to the Nexus Blocklist.")
        return True
    return False

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "online", "engine": "Nexus AI Hub (Dolphin-Phi)"}), 200

@app.route('/analyze', methods=['POST'])
def analyze_data():
    try:
        if not require_auth(request):
            return jsonify({"error": "Unauthorized."}), 401
        
        data = request.json
        module = data.get("module", "unknown")
        target = data.get("target", "unknown")
        raw_data = data.get("scan_data", "")
        
        # Determine Context
        context = "Analyze these network ports." if module == "mobile-recon" else "Analyze these system logs for brute-force attacks."
        
        system_prompt = f"You are Sentinel-AI. {context} Raw Data: {raw_data}"
        
        llm_payload = {"model": LLM_MODEL, "prompt": system_prompt, "stream": False}
        llm_response = requests.post(OLLAMA_URL, json=llm_payload, timeout=300)
        
        if llm_response.status_code == 200:
            analysis = llm_response.json().get("response", "")
            
            # --- IPS LOGIC: Mitigation Trigger ---
            # If AI identifies a high-threat brute-force, extract the IP
            if "brute-force" in analysis.lower() or "unauthorized" in analysis.lower():
                # Extract IP address from the raw log data
                ip_match = re.search(r'\b(?:\d{1,3}\.){3}\d{1,3}\b', raw_data)
                if ip_match:
                    attacker_ip = ip_match.group()
                    update_blocklist(attacker_ip)
            
            return jsonify({"analysis": analysis}), 200
        else:
            return jsonify({"analysis": "LLM Error"}), 500

    except Exception as e:
        return jsonify({"analysis": f"ENGINE CRASH: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000, debug=False)
