#!/usr/bin/env bash
# Aether-AI v12.1: Resilience Edition
ACCENT="#81a1c1"; RED="#ff5555"; DIM="#4c566a"; WHITE="#eceff4"
BIN="$HOME/llama.cpp/build/bin/llama-cli"
MODELS="$HOME/termux-ai-workspace/models"
THREADS=6

# --- HELPER: MODEL CHECKER ---
run_model() {
    if [ ! -f "$MODELS/$1" ]; then
        clear
        gum style --foreground "$RED" --border double --padding "1 2" "MODEL MISSING" "File: $1" "Please download this model to continue."
        echo -e "\nCopy/Paste this command to fix:\nwget -O $MODELS/$1 $2\n"
        read -p "Press Enter to exit..."
        return
    fi
    $BIN -m "$MODELS/$1" -cnv -t $THREADS --mmap -p "$3"
}

# --- METRICS ---
BATT=$(termux-battery-status 2>/dev/null | grep percentage | cut -d: -f2 | tr -d ' ,%')
STR=$(df -h /data | awk 'NR==2 {print $4}')

clear
# VERTICAL CENTERING
ROWS=$(tput lines); VPAD=$(( (ROWS - 18) / 2 ))
for i in $(seq 1 $VPAD); do echo ""; done

# LOGO
echo -ne "\033[1;34m"
figlet -f small "   AETHER"
echo -e "\033[0;34m   NEURAL INTERFACE SYSTEM // V 12.1\033[0m\n"

# STATUS BAR
gum style --foreground "$ACCENT" --border rounded --border-foreground "$DIM" --padding "0 1" --width 36 \
  " PWR: ${BATT:-0}%  •  STR: $STR  •  MEM: LOADED "

# MENU
CHOICE=$(gum choose --cursor.foreground "$ACCENT" --header "      [ SELECT NEURAL PATHWAY ]" \
	" ⚡ TURBO (3B / Instant) " \
	" 🤖 AGENT (8B / Tool-Use) " \
	" 🧠 LOGIC (9B / Reasoning) " \
	" ❌ DISCONNECT SESSION    ")

case "$CHOICE" in
    *"TURBO"*) run_model "llama-3.2-3b.gguf" "https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf" "You are Aether Turbo." ;;
    *"AGENT"*) run_model "hermes-3-8b.gguf" "https://huggingface.co/bartowski/Hermes-3-Llama-3.1-8B-GGUF/resolve/main/Hermes-3-Llama-3.1-8B-Q4_K_M.gguf" "You are Aether Agent." ;;
    *"LOGIC"*) run_model "gemma-2-9b.gguf" "https://huggingface.co/bartowski/gemma-2-9b-it-GGUF/resolve/main/gemma-2-9b-it-Q4_K_M.gguf" "You are Aether Logic." ;;
    *) exit 0 ;;
esac
