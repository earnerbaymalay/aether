# 🌌 Aether-AI: Neural Operating Interface (v12.0)

Welcome to Aether-AI. This is a complete, private, and offline artificial intelligence ecosystem that lives entirely on your Android device. Built natively for Termux and optimized for ARM64 architecture, Aether-AI turns your phone into a local AI control room.

---

## 📖 Table of Contents
1. [What is Aether-AI?](#what-is-aether-ai)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [How to Use Aether-AI](#how-to-use)
5. [Understanding the Tiers](#understanding-the-tiers)
6. [Your Knowledge Base (Memory)](#your-knowledge-base)
7. [Troubleshooting](#troubleshooting)

---

## 🧠 What is Aether-AI?
Aether-AI runs entirely on your device's hardware. It does not require Wi-Fi or cellular data, and it does not send your data to external servers. It uses a highly optimized C++ backend (`llama.cpp`) to run AI models smoothly on mobile processors.

You can use it to:
- Generate text, code, and ideas.
- Chat securely with a completely private assistant.
- Give the AI context about your life or projects by dropping text files into a folder.

---

## ⚙️ Prerequisites
Before installing, ensure you have the following from the Google Play Store, F-Droid, or Github:
1. **Termux:** The terminal emulator where Aether-AI lives.
2. **Termux:API:** An add-on that allows the AI to interact with your phone's hardware (like text-to-speech).

---

## 🚀 Installation

1. **Open Termux** on your device.
2. **Download the project** by typing (or pasting) this command and pressing Enter:
   ```bash
   git clone [https://github.com/earnerbaymalay/termux-ai-workspace](https://github.com/earnerbaymalay/termux-ai-workspace)

 * Navigate to the folder:
   cd termux-ai-workspace

 * Run the automated setup:
   chmod +x install.sh
./install.sh

   (This step downloads necessary tools and prepares the environment. It may take a few minutes.)
🕹️ How to Use Aether-AI
To launch the interface at any time, open Termux, go to the folder, and run the main script:
cd ~/termux-ai-workspace
./aether.sh

You will be greeted by a menu where you can select your desired "Neural Tier" or run a system benchmark. Use your on-screen keyboard arrows or touch to navigate the menu.
⚖️ Understanding the Tiers
Aether-AI uses different "models" (brains) depending on what you need.
| Tier | Model | Best For | Hardware Requirement |
|---|---|---|---|
| ⚡ Turbo | Llama-3.2 (3B) | Fast chats, everyday tasks, battery saving. | Highly Recommended for daily use. |
| 🤖 Agent | Hermes-3 (8B) | Coding, logic, running terminal commands. | Requires more RAM; slower generation. |
| 🧠 Logic | Gemma-2 (9B) | Complex reasoning and deep problem solving. | Heavy processing; expect slower speeds. |
📚 Your Knowledge Base (Memory)
You can teach Aether-AI about yourself, your projects, or your business.
 * Create a simple text file (.txt).
 * Write down the information you want the AI to remember.
 * Save or move that file into the ~/termux-ai-workspace/knowledge/ folder.
Next time you launch Aether-AI, it will automatically read those files and use them as context for your conversations.
🛠️ Troubleshooting & Hardware
 * App is slow or crashing: Your device might be running out of memory. Stick to the ⚡ Turbo tier.
 * Commands aren't working: Ensure you have updated Termux by running pkg update -y && pkg upgrade -y.
 * Test your hardware: Select the BENCHMARK option in the main menu to see how fast your device processes tokens.
(Developed for the ARM64 Ecosystem. Version 12.0)
