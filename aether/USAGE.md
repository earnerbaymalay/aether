# Aether -- Usage Guide

From installation to advanced features. Three tracks: beginner, intermediate, advanced.

---

## Beginner Track

### What You Need

- Android phone from the last 5+ years
- Termux from [F-Droid](https://f-droid.org/en/packages/com.termux/) (not the Play Store version)
- 3-5GB free storage
- 4GB+ RAM
- Wifi for initial setup only

### Install

```bash
git clone https://github.com/earnerbaymalay/aether.git
cd aether
./install.sh
```

The installer updates packages, compiles llama.cpp, creates your workspace folders, and sets up the `ai` shortcut. First install takes 10-15 minutes.

### First Conversation

After installation:
```
ai
```

You will see the main menu. Select TURBO for your first chat -- it is the fastest tier. If the model has not been downloaded, Aether will offer to download it (~2GB).

Type anything:
```
You: What is quantum computing? Explain it simply.
```

Type `exit` or Ctrl+C to leave.

### Tips for Good Results

- Be specific. "Explain Python list comprehensions with examples" works better than "tell me about Python"
- Ask for formats. "Give me a table comparing..." or "Show me code that..."
- Follow up. Aether remembers the current conversation
- Try creative tasks. "Write a haiku about android" or "Explain gravity like I'm five"

---

## Intermediate Track

### The Four AI Tiers

| Tier | Model | Speed | Best for |
|------|-------|-------|----------|
| TURBO | Llama-3.2-3B | 25+ t/s | Quick questions, summaries, translations |
| AGENT | Hermes-3-8B | 10-15 t/s | Complex reasoning, code, tool use |
| CODE | Qwen-Coder-3B | 18+ t/s | Code review, debugging, refactoring |
| LOGIC | DeepSeek-R1 | 22+ t/s | Architecture design, system planning |

Start with TURBO for quick tasks. Switch to AGENT for tools or complex reasoning. Use CODE for programming. Use LOGIC for deep thinking.

### Using the Toolbox

From the main menu select TOOLS. You can purge sessions, run the librarian to audit your knowledge vault, run benchmarks, browse the skill market, or open the debug console.

The AGENT tier can also execute tools automatically. Ask it to check battery status, list files, or search the web, and it will run the appropriate script.

Available tools: get_date, get_battery, list_files, gh_status, obsidian_list_notes, obsidian_search_notes, obsidian_read_note, web_search, web_read, and learn (saves knowledge to AetherVault).

### Persistent Memory (AetherVault)

Every AI you have used forgets everything when you close the chat. Aether does not. Knowledge is stored as Markdown files in `knowledge/aethervault/`.

Tell the AGENT to learn something:
```
You: Learn this: python_tips|Use list comprehensions for faster Python code.
```

Aether saves it as a Markdown file. Every future session, the AI reads your AetherVault files before chatting.

You can also add files manually:
```bash
echo "# Python Tips" > ~/aether/knowledge/aethervault/python_tips.md
```

### Connecting to Obsidian

1. Install Obsidian on Android
2. Create a new vault pointing to `~/aether/knowledge/aethervault/`
3. Your AI's knowledge now appears as notes in Obsidian
4. Use Obsidian's graph view to see how concepts link together

You can edit knowledge in both directions. Add notes in Obsidian, the AI reads them. Tell the AI to learn, it shows up in Obsidian.

### Running the Benchmark

```bash
./bench.sh
```

Reports tokens per second. 10+ t/s feels responsive. 20+ t/s feels instant. Below 5 t/s and your device may struggle with larger models. Results are saved to `hardware_report.txt`.

---

## Advanced Track

### The Agent Core

The AGENT runs on a persistent llama-server backend. When you select AGENT, `aether_agent.py` starts `llama-server` on port 8080. The AI receives a system prompt with AetherVault knowledge, available tools, and skills. When the AI outputs `<tool>name(args)</tool>`, the Python agent intercepts and executes it. Tool output is fed back to the AI. The last 8 messages are kept in context.

To build a custom tool, add a shell script to `toolbox/` and register it in `toolbox/manifest.json`. The AGENT auto-discovers it on next launch.

### Skill Marketplace

Skills are drop-in behavior modules. Each skill is a single `SKILL.md` file in `skills/your-skill-name/`. The file contains instructions for the AI on how to handle specific tasks.

Place the folder in `skills/`, restart Aether, and the skill is auto-detected and included in the system prompt.

### Swarm Orchestrator

```bash
./scripts/swarm_orchestrator.sh
```

Chains multiple AI models together. TURBO handles query breakdown, LOGIC deep-thinks on architecture, AGENT executes the plan using tools, CODE reviews the output. Use cases include multi-file refactoring, system architecture design, and complex research.

### Debug Console

```bash
./scripts/debug_console.sh
```

Shows real-time system logs, detects missing dependencies, offers self-healing suggestions, reports component health.

### Background Sentinel

```bash
./scripts/launch_sentinel.sh
```

Passively monitors your Termux environment. Scans for security misconfigurations, checks for outdated packages, monitors resource usage, generates security reports.

### Manual Configuration

Key variables in `aether.sh`:
```bash
THREADS=6          # CPU threads for inference
SESSION_DIR="$HOME/.aether/sessions"  # Chat history storage
```

Model files are stored in `~/aether/models/`.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Missing dependencies | Run `./install.sh` again |
| Model missing | Select the tier in the main menu and confirm download |
| Engine failed to start | Check `~/.aether/sessions/llama_server.log` |
| AI is very slow | Run `./bench.sh` -- below 5 t/s, try smaller models or free RAM |
| Out of memory | Close other apps. Reduce THREADS to 4 |
| llama.cpp build fails | Run `pkg install build-essential cmake ninja` manually |
| `ai` command not found | Re-run `./install.sh` |
| Obsidian can't find vault | Path must be exactly `~/aether/knowledge/aethervault/` |

## FAQ

**Is this really offline?** After the initial model download, everything runs on-device. No data leaves your phone unless you explicitly use web_search or web_read.

**How much does it cost?** Nothing. Models are open source and free.

**Which phone do I need?** Any Android phone with 4+ GB RAM from the last 5 years.

**Are the models censored?** No. Raw, unfiltered models.

**How do I update Aether?** `git pull` in the `~/aether` directory, then re-run `./install.sh` if new dependencies were added.

**What happens to my knowledge if I reinstall?** It is stored in `knowledge/aethervault/`. Back up that folder and your AI's memory is preserved.

---

[MIT License](LICENSE)
