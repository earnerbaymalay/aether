# Termux-Vault

A collection of helper tools and setup scripts for Termux, optimized for
**AI development on Pixel 8 Pro** with Qwen, Gemini, and Ollama.

Automates tasks that are difficult, tedious, or error-prone to configure
manually in Termux.

## AI Tools

| Tool | Description |
|------|-------------|
| `setup-ollama` | Install Ollama, manage models, benchmark, Pixel 8 Pro memory tuning |
| `setup-ai` | Set up Gemini CLI, Qwen (local/API), API key management, shell helpers |
| `ai-dev` | Python ML stack, Jupyter notebooks, LangChain, HuggingFace, project scaffold |

## General Tools

| Tool | Description |
|------|-------------|
| `tvault` | Main entry point — run any tool by name |
| `setup-dev` | One-command dev environment setup (Python, Node, Rust, Go, C/C++) |
| `pkg-bundle` | Install curated package bundles in one shot |
| `storage-fix` | Fix storage permissions and symlinks |
| `keygen` | Generate and manage SSH/GPG keys |
| `dotfiles` | Shell config manager (zsh, bash, aliases, prompt) |
| `netkit` | Network utilities (proxy, port-forward, API test) |
| `tbackup` | Backup and restore Termux environment |
| `proot-distro-setup` | Automated Linux distro install via proot-distro |

## Quick Start

```bash
# Clone and install
git clone https://github.com/earnerbaymalay/Termux-Vault.git
cd Termux-Vault
make install
```

## AI Quick Start (Pixel 8 Pro)

```bash
# Install Ollama and pull Qwen
tvault setup-ollama install
tvault setup-ollama pull qwen2.5:7b
tvault setup-ollama pull qwen2.5-coder:7b

# Set up Gemini CLI + API keys
tvault setup-ai gemini
tvault setup-ai keys set GEMINI_API_KEY your-key-here

# Add shell helpers (ask, code, explain, fix commands)
tvault setup-ai shell-integration

# After restarting shell:
ask "explain Python decorators"
code "fibonacci sequence in Rust"
qwen                               # interactive Qwen chat
qwen-code                          # interactive Qwen Coder chat
ai-commit-msg                      # auto-generate commit message
```

## AI Development

```bash
# Python ML environment
tvault ai-dev python-ml

# Jupyter notebooks (accessible from phone browser)
tvault ai-dev jupyter

# LangChain with Ollama integration
tvault ai-dev langchain

# Scaffold a new AI project
tvault ai-dev new-project my-chatbot

# FastAPI server wrapping your local models
tvault ai-dev api-server

# Benchmark models on your device
tvault setup-ollama recommend       # see what fits in 12GB RAM
tvault setup-ollama bench qwen2.5:7b
```

## Recommended Models for Pixel 8 Pro (12GB RAM)

| Model | Size | Best For |
|-------|------|----------|
| `qwen2.5:7b` | ~4.4GB | General purpose, primary workhorse |
| `qwen2.5-coder:7b` | ~4.4GB | Code generation and editing |
| `gemma2:9b` | ~5.4GB | Strong reasoning, optimized for Google silicon |
| `llama3.1:8b` | ~4.7GB | All-rounder |
| `phi3:3.8b` | ~2.2GB | Fast, lightweight tasks |
| `deepseek-coder:6.7b` | ~3.8GB | Code specialist |

## General Usage

```bash
tvault setup-dev python node   # install Python + Node dev environments
tvault pkg-bundle dev-core     # install core dev packages
tvault keygen github           # generate SSH key for GitHub
tvault dotfiles setup-zsh      # zsh + oh-my-zsh + plugins
tvault tbackup save            # backup your entire Termux setup
tvault doctor                  # check system health + AI tools
```

## Requirements

- [Termux](https://termux.dev) (F-Droid version recommended)
- Pixel 8 Pro (or any Android device with 8GB+ RAM for AI models)
- `bash` 4+ (comes with Termux)
- Internet connection for package installs

## Project Structure

```
Termux-Vault/
├── bin/            # All executable tools
├── lib/            # Shared functions and helpers
├── setup/          # Bootstrap and first-run scripts
├── config/         # Default config templates
├── backups/        # Backup storage (gitignored)
├── Makefile        # Install/uninstall targets
└── README.md
```

## Uninstall

```bash
make uninstall
```

## License

MIT
