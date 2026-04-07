#!/usr/bin/env python3
"""
🌌 Aether-AI Neural Agent Core // V 18.2
Enhanced Python-based agent with real-time tool execution,
Native C++ (llama.cpp) backend, and Context7 Knowledge Vault integration.
"""

import os, sys, json, re, subprocess, signal, time
from pathlib import Path
from datetime import datetime

# --- Constants & Configuration ---
DIR = Path.home() / "aether"
MODELS_DIR = DIR / "models"
TOOLBOX_DIR = DIR / "toolbox"
KNOWLEDGE_DIR = DIR / "knowledge"
CONTEXT7_DIR = KNOWLEDGE_DIR / "context7"
SESSION_DIR = Path.home() / ".aether" / "sessions"
LOG_FILE = SESSION_DIR / "last_session.log"
LLAMA_BIN = Path.home() / "llama.cpp" / "build" / "bin" / "llama-cli"

# Colors (ANSI)
C_AI = "\033[38;5;39m"
C_USR = "\033[38;5;153m"
C_TOOL = "\033[38;5;82m"
C_ERR = "\033[38;5;196m"
C_DIM = "\033[2m"
C_BOLD = "\033[1m"
C_RST = "\033[0m"

# --- Tool Engine ---
def load_manifest():
    manifest_path = TOOLBOX_DIR / "manifest.json"
    if not manifest_path.exists():
        return {"tools": []}
    with open(manifest_path) as f:
        return json.load(f)

def run_tool(name, args=""):
    # SPECIAL TOOL: Context7 Learning
    if name == "learn":
        try:
            if "|" not in args:
                return "Error: Format for learn is 'filename|content'"
            filename, content = args.split("|", 1)
            filepath = CONTEXT7_DIR / f"{filename.strip()}.md"
            filepath.parent.mkdir(parents=True, exist_ok=True)
            filepath.write_text(content.strip())
            # Auto-commit to side repo
            subprocess.run(["git", "-C", str(CONTEXT7_DIR), "add", "."], capture_output=True)
            subprocess.run(["git", "-C", str(CONTEXT7_DIR), "commit", "-m", f"AI Learned: {filename}"], capture_output=True)
            return f"Successfully learned: {filename} in Context7."
        except Exception as e:
            return f"Learning Error: {str(e)}. Format: learn(filename|content)"

    manifest = load_manifest()
    tool = next((t for t in manifest["tools"] if t["name"] == name), None)
    if not tool:
        return f"Error: Tool '{name}' not found."
    
    script_path = TOOLBOX_DIR / tool["script"]
    if not script_path.exists():
        return f"Error: Tool script '{tool['script']}' missing."

    print(f"\n{C_DIM}[Running: {name}({args})]{C_RST}")
    try:
        cmd = ["bash", str(script_path)]
        if args:
            cmd.append(args)
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=20)
        return result.stdout.strip() if result.returncode == 0 else f"Tool Error: {result.stderr.strip()}"
    except Exception as e:
        return f"Execution Error: {str(e)}"

# --- Inference Engine (llama-cli wrapper) ---
def build_prompt(user_input, history, knowledge="", skills=""):
    """Constructs the system prompt and conversation context"""
    manifest = load_manifest()
    tool_list = "\n".join([f"- **{t['name']}**: {t['description']}" for t in manifest["tools"]])
    
    # LOAD CONTEXT7 KNOWLEDGE
    c7_knowledge = ""
    if CONTEXT7_DIR.exists():
        for p in list(CONTEXT7_DIR.glob("**/*.md"))[:5]:
            try:
                c7_knowledge += f"### {p.name}\n{p.read_text()[:500]}\n\n"
            except: continue

    system_prompt = f"""You are AetherAI, a local-first neural interface running on Android.
Current Date: {datetime.now().strftime('%A, %d %B %Y')}

## Context7 (Deep Knowledge & Syntax)
{c7_knowledge}

## General Knowledge
{knowledge}

## Skills Available
{skills}

## Tool Execution Protocol
Execute local tools using: <tool>tool_name(arguments)</tool>
Special tool: <tool>learn(filename|content)</tool> - Store new technical insights.

Available tools:
{tool_list}

Rules:
1. Be technical and precise. Use tools immediately.
2. If you find a better way of doing things, use <tool>learn()</tool> to store it.
"""
    # Context compression: Last 10 exchanges
    recent_history = history[-10:] if history else []
    
    # We'll build the prompt string for llama-cli
    prompt = f"System: {system_prompt}\n"
    for msg in recent_history:
        role = "User" if msg["role"] == "user" else "AI"
        prompt += f"{role}: {msg['content']}\n"
    
    prompt += f"User: {user_input}\nAI: "
    return prompt

def generate_response(prompt, model_path):
    """Executes llama-cli and streams output back to Python"""
    if not model_path.exists():
        return f"Error: Model file {model_path.name} not found."

    cmd = [
        str(LLAMA_BIN),
        "-m", str(model_path),
        "-p", prompt,
        "-t", "6",
        "--mmap",
        "--quiet",
        "--log-disable",
        "-n", "512",
        "--temp", "0.7",
        "-c", "2048"
    ]

    try:
        process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, bufsize=1)
        full_response = ""
        
        # Simple token-by-token streaming
        for char in iter(lambda: process.stdout.read(1), ''):
            sys.stdout.write(char)
            sys.stdout.flush()
            full_response += char
            
        process.stdout.close()
        process.wait()
        return full_response.strip()
    except Exception as e:
        return f"Inference Error: {str(e)}"

# --- Main Logic ---
def chat_loop(model_name="hermes-3-8b.gguf"):
    model_path = MODELS_DIR / model_name
    history = []
    
    # Load knowledge
    knowledge_dir = DIR / "knowledge"
    knowledge_txt = ""
    if knowledge_dir.exists():
        for f in list(knowledge_dir.glob("*.txt"))[:3]:
            knowledge_txt += f.read_text()[:500] + "\n"

    # Load skills list
    skills_dir = DIR / "skills"
    skills_list = [d.name for d in skills_dir.iterdir() if d.is_dir()] if skills_dir.exists() else []

    print(f"\n{C_BOLD}{C_AI}\uD83C\uDF0C AETHER-AI OPERATOR {C_RST}{C_DIM}// V 18.2{C_RST}")
    print(f"  Model: {model_name} | Skills: {', '.join(skills_list)}")
    print(f"  Type 'exit' or 'tools' | ^C to save & quit\n")

    while True:
        try:
            user_input = input(f"{C_BOLD}{C_USR}You:{C_RST} ").strip()
            if not user_input: continue
            if user_input.lower() in ["exit", "quit"]:
                break
            
            if user_input.lower() == "tools":
                manifest = load_manifest()
                print(f"  {C_TOOL}\u2713 learn(file|data){C_RST} Store technical insights")
                for t in manifest["tools"]:
                    print(f"  {C_TOOL}\u2713 {t['name']:15s}{C_RST} {t['description']}")
                continue

            # 1. Build & Run Prompt
            prompt = build_prompt(user_input, history, knowledge_txt, ", ".join(skills_list))
            print(f"{C_BOLD}{C_AI}AI:{C_RST} ", end="", flush=True)
            response = generate_response(prompt, model_path)
            print() # End response line

            # 2. Parse Tools
            tool_match = re.search(r"<tool>(\w+)\(.*\)</tool>", response)
            if tool_match:
                name, args = tool_match.groups()
                output = run_tool(name, args)
                print(f"{C_DIM}[Tool Output: {output[:100]}...]{C_RST}")
                
                # Recursive call: Feed tool result back
                tool_prompt = f"User: [TOOL_RESULT] {name}({args}) returned: {output}\nAI: "
                print(f"{C_BOLD}{C_AI}AI (Analysis):{C_RST} ", end="", flush=True)
                follow_up = generate_response(prompt + response + "\n" + tool_prompt, model_path)
                print()
                response += f"\n[Tool Output: {output}]\n{follow_up}"

            # 3. Update History
            history.append({"role": "user", "content": user_input})
            history.append({"role": "assistant", "content": response})

        except KeyboardInterrupt:
            print(f"\n{C_DIM}Saving session and exiting...{C_RST}")
            break
        except EOFError:
            break

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", default="hermes-3-8b.gguf")
    args = parser.parse_args()
    chat_loop(args.model)
