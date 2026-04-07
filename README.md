<div align="center">

# 🌌 A E T H E R — A I
### *Your Phone. Your AI. Your Rules.*

<p align="center">
  <img src="https://raw.githubusercontent.com/earnerbaymalay/sideload/main/assets/aether-hero.svg" alt="Aether Neural Interface" width="700"/>
</p>

[![Status](https://img.shields.io/badge/Status-Active_Development-50fa7b?style=for-the-badge)](https://github.com/earnerbaymalay/aether)
[![Engine](https://img.shields.io/badge/Engine-Llama.cpp_Native-81a1c1?style=for-the-badge&logo=c%2B%2B)](https://github.com/ggerganov/llama.cpp)
[![Platform](https://img.shields.io/badge/Platform-Android_%7C_Termux-4c566a?style=for-the-badge&logo=android)](https://termux.dev/)
[![License](https://img.shields.io/badge/License-MIT-f1fa8c?style=for-the-badge)](LICENSE)
[![Privacy](https://img.shields.io/badge/Privacy-100%25_Local_Offline-bd93f9?style=for-the-badge)](#-why-does-this-exist)

[**⚡ Quick Start**](#-get-started-in-60-seconds) · [**📖 Full Guide**](USAGE.md) · [**🗺️ Roadmap**](ROADMAP.md) · [**🍎 Apple Edition**](https://github.com/earnerbaymalay/aether-apple) · [**💬 Community**](https://github.com/earnerbaymalay/aether/discussions)

</div>

---

## 🧬 The Mission

> *Picture this:* You're on a train. No wifi. No signal. You open your phone and type a question into a terminal. An AI answers — **instantly, locally, entirely on your device.** No subscription. No internet. No data leaving your hardware.

That's Aether.

Most mobile AI experiences are mere wrappers around corporate APIs. They're data-extractive, internet-dependent, and latency-heavy. Aether is the opposite — a **Neural Operating Interface (NOI)** built from the ground up for the local-first era.

**It doesn't just "chat."** It operates your device, learns your technical workflows, and evolves into a persistent extension of your own intelligence.

---

## 🔥 Why Does This Exist?

| Your data on… | **ChatGPT** | **Claude** | **Aether** |
|---|---|---|---|
| 💰 Cost | $20–200/month | $20–100/month | **Free forever** |
| 🌐 Internet | Required | Required | **Not needed** |
| 🔒 Privacy | Your data on their servers | Your data on their servers | **Zero bytes leave your device** |
| 📱 Devices | Browser only | Browser only | **Phone, Mac, iPad** |
| ⏱️ Latency | Network-dependent | Network-dependent | **Instant — your hardware** |
| 🧠 Memory | Per-session, reset daily | Per-session, limited history | **Persistent — grows with you** |
| 🚫 Censorship | Corporate guardrails | Corporate guardrails | **Uncensored — your AI, your rules** |

---

## 👋 Who Is This For?

> **Everyone.** Seriously. We built three experience tiers so anyone can use it:

| If you are… | Aether gives you |
|---|---|
| 🟢 **Complete beginner** | One install command → instant AI chat. Type a question, get an answer. Like having a genius in your pocket. |
| 🟡 **Curious tinkerer** | Multi-model routing, skill marketplace, persistent knowledge vault that connects to Obsidian. |
| 🔴 **Power developer** | Swarm orchestration, tool-use agents, shell-level system control, automated code review, hardware-tuned inference. |

---

## 🚀 Get Started in 60 Seconds

**Prerequisites:** An Android phone with [Termux](https://f-droid.org/en/packages/com.termux/) installed. That's it.

```bash
# 1. Clone
git clone https://github.com/earnerbaymalay/aether.git
cd aether

# 2. Run the guided installer
./install.sh

# 3. Launch your neural interface
ai
```

The installer handles everything: dependencies → llama.cpp engine → model download → `ai` shortcut.

> ⏱️ **First install takes ~10-15 minutes.** Subsequent installs are instant.

---

## 🧠 What You Get

### The Neural Interface

When you type `ai`, you enter the **Neural Orchestrator**:

```
   ╔══════════════════════════════════════════╗
   ║          🌌  A E T H E R  🌌            ║
   ║   NEURAL OPERATING INTERFACE // V 18.0   ║
   ╚══════════════════════════════════════════╝
   🔋 BATT: 78%  •  💾 STR: 42G  •  🧠 VAULT: ACTIVE

   ┌────────────────────────────────────────────┐
   │  [ SELECT NEURAL PATHWAY ]                 │
   │                                            │
   │  🤖 AGENT   (Hermes-8B)   — Smartest       │
   │  ⚡ TURBO   (Llama-3B)    — Fastest        │
   │  🧠 LOGIC   (DeepSeek)    — Deep thinker   │
   │  💻 CODE    (Qwen-3B)     — Coding expert  │
   │  🛡️ SECURITY (Sentinel)   — System audit   │
   │  🛠 TOOLS   (Skills)      — Plugins        │
   └────────────────────────────────────────────┘
```

### Four AI "Brains" — Auto-Routed

Aether doesn't use one-size-fits-all. It **intelligently routes** your request:

| Tier | Model | Speed | Best For |
|---|---|---|---|
| ⚡ **TURBO** | Llama-3.2-3B | 25+ t/s | Quick questions, summaries, translations |
| 🤖 **AGENT** | Hermes-3-8B | 10-15 t/s | Complex tasks, code writing, tool use |
| 💻 **CODE** | Qwen-Coder-3B | 18+ t/s | Code review, refactoring, debugging |
| 🧠 **LOGIC** | DeepSeek-R1 | 22+ t/s | Architecture design, deep reasoning |

### 🔧 The Toolbox — AI That *Does* Things

Unlike chat-only AI, Aether's agent can **interact with your actual device**:

| Tool | What It Does |
|---|---|
| `get_date` | Check current date/time |
| `get_battery` | Monitor battery level |
| `list_files` | Browse your filesystem |
| `web_search` | Privacy-first DuckDuckGo search |
| `web_read` | Fetch and read any webpage |
| `obsidian_*` | Full Obsidian vault integration (list, search, read) |
| `learn` | **Teach the AI** — knowledge persists across sessions |

### 📂 Context7 Persistent Memory

> **Most AI forgets everything when you close the tab. Not this one.**

Every insight you teach Aether is saved as a Markdown file in `knowledge/context7/`. The AI reads these files on every session — building a personalized knowledge base that grows with you.

Connect it to [Obsidian](https://obsidian.md/) on Android and **watch your AI's brain visually grow** as a networked knowledge graph.

---

## 💡 "Okay, But What Can I Actually *Do* With It?"

Real scenarios people use Aether for right now:

| Scenario | How It Works |
|---|---|
| 📝 **Writing code on the bus** | Open TURBO → describe what you need → get working code. No wifi. |
| 🔍 **Debugging a script** | Paste the error into CODE → get a fix with explanation. |
| 📱 **Checking system health** | AGENT runs toolbox tools → "What's my battery? Storage?" |
| 📚 **Learning a new technology** | "Teach me Rust" → LOGIC tier gives deep explanations. |
| 🗂️ **Managing knowledge** | Tell the AI to `learn` something → saved forever in Context7. |
| 🛡️ **Security auditing** | Launch Sentinel → scan your Termux environment. |
| 🤖 **Automating tasks** | AGENT chains tools → search web → read page → summarize. |

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
│   └── obsidian_*.sh      ← Obsidian vault tools
├── scripts/
│   ├── librarian.py       ← Knowledge vault auditor
│   ├── skill_market.sh    ← Plugin marketplace
│   ├── debug_console.sh   ← Self-healing diagnostics
│   └── launch_sentinel.sh ← Security scanner
├── skills/                ← Drop-in AI behavior modules
├── knowledge/
│   └── context7/          ← Persistent AI memory (Markdown)
└── docs/
    └── terminal-setup/    ← Setup guides for Claude, Gemini, etc.
```

---

## 🍎 Also Available: Apple Edition

**Got a Mac or iPad?** We've built a streamlined version for the Apple ecosystem too — same local-first, private, free AI philosophy, adapted for macOS and iPadOS.

👉 **[Get Aether Apple Edition →](https://github.com/earnerbaymalay/aether-apple)**

| | 📱 Android (this repo) | 🖥️ Mac | 📱 iPad (iSH) | 📱 iPad (a-Shell) |
|---|---|---|---|---|
| **AI Models** | 4 tiers | 2 modes | 2 modes | 2 modes |
| **Tools** | 10+ (Termux:API) | 6 (macOS native) | 5 | 5 |
| **Advanced** | Swarm, Sentinel, Agent | Chat + Toolbox | Chat + Toolbox | Chat + Toolbox |
| **Price** | Free | Free | Free | Free |
| **Privacy** | 100% local | 100% local | 100% local | 100% local |

> **One philosophy across every device.** The Android version is the full-power experience. The Apple edition covers Mac (full), iPad via iSH (medium), and iPad via a-Shell (lite). **Use them together — they share the same knowledge format.**

### 📲 Install Anywhere

All our apps are available through **[Sideload](https://earnerbaymalay.github.io/sideload/)** — our central distribution hub for local-first apps. One tap to install on any device.

---

## 📋 Requirements

- **Android 7.0+** device
- **[Termux](https://f-droid.org/en/packages/com.termux/)** (install from F-Droid, *not* Play Store)
- **~3-5 GB free storage** (for AI models)
- **At least 4 GB RAM** (6+ GB recommended)
- **Patience for the first setup** (~10-15 min)

> **No root required.** Aether runs entirely in Termux's user space.

---

## 🗺️ Roadmap

| Phase | Status | What's Done |
|---|---|---|
| **Phase 1: Foundations** | ✅ Complete | 4-tier routing, Context7 vault, premium TUI, Librarian |
| **Phase 2: Orchestration** | ✅ Complete | Self-healing, skill marketplace, guided installer |
| **Phase 3: Agency** | 🔄 In Progress | Swarm orchestrator, web integration, advanced RAG |
| **Phase 4: Autonomy** | 🔮 Vision | Distributed mesh, NPU/GPU acceleration, self-coding |

See [ROADMAP.md](ROADMAP.md) for full details.

---

## 📚 Documentation

| Document | What It Covers |
|---|---|
| [**Usage Guide**](USAGE.md) | Start-to-finish: install, first conversation, toolbox, Context7 vault, troubleshooting |
| [**Roadmap**](ROADMAP.md) | Development phases, what's done, what's next |
| [**Contributing**](CONTRIBUTING.md) | How to contribute, coding standards |
| [**Security Policy**](SECURITY.md) | Vulnerability disclosure |

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

**⭐ If this project impressed you, star this repo — it helps more people discover local AI.**

</div>
