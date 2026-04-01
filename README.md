# 🌌 NEXUS: Autonomous Mobile AI Workspace
**Architect:** Deadly Sing | **Version:** 2.2.0 | **Arch:** AArch64 (Nokia XR20)

Nexus is a terminal-native AI laboratory bridging local LLM inference with automated forensics and productivity modules. Designed for offline data sovereignty.

---

## 🛠️ Power User Matrix

| Command | Action | Implementation |
| :--- | :--- | :--- |
| \`nexus ask\` | **Inference** | Direct prompt to Dolphin-Phi. |
| \`nexus chat\` | **Session** | Stateful, multi-turn conversation. |
| \`nexus remember\` | **Persistence** | Adds facts to the Knowledge Base (\`brain.md\`). |
| \`nexus summarize\` | **Context** | Tokenizes local files for AI-driven summaries. |
| \`nexus start\` | **Core** | Boots the background API Hub. |
| \`nexus health\` | **Diagnostic** | Verifies Ecosystem health. |

---

## 🧠 Memory & Context
Nexus maintains an editable knowledge base at \`~/termux-ai-workspace/core/brain.md\`.
* **Add Context:** \`nexus remember "Working on CypherChat cryptography."\`
* **Summarize Logs:** \`nexus summarize logs/nmap_scan.txt\`

## 🩺 Troubleshooting
* **"Hub Offline":** Run \`nexus start\`.
* **"File not found":** Ensure you are using absolute paths or are in the workspace root.
* **Slow Response:** Clear background RAM; mobile CPUs throttle under load.

---
*No cloud telemetry. All inference is 100% local.*
