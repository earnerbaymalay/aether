# 🌌 Termux AI Workspace (Nexus Hub)
**Author:** KHEMM
**Status:** 🟢 Production | **Focus:** Local AI SIEM & Telemetry
**Hardware:** Mobile-Optimized (AArch64)

## 🏗️ Architecture Overview
The Nexus Hub is a localized Security Information and Event Management (SIEM) platform. It utilizes a microservices architecture to ingest telemetry from peripheral security modules and process it through an uncensored, on-device Large Language Model (Dolphin-phi) for threat assessment.

### 🧠 The Engine
* **API Routing:** Python / Flask (Localhost Port 5000)
* **Inference Engine:** Ollama running `dolphin-phi:latest` (2.7B Parameters)
* **Security:** Token-based API Authentication (`X-Nexus-Token`)

### 🛡️ The Modules (Spokes)
1. **Mobile-Recon:** Executes aggressive Nmap scans and pipes raw output to the Hub to identify vulnerable network topologies.
2. **Sentinel-AI:** Ingests system authorization logs (e.g., `auth.log`), filters for anomalies, and pipes them to the Hub to detect brute-force attacks and unauthorized access.

## 🚀 Usage (The `nexus` CLI)
The entire ecosystem is controlled via a custom command-line interface.

```bash
# 1. Boot the Hub API in the background
nexus start

# 2. Run an

cat << 'EOF' > ~/termux-ai-workspace/README.md
# 🌌 Termux AI Workspace (Nexus Hub)
**Author:** KHEMM
**Status:** 🟢 Production | **Focus:** Local AI SIEM & Telemetry
**Hardware:** Mobile-Optimized (AArch64)

## 🏗️ Architecture Overview
The Nexus Hub is a localized Security Information and Event Management (SIEM) platform. It utilizes a microservices architecture to ingest telemetry from peripheral security modules and process it through an uncensored, on-device Large Language Model (Dolphin-phi) for threat assessment.

### 🧠 The Engine
* **API Routing:** Python / Flask (Localhost Port 5000)
* **Inference Engine:** Ollama running `dolphin-phi:latest` (2.7B Parameters)
* **Security:** Token-based API Authentication (`X-Nexus-Token`)

### 🛡️ The Modules (Spokes)
1. **Mobile-Recon:** Executes aggressive Nmap scans and pipes raw output to the Hub to identify vulnerable network topologies.
2. **Sentinel-AI:** Ingests system logs, filters for anomalies, and pipes them to the Hub to detect brute-force attacks.

## 🚀 Usage (The CLI)
The entire ecosystem is controlled via a custom command-line interface:

    # 1. Boot the Hub API in the background
    nexus start

    # 2. Run an AI-driven network scan
    nexus recon -t 192.168.1.1

    # 3. Analyze a system log for threats
    nexus sentinel -t /path/to/auth.log

## 🔒 Security Philosophy
**Data Sovereignty:** All inference stays on-device to prevent data exfiltration.
