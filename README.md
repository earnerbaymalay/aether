<div align="center">

# 🌌 A E T H E R — A I
### *The Neural Operating Interface for Android*

[![Status](https://img.shields.io/badge/Status-Superior-81a1c1?style=for-the-badge)]()
[![Engine](https://img.shields.io/badge/Engine-Llama.cpp_C%2B%2B-565f89?style=for-the-badge&logo=c%2B%2B)]()
[![Hardware](https://img.shields.io/badge/Hardware-ARM64_Native-4c566a?style=for-the-badge&logo=android)]()

[**Quick Start**](#-quick-start) • [**Neural Tiers**](#-neural-tier-system) • [**Usage Guide**](USAGE.md) • [**Roadmap**](ROADMAP.md)

---
</div>

## 💎 The Philosophy
Most mobile AI tools are slow, internet-dependent wrappers. **Aether-AI** is a local-first **Neural Operating Interface (NOI)**. It lives entirely on your device, bypasses the cloud, and uses a custom-compiled C++ backend tuned specifically for **ARMv8 NEON** instructions.

- **100% Private**: No data ever leaves your phone.
- **Hardware Native**: Direct execution on Snapdragon/Pixel silicon.
- **Self-Evolving**: A persistent memory system that learns as you work.

---

## 🚀 Quick Start
Get up and running in minutes. (Requires [Termux](https://f-droid.org/packages/com.termux/))

1. **Deploy**:
```bash
git clone https://github.com/earnerbaymalay/aether.git
cd aether
./install.sh
```

2. **Launch**:
```bash
ai
```
*Type `ai` from anywhere in your terminal to return to the interface.*

---

## 🧠 Neural Tier System
Aether dynamically routes your requests to the optimal "brain" for the task:

| Tier | Model | Specialty | Performance |
| :--- | :--- | :--- | :--- |
| **⚡ TURBO** | Llama-3.2-3B | Instant Chat & Daily Tasks | 25+ t/s |
| **🤖 AGENT** | Hermes-3-8B | Shell Execution & Tool-Use | 10-15 t/s |
| **💻 CODE** | Qwen-Coder-3B | Scripting, Debugging & Refactoring | 18+ t/s |
| **🧠 LOGIC** | DeepSeek-R1 | Complex Reasoning & Auditing | 22+ t/s |

---

## 💾 Context7: The Local Brain
Aether isn't just a chatbot; it has a **Persistent Memory Vault**.
- **Location**: `~/aether/knowledge/context7/`
- **Mechanism**: The **AGENT** tier uses a specialized `learn` tool to write technical insights, syntax rules, and examples into this vault.
- **Compatibility**: All memory is stored as Markdown, fully compatible with **Obsidian**.

---

## 📖 The Librarian
To ensure your Context7 brain doesn't get cluttered with "junk," Aether includes a dedicated **Librarian** (powered by the Logic tier). 
- **Deduplication**: Merges similar knowledge entries.
- **Audit**: Archives low-value or outdated info.
- **Standardization**: Ensures all learned notes follow a professional technical format.

---

## 📂 Project Structure
- `aether.sh`: The master UI and neural orchestrator.
- `agent/`: Python-based agent core with real-time tool execution.
- `skills/`: Specialized modules for Obsidian, Humanizing text, and more.
- `toolbox/`: A suite of local shell tools the AI can execute.
- `models/`: High-performance GGUF neural weights.

---

## 🏆 Why Aether?
In a world of subscription-locked, data-harvesting AI, Aether offers:
1. **Uncensored Intelligence**: No corporate guardrails on your own hardware.
2. **Infinite Context**: Your local memory vault grows with you, indefinitely.
3. **Zero Latency**: Instant response times, even in airplane mode.

---
<div align="center">
Aether-AI: Beyond the Clouds. Developed for the High-Performance ARM64 Ecosystem.
</div>
