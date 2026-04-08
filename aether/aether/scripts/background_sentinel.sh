#!/usr/bin/env bash
# 🌌 Aether-AI Background Sentinel // V 1.0
# Passive monitoring agent for proactive system insights.

ACCENT="#81a1c1"; SUC="#50fa7b"; ERR="#ff5555"
LOG_DIR="$HOME/.aether/sessions"
SENTINEL_LOG="$LOG_DIR/sentinel_passive.log"

echo -e "\033[1;34m[*] Activating Aether Background Sentinel...\033[0m"

# Main Passive Loop
while true; do
    # Check for battery level
    BATT=$(termux-battery-status 2>/dev/null | grep percentage | cut -d: -f2 | tr -d ' ,%')
    if [ -n "$BATT" ] && [ "$BATT" -lt 15 ]; then
        echo "$(date): [!] Critical Power: $BATT%" >> "$SENTINEL_LOG"
        gum toast --background "$ERR" "Aether Power Low: $BATT%. Neural stability affected."
    fi

    # Check for storage space
    STR=$(df -h /data | awk 'NR==2 {print $4}' | tr -d 'G')
    if (( $(echo "$STR < 1.0" | bc -l) )); then
        echo "$(date): [!] Low Storage: $STR GB" >> "$SENTINEL_LOG"
        gum toast --background "$ERR" "Aether Vault Storage Critical: $STR GB remaining."
    fi

    # Check for new AetherVault entries (Knowledge growth)
    NEW_NOTES=$(find ~/aether/knowledge/aethervault/ -mmin -10 -name "*.md" | wc -l)
    if [ "$NEW_NOTES" -gt 0 ]; then
        echo "$(date): [+] AetherVault Growth: $NEW_NOTES new entries archived." >> "$SENTINEL_LOG"
        gum toast --background "$SUC" "AetherVault evolved: $NEW_NOTES new knowledge entries."
    fi

    sleep 300 # Run every 5 minutes
done
