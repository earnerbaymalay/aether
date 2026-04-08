# Aether

Local AI workstation that runs on your phone. No cloud, no API keys, no internet needed after setup.

[![Version](https://img.shields.io/badge/version-26.04.2-50fa7b?style=for-the-badge)](VERSIONS.md)
[![License](https://img.shields.io/badge/license-MIT-f1fa8c?style=for-the-badge)](LICENSE)

[Quick Start](#quick-start) · [Architecture](#architecture) · [Version History](VERSIONS.md) · [Usage Guide](USAGE.md)

---

## Quick Start

```bash
git clone https://github.com/earnerbaymalay/aether.git
cd aether
./install.sh
ai
```

Requires Android with Termux (from F-Droid). 4GB+ RAM, 3-5GB free storage.

---

## What It Does

Aether runs open-source AI models on-device. It routes between four models depending on the task, executes real shell operations, and saves knowledge across sessions.

### Four AI tiers

| Tier | Model | Best For |
|------|-------|----------|
| TURBO | Llama-3.2-3B | Quick questions, summaries |
| AGENT | Hermes-3-8B | Tool use, complex tasks |
| CODE | Qwen-Coder-3B | Code generation and review |
| LOGIC | DeepSeek-R1-1.5B | Reasoning, planning |

### Toolbox (17 tools)

The AGENT can execute real operations: check battery, search the web, read files, manage Obsidian vaults, analyze logs, monitor systems.

### Persistent memory

Knowledge is saved as Markdown files in `knowledge/aethervault/`. The AI reads these files at the start of each session and adds to them during conversations.

### Swarm orchestrator

Three-stage pipeline: LOGIC plans, CODE implements, AGENT analyzes. Each stage runs a real model with output passed between them.

### Voice I/O

Whisper.cpp for speech input, Piper TTS for spoken output.

### Session manager

Every session gets a unique ID. Transcripts are compressed and archived. Resume any session by ID.

---

## Architecture

```
aether/
├── aether.sh                 # Main TUI and model router
├── install.sh                # Guided installer
├── agent/aether_agent.py     # Python agent with HTTP server
├── toolbox/                  # 17 shell tools
├── skills/                   # 17 behavior modules
├── knowledge/aethervault/    # Persistent AI memory
├── scripts/
│   ├── swarm_orchestrator.sh # 3-stage multi-agent pipeline
│   ├── session_manager.sh    # Session IDs and transcripts
│   ├── voice_handler.sh      # Whisper.cpp STT + Piper TTS
│   ├── workflow_engine.sh    # Multi-stage workflow automation
│   ├── logic_engine.sh       # Decision trees, fallback routing
│   ├── token_optimizer.sh    # 60-90% token compression
│   ├── vault_manager.sh      # AetherVault browse/search/stats
│   ├── auto_scaler.sh        # Dynamic resource allocation
│   └── extras_installer.sh   # Optional features
├── settings/settings.sh      # Central settings TUI
├── contexts/context_manager.sh
├── lsp/lsp_server.sh
└── workflows/registry/workflows.yaml
```

---

## Version History

Uses CalVer (YY.MM.patch). See [VERSIONS.md](VERSIONS.md) for details.

| Version | Theme |
|---------|-------|
| [26.04.2](VERSIONS.md) | Voice I/O, real swarm, versioning |
| [26.04.1](VERSIONS.md) | Settings, LSP, context, token optimization |
| [26.04.0](VERSIONS.md) | Skills, tools, scripts |
| [26.03.0](VERSIONS.md) | AetherVault, session manager |
| [1.0.0-alpha](VERSIONS.md) | Foundation |

---

## Why Local

| | Cloud AI | Aether |
|---|---|---|
| Cost | $20-200/month | Free |
| Internet | Required | Not needed |
| Privacy | Data on their servers | Zero bytes leave device |
| Memory | Per-session | Persistent, grows with you |

---

## Also Available

- [Aether Apple](https://github.com/earnerbaymalay/aether-apple) -- macOS and iPad
- [Aether Desktop](https://github.com/earnerbaymalay/aether-desktop) -- Tauri desktop app
- [Edge Sentinel](https://github.com/earnerbaymalay/edge-sentinel) -- Security dashboard
- [Sideload Hub](https://earnerbaymalay.github.io/sideload/) -- Install any app from one page

---

## Contributing

Bug reports, feature ideas, and pull requests welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

---

[MIT License](LICENSE)
