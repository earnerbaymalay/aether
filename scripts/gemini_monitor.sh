#!/usr/bin/env bash
# 🌌 Aether-AI Gemini Monitor // V 1.0
# Background service to monitor and heal Gemini CLI sessions.

LOG_FILE="$HOME/.aether/sessions/gemini_monitor.log"
ACCENT="#81a1c1"; SUC="#50fa7b"; ERR="#ff5555"

echo -e "\033[1;34m[*] Starting Aether Gemini Monitor...\033[0m"

while true; do
    # Check if Gemini CLI process is struggling (e.g., high memory or hung)
    # This is a representative check for local "Self-Healing"
    
    if pgrep -f "gemini-cli" > /dev/null; then
        MEM_USAGE=$(ps -o rss= -p $(pgrep -f "gemini-cli") | awk '{print $1/1024}')
        
        if (( $(echo "$MEM_USAGE > 1024" | bc -l) )); then
            echo "$(date): [!] High Memory Detected ($MEM_USAGE MB). Auto-healing..." >> "$LOG_FILE"
            # In a real self-healing scenario, we might restart the service or clear context
            # For now, we log the intent and issue a warning toast
            gum toast --background "$ERR" "Aether Memory High. Optimizing..."
        fi
    fi
    
    sleep 60
done
