# Aether usage guide

Instructions for setup, first launch, and advanced features.

---

## Beginner guide

### Requirements

- Android phone from the last 5 years
- Termux from [F-Droid](https://f-droid.org/en/packages/com.termux/)
- 3-5GB free storage
- 4GB+ RAM

### Installation

```bash
git clone https://github.com/earnerbaymalay/aether.git
cd aether
./install.sh
```

The installer updates packages, compiles llama.cpp, and creates your workspace. Setup takes 10-15 minutes.

### First launch

Run:
```
ai
```

Select Turbo for your first chat. It is the fastest tier. Aether will download the model if it is missing.

Type anything:
```
You: Explain list comprehensions in Python simply.
```

Type `exit` or use Ctrl+C to leave.

---

## Intermediate guide

### AI tiers

| Tier | Model | Best for |
|------|-------|----------|
| Turbo | Llama-3.2-3B | Quick questions and summaries |
| Agent | Hermes-3-8B | Reasoning, code, and tools |
| Code | Qwen-Coder-3B | Programming and review |
| Logic | DeepSeek-R1 | Architecture and deep thinking |

### Toolbox

Select TOOLS from the main menu to run benchmarks, audit your knowledge, or open the debug console.

The Agent tier runs tools automatically. Ask it to check battery status or search the web.

Available tools: get_date, get_battery, list_files, gh_status, obsidian_notes, web_search, learn (saves memory).

### Persistent memory (AetherVault)

Knowledge is stored as Markdown in `knowledge/aethervault/`. The AI reads these files during every session.

Tell the Agent to learn something:
```
You: Learn this: python_tips | Use list comprehensions for speed.
```

### Obsidian integration

1. Install Obsidian on Android.
2. Open a new vault pointing to `~/aether/knowledge/aethervault/`.
3. Your AI's memory appears as editable notes.

---

## Advanced guide

### Agent core

The Agent runs on a llama-server on port 8080. When it outputs `<tool>name(args)</tool>`, the Python agent executes the script and feeds the result back.

To add a custom tool, place a shell script in `toolbox/` and update `toolbox/manifest.json`.

### Skills

Skills are drop-in modules. Place a `SKILL.md` file in `skills/your-skill-name/` to add new behaviors.

### Swarm orchestrator

Run:
```bash
./scripts/swarm_orchestrator.sh
```

This chains models together: Logic plans, Agent executes, Code reviews.

### Background sentinel

Run:
```bash
./scripts/launch_sentinel.sh
```

Monitors system health and security.
