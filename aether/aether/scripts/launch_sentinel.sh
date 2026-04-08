#!/usr/bin/env bash
# 🛡️ Edge-Sentinel Launcher // Aether-AI Security Module
# Manages the local telemetry backend and dashboard access.

# --- Configuration ---
DIR="$HOME/aether"
SENTINEL_DIR="$HOME/edge-sentinel"
PORT=8000
ACCENT="#81a1c1"; SUC="#50fa7b"; ERR="#ff5555"

# --- Backend Management ---
check_backend() {
    if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
        return 0 # Running
    else
        return 1 # Stopped
    fi
}

start_backend() {
    echo -e "\033[1;34m[*] Initializing Sentinel Security Engine...\033[0m"
    cd "$SENTINEL_DIR/backend"
    # Start FastAPI in background
    python3 main.py > "$DIR/.aether/sessions/sentinel.log" 2>&1 &
    sleep 3
    if check_backend; then
        echo -e "\033[1;32m[+] Sentinel Backend Online (Port $PORT)\033[0m"
    else
        echo -e "\033[1;31m[!] Failed to start backend. Check edge-sentinel/backend/main.py\033[0m"
    fi
}

# --- Main Entry ---
clear
gum style --foreground "$ACCENT" --border double --padding "1" "EDGE-SENTINEL SECURITY HUB"

if ! check_backend; then
    gum confirm "Sentinel backend is offline. Start now?" && start_backend
else
    echo -e "\033[1;32m[✓] Security Engine is already active.\033[0m"
fi

echo -e "\n\033[1mDashboard URL:\033[0m http://localhost:$PORT"
echo -e "\033[1mLog File:\033[0m $DIR/.aether/sessions/sentinel.log"

ACTION=$(gum choose " 🌐 OPEN DASHBOARD (Lynx) " " 📜 VIEW LOGS " " 🛑 STOP BACKEND " " 🔙 BACK ")

case "$ACTION" in
    *"OPEN"*) lynx "http://localhost:$PORT" ;;
    *"LOGS"*) gum pager < "$DIR/.aether/sessions/sentinel.log" ;;
    *"STOP"*) fuser -k $PORT/tcp && gum toast "Sentinel Stopped." ;;
    *) exit 0 ;;
esac
