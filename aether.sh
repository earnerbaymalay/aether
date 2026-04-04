#!/usr/bin/env bash
# Aether-AI v10.0: Compact Studio Edition

# --- PALETTE ---
ACCENT="#81a1c1"; DIM="#4c566a"; WHITE="#eceff4"; GOLD="#f1fa8c"
BIN="$HOME/llama.cpp/build/bin/llama-cli"
MODELS="$HOME/termux-ai-workspace/models"
THREADS=6

# --- MEMORY SCAN ---
MEMORY=$(cat ~/termux-ai-workspace/knowledge/*.txt 2>/dev/null | tr '\n' ' ' | cut -c 1-500)
BASE_PROMPT="You are Aether. Knowledge: $MEMORY. User tools via bash blocks."

# --- METRICS (Compact Logic) ---
BATT=$(termux-battery-status 2>/dev/null | grep percentage | cut -d: -f2 | tr -d ' ,%')
[ -z "$BATT" ] && BATT="--"
STR=$(df -h /data | awk 'NR==2 {print $4}')

clear
# DYNAMIC CENTERING
ROWS=$(tput lines); VPAD=$(( (ROWS - 18) / 2 ))
for i in $(seq 1 $VPAD); do echo ""; done

# 1. STABLE LOGO (Manual Indent for Precision)
echo -e "\033[1;34m"
figlet -f small "   AETHER"
echo -e "\033[0;34m   NEURAL OPERATING INTERFACE // V 10.0\033[0m"
echo ""

# 2. COMPACT STATUS BAR (Fixed width to prevent wrapping)
gum style --foreground "$ACCENT" --border rounded --border.foreground "$DIM" --padding "0 1" --width 38 \
  " PWR: $BATT%  •  STR: $STR  •  MEM: ACTIVE "

# 3. THE 3-TIER INTERFACE
CHOICE=$(gum choose --cursor.foreground "$ACCENT" --header "      [ ACCESS NEURAL PATHWAY ]" \
	" ⚡ TURBO MODE (Fast / 3B) " \
	" 🤖 AGENT MODE (Tools / 8B) " \
	" 🧠 LOGIC MODE (Expert / 9B) " \
	" 🎤 VOICE INTERFACE (TTS)    " \
	" ❌ DISCONNECT SESSION       ")

case "$CHOICE" in
    *"TURBO"*)
        $BIN -m "$MODELS/llama-3.2-3b.gguf" -cnv -t $THREADS --mmap -p "You are Aether-Turbo. $BASE_PROMPT" ;;
    *"AGENT"*)
        $BIN -m "$MODELS/hermes-3-8b.gguf" -cnv -t $THREADS --mmap -p "You are Aether-Agent. $BASE_PROMPT" ;;
    *"LOGIC"*)
        echo -e "\033[1;33m[!] Logic mode is heavy. Tool-use may be slow.\033[0m"
        sleep 1
        $BIN -m "$MODELS/gemma-2-9b.gguf" -cnv -t $THREADS --mmap -p "You are Aether-Logic. $BASE_PROMPT" ;;
    *"VOICE"*)
        INPUT=$(gum input --placeholder "Direct command...")
        RESPONSE=$($BIN -m "$MODELS/llama-3.2-3b.gguf" -t $THREADS -p "$INPUT" -n 64 --quiet)
        echo -e "\nAether: $RESPONSE"
        termux-tts-speak "$RESPONSE"
        read -p "..." && ./aether.sh ;;
    *) exit 0 ;;
esac
