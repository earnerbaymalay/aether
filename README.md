# 🤖 Termux AI Workspace

[![Stars](https://img.shields.io/github/stars/earnerbaymalay/termux-ai-workspace?style=flat-square)](https://github.com/earnerbaymalay/termux-ai-workspace/stargazers)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://github.com/earnerbaymalay/termux-ai-workspace/blob/main/LICENSE)
[![Last Commit](https://img.shields.io/github/last-commit/earnerbaymalay/termux-ai-workspace?style=flat-square)](https://github.com/earnerbaymalay/termux-ai-workspace/commits/main)
[![Issues](https://img.shields.io/github/issues/earnerbaymalay/termux-ai-workspace?style=flat-square)](https://github.com/earnerbaymalay/termux-ai-workspace/issues)
[![Platform](https://img.shields.io/badge/platform-Android%20(Termux)-green?style=flat-square)](https://termux.dev)
[![No Root Required](https://img.shields.io/badge/root-not%20required-brightgreen?style=flat-square)](#requirements)

A **local-first AI development environment** running entirely on Android via Termux — no root required. Built around Ollama + qwen3.5, with 16+ automation scripts, 11 homescreen widgets, 25+ HTTP shortcut presets, Syncthing sync, and a multi-model Kimi agent swarm.

> Developed and maintained on a **Pixel 8 Pro** (unrooted, Android 14+). Tested with Termux from F-Droid.

---

## 📖 Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Quick Start](#quick-start)
- [Installation Guide](#installation-guide)
- [Project Structure](#project-structure)
- [Usage](#usage)
  - [Core Scripts](#core-scripts)
  - [Widget Scripts](#widget-scripts)
  - [HTTP Shortcuts](#http-shortcuts)
  - [Kimi Swarm](#kimi-swarm)
  - [Syncthing + Obsidian](#syncthing--obsidian)
- [API Key Setup](#api-key-setup)
- [Models & Storage](#models--storage)
- [Known Limitations](#known-limitations)
- [Contributing](#contributing)
- [Roadmap](#roadmap)
- [License](#license)

---

## ✨ Features

| Feature | Details |
|---|---|
| **Local AI (Ollama)** | Run `qwen3.5` fully offline on-device via TUR repo |
| **Multi-model routing** | Fallback chain: `qwen3.5 → glm-4.7-flash → kimi-k2.5` |
| **Kimi Agent Swarm** | Multi-agent orchestration via `kimi_swarm.py` |
| **16+ Scripts** | Checkpoint, qwen-chat, ai-helper, ai-context, auto-log, and more |
| **11 Homescreen Widgets** | Quick-access Termux:Widget scripts on the Android home screen |
| **25+ HTTP Shortcuts** | Pre-configured API calls for AI services via HTTP Shortcuts app |
| **Syncthing + Obsidian** | Seamless file sync between phone and PC with Obsidian note integration |
| **Checkpoint System** | Full backup/restore of your Termux environment |
| **NetGuard** | Per-app firewall to control which AI tools can phone home |
| **Fish + Zsh shell** | Oh-my-zsh with Powerlevel10k, lolcat+neofetch on startup |
| **RF/SDR Tools** | Sub-GHz and SDR support for Flipper Zero workflows |
| **No Root Required** | Everything runs in userland via Termux (F-Droid build) |

---

## 📋 Requirements

### Device
- Android 9+ (tested on Android 14 / Pixel 8 Pro)
- **Minimum 6 GB RAM** recommended (Ollama needs ~2–4 GB free for qwen3.5)
- **~10 GB free storage** (Ollama models + Termux packages)
- Battery optimisation **disabled** for Termux (Settings → Apps → Termux → Battery → Unrestricted)

### Apps (install from F-Droid or GitHub releases — NOT Google Play)
- [Termux](https://f-droid.org/en/packages/com.termux/) — core terminal
- [Termux:Widget](https://f-droid.org/en/packages/com.termux.widget/) — homescreen widgets
- [Termux:API](https://f-droid.org/en/packages/com.termux.api/) — Android API bridge
- [HTTP Shortcuts](https://f-droid.org/en/packages/ch.rmy.android.http_shortcuts/) — API shortcut launcher
- [Syncthing](https://f-droid.org/en/packages/com.nutomic.syncthingandroid/) — file sync
- [Obsidian](https://obsidian.md/) — note-taking linked to Syncthing vault

> ⚠️ **Do not install Termux from the Google Play Store.** Google Play builds are outdated and incompatible with TUR repo packages.

### API Keys (optional — local model works offline)
- `ANTHROPIC_API_KEY` — Claude fallback
- `MOONSHOT_API_KEY` — Kimi / glm-4.7-flash / kimi-k2.5
- `DEEPSEEK_API_KEY` — DeepSeek (via OpenRouter)
- `GROQ_API_KEY` — Groq fast inference fallback

---

## ⚡ Quick Start

One-liner for a fresh Termux session:

```bash
pkg install git -y && git clone https://github.com/earnerbaymalay/termux-ai-workspace.git && cd termux-ai-workspace && bash setup/termux-setup.sh
```

---

## 🛠 Installation Guide

### 1. Install Termux from F-Droid

Download from [https://f-droid.org](https://f-droid.org/en/packages/com.termux/) and grant storage permission:

```bash
termux-setup-storage
```

### 2. Clone this repository

```bash
git clone https://github.com/earnerbaymalay/termux-ai-workspace.git
cd termux-ai-workspace
```

### 3. Run the setup script

```bash
bash setup/termux-setup.sh
```

The script will:
- Update packages and add TUR + X11 repos
- Install Python, git, curl, fish, zsh + oh-my-zsh, Powerlevel10k
- Install Ollama via TUR repo and pull `qwen3.5`
- Copy scripts to `~/.local/bin/` and set permissions
- Copy widget scripts to `~/.shortcuts/`
- Install Python requirements from `setup/pip-requirements.txt`
- Set up F-Droid repos from `setup/fdroid-repos.txt`

### 4. Add your API keys

```bash
# Edit the env file (created by setup script)
nano ~/.config/ai-workspace/keys.env
```

See [API Key Setup](#api-key-setup) for the full list.

### 5. Set up Syncthing (optional)

```bash
# Start Syncthing
syncthing &

# Open the web UI
termux-open-url http://127.0.0.1:8384
```

Link your PC and set the Obsidian vault folder as a shared directory.

---

## 📁 Project Structure

```
termux-ai-workspace/
├── README.md
├── LICENSE
├── ROADMAP.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── kimi_swarm.py              # Kimi multi-agent swarm orchestrator (root-level for direct use)
├── .github/
│   └── workflows/             # CI/CD: auto-generate marketing materials, sync to GitHub
├── demos/
│   └── screenshots/           # Demo screenshots for README
├── docs/
│   ├── kimi-setup-termux.md   # Kimi API + Termux integration guide
│   ├── PROJECT-SUMMARY.md     # Project overview and architecture
│   ├── SUMMARY.md             # Build summary
│   └── COMPLETION-CHECKLIST.md
├── setup/
│   ├── termux-setup.sh        # Main installer script
│   ├── fdroid-repos.txt       # F-Droid repo fingerprints
│   ├── pip-requirements.txt   # Python dependencies
│   └── config/                # Shell configs, .bashrc/.zshrc templates
├── scripts/
│   ├── checkpoint             # Backup/restore Termux environment
│   ├── qwen-chat              # Interactive qwen3.5 chat session
│   ├── ai-helper.py           # Python AI helper (multi-model)
│   ├── ai-context             # Inject context into prompts
│   ├── auto-log               # Auto-logging for sessions
│   └── widget-scripts/        # Scripts exposed as homescreen widgets
│       ├── quick-chat
│       ├── ollama-status
│       └── sync-vault
└── templates/
    ├── obsidian/              # Obsidian vault template
    └── http-shortcuts/        # HTTP Shortcuts JSON import file
```

---

## 🚀 Usage

### Core Scripts

After installation, scripts are available globally:

```bash
# Create a full backup of your Termux environment
checkpoint

# Start an interactive qwen3.5 chat
qwen-chat

# Use the multi-model AI helper
ai-helper.py "explain this error: ..."

# Inject project context into a prompt
ai-context myproject "what does this function do?"

# Start auto-logging for a session
auto-log start
```

### Widget Scripts

Widget scripts live in `~/.shortcuts/` (symlinked from `scripts/widget-scripts/`).

To add a widget:
1. Install **Termux:Widget** from F-Droid
2. Long-press your Android homescreen → Widgets → Termux:Widget
3. Select a script

Available widgets:
- `quick-chat` — opens a Termux session with qwen-chat
- `ollama-status` — shows current Ollama model status in a toast
- `sync-vault` — triggers Syncthing sync of the Obsidian vault

### HTTP Shortcuts

Import the preset collection:

1. Open **HTTP Shortcuts** app
2. Menu → Import/Export → Import
3. Select `templates/http-shortcuts/collection.json`

Presets include shortcuts for: Anthropic Claude, Moonshot Kimi, DeepSeek, Groq, and local Ollama.

### Kimi Swarm

`kimi_swarm.py` is a multi-agent orchestrator using the Moonshot Kimi API. It spawns parallel sub-agents for research, code review, and long-horizon tasks.

```bash
# Basic usage
python kimi_swarm.py "research the latest advances in ARM64 AI inference"

# With a specific task file
python kimi_swarm.py --task tasks/my_task.txt

# Run from anywhere (after setup adds it to PATH)
kimi-swarm "summarise this repo and suggest improvements"
```

**Requirements:**
- `MOONSHOT_API_KEY` set in `~/.config/ai-workspace/keys.env`
- Python packages: `httpx`, `asyncio` (included in `pip-requirements.txt`)

See [`docs/kimi-setup-termux.md`](docs/kimi-setup-termux.md) for full Kimi API setup on Termux.

### Syncthing + Obsidian

```
Phone (Termux/Syncthing) ←→ PC (Syncthing) ←→ Obsidian vault (PC)
                                                       ↕
                                              Obsidian (Android)
```

1. Run `syncthing` in Termux (auto-starts via Termux:Boot if configured)
2. Share folder `~/obsidian-vault` with your PC
3. Open Obsidian on Android and point it at the shared folder via Syncthing

---

## 🔑 API Key Setup

```bash
nano ~/.config/ai-workspace/keys.env
```

```bash
# ~/.config/ai-workspace/keys.env
export ANTHROPIC_API_KEY="sk-ant-..."
export MOONSHOT_API_KEY="sk-..."          # Kimi / glm-4.7-flash / kimi-k2.5
export DEEPSEEK_API_KEY="sk-..."
export GROQ_API_KEY="gsk_..."

# Local Ollama (no key needed — runs on 127.0.0.1:11434)
export OLLAMA_HOST="http://127.0.0.1:11434"
```

Source this file in your shell config:

```bash
echo 'source ~/.config/ai-workspace/keys.env' >> ~/.zshrc
```

---

## 🗄 Models & Storage

| Model | Size on disk | RAM needed | Source |
|---|---|---|---|
| `qwen3.5` (default) | ~2.3 GB (Q4) | ~3 GB | Ollama via TUR |
| `glm-4.7-flash` | API only | — | Moonshot API |
| `kimi-k2.5` | API only | — | Moonshot API |

Pull the default model:

```bash
ollama pull qwen3.5
```

Check what's running:

```bash
ollama list
ollama ps
```

---

## ⚠️ Known Limitations

| Issue | Details |
|---|---|
| **No root** | All Termux work runs in userland. Some network tools require root — not available here. |
| **`SIGKILL` (signal 9)** | Android may kill background processes. Use Termux:Boot + `termux-wake-lock` for long tasks. |
| **Battery optimisation** | Must be disabled per-app or Termux sessions are terminated aggressively. |
| **ARM64 pip packages** | Some Python packages (`cryptography`, `grpcio`) have no ARM64 wheels — use pre-compiled versions from TUR or piwheels. |
| **Ollama memory pressure** | On devices with <8 GB RAM, qwen3.5 may be slow or OOM. Use `glm-4.7-flash` (API) as a fallback. |
| **No GPU acceleration** | Ollama runs on CPU only in Termux userland. Inference is slower than desktop. |
| **kimi_swarm.py** | Requires a valid `MOONSHOT_API_KEY`. Agent Swarm is a Kimi beta feature — availability may vary. |

---

## 🤝 Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for full guidelines.

Quick steps:

```bash
# Fork and clone
git clone https://github.com/YOUR_USERNAME/termux-ai-workspace.git
cd termux-ai-workspace

# Create a feature branch
git checkout -b feature/my-improvement

# Commit and push
git commit -m 'Add: my improvement'
git push origin feature/my-improvement

# Open a Pull Request on GitHub
```

Please test scripts on a real Termux session before submitting.

---

## 🗺 Roadmap

See [ROADMAP.md](ROADMAP.md) for the full planned feature list.

Highlights:
- [ ] Voice-to-prompt widget via `termux-microphone-record`
- [ ] Automated nightly Syncthing + git push via Termux:Boot
- [ ] Dolphin Agent TUI integration
- [ ] Gloam encrypted journal integration
- [ ] OpenClaw gateway auto-start on boot

---

## 📄 License

MIT © [earnerbaymalay](https://github.com/earnerbaymalay) — see [LICENSE](LICENSE) for details.
