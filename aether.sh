#!/usr/bin/env bash
# Aether-AI v10.1: Studio Stability Edition

# --- PALETTE ---
ACCENT="#81a1c1"; DIM="#4c566a"; WHITE="#eceff4"
BIN="$HOME/llama.cpp/build/bin/llama-cli"
MODELS="$HOME/termux-ai-workspace/models"
THREADS=6

# --- MEMORY INJECTION ---
MEMORY=$(cat ~/termux-ai-workspace/knowledge/*.txt 2>/dev/null | tr '\n' ' ' | cut -c 1-300)
BASE_PROMPT="You are Aether. Knowledge: $MEMORY. User tools via bash."

# --- SYSTEM METRICS ---
BATT=$(termux-battery-status 2>/dev/null | grep percentage | cut -d: -f2 | tr -d ' ,%')
STR=$(df -h /data | awk 'NR==2 {print $4}')

clear
# VERTICAL CENTERING
ROWS=$(tput lines); VPAD=$(( (ROWS - 18) / 2 ))
for i in $(seq 1 $VPAD); do echo ""; done

# 1. LOGO (Precision Aligned)
echo -ne "\033[1;34m"
figlet -f small "   AETHER"
echo -e "\033[0;34m   NEURAL OPERATING INTERFACE // V 10.1\033[0m"
echo ""

# 2. STATUS BAR (Fixed Hyphen Syntax)
gum style --foreground "$ACCENT" --border rounded --border-foreground "$DIM" --padding "0 1" --width 36 \
  " PWR: ${BATT:-N/A}%  •  STR: $STR  •  MEM: OK "

# 3. INTERFACE
CHOICE=$(gum choose --cursor.foreground "$ACCENT" --header "      [ ACCESS NEURAL PATHWAY ]" \
	" ⚡ TURBO (3B / Instant) " \
	" 🤖 AGENT (8B / Tool-Use) " \
	" 🧠 LOGIC (9B / Reasoning) " \
	" 🎤 VOICE (Native TTS)    " \
	" ❌ DISCONNECT SESSION    ")

case "$CHOICE" in
    *"TURBO"*)
        $BIN -m "$MODELS/llama-3.2-3b.gguf" -cnv -t $THREADS --mmap -p "Aether-Turbo: $BASE_PROMPT" ;;
    *"AGENT"*)
        $BIN -m "$MODELS/hermes-3-8b.gguf" -cnv -t $THREADS --mmap -p "Aether-Agent: $BASE_PROMPT" ;;
    *"LOGIC"*)
        echo -e "\033[1;33m[!] High latency mode. Tools throttled.\033[0m"
        sleep 1
        $BIN -m "$MODELS/gemma-2-9b.gguf" -cnv -t $THREADS --mmap -p "Aether-Logic: $BASE_PROMPT" ;;
    *"VOICE"*)
        CMD=$(gum input --placeholder "Direct Voice Command...")
        RES=$($BIN -m "$MODELS/llama-3.2-3b.gguf" -t $THREADS -p "$CMD" -n 64 --quiet)
        echo -e "\nAether: $RES"
        termux-tts-speak "$RES"
        read -p "..." && ./aether.sh ;;
    *) exit 0 ;;
esac
