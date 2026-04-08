#!/data/data/com.termux/files/usr/bin/bash

# Configuration
LOG_DIR="$HOME/.audit_logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/scan_$TIMESTAMP.log"
TARGET_NET="192.168.1.0/24" # Adjust to your local subnet

# Ensure log directory exists
mkdir -p "$LOG_DIR"

echo "--- XR20 SECURITY AUDIT START: $TIMESTAMP ---" > "$LOG_FILE"

# 1. Network Discovery (Nmap)
# Scans for live hosts and open ports 80, 443, 22
echo "[+] Scanning Network: $TARGET_NET" >> "$LOG_FILE"
nmap -sn "$TARGET_NET" | grep "Nmap scan report" >> "$LOG_FILE"

# 2. Local Process Audit
# Lists running processes to identify background anomalies
echo -e "\n[+] Local Process Audit:" >> "$LOG_FILE"
ps aux | head -n 20 >> "$LOG_FILE"

# 3. Connection Audit (Netstat)
# Identifies active outgoing connections
echo -e "\n[+] Active Connections:" >> "$LOG_FILE"
netstat -tunlp >> "$LOG_FILE"

# 4. Storage/Vault Integrity
# Check if your 'Termux-Vault' directory has been modified recently
echo -e "\n[+] Vault Integrity Check:" >> "$LOG_FILE"
find $HOME/Termux-Vault -mmin -60 >> "$LOG_FILE"

echo -e "\n--- AUDIT COMPLETE ---" >> "$LOG_FILE"

# Visual Feedback (Requires Termux:API)
termux-toast "Security Audit Complete: $TIMESTAMP"
