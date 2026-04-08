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
CONTEXT7_DIR = KNOWLEDGE_DIR / "aethervault"  # Legacy path (AetherVault)
SESSION_DIR = Path.home() / ".aether" / "sessions"
SERVER_LOG = SESSION_DIR / "llama_server.log"
LLAMA_SERVER_BIN = Path.home() / "llama.cpp" / "build" / "bin" / "llama-server"
API_URL = "http://127.0.0.1:8080/completion"

# Add knowledge loader to path
sys.path.insert(0, str(KNOWLEDGE_DIR))
try:
    from knowledge_loader import AetherVault
    HAS_VAULT_LOADER = True
except ImportError:
    HAS_VAULT_LOADER = False

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
            
            # Try AetherVault smart storage first
            if HAS_VAULT_LOADER:
                try:
                    vault = AetherVault()
                    # Infer category from filename
                    safe_name = filename.strip().replace(" ", "_").lower()
                    path = vault.add_entry(safe_name, content.strip(), category="memory")
                    return f"Successfully learned: {safe_name} in AetherVault ({path})."
                except:
                    pass
            
            # Fallback: legacy direct storage
            filepath = CONTEXT7_DIR / "memories" / f"{filename.strip()}.md"
            filepath.parent.mkdir(parents=True, exist_ok=True)
            filepath.write_text(content.strip())
            subprocess.run(["git", "-C", str(CONTEXT7_DIR), "add", "."], capture_output=True)
            subprocess.run(["git", "-C", str(CONTEXT7_DIR), "commit", "-m", f"vault: learned {filename}"], capture_output=True)
            return f"Successfully learned: {filename} in AetherVault."
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
def load_skill_content(skill_name):
    """Load full SKILL.md content instead of just the name."""
    skill_path = DIR / "skills" / skill_name / "SKILL.md"
    if skill_path.exists():
        try:
            return skill_path.read_text()[:2000]  # Cap at 2000 chars per skill
        except:
            return f"[Skill: {skill_name} - content unreadable]"
    return f"[Skill: {skill_name} - not found]"

def _legacy_knowledge_load():
    """Fallback: legacy naive Context7 loading for backward compatibility."""
    c7_knowledge = ""
    if CONTEXT7_DIR.exists():
        for p in list(CONTEXT7_DIR.glob("**/*.md"))[:8]:
            try:
                c7_knowledge += f"### {p.name}\n{p.read_text()[:500]}\n\n"
            except:
                continue
    return c7_knowledge

def build_system_prompt(knowledge="", skills="", query=""):
    manifest = load_manifest()
    tool_list = "\n".join([f"- **{t['name']}**: {t['description']}" for t in manifest["tools"]])

    # Load actual SKILL.md content, not just names
    skills_dir = DIR / "skills"
    skill_content = ""
    if skills_dir.exists():
        for skill_dir in skills_dir.iterdir():
            if skill_dir.is_dir():
                content = load_skill_content(skill_dir.name)
                skill_content += f"\n## Skill: {skill_dir.name}\n{content}\n"

    # AETHERVAULT: Smart knowledge loading with relevance scoring
    vault_knowledge = ""
    if HAS_VAULT_LOADER:
        try:
            vault = AetherVault()
            # Calculate budget based on model context size
            settings_file = DIR / "settings" / "config.json"
            ctx_size = 2048  # default
            if settings_file.exists():
                try:
                    cfg = json.loads(settings_file.read_text())
                    ctx_size = cfg.get('model', {}).get('context_size', 2048)
                except:
                    pass
            
            # Allocate ~40% of context window for knowledge
            budget = int(ctx_size * 4 * 0.4)  # 4 chars per token * 40%
            budget = min(budget, 8000)  # Cap at 8000 chars
            
            vault_knowledge = vault.load_for_query(query or "", budget)
        except Exception as e:
            # Fallback to legacy loading if smart loader fails
            vault_knowledge = _legacy_knowledge_load()
    else:
        # Fallback: legacy naive loading
        vault_knowledge = _legacy_knowledge_load()

    # Load settings if available
    settings_info = ""
    settings_file = DIR / "settings" / "config.json"
    if settings_file.exists():
        try:
            cfg = json.loads(settings_file.read_text())
            settings_info = f"## Configuration\nProfile: {cfg.get('profile', 'balanced')}\n"
            model_cfg = cfg.get('model', {})
            settings_info += f"Context: {model_cfg.get('context_size', 2048)} tokens, "
            settings_info += f"Temperature: {model_cfg.get('temperature', 0.7)}, "
            settings_info += f"Threads: {model_cfg.get('threads', 4)}\n\n"
        except:
            pass

    # Load active memory slot if present
    memory_slot_info = ""
    memory_file = Path.home() / ".aether" / "sessions" / "loaded_memory.txt"
    if memory_file.exists():
        try:
            memory_content = memory_file.read_text()[:2000]
            memory_slot_info = f"## Active Memory Slot\n{memory_content}\n\n"
        except:
            pass

    return f"""You are AetherAI, a local-first neural interface running on Android.
Your phone. Your AI. Your rules. No cloud. No tracking. No limits.
Current Date: {datetime.now().strftime('%A, %d %B %Y')}

{settings_info}
## AetherVault Knowledge
{vault_knowledge}

## Skills (Full Instructions)
{skill_content}

{memory_slot_info}
## Tool Protocol
Execute tools via: <tool>name(args)</tool>
Special: <tool>learn(filename|content)</tool> — Save to AetherVault

Available tools:
{tool_list}

Rules:
1. Be technical and concise. No conversational filler, no AI-isms.
2. Use tools immediately if they help answer the query.
3. Read and follow skill instructions from the Skills section above.
4. If you discover something valuable, use <tool>learn()</tool> to save it to AetherVault.
5. NEVER mention being an AI, language model, or assistant.
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
