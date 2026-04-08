# 🌌 A E T H E R — U S A G E
### *The Complete User Guide — From Zero to Neural Power User*

> **No matter your experience level, this guide will get you running.** We've organized it in three tracks so you can skip to what matters to you.

---

## 📑 Table of Contents

### 🟢 Beginner Track (Just want AI on my phone)
1. [What You'll Need](#-1-what-youll-need)
2. [Installing Aether (One Command)](#-2-installing-aether)
3. [Your First Conversation](#-3-your-first-conversation)
4. [Asking Questions & Getting Answers](#-4-asking-questions--getting-answers)

### 🟡 Intermediate Track (I want to customize & explore)
5. [Understanding the Four AI Tiers](#-5-understanding-the-four-ai-tiers)
6. [Using the Toolbox](#-6-using-the-toolbox)
7. [Teaching Aether — The AetherVault Vault](#-7-teaching-aether--the-aethervault-vault)
8. [Connecting to Obsidian](#-8-connecting-to-obsidian)
9. [Running the Benchmark](#-9-running-the-benchmark)

### 🔴 Advanced Track (I want full control)
10. [The Agent Core — Tool-Use & Automation](#-10-the-agent-core--tool-use--automation)
11. [Skill Marketplace — Building Plugins](#-11-skill-marketplace--building-plugins)
12. [Swarm Orchestrator](#-12-swarm-orchestrator)
13. [Debug Console & Self-Healing](#-13-debug-console--self-healing)
14. [Background Sentinel](#-14-background-sentinel)
15. [Manual Configuration](#-15-manual-configuration)

### 📎 Appendix
- [Troubleshooting](#-troubleshooting)
- [Frequently Asked Questions](#-frequently-asked-questions)
- [File Reference](#-file-reference)

---

## 🟢 BEGINNER TRACK

### 🔧 1. What You'll Need

Before we start, here's your checklist:

- [ ] **Android phone** (any phone from the last 5+ years works)
- [ ] **Termux installed** → Get it from [F-Droid](https://f-droid.org/en/packages/com.termux/) (**not** the Play Store — that version is outdated)
- [ ] **~3-5 GB free storage** (the AI models take up space)
- [ ] **At least 4 GB RAM** on your device
- [ ] **Wifi connection** (for the initial setup only — after that, Aether works offline)

> **No root. No special permissions. No Google account needed.**

---

### 🚀 2. Installing Aether

Open Termux and type (or copy-paste) these commands:

```bash
# Step 1: Get the code
git clone https://github.com/earnerbaymalay/aether.git
cd aether

# Step 2: Run the guided installer
./install.sh
```

**That's the only command you need to remember.** The installer will:

1. 📦 **Install dependencies** — It updates Termux packages and installs everything needed
2. 🔨 **Build the AI engine** — Compiles `llama.cpp` (the high-performance C++ engine that runs AI models)
3. 🏗️ **Create your workspace** — Sets up folders for models, knowledge, skills, and sessions
4. ⌨️ **Create the `ai` shortcut** — So you can type `ai` from anywhere to launch

The installer will ask:
- *"Ready to begin deployment?"* → Confirm to start
- *"Would you like to run a hardware benchmark now?"* → Optional, but recommended

> ⏱️ **First install takes ~10-15 minutes** depending on your internet speed. Subsequent installs are instant.

---

### 💬 3. Your First Conversation

After installation completes, simply type:

```
ai
```

You'll see a beautiful boot sequence, then the main menu:

```
   AETHER
   NEURAL OPERATING INTERFACE // V 18.0
   🔋 BATT: 78%  •  💾 STR: 42G  •  🧠 VAULT: ACTIVE

      [ SELECT NEURAL PATHWAY ]
   🤖 AGENT   (Hermes-8B)
   ⚡ TURBO   (Llama-3B)
   🧠 LOGIC   (DeepSeek)
   💻 CODE    (Qwen-3B)
   🛡️ SECURITY (Sentinel Hub)
   🛠 TOOLS   (Skills & Maintenance)
   ❌ EXIT
```

**For your first chat, select `⚡ TURBO`** — it's the fastest and works great for general questions.

If the model hasn't been downloaded yet, Aether will offer to download it (~2 GB). Confirm and wait for the download.

Once loaded, you'll see a chat prompt:

```
You: 
```

Type anything and press Enter. Try:

```
You: What is quantum computing? Explain it simply.
```

The AI will respond right in the terminal. It feels like chatting with a very knowledgeable person — except they never sleep, never run out of patience, and never send your data to a server.

To exit, type `exit` or press `Ctrl+C`.

---

### 🤔 4. Asking Questions & Getting Answers

**Tips for great results:**

- **Be specific.** Instead of "tell me about Python," try "explain Python list comprehensions with examples"
- **Ask for formats.** "Give me a table comparing..." or "Show me code that..."
- **Follow up.** Aether remembers the current conversation context
- **Try creative tasks.** "Write a haiku about android" or "Explain gravity like I'm five"

**Example conversations:**

| You type | What happens |
|---|---|
| `What's 15% of 247?` | Instant math answer |
| `Summarize the plot of Dune in 3 sentences` | Concise summary |
| `Write a Python function to sort a list` | Working code |
| `Translate "hello world" to Japanese` | こんにちは世界 |
| `What's the capital of France?` | Paris (yes, really) |

> **Pro tip:** If the answer isn't quite right, rephrase your question or ask it to try again with a different approach.

---

## 🟡 INTERMEDIATE TRACK

### 🧠 5. Understanding the Four AI Tiers

Aether's superpower is using **different AI models for different tasks**. Here's when to use each:

#### ⚡ TURBO (Llama-3.2-3B) — *Your Daily Driver*
- **Speed:** 25+ tokens/second (blazing fast)
- **Use for:** General Q&A, summaries, translations, creative writing
- **Think of it as:** A very smart, very fast assistant

#### 🤖 AGENT (Hermes-3-8B) — *The Problem Solver*
- **Speed:** 10-15 tokens/second
- **Use for:** Complex reasoning, code writing with tool use, multi-step tasks
- **Think of it as:** Your senior engineer who can actually run commands
- **Special:** This is the only tier that can use **tools** (read files, search the web, etc.)

#### 💻 CODE (Qwen-Coder-3B) — *The Programming Expert*
- **Speed:** 18+ tokens/second
- **Use for:** Code review, debugging, refactoring, writing functions
- **Think of it as:** A coding specialist who only does code

#### 🧠 LOGIC (DeepSeek-R1) — *The Deep Thinker*
- **Speed:** 22+ tokens/second
- **Use for:** Architecture design, system planning, complex reasoning
- **Think of it as:** Your architect who thinks three steps ahead

**Rule of thumb:** Start with TURBO for quick stuff. Switch to AGENT when you need tools or complex reasoning. Use CODE for programming. Use LOGIC for deep thinking.

---

### 🛠️ 6. Using the Toolbox

From the main menu, select `🛠 TOOLS` to access:

| Tool | What It Does |
|---|---|
| 🧹 **PURGE** | Clears the current session memory. Start fresh. |
| 📖 **LIBRARIAN** | Audits your AetherVault knowledge vault for duplicates and organization |
| 📏 **BENCHMARK** | Tests your phone's AI performance (tokens/sec) |
| 🛒 **SKILL MARKET** | Browse and install community-made AI skills |
| 🐞 **DEBUG CONSOLE** | View logs and run self-healing diagnostics |
| 🔙 **BACK** | Return to main menu |

**But the real toolbox magic happens inside the AGENT.**

When you're chatting with the AGENT (Hermes-8B), it can automatically use tools. Just ask:

```
You: What files are in my current directory?
[AGENT automatically runs list_files tool]
AI: I found 5 files: ...

You: Check my battery status
[AGENT automatically runs get_battery tool]
AI: Your battery is at 78% and charging.

You: Search the web for "latest Python 3.13 features"
[AGENT runs web_search]
AI: Here are the top results: ...
```

**Available tools the AGENT can use:**

| Tool | Description |
|---|---|
| `get_date` | Returns the current date and time |
| `get_battery` | Reports battery level and charging status |
| `list_files` | Lists files in any directory |
| `gh_status` | Checks git and GitHub status |
| `obsidian_list_notes` | Lists all notes in your Obsidian vault |
| `obsidian_search_notes` | Searches your Obsidian vault |
| `obsidian_read_note` | Reads a specific Obsidian note |
| `web_search` | Searches DuckDuckGo (privacy-first) |
| `web_read` | Reads any webpage as text |
| `learn` | Saves new knowledge to the AetherVault vault |

---

### 📚 7. Teaching Aether — The AetherVault Vault

> **This is what makes Aether fundamentally different from ChatGPT or Claude.**

Every AI you've used before **forgets everything** when you close the chat. Aether doesn't. It has a persistent memory system called **AetherVault**.

#### How it works:

1. **Tell the AGENT to learn something:**
   ```
   You: Learn this: python_tips|Use list comprehensions for faster Python code. Example: [x*2 for x in range(10)]
   ```

2. **Aether saves it** as a Markdown file in `knowledge/aethervault/python_tips.md`

3. **Every future session** — the AI reads your AetherVault files before chatting. It *knows* what you've taught it.

#### Why this is powerful:

- 📖 **Build a personal knowledge base** — coding patterns, API docs, your project notes
- 🧠 **The AI gets smarter about YOUR work** — not generic training data, but your specific workflows
- 🔄 **Knowledge compounds** — each session builds on previous learnings
- 📝 **Everything is plain Markdown** — readable by any text editor, syncable with Obsidian

#### Manual vault management:

```bash
# View all learned knowledge
ls ~/aether/knowledge/aethervault/

# Read a specific file
cat ~/aether/knowledge/aethervault/python_tips.md

# Edit knowledge manually
nano ~/aether/knowledge/aethervault/python_tips.md
```

---

### 📓 8. Connecting to Obsidian

[Obsidian](https://obsidian.md/) is a powerful knowledge management app. Aether's AetherVault vault is designed to work with it seamlessly.

**Setup steps:**

1. Install Obsidian on Android from the Play Store
2. Open Obsidian → Create a new vault → Point it to `~/aether/knowledge/aethervault/`
3. Your AI's learned knowledge now appears as notes in Obsidian
4. Use Obsidian's graph view to **visualize your AI's brain growing**

**Why this is cool:**

- 🗺️ **See knowledge connections visually** — Obsidian's graph view shows how concepts link together
- ✏️ **Edit knowledge in both directions** — Add notes in Obsidian, the AI reads them. Tell the AI to learn, it shows up in Obsidian
- 📱 **Access your AI's knowledge anywhere** — Even without Termux running

---

### 📏 9. Running the Benchmark

Want to know how fast your phone runs AI? Run the benchmark:

```bash
# From inside Aether
ai → TOOLS → 📏 BENCHMARK

# Or directly
./bench.sh
```

This will:
1. Load a test model (Llama-3.2-3B)
2. Run a short inference test
3. Report your **tokens per second** speed

**Example output:**
```
=== BENCHMARK RESULTS ===
📱 Device:  Nokia XR20
⚙️ Chipset: sm6225
🧠 RAM:     3247 MB used / 5771 MB total
⚡ Speed:   12.4 Tokens/sec
📅 Date:    2026-04-07 14:32
```

**What the number means:** Higher is better. 10+ t/s feels responsive. 20+ t/s feels instant. If you're below 5 t/s, your device may struggle with larger models.

> The benchmark also saves results to `hardware_report.txt` so you can track performance over time.

---

## 🔴 ADVANCED TRACK

### 🤖 10. The Agent Core — Tool-Use & Automation

The AGENT (Hermes-8B) runs on a **persistent llama-server backend** that provides instant responses and real tool execution.

#### How the agent works internally:

1. **Server startup** — When you select AGENT, `aether_agent.py` starts `llama-server` on port 8080
2. **System prompt** — The AI receives a rich system prompt including AetherVault knowledge, available tools, and skills
3. **Tool detection** — When the AI outputs `<tool>name(args)</tool>`, the Python agent intercepts and executes it
4. **Result injection** — The tool output is fed back to the AI for analysis
5. **Conversation history** — Last 8 messages are kept in context for coherent multi-turn dialogue

#### Advanced tool usage examples:

```python
# The AGENT can chain tools in a single conversation:

You: Search the web for "Termux API setup guide", read the top result, and summarize it

# Behind the scenes:
# 1. <tool>web_search(Termux API setup guide)</tool>
# 2. <tool>web_read(https://wiki.termux.com/wiki/Termux:API)</tool>
# 3. AI summarizes the fetched content
```

#### Building custom tools:

Add a shell script to `toolbox/`, then register it in `toolbox/manifest.json`:

```json
{
  "tools": [
    {
      "name": "my_custom_tool",
      "description": "Does something amazing",
      "script": "my_tool.sh",
      "enabled": true
    }
  ]
}
```

The AGENT auto-discovers it on next launch.

---

### 🛒 11. Skill Marketplace — Building Plugins

Skills are **drop-in AI behavior modules**. They tell the AI how to handle specific types of tasks.

**Structure of a skill:**
```
skills/your-skill-name/
└── SKILL.md    ← Instructions for the AI
```

**Example SKILL.md:**
```markdown
# Code Reviewer Skill
When the user asks for a code review:
1. Check for security vulnerabilities first
2. Suggest performance improvements
3. Note style issues
4. Provide a corrected version
```

**Installing a skill:**
1. Place the folder in `skills/`
2. Restart Aether — the skill is auto-detected
3. The AI includes it in its system prompt

**Browse available skills:** `ai → TOOLS → 🛒 SKILL MARKET`

---

### 🧬 12. Swarm Orchestrator

> **What if one AI isn't enough?**

The Swarm Orchestrator lets you chain multiple AI models together for complex tasks:

```bash
./scripts/swarm_orchestrator.sh
```

**How it works:**
1. TURBO handles the initial query breakdown
2. LOGIC deep-thinks on the architecture
3. AGENT executes the plan using tools
4. CODE reviews the output

**Use cases:**
- Multi-file codebase refactoring
- System architecture design with implementation
- Complex research projects

---

### 🐞 13. Debug Console & Self-Healing

Aether can diagnose and fix itself:

```bash
./scripts/debug_console.sh
```

The debug console:
- 📊 Shows real-time system logs
- 🔍 Detects missing dependencies
- 🩹 Offers self-healing suggestions
- 📋 Reports component health

---

### 🛡️ 14. Background Sentinel

The Sentinel passively monitors your Termux environment:

```bash
./scripts/launch_sentinel.sh
```

It can:
- Scan for security misconfigurations
- Check for outdated packages
- Monitor resource usage
- Generate security reports

---

### ⚙️ 15. Manual Configuration

For those who want full control, here are the key variables:

**In `aether.sh`:**
```bash
THREADS=6          # CPU threads for inference (adjust for your device)
SESSION_DIR="$HOME/.aether/sessions"  # Where chat history is stored
```

**In `agent/aether_agent.py`:**
```python
SERVER_PORT = 8080     # llama-server API port
CONTEXT_LENGTH = 2048  # Max context window
```

**In `install.sh`:**
```bash
# llama.cpp build options
cmake .. -G Ninja -DGGML_OPENMP=OFF  # OpenMP disabled for Android stability
```

**Model files** are stored in `~/aether/models/` and are named by their tier:
- `llama-3.2-3b.gguf`
- `hermes-3-8b.gguf`
- `deepseek-r1-1.5b.gguf`
- `qwen-coder-3b.gguf`

---

## 📎 APPENDIX

### 🔧 Troubleshooting

| Problem | Solution |
|---|---|
| `"Missing dependencies"` | Run `./install.sh` again |
| `"Model Missing"` | Select the tier in the main menu and confirm the download |
| `"Engine failed to start"` | Check `~/.aether/sessions/llama_server.log` for errors |
| **AI is very slow** | Run `./bench.sh` — if below 5 t/s, try smaller models or free up RAM |
| **Out of memory** | Close other apps. Reduce `THREADS` in `aether.sh` to 4 |
| **llama.cpp build fails** | Run `pkg install build-essential cmake ninja` manually, then retry |
| **`ai` command not found** | Re-run `./install.sh` to recreate the shortcut |
| **Session context not persisting** | Check that `~/.aether/sessions/last_session.log` exists |
| **Agent server crashes** | Run the Debug Console from TOOLS menu |
| **Obsidian can't find vault** | Make sure the path is exactly `~/aether/knowledge/aethervault/` |

### ❓ Frequently Asked Questions

**Q: Is this really 100% offline?**
A: Yes. After the initial model download, everything runs on your device. No data ever leaves your phone unless you explicitly use the `web_search` or `web_read` tools.

**Q: How much does it cost?**
A: Nothing. No subscriptions, no API keys, no hidden fees. The models are open source and free.

**Q: Which phone do I need?**
A: Any Android phone with 4+ GB RAM from the last 5 years. Aether is optimized for ARM64 (Snapdragon, MediaTek, etc.).

**Q: Can I use this on iOS?**
A: Not directly. Aether is built for Termux on Android. However, the concepts could be adapted for iOS shortcuts + local ML frameworks in the future.

**Q: Are the AI models censored?**
A: No. These are raw, unfiltered models. You get the full, uncensored experience.

**Q: Can I update the models?**
A: Yes. Delete the model file from `~/aether/models/` and Aether will download the latest version when you next select that tier.

**Q: How do I update Aether itself?**
A: Run `git pull` in the `~/aether` directory, then re-run `./install.sh` if new dependencies were added.

**Q: Can I use this for commercial work?**
A: Yes. The code is MIT licensed. The models have their own licenses (check each model's HuggingFace page).

**Q: What happens to my AetherVault knowledge if I reinstall?**
A: It's stored in `knowledge/aethervault/` which is part of the git repo. If you back up the folder, your AI's memory is preserved.

**Q: Can I run multiple instances?**
A: The AGENT tier uses a single server on port 8080. Running two simultaneously would cause conflicts. Use one at a time.

### 📂 File Reference

| File | Purpose |
|---|---|
| `aether.sh` | Main TUI and model orchestrator |
| `install.sh` | Guided one-command installer |
| `bench.sh` | Hardware benchmark tool |
| `agent/aether_agent.py` | Python agent with server & tool execution |
| `toolbox/manifest.json` | Tool registry (auto-discovered by AGENT) |
| `toolbox/*.sh` | Individual tool scripts |
| `scripts/librarian.py` | Knowledge vault auditor |
| `scripts/skill_market.sh` | Skill marketplace UI |
| `scripts/debug_console.sh` | Diagnostics and self-healing |
| `scripts/launch_sentinel.sh` | Security scanner |
| `knowledge/bio.txt` | User profile and preferences |
| `knowledge/aethervault/` | Persistent AI memory (Markdown) |
| `skills/*/SKILL.md` | AI behavior modules |
| `hardware_report.txt` | Benchmark history |
| `~/.aether/sessions/` | Chat session logs |
| `~/aether/models/` | Downloaded AI model files (.gguf) |

---

<div align="center">

### 🌌 *The journey has begun. Welcome to the Neural Operating Interface.*

**Need help?** Check the [README](README.md) or [open an issue](https://github.com/earnerbaymalay/aether/issues).

</div>
