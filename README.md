<div align="center">

# 🌌 A E T H E R
### *Offline AI Workstation for Android.*

[![Version](https://img.shields.io/badge/version-26.04.2-50fa7b?style=for-the-badge)](VERSIONS.md)
[![License](https://img.shields.io/badge/license-MIT-f1fa8c?style=for-the-badge)](LICENSE)
[![Privacy](https://img.shields.io/badge/privacy-100%25_local-bd93f9?style=for-the-badge)](#privacy)

**[📲 Download](https://github.com/earnerbaymalay/aether/releases)** · **[🌐 Sideload Hub](https://earnerbaymalay.github.io/sideload/)** · **[📖 Usage Guide](USAGE.md)** · **[🔧 Troubleshooting](TROUBLESHOOTING.md)**

</div>

---

![Aether](docs/media/hero.svg)

## What is Aether?

**Aether runs 4 AI models entirely on your phone.** It routes tasks between specialized models, executes shell operations, and maintains a persistent knowledge base. Zero bytes leave your device.

---

## Quick Start

### Install on Android

```bash
git clone https://github.com/earnerbaymalay/aether.git
cd aether
./install.sh   # guided installer (~10 min first time)
ai             # launch
```

Requires: Android + [Termux](https://f-droid.org/en/packages/com.termux/) (from F-Droid). 4GB+ RAM, 3-5GB storage.

### All Platforms

<div align="center">

| Platform | Repo | Version |
|----------|------|---------|
| 📱 **Android (Termux)** | [aether](https://github.com/earnerbaymalay/aether) | 26.04.2 |
| 🖥️ **macOS** | [aether-apple](https://github.com/earnerbaymalay/aether-apple) | 26.04.2 |
| 📱 **iPad (iSH)** | [aether-apple](https://github.com/earnerbaymalay/aether-apple) | 26.04.2 |
| 📱 **iPad (a-Shell)** | [aether-apple](https://github.com/earnerbaymalay/aether-apple) | 26.04.2 |
| 🖥️ **Desktop** | [aether-desktop](https://github.com/earnerbaymalay/aether-desktop) | 26.04.2 |

</div>

---

## AI Tiers

| Tier | Model | Best For |
|------|-------|----------|
| ⚡ TURBO | Llama-3.2-3B | Fast questions, summaries |
| 🤖 AGENT | Hermes-3-8B | Tool use, complex tasks |
| 💻 CODE | Qwen-Coder-3B | Code generation, review |
| 🧠 LOGIC | DeepSeek-R1-1.5B | Reasoning, planning |

---

## Key Features

| Feature | Description |
|---------|-------------|
| **Toolbox (17 tools)** | Battery, web search, file ops, Obsidian vault, system health, log analysis. |
| **Skills (17 modules)** | Code review, security audit, data analysis, architecture design. |
| **AetherVault** | Persistent Markdown knowledge base · grows every session. |
| **Swarm Orchestrator** | Logic plans → Code implements → Agent analyzes. |
| **Voice I/O** | Whisper.cpp STT · Piper TTS · hands-free operation. |
| **Session Manager** | Unique IDs · save transcripts · resume later. |

---

## Related Projects

<div align="center">

| Project | Platform | Description | Link |
|---------|----------|-------------|------|
| 🌗 **Gloam** | 📱 Android / 🖥️ Desktop | Solar-timed CBT journal | [Source →](https://github.com/earnerbaymalay/Gloam) |
| 🛡️ **Cyph3rChat** | 📱 Android | E2E encrypted messaging | [Source →](https://github.com/earnerbaymalay/cyph3rchat) |
| 🧰 **Termux-Vault** | 📱 Android | Dev environment toolchain | [Source →](https://github.com/earnerbaymalay/Termux-Vault) |
| 📲 **Sideload Hub** | 🌐 Web / PWA | Central app distribution | [Open Hub →](https://earnerbaymalay.github.io/sideload/) |

</div>

---

## Documentation

- **[📖 Usage Guide](USAGE.md)** — Installation, AI tiers, toolbox, skills, AetherVault, voice I/O.
- **[🔧 Troubleshooting](TROUBLESHOOTING.md)** — Build issues, model errors, memory problems.
- **[🗺️ Roadmap](ROADMAP.md)** — Planned features and future direction.
- **[🔒 Security](SECURITY.md)** — Privacy model, local-first guarantees.

---

## Privacy

- **Zero bytes leave device** — No cloud, no APIs, no tracking.
- **No accounts** — No registration, no phone numbers, no passwords.
- **Persistent memory** — AetherVault stores knowledge as Markdown files on your device.
- **No telemetry** — No crash reporting, no analytics, no phone-home.

---

[MIT License](LICENSE)
