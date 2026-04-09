# Aether

Local AI workstation for Android. No cloud, no API keys, and no internet required after setup.

[![Version](https://img.shields.io/badge/version-26.04.2-50fa7b?style=for-the-badge)](../VERSIONS.md)
[![License](https://img.shields.io/badge/license-MIT-f1fa8c?style=for-the-badge)](LICENSE)

[Quick start](#quick-start) · [Architecture](#architecture) · [Related projects](#related-projects)

---

## Functions

Aether runs open-source AI models on your device. It routes tasks between four specialized models, executes shell operations, and maintains a persistent knowledge base.

### AI tiers

| Tier | Model | Best for |
|------|-------|----------|
| Turbo | Llama-3.2-3B | Fast questions and summaries |
| Agent | Hermes-3-8B | Tool use and complex tasks |
| Code | Qwen-Coder-3B | Programming and review |
| Logic | DeepSeek-R1-1.5B | Reasoning and planning |

### Toolbox

The Agent tier executes operations like checking battery status, searching the web, reading files, and managing Obsidian vaults. It also monitors system health and analyzes logs.

### Persistent memory

Knowledge is saved as Markdown files in the AetherVault. The AI reads these files during every session and updates them as it learns.

### Swarm orchestrator

A multi-stage pipeline where Logic plans, Code implements, and the Agent analyzes the result. Each stage uses a dedicated model to ensure accuracy.

### Voice interaction

Uses Whisper.cpp for speech-to-text and Piper for text-to-speech.

### Session manager

Each session has a unique ID. Transcripts are archived and can be resumed at any time.

---

## Architecture

```
aether/
├── aether.sh                 # Main TUI and router
├── install.sh                # Installer
├── agent/aether_agent.py     # Python agent
├── toolbox/                  # 17 shell tools
├── skills/                   # 17 behavior modules
├── knowledge/aethervault/    # Persistent memory
├── scripts/
│   ├── swarm_orchestrator.sh # Multi-agent pipeline
│   ├── session_manager.sh    # Session history
│   ├── voice_handler.sh      # STT and TTS
│   ├── workflow_engine.sh    # Automation
│   ├── logic_engine.sh       # Decision logic
│   ├── token_optimizer.sh    # Context compression
│   ├── vault_manager.sh      # Memory management
│   ├── auto_scaler.sh        # Resource allocation
│   └── extras_installer.sh   # Optional features
├── settings/settings.sh      # Settings TUI
├── contexts/                 # Context management
├── lsp/                      # Code intelligence
└── workflows/                # Automation registry
```

---

## Version history

Uses CalVer (YY.MM.patch). Details in the main repository's [VERSIONS.md](../VERSIONS.md).

---

## Local vs cloud

| Feature | Cloud AI | Aether |
|---|---|---|
| Cost | Subscriptions | Free |
| Internet | Always required | Offline |
| Privacy | Data is tracked | Data stays on device |
| Memory | Temporary | Persistent |

---

## Related projects

- [Aether Apple](https://github.com/earnerbaymalay/aether-apple) - macOS and iPad
- [Aether Desktop](https://github.com/earnerbaymalay/aether-desktop) - Desktop app
- [Edge Sentinel](https://github.com/earnerbaymalay/edge-sentinel) - Security dashboard
- [Sideload Hub](https://earnerbaymalay.github.io/sideload/) - App distribution

---

## Contributing

Submit bug reports or pull requests at [CONTRIBUTING.md](CONTRIBUTING.md).

---

[MIT License](LICENSE)
