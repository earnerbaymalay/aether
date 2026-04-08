<div align="center">

# 🌌 A E T H E R — A I
### *Your Phone. Your AI. Your Rules.*

[![Version](https://img.shields.io/badge/version-26.04.2-50fa7b?style=for-the-badge)](VERSIONS.md)
[![License](https://img.shields.io/badge/license-MIT-f1fa8c?style=for-the-badge)](LICENSE)
[![Privacy](https://img.shields.io/badge/privacy-100%25_local-bd93f9?style=for-the-badge)](#why-local)
[![Engine](https://img.shields.io/badge/engine-llama.cpp-81a1c1?style=for-the-badge)](https://github.com/ggerganov/llama.cpp)

**Local-first AI Neural Operating Interface — runs entirely on-device. No cloud. No tracking. No subscriptions.**

[Quick Start](#quick-start) · [What It Does](#what-it-does) · [Architecture](#architecture) · [Version History](VERSIONS.md) · [Roadmap](ROADMAP.md) · [Usage Guide](USAGE.md)

</div>

---

## Quick Start

```bash
git clone https://github.com/earnerbaymalay/aether.git
cd aether
./install.sh   # guided installer (~10 min first time)
ai             # launch
```

Requires: Android + [Termux](https://f-droid.org/en/packages/com.termux/) (from F-Droid, not Play Store). 4GB+ RAM, 3-5GB storage.

---

## What It Does

Aether runs multiple open-source AI models **entirely on your phone** — no internet needed. It's not a chat wrapper. It's a system that:

- **Routes intelligently** — 4 AI models for different tasks (fast chat, tool use, code, reasoning)
- **Uses tools** — reads files, searches the web, checks system status, manages your Obsidian vault
- **Remembers everything** — persistent knowledge base that grows with every session
- **Automates workflows** — multi-agent pipelines for code review, security audits, research
- **Stays private** — zero bytes leave your device

### What You Can Do

| Use Case | How |
|----------|-----|
| Chat with AI offline | Pick a tier, type a question, get an answer |
| Write/debug code | CODE tier generates and reviews code |
| Analyze systems | Run security scans, check performance |
| Manage knowledge | Save insights to AetherVault, they persist forever |
| Automate tasks | Swarm orchestrator chains multiple AI models together |
| Voice interaction | Speak questions, hear answers (Whisper.cpp + Piper TTS) |

---

## Architecture

```
aether/
├── aether.sh                 # Main TUI / Neural Orchestrator
├── install.sh                # Guided installer with optional extras
├── VERSION                   # Current version (CalVer YY.MM.patch)
├── VERSIONS.md               # Detailed version history
│
├── agent/
│   └── aether_agent.py       # Python agent with tool-use & HTTP server
│
├── toolbox/                  # Shell tools the AI can execute (17 tools)
│   ├── manifest.json         # Tool registry (auto-discovered by agent)
│   ├── get_battery.sh        # Device status
│   ├── web_search.sh         # Privacy-first web search
│   ├── obsidian_*.sh         # Obsidian vault integration
│   └── ...                   # + 12 more tools
│
├── skills/                   # Drop-in behavior modules (17 skills)
│   ├── code-review/          # Multi-phase code review
│   ├── security-audit/       # System security scanning
│   ├── data-analysis/        # Statistical analysis
│   └── ...                   # + 14 more
│
├── knowledge/
│   └── aethervault/          # Persistent AI memory (smart loader)
│       ├── protocols/        # Rules the AI follows (always loaded)
│       ├── guides/           # How-to documentation (high priority)
│       ├── reference/        # Technical reference (medium priority)
│       ├── troubleshooting/  # Error diagnosis (on-demand)
│       ├── templates/        # Reusable formats (low priority)
│       └── memories/         # AI-learned knowledge (medium priority)
│
├── scripts/
│   ├── swarm_orchestrator.sh # Real 3-stage multi-agent pipeline
│   ├── session_manager.sh    # Session IDs, transcripts, memory slots
│   ├── voice_handler.sh      # Whisper.cpp STT + Piper TTS
│   ├── workflow_engine.sh    # Multi-stage workflow automation
│   ├── logic_engine.sh       # Decision trees, fallback routing
│   ├── token_optimizer.sh    # 60-90% token compression
│   ├── vault_manager.sh      # AetherVault browse/search/stats
│   ├── auto_scaler.sh        # Dynamic resource allocation
│   └── extras_installer.sh   # Optional features (17 available)
│
├── settings/
│   └── settings.sh           # Central settings TUI with profiles
│
├── contexts/
│   └── context_manager.sh    # Gemini-style context import/export
│
├── lsp/
│   └── lsp_server.sh         # Language Server Protocol bridge
│
├── workflows/
│   └── registry/
│       └── workflows.yaml    # Declarative workflow definitions
│
└── docs/                     # Setup guides, architecture diagrams
```

### Four AI Tiers

| Tier | Model | Best For |
|------|-------|----------|
| ⚡ TURBO | Llama-3.2-3B | Quick questions, summaries |
| 🤖 AGENT | Hermes-3-8B | Tool use, complex tasks |
| 💻 CODE | Qwen-Coder-3B | Code generation, review |
| 🧠 LOGIC | DeepSeek-R1-1.5B | Reasoning, planning |

---

## Key Features

### 🔧 Toolbox (17 tools)
AI can execute real operations: check battery, search the web, browse files, manage Obsidian vaults, analyze logs, check dependencies, monitor systems, and more.

### 🧠 Skills (17 modules)
Drop-in behavior modules: code review, security audit, data analysis, system optimization, architecture design, project planning, Obsidian integration, and more.

### 📂 AetherVault
Persistent knowledge base with smart loading — relevance-scored, categorized, token-budgeted. The AI learns from every session and saves knowledge forever.

### 🔄 Swarm Orchestrator
Real 3-stage pipeline: LOGIC plans → CODE implements → AGENT analyzes. Each stage runs actual AI models with output passed between them.

### 🎤 Voice I/O
Speak questions (Whisper.cpp STT), hear answers (Piper TTS). Hands-free operation for when typing isn't convenient.

### 📋 Session Manager
Every session gets a unique ID. Save transcripts, resume later, isolate knowledge per project with memory slots.

### ⚙ Settings Hub
Central TUI for all configuration. Five profiles (performance/reasoning/coding/conservative/balanced). Feature toggles. Import/export.

---

## Version History

We use **CalVer** (`YY.MM.patch`). See [VERSIONS.md](VERSIONS.md) for detailed per-version documentation.

| Version | Date | Theme |
|---------|------|-------|
| [`26.04.2`](VERSIONS.md) | Apr 8 | Voice I/O, Real Swarm, Versioning |
| [`26.04.1`](VERSIONS.md) | Apr 8 | Settings, LSP, Context, Token Optimization |
| [`26.04.0`](VERSIONS.md) | Apr 8 | Skills, Tools, Scripts |
| [`26.03.0`](VERSIONS.md) | Mar | AetherVault, Session Manager |
| [`1.0.0-alpha`](VERSIONS.md) | Apr 7 | Foundation |

---

## Why Local?

| | Cloud AI | Aether |
|---|---|---|
| Cost | $20-200/month | Free |
| Internet | Required | Not needed |
| Privacy | Data on their servers | Zero bytes leave device |
| Latency | Network-dependent | Instant (your hardware) |
| Memory | Per-session | Persistent, grows with you |
| Censorship | Corporate guardrails | None — your AI |

---

## Also Available

- **[Aether Apple](https://github.com/earnerbaymalay/aether-apple)** — macOS/iPad port
- **[Aether Desktop](https://github.com/earnerbaymalay/aether-desktop)** — Tauri desktop app
- **[Edge Sentinel](https://github.com/earnerbaymalay/edge-sentinel)** — Security dashboard
- **[Sideload Hub](https://earnerbaymalay.github.io/sideload/)** — Central distribution hub

---

## Contributing

Bug reports, feature ideas, and pull requests welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

<div align="center">

**[MIT License](LICENSE)** — Free forever. Use it. Modify it. Share it.

*Develop natively. Think locally. Evolve autonomously.*

</div>
