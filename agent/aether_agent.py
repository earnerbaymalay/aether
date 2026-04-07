#!/usr/bin/env python3
"""
🌌 Aether-AI Neural Agent Core // V 19.0 (Server Edition)
High-performance Python agent utilizing a persistent llama-server backend.
Optimized for instant responses and robust error handling on Android.
"""

import os, sys, json, re, subprocess, signal, time, requests
from pathlib import Path
from datetime import datetime

# --- Constants & Configuration ---
DIR = Path.home() / "aether"
MODELS_DIR = DIR / "models"
TOOLBOX_DIR = DIR / "toolbox"
KNOWLEDGE_DIR = DIR / "knowledge"
CONTEXT7_DIR = KNOWLEDGE_DIR / "context7"
SESSION_DIR = Path.home() / ".aether" / "sessions"
SERVER_LOG = SESSION_DIR / "llama_server.log"
LLAMA_SERVER_BIN = Path.home() / "llama.cpp" / "build" / "bin" / "llama-server"
API_URL = "http://127.0.0.1:8080/completion"

# Colors (ANSI)
C_AI = "\033[38;5;39m"
C_USR = "\033[38;5;153m"
C_TOOL = "\033[38;5;82m"
C_ERR = "\033[38;5;196m"
C_DIM = "\033[2m"
C_BOLD = "\033[1m"
C_RST = "\033[0m"

# --- Server Management ---
def is_server_running():
    try:
        response = requests.get("http://127.0.0.1:8080/health", timeout=2)
        return response.status_code == 200
    except:
        return False

def start_server(model_path):
    if is_server_running():
        # Check if the running server has the same model (simplified check)
        return True

    print(f"{C_DIM}[Starting Aether Neural Engine: {model_path.name}...]{C_RST}")
    SESSION_DIR.mkdir(parents=True, exist_ok=True)
    
    cmd = [
        str(LLAMA_SERVER_BIN),
        "-m", str(model_path),
        "--port", "8080",
        "-t", "6",
        "--mmap",
        "-c", "2048",
        "--slot-save-path", str(SESSION_DIR / "slots")
    ]
    
    with open(SERVER_LOG, "w") as log:
        subprocess.Popen(cmd, stdout=log, stderr=log, preexec_fn=os.setpgrp)
    
    # Wait for server to be ready
    for _ in range(30):
        if is_server_running():
            print(f"{C_TOOL}[Engine Online]{C_RST}")
            return True
        time.sleep(1)
    
    print(f"{C_ERR}[Error: Engine failed to start. Check {SERVER_LOG}]{C_RST}")
    return False

def kill_server():
    subprocess.run(["pkill", "-f", "llama-server"], capture_output=True)

# --- Tool Engine ---
def load_manifest():
    manifest_path = TOOLBOX_DIR / "manifest.json"
    if not manifest_path.exists():
        return {"tools": []}
    with open(manifest_path) as f:
        return json.load(f)

def run_tool(name, args=""):
    if name == "learn":
        try:
            if "|" not in args: return "Error: Format is 'filename|content'"
            filename, content = args.split("|", 1)
            filepath = CONTEXT7_DIR / f"{filename.strip()}.md"
            filepath.parent.mkdir(parents=True, exist_ok=True)
            filepath.write_text(content.strip())
            subprocess.run(["git", "-C", str(CONTEXT7_DIR), "add", "."], capture_output=True)
            subprocess.run(["git", "-C", str(CONTEXT7_DIR), "commit", "-m", f"AI Learned: {filename}"], capture_output=True)
            return f"Successfully learned: {filename} in Context7."
        except Exception as e:
            return f"Learning Error: {str(e)}"

    manifest = load_manifest()
    tool = next((t for t in manifest["tools"] if t["name"] == name), None)
    if not tool: return f"Error: Tool '{name}' not found."
    
    script_path = TOOLBOX_DIR / tool["script"]
    if not script_path.exists(): return f"Error: Tool script missing."

    print(f"\n{C_DIM}[Executing: {name}]{C_RST}")
    try:
        cmd = ["bash", str(script_path)] + ([args] if args else [])
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=20)
        return result.stdout.strip() if result.returncode == 0 else f"Tool Error: {result.stderr.strip()}"
    except Exception as e:
        return f"Execution Error: {str(e)}"

# --- Inference Engine ---
def build_system_prompt(knowledge="", skills=""):
    manifest = load_manifest()
    tool_list = "\n".join([f"- **{t['name']}**: {t['description']}" for t in manifest["tools"]])
    
    c7_knowledge = ""
    if CONTEXT7_DIR.exists():
        for p in list(CONTEXT7_DIR.glob("**/*.md"))[:5]:
            try: c7_knowledge += f"### {p.name}\n{p.read_text()[:300]}\n\n"            except: continue

    return f"""You are AetherAI, a local-first neural interface running on Android.
Current Date: {datetime.now().strftime('%A, %d %B %Y')}

## Context7 Knowledge
{c7_knowledge}

## Skills Available
{skills}

## Tool Protocol
Execute tools via: <tool>name(args)</tool>
Special: <tool>learn(filename|content)</tool>

Available tools:
{tool_list}

Rules:
1. Be technical and concise. No conversational filler.
2. Use tools immediately if they help.
3. If you find a better way, use <tool>learn()</tool>.
"""

def generate_completion(prompt, stream=True):
    payload = {
        "prompt": prompt,
        "n_predict": 512,
        "temperature": 0.7,
        "stop": ["User:", "System:", "AI:", "\n\n\n"],
        "stream": stream
    }
    
    try:
        if not stream:
            r = requests.post(API_URL, json=payload, timeout=60)
            return r.json().get("content", "").strip()
        
        r = requests.post(API_URL, json=payload, stream=True, timeout=60)
        full_text = ""
        for line in r.iter_lines():
            if line:
                chunk = json.loads(line.decode("utf-8").replace("data: ", ""))
                content = chunk.get("content", "")
                sys.stdout.write(content)
                sys.stdout.flush()
                full_text += content
                if chunk.get("stop"): break
        return full_text.strip()
    except Exception as e:
        if not is_server_running():
            return f"CRITICAL: Neural Engine crashed. Reason: {str(e)}"
        return f"Inference Error: {str(e)}"

# --- Main Logic ---
def chat_loop(model_name="hermes-3-8b.gguf"):
    model_path = MODELS_DIR / model_name
    if not start_server(model_path): return

    history = []
    knowledge_dir = DIR / "knowledge"
    knowledge_txt = ""
    if knowledge_dir.exists():
        for f in list(knowledge_dir.glob("*.txt"))[:2]:
            knowledge_txt += f.read_text()[:300] + "\n"

    skills_dir = DIR / "skills"
    skills_list = [d.name for d in skills_dir.iterdir() if d.is_dir()] if skills_dir.exists() else []

    print(f"\n{C_BOLD}{C_AI}\uD83C\uDF0C AETHER-AI OPERATOR {C_RST}{C_DIM}// V 19.0 (STABLE){C_RST}")
    print(f"  Engine: llama-server | Model: {model_name}")
    print(f"  Type 'exit' or 'tools' | ^C to save & quit\n")

    system_prompt = build_system_prompt(knowledge_txt, ", ".join(skills_list))

    while True:
        try:
            user_input = input(f"{C_BOLD}{C_USR}You:{C_RST} ").strip()
            if not user_input: continue
            if user_input.lower() in ["exit", "quit"]: break
            
            if user_input.lower() == "tools":
                manifest = load_manifest()
                print(f"  {C_TOOL}\u2713 learn(file|data){C_RST} Store insights")
                for t in manifest["tools"]:
                    print(f"  {C_TOOL}\u2713 {t['name']:15s}{C_RST} {t['description']}")
                continue

            # Construct Prompt with History
            full_prompt = f"System: {system_prompt}\n"
            for msg in history[-8:]:
                role = "User" if msg["role"] == "user" else "AI"
                full_prompt += f"{role}: {msg['content']}\n"
            full_prompt += f"User: {user_input}\nAI: "

            print(f"{C_BOLD}{C_AI}AI:{C_RST} ", end="", flush=True)
            response = generate_completion(full_prompt)
            print()

            # Tool Handling
            tool_match = re.search(r"<tool>(\w+)\(.*\)</tool>", response)
            if tool_match:
                name, args = tool_match.groups()
                output = run_tool(name, args)
                print(f"{C_DIM}[Result: {output[:80]}...]{C_RST}")
                
                tool_prompt = full_prompt + response + f"\nUser: [TOOL_RESULT] {output}\nAI: "
                print(f"{C_BOLD}{C_AI}AI (Analysis):{C_RST} ", end="", flush=True)
                follow_up = generate_completion(tool_prompt)
                print()
                response += f"\n[Tool Result: {output}]\n{follow_up}"

            history.append({"role": "user", "content": user_input})
            history.append({"role": "assistant", "content": response})

        except KeyboardInterrupt:
            break
        except Exception as e:
            print(f"\n{C_ERR}[Critical Error: {e}]{C_RST}")
            if not is_server_running(): start_server(model_path)

    print(f"\n{C_DIM}Shutting down neural engine...{C_RST}")
    kill_server()

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", default="hermes-3-8b.gguf")
    args = parser.parse_args()
    chat_loop(args.model)
