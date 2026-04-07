# 🌌 A E T H E R — U S A G E
### *The Definitive Guide to Your Neural Operating Interface*

Welcome to the **Aether** ecosystem. This document provides a detailed walkthrough of the interface, its neural tiers, and advanced orchestration features.

---

## 🛠 Core Commands
Access Aether from anywhere in your Termux terminal.

- **`ai`**: The global shortcut to launch the Aether Interface.
- **`./aether.sh`**: Manual launch from the project directory.
- **`./bench.sh`**: Execute a hardware-level performance profile.

---

## 🧠 The Neural Tier System
Aether routes requests to specialized models based on your needs. Select the right pathway for maximum efficiency:

### ⚡ TURBO (Llama-3.2-3B)
*Best for: Daily tasks, instant queries, brainstorming.*
- **Performance**: Optimized for 20+ tokens per second.
- **Memory**: Extremely lightweight (~2GB RAM).
- **Usage**: General-purpose assistant for quick answers.

### 🤖 AGENT (Hermes-3-8B)
*Best for: File manipulation, coding, shell automation.*
- **Performance**: Balanced for reasoning and speed.
- **Persistence**: Directly writes to your **Context7** vault.
- **Usage**: Ask it to "Create a Python script to..." or "Analyze my project structure."

### 🧠 LOGIC (DeepSeek-R1)
*Best for: Complex debugging, architectural planning, auditing.*
- **Performance**: High-precision reasoning (Distilled R1).
- **Specialty**: Step-by-step logic and mathematical verification.
- **Usage**: "Audit this security script" or "Plan a multi-layer microservice architecture."

### 💻 CODE (Qwen-Coder-3B)
*Best for: Syntax-heavy tasks and large-scale refactoring.*
- **Performance**: Native understanding of 90+ programming languages.
- **Usage**: "Refactor this React component for performance" or "Explain this Go logic."

---

## 💾 Context7: Persistent Local Memory
Unlike standard chatbots, Aether **learns** from you.

- **Vault Location**: `~/aether/knowledge/context7/`
- **Mechanism**: The **AGENT** uses a specialized `learn` tool. When you provide a technical breakthrough or a custom syntax rule, the Agent archives it as a Markdown file.
- **Obsidian Sync**: Point your Obsidian vault to the `knowledge/` directory to visualize your neural growth.

---

## 📖 The Librarian: Vault Maintenance
To prevent "hallucination bloat," the Librarian script runs periodic audits.

1. Launch `ai` -> `🛠 TOOLS` -> `📖 LIBRARIAN`.
2. The Logic tier will scan your Context7 notes.
3. It will merge duplicates, archive outdated info, and format notes for better retrieval.

---

## 🛡️ Sentinel Hub: Security & Privacy
Aether includes **Edge Sentinel** integration for local file auditing.
- **Scan**: Launch `ai` -> `🛡️ SECURITY`.
- **Purpose**: Audits your local directory for secrets (`.env`, `.git/config`) before they can be leaked or processed by external scripts.

---

## 🔧 Maintenance & Updates
Keep your neural interface at peak performance.

- **`./install.sh`**: Run again to update dependencies or rebuild the C++ engine.
- **`ai` -> `🛠 TOOLS` -> `🧹 PURGE`**: Clears the current session history to reclaim context window space.

---
<div align="center">
*Aether-AI is a high-performance, local-first system. No internet is required after initial model download.*
</div>
