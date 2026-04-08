#!/usr/bin/env bash
# 🌌 Aether-AI Debug Console // V 1.0
# Real-time monitoring and self-healing for the Neural Interface.

ACCENT="#81a1c1"; RED="#ff5555"; SUC="#50fa7b"
LOG_DIR="$HOME/.aether/sessions"
AETHER_LOG="$LOG_DIR/last_session.log"
SENTINEL_LOG="$LOG_DIR/sentinel.log"

header() {
    clear
    figlet -f small "  DEBUG" | gum style --foreground "$RED"
    echo -e "   \033[1;30mNEURAL INTERFACE // MONITORING CONSOLE\033[0m\n"
}

check_errors() {
    if grep -Eiq "error|fail|oom|panic" "$AETHER_LOG" 2>/dev/null; then
        echo -e "\033[1;31m[!] Critical Error Detected in Aether Session.\033[0m"
        gum confirm "Initiate Self-Healing (Reset Session)?" && {
            rm -f "$AETHER_LOG"
            gum toast "Neural State Reset. Memory Flushed."
        }
    else
        echo -e "\033[1;32m[✓] Neural Pathways Healthy.\033[0m"
    fi
}

header
check_errors

echo -e "\n\033[1;34m[ MONITORING CHANNELS ]\033[0m"
CHANNEL=$(gum choose " 🌌 AETHER (Main Session) " " 🛡️ SENTINEL (Security Hub) " " ⚙️ SYSTEM (Termux Logs) " " 🔙 BACK ")

case "$CHANNEL" in
    *"AETHER"*) tail -f "$AETHER_LOG" | gum pager ;;
    *"SENTINEL"*) tail -f "$SENTINEL_LOG" | gum pager ;;
    *"SYSTEM"*) logcat -d | tail -n 50 | gum pager ;;
    *) exit 0 ;;
esac
