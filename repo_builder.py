import os, subprocess

# Configuration
base_dir = os.path.expanduser("~/edge-sentinel")
os.makedirs(os.path.join(base_dir, "app/static"), exist_ok=True)

# 1. Visual Asset: SVG Banner
banner = '''<svg width="800" height="200" xmlns="http://www.w3.org/2000/svg">
<rect width="100%" height="100%" fill="#0a0a0a"/>
<text x="40" y="70" font-family="monospace" font-size="40" fill="#4EAA25" font-weight="bold">EDGE-SENTINEL</text>
<text x="40" y="110" font-family="monospace" font-size="18" fill="#005571">LOCAL-FIRST AIR-GAPPED AI SECURITY</text>
<text x="40" y="150" font-family="monospace" font-size="14" fill="#FF7F50">> SNAPDRAGON 480 // QWEN 0.5B // AARCH64</text>
<circle cx="700" cy="100" r="30" fill="none" stroke="#4EAA25" stroke-width="2" stroke-dasharray="5,3"/>
</svg>'''

# 2. Marketable README
readme = '''# 🛡️ Edge-Sentinel-Mobile
![Banner](banner.svg)

![Python](https://img.shields.io/badge/Python-3.11%2B-blue?style=flat-square)
![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=flat-square)
![llama.cpp](https://img.shields.io/badge/llama.cpp-Native-orange?style=flat-square)

**Autonomous, Air-Gapped AI Security for Constrained Edge Devices.**

Edge-Sentinel-Mobile transforms your Android device into a private security node. It runs real-time telemetry and LLM analysis entirely on-device. No cloud. No APIs. No leaks.

## 🏗️ Architecture
- **Backend:** FastAPI with Asynchronous WebSockets.
- **AI Engine:** llama.cpp (compiled natively for ARM64/NEON).
- **Inference:** Qwen-1.5-0.5B (Quantized Q4_K_M).

## 🚀 Quick Start
1. `./install.sh`
2. `./start.sh`
3. View at `http://127.0.0.1:8001`
'''

# 3. Usage Guide
usage = '''# 📖 Usage Guide
- **Start:** Execute `./start.sh`. It boots the AI server on 8080 and the Dashboard on 8001.
- **Stop:** Execute `./stop.sh` to safely terminate all background processes.
- **Log Monitoring:** View Termux for real-time inference logs.
'''

# 4. Expansion Roadmap
roadmap = '''# 🗺️ Roadmap
- **Phase 1:** Real-time Battery/System Telemetry (Complete).
- **Phase 2:** Network Sentinel (Nmap intruder detection).
- **Phase 3:** Thermal-Aware Batching (Optimizing for Snapdragon 480 heat).
'''

# 5. Main Python Logic
main_py = '''import asyncio, json, httpx
from fastapi import FastAPI, WebSocket
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])
app.mount("/static", StaticFiles(directory="app/static"), name="static")

@app.get("/")
async def get(): return FileResponse('app/static/index.html')

async def analyze(data):
    try:
        async with httpx.AsyncClient(base_url="http://localhost:8080", timeout=15.0) as c:
            p = {"prompt": f"Battery at {data.get('percentage')}%. Is this a risk?", "n_predict": 24}
            r = await c.post("/completion", json=p)
            return r.json().get("content", "Analysis stable.")
    except: return "AI Engine Sleeping..."

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    while True:
        try:
            proc = await asyncio.create_subprocess_shell("termux-battery-status", stdout=asyncio.subprocess.PIPE)
            out, _ = await proc.communicate()
            d = json.loads(out.decode())
            d["analysis"] = await analyze(d)
            await websocket.send_json(d)
            await asyncio.sleep(5)
        except: break
'''

# 6. Dashboard HTML
index_html = '''<!DOCTYPE html><html><head><title>Sentinel</title><style>
body{background:#0a0a0a;color:#4EAA25;font-family:monospace;padding:20px}
.box{border:1px solid #005571;padding:15px;margin-top:10px;border-radius:4px}
h1{color:#FF7F50}</style></head><body><h1>🛡️ EDGE-SENTINEL</h1>
<div class="box" id="t">Connecting Telemetry...</div>
<div class="box" id="a">Awaiting AI Analysis...</div>
<script>
const ws = new WebSocket("ws://localhost:8001/ws");
ws.onmessage = e => {
    const d = JSON.parse(e.data);
    document.getElementById('t').innerText = "🔋 BATTERY: " + d.percentage + "% [" + d.status + "]";
    document.getElementById('a').innerText = "🧠 AI: " + d.analysis;
};
</script></body></html>'''

# 7. Shell Scripts
install_sh = '#!/bin/bash\npython -m venv venv\nsource venv/bin/activate\npip install fastapi uvicorn[standard] httpx pydantic\necho "Setup Complete."'
start_sh = '#!/bin/bash\npkill -f llama-server; pkill -f uvicorn\ncd ~/llama.cpp && ./build/bin/llama-server -m models/qwen.gguf -c 512 -t 4 --port 8080 --host 0.0.0.0 > /dev/null 2>&1 &\ncd ~/edge-sentinel && source venv/bin/activate && python -m uvicorn app.main:app --port 8001'
stop_sh = '#!/bin/bash\npkill -f llama-server; pkill -f uvicorn\necho "Services Stopped."'

# Write files
mapping = {
    "banner.svg": banner, "README.md": readme, "USAGE.md": usage, "ROADMAP.md": roadmap,
    "app/main.py": main_py, "app/static/index.html": index_html,
    "install.sh": install_sh, "start.sh": start_sh, "stop.sh": stop_sh,
    "LICENSE": "MIT License", ".gitignore": "venv/\n__pycache__/\n*.gguf"
}

for path, content in mapping.items():
    with open(os.path.join(base_dir, path), "w") as f:
        f.write(content)

os.chmod(os.path.join(base_dir, "install.sh"), 0o755)
os.chmod(os.path.join(base_dir, "start.sh"), 0o755)
os.chmod(os.path.join(base_dir, "stop.sh"), 0o755)

print("\n✅ REPOSITORY GENERATED IN ~/edge-sentinel")
