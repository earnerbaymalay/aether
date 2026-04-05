#!/usr/bin/env bash
# Aether-AI v12.2: Silicon Optimized (2025 Edition)

# --- COLORS & CONFIG ---
ACCENT="#81a1c1"; DIM="#4c566a"; WHITE="#eceff4"; GOLD="#f1fa8c"
BIN="$HOME/llama.cpp/build/bin/llama-cli"
MODELS="$HOME/termux-ai-workspace/models"
THREADS=6

# --- METRICS ---
BATT=$(termux-battery-status 2>/dev/null | grep percentage | cut -d: -f2 | tr -d ' ,%')
STR=$(df -h /data | awk 'NR==2 {print $4}')

clear
ROWS=$(tput lines); VPAD=$(( (ROWS - 18) / 2 ))
for i in $(seq 1 $VPAD); do echo ""; done

# LOGO
echo -ne "\033[1;34m"
figlet -f small "   AETHER"
echo -e "\033[0;34m   NEURAL INTERFACE SYSTEM // V 12.2\033[0m\n"

# STATUS BAR
gum style --foreground "$ACCENT" --border rounded --border-foreground "$DIM" --padding "0 1" --width 36 \
  " PWR: ${BATT:-0}%  •  STR: $STR  •  CORE: ARM64 "

# --- 4-TIER MODEL HUB ---
CHOICE=$(gum choose --cursor.foreground "$ACCENT" --header "      [ SELECT NEURAL PATHWAY ]" \
	" ⚡ TURBO (Llama-3.2-3B) " \
	" 🤖 AGENT (Hermes-3-8B)  " \
	" 💻 CODE  (Qwen-Coder-3B) " \
	" 🧠 LOGIC (DeepSeek-R1)   " \
	" ❌ DISCONNECT SESSION    ")

case "$CHOICE" in
    *"TURBO"*) $BIN -m "$MODELS/llama-3.2-3b.gguf" -cnv -t $THREADS --mmap ;;
    *"AGENT"*) $BIN -m "$MODELS/hermes-3-8b.gguf" -cnv -t $THREADS --mmap -p "You are Aether-Agent. Expert in Termux tools." ;;
    *"CODE"*)  $BIN -m "$MODELS/qwen-coder-3b.gguf" -cnv -t $THREADS --mmap -p "You are Aether-Dev. Expert coder." ;;
    *"LOGIC"*) $BIN -m "$MODELS/deepseek-r1-1.5b.gguf" -cnv -t $THREADS --mmap -p "You are Aether-Logic. Think step by step." ;;
    *) exit 0 ;;
esac
