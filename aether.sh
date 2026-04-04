#!/usr/bin/env bash
# Aether-AI v11.0: Professional Suite
ACCENT="#81a1c1"; DIM="#4c566a"; WHITE="#eceff4"; LOGS="$HOME/.aether/sessions/last_chat.txt"
BIN="$HOME/llama.cpp/build/bin/llama-cli"
MODELS="$HOME/termux-ai-workspace/models"
THREADS=6

# --- SESSION LOGIC ---
RESUME_PROMPT=""
if [ -f "$LOGS" ]; then
    RESUME_PROMPT=$(tail -c 500 "$LOGS" | tr '\n' ' ')
fi

clear
ROWS=$(tput lines); VPAD=$(( (ROWS - 20) / 2 ))
for i in $(seq 1 $VPAD); do echo ""; done

echo -ne "\033[1;34m"
figlet -f small "   AETHER"
echo -e "\033[0;34m   NEURAL OPERATING INTERFACE // V 11.0\033[0m"
echo ""

# STATUS BAR
BATT=$(termux-battery-status 2>/dev/null | grep percentage | cut -d: -f2 | tr -d ' ,%')
gum style --foreground "$ACCENT" --border rounded --border-foreground "$DIM" --padding "0 1" --width 36 \
  " PWR: ${BATT:-0}%  •  NODE: NATIVE  •  MEM: OK "

# MENU
CHOICE=$(gum choose --cursor.foreground "$ACCENT" --header "      [ SELECT NEURAL PATHWAY ]" \
	" ⚡ TURBO (3B / Instant) " \
	" 🤖 AGENT (8B / Tool-Use) " \
	" 🧠 LOGIC (9B / Reasoning) " \
	" 💻 DEV   (7B / Coding)    " \
	" 📊 BENCHMARK HARDWARE     " \
	" ❌ DISCONNECT SESSION    ")

case "$CHOICE" in
    *"TURBO"*) $BIN -m "$MODELS/llama-3.2-3b.gguf" -cnv -t $THREADS --mmap ;;
    *"AGENT"*) $BIN -m "$MODELS/hermes-3-8b.gguf" -cnv -t $THREADS --mmap -p "You are Aether. Last context: $RESUME_PROMPT" --log-file "$LOGS" ;;
    *"LOGIC"*) $BIN -m "$MODELS/gemma-2-9b.gguf" -cnv -t $THREADS --mmap ;;
    *"DEV"*)
        # Mistral-7B check
        if [ ! -f "$MODELS/mistral-7b.gguf" ]; then
            gum style --foreground "#ff5555" "Mistral 7B not found. Downloading..."
            wget -O "$MODELS/mistral-7b.gguf" https://huggingface.co/bartowski/Mistral-7B-Instruct-v0.3-GGUF/resolve/main/Mistral-7B-Instruct-v0.3-Q4_K_M.gguf
        fi
        $BIN -m "$MODELS/mistral-7b.gguf" -cnv -t $THREADS --mmap -p "You are Aether-Dev. Expert coder." ;;
    *"BENCHMARK"*) ./bench.sh ;;
    *) exit 0 ;;
esac
