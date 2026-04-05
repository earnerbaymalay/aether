#!/usr/bin/env bash
# Aether-AI v12.0: Neural Operating Interface (Stable)
ACCENT="#81a1c1"; DIM="#4c566a"; WHITE="#eceff4"
BIN="$HOME/llama.cpp/build/bin/llama-cli"
MODELS="$HOME/termux-ai-workspace/models"
THREADS=6

# --- LOCAL MEMORY (RAG) ---
KNOWLEDGE=$(cat ~/termux-ai-workspace/knowledge/*.txt 2>/dev/null | tr '\n' ' ' | cut -c 1-500)
BASE_PROMPT="You are Aether. Phone: Nokia ARM64. Local Knowledge: $KNOWLEDGE. Session log active."

# --- SYSTEM METRICS ---
BATT=$(termux-battery-status 2>/dev/null | grep percentage | cut -d: -f2 | tr -d ' ,%')
STR=$(df -h /data | awk 'NR==2 {print $4}')

clear
ROWS=$(tput lines); VPAD=$(( (ROWS - 18) / 2 ))
for i in $(seq 1 $VPAD); do echo ""; done

# LOGO
echo -ne "\033[1;34m"
figlet -f small "   AETHER"
echo -e "\033[0;34m   NEURAL INTERFACE SYSTEM // V 12.0\033[0m\n"

# STATUS BAR
gum style --foreground "$ACCENT" --border rounded --border-foreground "$DIM" --padding "0 1" --width 36 \
  " PWR: ${BATT:-0}%  •  STR: $STR  •  MEM: LOADED "

# 4-TIER INTERFACE
CHOICE=$(gum choose --cursor.foreground "$ACCENT" --header "      [ SELECT NEURAL PATHWAY ]" \
	" ⚡ TURBO (3B / Instant) " \
	" 🤖 AGENT (8B / Tool-Use) " \
	" 💻 DEV   (7B / Coding)    " \
	" 🧠 LOGIC (9B / Reasoning) " \
	" ❌ DISCONNECT SESSION    ")

case "$CHOICE" in
    *"TURBO"*) $BIN -m "$MODELS/llama-3.2-3b.gguf" -cnv -t $THREADS --mmap -p "$BASE_PROMPT" ;;
    *"AGENT"*) $BIN -m "$MODELS/hermes-3-8b.gguf" -cnv -t $THREADS --mmap -p "$BASE_PROMPT" ;;
    *"DEV"*)   $BIN -m "$MODELS/mistral-7b.gguf" -cnv -t $THREADS --mmap -p "Aether-Dev Expert: $BASE_PROMPT" ;;
    *"LOGIC"*) $BIN -m "$MODELS/gemma-2-9b.gguf" -cnv -t $THREADS --mmap -p "$BASE_PROMPT" ;;
    *) exit 0 ;;
esac
