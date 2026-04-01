from flask import Flask, request, jsonify
import requests
import os

app = Flask(__name__)
API_TOKEN = os.environ.get("NEXUS_API_TOKEN", "dev-token-123")
OLLAMA_URL = "http://127.0.0.1:11434/api/generate"
LLM_MODEL = "dolphin-phi:latest" 

def require_auth(req):
    return req.headers.get("Authorization") == f"Bearer {API_TOKEN}"

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
        
        print(f"📡 {module.upper()} payload received. Routing to Dolphin-Phi...")
        
        # Dynamic Prompt Engineering
        if module == "mobile-recon":
            context = f"Review the following raw Nmap scan data for target: {target}. Identify open ports and assess risk."
        elif module == "sentinel":
            context = f"Review the following system log anomalies extracted from: {target}. Identify brute-force attempts, unauthorized access, and assess the threat level."
        else:
            context = f"Analyze the following security data for target: {target}."

        system_prompt = f"""
        You are Sentinel-AI, a senior cybersecurity analyst. 
        {context}
        Be concise, professional, and factual. Limit to 3 sentences.

        RAW DATA:
        {raw_data}
        """
        
        llm_payload = {"model": LLM_MODEL, "prompt": system_prompt, "stream": False}
        llm_response = requests.post(OLLAMA_URL, json=llm_payload, timeout=300)
        
        if llm_response.status_code == 200:
            return jsonify({"analysis": llm_response.json().get("response", "")}), 200
        else:
            return jsonify({"analysis": f"API Error {llm_response.status_code}"}), 500

    except requests.exceptions.Timeout:
        return jsonify({"analysis": "CRITICAL: AI Timeout."}), 500
    except Exception as e:
        return jsonify({"analysis": f"ENGINE CRASH: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000, debug=False)
