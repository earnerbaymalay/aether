#!/usr/bin/env bash
# Aether-AI v16.0: The Integrated Suite
ACCENT="#81a1c1"; DIM="#4c566a"; WHITE="#eceff4"; RED="#ff5555"
BIN="$HOME/llama.cpp/build/bin/llama-cli"
MODELS="$HOME/termux-ai-workspace/models"
THREADS=6

# --- WIDGET / HTTP SHORTCUT BRIDGE ---
if [ ! -z "$1" ]; then
    $BIN -m "$MODELS/llama-3.2-3b.gguf" -p "User: $1. Assistant:" -n 128 --quiet
    exit 0
fi

# --- INTERNAL HELPERS ---
launch_ai() {
    if [ ! -f "$MODELS/$1" ]; then
        clear
        gum style --foreground "$RED" --border double --padding "1 2" "MODEL MISSING" "File: $1"
        echo -e "\nRun this to fix:\nwget -O $MODELS/$1 $2\n"
        read -p "Press Enter..." && return
    fi
    $BIN -m "$MODELS/$1" -cnv -t $THREADS --mmap -p "$3"
}

# --- UI LOGIC ---
BATT=$(termux-battery-status 2>/dev/null | grep percentage | cut -d: -f2 | tr -d ' ,%')
STR=$(df -h /data | awk 'NR==2 {print $4}')
clear
ROWS=$(tput lines); VPAD=$(( (ROWS - 18) / 2 ))
for i in $(seq 1 $VPAD); do echo ""; done

echo -ne "\033[1;34m"
figlet -f small "   AETHER"
echo -e "\033[0;34m   NEURAL OPERATING INTERFACE // V 16.0\033[0m\n"

gum style --foreground "$ACCENT" --border rounded --border-foreground "$DIM" --padding "0 1" --width 36 \
  " PWR: ${BATT:-0}%  •  STR: $STR  •  WIDGET: ON "

CHOICE=$(gum choose --cursor.foreground "$ACCENT" --header "      [ SELECT NEURAL PATHWAY ]" \
	" ⚡ TURBO   (Llama-3B / Instant) " \
	" 🤖 AGENT   (Hermes-8B / Tools)   " \
	" 🧠 LOGIC   (DeepSeek / Reason)   " \
	" 💻 CODE    (Qwen / Development)  " \
	" 🛠️  UTILITY (System Toolbox)      " \
	" ❌ DISCONNECT SESSION            ")

case "$CHOICE" in
    *"TURBO"*) launch_ai "llama-3.2-3b.gguf" "https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf" "You are Aether Turbo." ;;
    *"AGENT"*) launch_ai "hermes-3-8b.gguf" "https://huggingface.co/bartowski/Hermes-3-Llama-3.1-8B-GGUF/resolve/main/Hermes-3-Llama-3.1-8B-Q4_K_M.gguf" "You are Aether Agent." ;;
    *"LOGIC"*) launch_ai "deepseek-r1-1.5b.gguf" "https://huggingface.co/unsloth/DeepSeek-R1-Distill-Qwen-1.5B-GGUF/resolve/main/DeepSeek-R1-Distill-Qwen-1.5B-Q4_K_M.gguf" "You are Aether Logic." ;;
    *"CODE"*)  launch_ai "qwen-coder-3b.gguf" "https://huggingface.co/bartowski/Qwen2.5-Coder-3B-Instruct-GGUF/resolve/main/Qwen2.5-Coder-3B-Instruct-Q4_K_M.gguf" "You are Aether Code." ;;
    *"UTILITY"*)
        T=$(gum choose "🧹 Cleanup" "📡 Network" "🔙 Back")
        [[ "$T" == *"Cleanup"* ]] && { pkg clean -y; rm -rf ~/.cache/* 2>/dev/null; gum toast "System Purged."; }
        ./aether.sh ;;
    *) exit 0 ;;
esac
launch_ai() {
    if [ ! -f "$MODELS/$1" ]; then
        clear
        gum style --foreground "$RED" --border double "MODEL MISSING: $1"
        echo -e "\nRun: wget -O $MODELS/$1 $2\n"
        read -p "Press Enter..." && return
    fi
    $BIN -m "$MODELS/$1" -cnv -t $THREADS --mmap -p "$3"
}
BATT=$(termux-battery-status 2>/dev/null | grep percentage | cut -d: -f2 | tr -d ' ,%')
STR=$(df -h /data | awk 'NR==2 {print $4}')
clear
ROWS=$(tput lines); VPAD=$(( (ROWS - 18) / 2 ))
for i in $(seq 1 $VPAD); do echo ""; done
echo -ne "\033[1;34m"
figlet -f small "   AETHER"
echo -e "\033[0;34m   NEURAL INTERFACE SYSTEM // V 16.0\033[0m\n"
gum style --foreground "$ACCENT" --border rounded --border-foreground "$DIM" --padding "0 1" --width 36 \
  " PWR: ${BATT:-0}%  •  STR: $STR  •  WIDGET: ON "
CHOICE=$(gum choose --cursor.foreground "$ACCENT" --header "      [ SELECT NEURAL PATH ]" \
	" ⚡ TURBO   (Llama-3B) " " 🤖 AGENT   (Hermes-8B) " \
	" 🧠 LOGIC   (DeepSeek) " " 💻 CODE    (Qwen-3B)   " \
	" 🛠️  UTILITY (Cleanup)  " " ❌ DISCONNECT SESSION ")
case "$CHOICE" in
    *"TURBO"*) launch_ai "llama-3.2-3b.gguf" "https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf" "You are Aether Turbo." ;;
    *"AGENT"*) launch_ai "hermes-3-8b.gguf" "https://huggingface.co/bartowski/Hermes-3-Llama-3.1-8B-GGUF/resolve/main/Hermes-3-Llama-3.1-8B-Q4_K_M.gguf" "You are Aether Agent." ;;
    *"LOGIC"*) launch_ai "deepseek-r1-1.5b.gguf" "https://huggingface.co/unsloth/DeepSeek-R1-Distill-Qwen-1.5B-GGUF/resolve/main/DeepSeek-R1-Distill-Qwen-1.5B-Q4_K_M.gguf" "You are Aether Logic." ;;
    *"CODE"*)  launch_ai "qwen-coder-3b.gguf" "https://huggingface.co/bartowski/Qwen2.5-Coder-3B-Instruct-GGUF/resolve/main/Qwen2.5-Coder-3B-Instruct-Q4_K_M.gguf" "You are Aether Code." ;;
    *"UTILITY"*) pkg clean -y; rm -rf ~/.cache/* 2>/dev/null; gum toast "System Purged."; ./aether.sh ;;
    *) exit 0 ;;
esac
