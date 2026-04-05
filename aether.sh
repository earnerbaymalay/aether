#!/usr/bin/env bash
# Aether-AI v14.0: Multitool Edition

# --- CONFIG ---
ACCENT="#81a1c1"; DIM="#4c566a"; WHITE="#eceff4"; GOLD="#f1fa8c"
BIN="$HOME/llama.cpp/build/bin/llama-cli"
MODELS="$HOME/termux-ai-workspace/models"
THREADS=6

# --- AUTO-INSTALLER WIZARD ---
if [ ! -f "$BIN" ]; then
    clear
    gum style --border double --margin "1" --padding "1 2" --border-foreground "$ACCENT" "🌌 AETHER-AI: INITIALIZATION" "Engine not found. Start setup?"
    gum confirm && ./install.sh || exit 1
fi

# --- METRICS ---
BATT=$(termux-battery-status 2>/dev/null | grep percentage | cut -d: -f2 | tr -d ' ,%')
STR=$(df -h /data | awk 'NR==2 {print $4}')

clear
ROWS=$(tput lines); VPAD=$(( (ROWS - 20) / 2 ))
for i in $(seq 1 $VPAD); do echo ""; done

# LOGO
echo -ne "\033[1;34m"
figlet -f small "   AETHER"
echo -e "\033[0;34m   NEURAL OPERATING INTERFACE // V 14.0\033[0m\n"

gum style --foreground "$ACCENT" --border rounded --border-foreground "$DIM" --padding "0 1" --width 38 \
  " PWR: ${BATT:-0}%  •  STR: $STR  •  TOOLS: READY "

# --- MAIN HUB ---
CHOICE=$(gum choose --cursor.foreground "$ACCENT" --header "      [ SELECT NEURAL PATHWAY ]" \
	" 🤖 AGENT   (Hermes / Shell Tools) " \
	" 🧠 LOGIC   (DeepSeek / Reasoning) " \
	" 💻 CODE    (Qwen / Development)   " \
	" 🛠️  TOOLBOX (System Utilities)     " \
	" ❌ DISCONNECT SESSION             ")

case "$CHOICE" in
    *"AGENT"*) $BIN -m "$MODELS/hermes-3-8b.gguf" -cnv -t $THREADS --mmap -p "You are Aether-Agent. Control Termux." ;;
    *"LOGIC"*) $BIN -m "$MODELS/deepseek-r1-1.5b.gguf" -cnv -t $THREADS --mmap ;;
    *"CODE"*)  $BIN -m "$MODELS/qwen-coder-3b.gguf" -cnv -t $THREADS --mmap ;;
    *"TOOLBOX"*)
        TOOL=$(gum choose --header "UTILITY TOOLBOX" "📡 Network Scan" "📂 Project Scaffold" "🧹 System Cleanup" "🔙 Back")
        case "$TOOL" in
            *"Network"*) 
                TARGET=$(gum input --placeholder "IP or Domain")
                echo "Analyzing $TARGET..."
                nmap -F "$TARGET" | $BIN -m "$MODELS/llama-3.2-3b.gguf" -t $THREADS -p "Explain these nmap results briefly:" ;;
            *"Scaffold"*)
                PROJ=$(gum input --placeholder "Project Type (e.g. Python Bot)")
                $BIN -m "$MODELS/hermes-3-8b.gguf" -t $THREADS -p "Output only the bash commands to create a directory structure for: $PROJ" ;;
            *"Cleanup"*)
                pkg clean && rm -rf ~/.cache/*
                gum toast "System Purged." ;;
        esac
        ./aether.sh ;;
    *) exit 0 ;;
esac
