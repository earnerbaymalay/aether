#!/bin/bash
# AetherAI Nokia XR20 "Phoenix" Build
# Optimized for West Perth / Snapdragon 480 / 6GB RAM

B=$'\033[1m'; BL=$'\033[38;5;39m'; GR=$'\033[38;5;82m'; RD=$'\033[38;5;196m'; R=$'\033[0m'

echo "${BL}${B}  [AETHER RECOVERY] Rebuilding workspace...${R}"

# 1. CLEAN & SCAFFOLD
rm -rf ~/aether && mkdir -p ~/aether/{core,agent,toolbox/user_tools,models,docs}
cd ~/aether

# 2. CREATE TOOLBOX MANIFEST & DEFAULT TOOLS
cat << 'JSON_EOF' > toolbox/manifest.json
{
  "tools": [
    {"name": "get_date", "description": "Current date/time", "script": "get_date.sh", "enabled": true},
    {"name": "get_battery", "description": "Battery status", "script": "get_battery.sh", "enabled": true},
    {"name": "list_files", "description": "Lists files in a dir", "script": "list_files.sh", "enabled": true},
    {"name": "gh_status", "description": "Check git/gh status", "script": "gh_status.sh", "enabled": true}
  ]
}
JSON_EOF

cat << 'B_EOF' > toolbox/get_battery.sh
#!/bin/bash
termux-battery-status | grep -E "percentage|status"
B_EOF

cat << 'D_EOF' > toolbox/get_date.sh
#!/bin/bash
date '+%A, %d %B %Y %H:%M:%S'
D_EOF

cat << 'L_EOF' > toolbox/list_files.sh
#!/bin/bash
ls -F "${1:-.}"
L_EOF

cat << 'G_EOF' > toolbox/gh_status.sh
#!/bin/bash
gh repo view --json name,url,description
G_EOF

chmod +x toolbox/*.sh

# 3. CREATE THE CORE AGENT (RELIABLE VERSION)
cat << 'PY_EOF' > agent/chat.py
import os, sys, json, requests, subprocess

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def run_tool(name, args=""):
    with open(f"{ROOT}/toolbox/manifest.json") as f:
        tools = json.load(f)["tools"]
    tool = next((t for t in tools if t["name"] == name), None)
    if not tool: return "Tool not found."
    cmd = ["bash", f"{ROOT}/toolbox/{tool['script']}"] + ([args] if args else [])
    return subprocess.check_output(cmd, text=True)

def chat():
    print(f"\n\033[1mAetherAI (Local) | Nokia XR20 Optimized\033[0m")
    print("Type 'exit' to quit or 'tools' to see available commands.\n")
    history = [{"role": "system", "content": "You are AetherAI. You run locally in Termux. Use tools via <tool_call>name(arg)</tool_call>."}]
    
    while True:
        try:
            user = input("\033[38;5;153mYou:\033[0m ").strip()
            if not user: continue
            if user.lower() in ['exit', 'quit']: break
            if user.lower() == 'tools':
                with open(f"{ROOT}/toolbox/manifest.json") as f:
                    print(json.dumps(json.load(f), indent=2))
                continue

            history.append({"role": "user", "content": user})
            r = requests.post("http://localhost:11434/api/chat", 
                             json={"model": "qwen2.5-coder:1.5b", "messages": history, "stream": False}, timeout=60)
            
            ans = r.json()['message']['content']
            print(f"\n\033[38;5;39mAI:\033[0m {ans}\n")
            history.append({"role": "assistant", "content": ans})
        except Exception as e:
            print(f"\033[38;5;196mError:\033[0m {e}. Is 'ollama serve' running?")

if __name__ == "__main__":
    chat()
PY_EOF

# 4. MASTER LAUNCHER (aether.sh)
cat << 'RUN_EOF' > aether.sh
#!/bin/bash
pgrep ollama >/dev/null || (ollama serve >/dev/null 2>&1 & sleep 3)
ollama pull qwen2.5-coder:1.5b
python3 agent/chat.py
RUN_EOF
chmod +x aether.sh

echo "${GR}${B}  [SUCCESS] All files written to ~/aether${R}"
echo "  Run 'bash aether.sh' to start."
