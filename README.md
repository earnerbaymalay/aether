<div align="center">

# 🌌 A E T H E R — A I

### *Your Phone. Your AI. Your Rules.*

[![Status](https://img.shields.io/badge/Status-Production_Ready-50fa7b?style=for-the-badge)]()
[![Engine](https://img.shields.io/badge/Engine-Llama.cpp_Native-81a1c1?style=for-the-badge&logo=c%2B%2B)]()
[![Platform](https://img.shields.io/badge/Platform-Android_%7C_Termux-4c566a?style=for-the-badge&logo=android)]()
[![License](https://img.shields.io/badge/License-MIT-f1fa8c?style=for-the-badge)]()
[![Privacy](https://img.shields.io/badge/Privacy-100%25_Local_Offline-bd93f9?style=for-the-badge)]()

[**⚡ Quick Start**](#-get-started-in-60-seconds) • [**📖 Full Guide**](USAGE.md) • [**🗺️ Roadmap**](ROADMAP.md) • [**🍎 Apple Edition**](https://github.com/earnerbaymalay/aether-apple) • [**💬 Community**](https://github.com/earnerbaymalay/aether/discussions)

---

### 🤔 What even *is* this?

Imagine running **powerful AI models** — the same technology behind ChatGPT and Claude — **entirely on your phone**. No subscriptions. No internet required. No data leaving your device.

**Aether transforms your Android phone into a fully offline AI workstation** that can write code, analyze systems, manage files, answer questions, and even learn from your workflows — all running locally through [Termux](https://termux.dev/).

> **Your phone is more powerful than you think.** Aether proves it.

### 🔥 Why should you care?

| | **Cloud AI** (ChatGPT, Claude) | **Aether** (Local AI) |
|---|---|---|
| 💰 Cost | $20–200/month | **Free forever** |
| 🔒 Privacy | Your data goes to their servers | **100% on-device, zero transmission** |
| 🌐 Internet | Required | **Not needed — works in airplane mode** |
| 🚫 Censorship | Corporate guardrails | **Uncensored — your AI, your rules** |
| ⚡ Latency | Network-dependent | **Instant — limited only by your hardware** |
| 🧠 Memory | Per-session, reset daily | **Persistent — learns and grows with you** |

---

### 👋 Who is this for?

> **Everyone.** Seriously.

| If you are... | What Aether does for you |
|---|---|
| 🟢 **Complete beginner** | One install command → instant AI chat. Type a question, get an answer. Like having a genius in your pocket. |
| 🟡 **Curious tinkerer** | Explore multi-model routing, a skill marketplace, and a persistent knowledge vault that connects to Obsidian. |
| 🔴 **Power developer** | Swarm orchestration, tool-use agents, shell-level system control, automated code review, and hardware-tuned inference. |

---

</div>

## 🚀 Get Started in 60 Seconds

**Prerequisites:** An Android phone with [Termux](https://termux.dev/) installed. That's it.

```bash
# 1. Clone the repo
git clone https://github.com/earnerbaymalay/aether.git
cd aether

# 2. Run the guided installer (it handles everything)
./install.sh

# 3. Launch your neural interface
ai
```

The installer will:
- ✅ Install all dependencies (Termux packages, llama.cpp engine)
- ✅ Set up the `ai` shortcut so you can launch from anywhere
- ✅ Offer to benchmark your hardware for optimal performance
- ✅ Leave you at a beautiful menu — ready to go

> **No configuration files to edit. No environment variables. Just `ai`.**

---

## 🧠 What You Get

### The Neural Interface (Main Menu)

When you type `ai`, you're greeted with a premium terminal UI:

```
   AETHER
   NEURAL OPERATING INTERFACE // V 18.0
   🔋 BATT: 78%  •  💾 STR: 42G  •  🧠 VAULT: ACTIVE

      [ SELECT NEURAL PATHWAY ]
   🤖 AGENT   (Hermes-8B)   — Smartest. Writes code, uses tools.
   ⚡ TURBO   (Llama-3B)    — Fastest. Daily questions, summaries.
   🧠 LOGIC   (DeepSeek)    — Deep thinker. Architecture & planning.
   💻 CODE    (Qwen-3B)     — Coding specialist. Refactor, debug.
   🛡️ SECURITY (Sentinel)   — System auditor. Scan for issues.
   🛠 TOOLS   (Skills)      — Plugins, maintenance, benchmark.
   ❌ EXIT
```

### Four AI "Brains" — Auto-Routed to the Right One

Aether doesn't use a one-size-fits-all model. It intelligently routes your request:

| Tier | Model | Speed | Best For |
|---|---|---|---|
| ⚡ **TURBO** | Llama-3.2-3B | 25+ t/s | Quick questions, summaries, translations |
| 🤖 **AGENT** | Hermes-3-8B | 10-15 t/s | Complex tasks, code writing, tool use |
| 💻 **CODE** | Qwen-Coder-3B | 18+ t/s | Code review, refactoring, debugging |
| 🧠 **LOGIC** | DeepSeek-R1 | 22+ t/s | Architecture design, deep reasoning |

### 🔧 The Toolbox — AI That *Does* Things

Unlike chat-only AI, Aether's agent can **interact with your actual device**:

- **`get_date`** — Check the current time
- **`get_battery`** — Monitor battery level
- **`list_files`** — Browse your filesystem
- **`web_search`** — Privacy-first DuckDuckGo search
- **`web_read`** — Fetch and read any webpage
- **`obsidian_*`** — Full Obsidian vault integration
- **`learn`** — Teach the AI new knowledge that persists forever

### 📂 Persistent Memory — The Context7 Vault

> **Most AI forgets everything when you close the tab. Not this one.**

Every insight you teach Aether is saved as a Markdown file in `knowledge/context7/`. The AI reads these files on every session — building a personalized knowledge base that grows with you.

Connect it to [Obsidian](https://obsidian.md/) on Android and **watch your AI's brain visually grow** as a networked knowledge graph.

---

## 🏗️ Architecture at a Glance

```
aether/
├── aether.sh              ← Main TUI / Neural Orchestrator
├── install.sh             ← One-command guided installer
├── bench.sh               ← Hardware benchmark & profiler
├── agent/
│   └── aether_agent.py    ← Python agent with tool-use & API server
├── toolbox/               ← Shell tools the AI can execute
│   ├── manifest.json      ← Tool registry (auto-discovered)
│   ├── get_battery.sh
│   ├── web_search.sh
│   ├── obsidian_*.sh      ← Obsidian vault tools
│   └── ...
├── scripts/
│   ├── librarian.py       ← Knowledge vault auditor
│   ├── skill_market.sh    ← Plugin marketplace
│   ├── debug_console.sh   ← Self-healing diagnostics
│   └── launch_sentinel.sh ← Security scanner
├── skills/                ← Extensible AI skills (drop-in)
├── knowledge/
│   ├── bio.txt            ← Your profile & preferences
│   └── context7/          ← Persistent AI memory (git-tracked)
├── legacy/                ← Archived versions (reference)
└── docs/
    └── terminal-setup/    ← Setup guides for Claude, Gemini, etc.
```

---

## 💡 "Okay, But What Can I Actually *Do* With It?"

Here are real scenarios people are using Aether for **right now**:

| Scenario | How Aether Helps |
|---|---|
| 📝 **Writing code on the bus** | Open TURBO → describe what you need → get working code. No wifi needed. |
| 🔍 **Debugging a script** | Paste the error into CODE tier → get a fix with explanation. |
| 📱 **Checking system health** | AGENT runs toolbox tools → "What's my battery health? Storage?" |
| 📚 **Learning a new technology** | "Teach me Rust" → the AI uses LOGIC tier for deep explanations. |
| 🗂️ **Managing knowledge** | Tell the AI to `learn` something → it's saved forever in Context7. |
| 🛡️ **Security auditing** | Launch Sentinel → scan your Termux environment for vulnerabilities. |
| 🤖 **Automating repetitive tasks** | AGENT can chain tools → search the web, read a page, summarize it. |
| 📊 **Benchmarking your phone** | Run `bench.sh` → see tokens/sec → compare with other devices. |

---

## 📋 Requirements

- **Android 8+** device
- **[Termux](https://termux.dev/)** (install from [F-Droid](https://f-droid.org/en/packages/com.termux/), *not* Play Store)
- **~3-5 GB free storage** (for AI models)
- **At least 4 GB RAM** (6+ GB recommended)
- **Patience for the first setup** (~10-15 min for the installer + model download)

> **No root required.** Aether runs entirely in Termux's user space.

---

## 🗺️ Roadmap

We're building toward something big. Here's where we're headed:

- ✅ **Phase 1** — Core engine, multi-model routing, Context7 vault → **Done**
- ✅ **Phase 2** — Self-healing, skill marketplace, guided installer → **Done**
- 🔄 **Phase 3** — Android shortcuts, voice interface, advanced RAG → **In Progress**
- 🔮 **Phase 4** — Distributed mesh networking, NPU/GPU acceleration → **Vision**

See the full [ROADMAP.md](ROADMAP.md) for details.

---

## 🍎 Also Available: Aether Apple Edition

**Got a Mac or iPad?** We've built a streamlined version for the Apple ecosystem too — same local-first, private, free AI philosophy, adapted for macOS and iPadOS.

👉 **[Get Aether Apple Edition →](https://github.com/earnerbaymalay/aether-apple)**

| | 📱 Android (this repo) | 🖥️ Mac | 📱 iPad (iSH) | 📱 iPad (a-Shell) |
|---|---|---|---|---|
| **AI Models** | 4 tiers | 2 modes | 2 modes | 2 modes |
| **Tools** | 10+ (Termux:API) | 6 (macOS native) | 5 | 5 |
| **Advanced** | Swarm, Sentinel, Agent | Chat + Toolbox | Chat + Toolbox | Chat + Toolbox |
| **Price** | Free | Free | Free | Free |
| **Privacy** | 100% local | 100% local | 100% local | 100% local |

> **One philosophy across every device:** Free, private, offline AI for everyone. The Android version is the full-power experience. The Apple edition covers Mac (full), iPad via iSH (medium), and iPad via a-Shell (lite). **Use them together — they share the same knowledge format.**

---

## 🤝 Contributing

Aether is built by people who believe AI should be **free, private, and local**. Whether you're a developer, writer, or just someone with a cool idea — you're welcome here.

- 🐛 Found a bug? [Open an issue](https://github.com/earnerbaymalay/aether/issues)
- 💡 Have an idea? [Start a discussion](https://github.com/earnerbaymalay/aether/discussions)
- 🔧 Want to code? Fork the repo and submit a PR!
- 📖 Know a niche? Write a [Skill](aether/skills/) and share it

---

## 📜 License

[MIT License](LICENSE) — Use it. Modify it. Share it. No restrictions.

---

<div align="center">

### 🌌 *Develop natively. Think locally. Evolve autonomously.*

**⭐ If this project impressed you, give it a star — it helps more people discover local AI.**

</div>
