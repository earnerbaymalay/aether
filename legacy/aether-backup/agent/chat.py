#!/usr/bin/env python3
"""AetherAI Agent - Local-first AI assistant with tool execution, streaming, and session persistence"""

import os, sys, json, re, time, signal, subprocess
from pathlib import Path
from datetime import datetime

ROOT = Path(__file__).resolve().parent.parent
SESSION_DIR = Path.home() / ".aether" / "sessions"
SESSION_FILE = SESSION_DIR / "last_session.log"
MODEL = os.environ.get("AETHER_MODEL", "qwen2.5-coder:1.5b")
OLLAMA_URL = "http://localhost:11434"
MAX_HISTORY = 20
TOOL_CALL_RE = re.compile(r'<tool>(\w+)(?:\(([^)]*)\))?</tool>')
TOOL_RESULT_PREFIX = "[TOOL_RESULT]"

# Colors
C_USER = "\033[38;5;153m"
C_AI = "\033[38;5;39m"
C_TOOL = "\033[38;5;82m"
C_ERR = "\033[38;5;196m"
C_DIM = "\033[2m"
C_BOLD = "\033[1m"
C_RST = "\033[0m"


def load_tools():
    manifest = ROOT / "toolbox" / "manifest.json"
    if not manifest.exists():
        return []
    with open(manifest) as f:
        return json.load(f).get("tools", [])


def run_tool(name, args=""):
    tools = load_tools()
    tool = next((t for t in tools if t["name"] == name), None)
    if not tool:
        return f"Error: Tool '{name}' not found"
    if not tool.get("enabled", True):
        return f"Error: Tool '{name}' is disabled"
    script = ROOT / "toolbox" / tool["script"]
    if not script.exists():
        return f"Error: Script '{tool['script']}' not found"
    try:
        cmd = ["bash", str(script)]
        if args:
            cmd.append(args)
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=15)
        if result.returncode != 0:
            return f"Tool error: {result.stderr.strip()}"
        return result.stdout.strip()
    except subprocess.TimeoutExpired:
        return f"Error: Tool '{name}' timed out (15s limit)"
    except Exception as e:
        return f"Error: {str(e)}"


def build_system_prompt():
    tools = load_tools()
    tool_list = "\n".join([
        f"- **{t['name']}**: {t['description']}" for t in tools if t.get("enabled", True)
    ])
    return f"""You are AetherAI, a local-first AI assistant running on Termux Android.

## Rules
- Be concise and direct. No filler.
- Use tools when helpful. Format: <tool>name(args)</tool>
- Only use ONE tool per response unless chaining is needed.
- After a tool runs, continue naturally with results.
- If the user asks something that needs a tool, USE IT before answering.
- You are running locally. No cloud. No tracking.

## Available Tools
{tool_list}

## Tool Examples
- Get date: <tool>get_date()</tool>
- List files: <tool>list_files(/data/data/com.termux/files/home)</tool>
- Check battery: <tool>get_battery()</tool>

Current date: {datetime.now().strftime('%Y-%m-%d %H:%M')}"""


def save_session(history):
    SESSION_DIR.mkdir(parents=True, exist_ok=True)
    with open(SESSION_FILE, "w") as f:
        json.dump(history, f, indent=2)


def load_session():
    if SESSION_FILE.exists():
        try:
            with open(SESSION_FILE) as f:
                return json.load(f)
        except (json.JSONDecodeError, IOError):
            pass
    return None


def chat_stream(messages):
    """Stream response from Ollama, yield tokens as they arrive"""
    try:
        r = requests.post(
            f"{OLLAMA_URL}/api/chat",
            json={"model": MODEL, "messages": messages, "stream": True},
            stream=True, timeout=120
        )
        r.raise_for_status()
        full = ""
        for line in r.iter_lines():
            if not line:
                continue
            try:
                chunk = json.loads(line)
                token = chunk.get("message", {}).get("content", "")
                if token:
                    full += token
                    yield token, chunk.get("done", False)
            except json.JSONDecodeError:
                continue
        return full
    except requests.ConnectionError:
        return None
    except requests.Timeout:
        return None


def process_tools_in_response(text):
    """Find and execute tool calls in AI response text"""
    matches = TOOL_CALL_RE.findall(text)
    results = []
    for name, args in matches:
        args = args or ""
        print(f"\n{C_DIM}[Running: {name}({args})]{C_RST}")
        output = run_tool(name, args)
        results.append((name, args, output))
    return results


def chat():
    print(f"\n{C_BOLD}{C_AI}  AetherAI Agent (Local){C_RST}")
    print(f"{C_DIM}  Model: {MODEL} | Tools: {len(load_tools())} loaded{C_RST}")
    print(f"  Type 'exit' to quit, 'tools' to list, 'clear' to reset context\n")

    # Load previous session
    history = load_session()
    if history:
        print(f"{C_DIM}[Restored previous session - {len(history)} messages]{C_RST}")
        # Keep system prompt + last N messages
        if len(history) > MAX_HISTORY:
            history = [history[0]] + history[-(MAX_HISTORY-1):]
    else:
        history = [{"role": "system", "content": build_system_prompt()}]

    # Handle graceful exit
    def handle_exit(sig, frame):
        print(f"\n{C_DIM}Saving session...{C_RST}")
        save_session(history)
        sys.exit(0)
    signal.signal(signal.SIGINT, handle_exit)
    signal.signal(signal.SIGTERM, handle_exit)

    while True:
        try:
            user = input(f"\n{C_BOLD}{C_USER}You:{C_RST} ").strip()
            if not user:
                continue
            if user.lower() in ("exit", "quit"):
                break
            if user.lower() == "tools":
                tools = load_tools()
                for t in tools:
                    status = "\u2705" if t.get("enabled", True) else "\u274c"
                    print(f"  {status} {t['name']:15s} - {t['description']}")
                continue
            if user.lower() == "clear":
                history = [{"role": "system", "content": build_system_prompt()}]
                print(f"{C_DIM}[Context cleared]{C_RST}")
                continue

            # Ensure system prompt is current
            if history[0]["role"] == "system":
                history[0]["content"] = build_system_prompt()

            history.append({"role": "user", "content": user})

            # Stream response
            print(f"\n{C_BOLD}{C_AI}AI:{C_RST} ", end="", flush=True)
            full_response = ""

            stream_result = chat_stream(history)
            if stream_result is None:
                print(f"\n{C_ERR}[Error: Cannot reach Ollama. Run 'ollama serve']{C_RST}")
                history.pop()
                continue

            for token, done in stream_result:
                print(token, end="", flush=True)
                full_response += token

            print()  # newline after response

            # Check for tool calls
            tool_results = process_tools_in_response(full_response)
            if tool_results:
                # Append AI response with tool calls
                history.append({"role": "assistant", "content": full_response})

                # Run each tool and feed result back
                for name, args, output in tool_results:
                    tool_msg = f"{TOOL_RESULT_PREFIX} {name}({args}) returned:\n{output}"
                    history.append({"role": "user", "content": tool_msg})
                    print(f"{C_DIM}[Tool output: {output[:200]}{'...' if len(output) > 200 else ''}]{C_RST}")

                # Get follow-up response after tool execution
                print(f"\n{C_BOLD}{C_AI}AI:{C_RST} ", end="", flush=True)
                follow_up = ""
                stream_result2 = chat_stream(history)
                if stream_result2:
                    for token, done in stream_result2:
                        print(token, end="", flush=True)
                        follow_up += token
                    print()
                    history.append({"role": "assistant", "content": follow_up})
            else:
                history.append({"role": "assistant", "content": full_response})

            # Trim history to prevent context overflow
            if len(history) > MAX_HISTORY:
                history = [history[0]] + history[-(MAX_HISTORY-1):]

            # Save session
            save_session(history)

        except EOFError:
            break
        except KeyboardInterrupt:
            print(f"\n{C_DIM}Saving session...{C_RST}")
            save_session(history)
            sys.exit(0)
        except Exception as e:
            print(f"\n{C_ERR}[Error: {e}]{C_RST}")

    print(f"\n{C_DIM}Saving session and exiting...{C_RST}")
    save_session(history)


if __name__ == "__main__":
    chat()
