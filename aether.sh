#!/usr/bin/env bash
# Aether-AI v6.0: Multi-Engine
ACCENT="#81a1c1"; DIM="#4c566a"; WHITE="#eceff4"
BIN=$(find $HOME/llama.cpp -name "llama-cli" | head -n 1)
MODELS="$HOME/termux-ai-workspace/models"
THREADS=4

BATT=$(termux-battery-status 2>/dev/null | grep percentage | cut -d: -f2 | tr -d ' ,%')
STORAGE=$(df -h /data | awk 'NR==2 {print $4}')

clear
ROWS=$(tput lines); VPAD=$(( (ROWS - 18) / 2 ))
for i in $(seq 1 $VPAD); do echo ""; done

figlet -f small "   A E T H E R" | gum style --foreground "$ACCENT" --bold
echo -e "\033[0;34m   NEURAL INTELLIGENCE SYSTEM // V 6.0\033[0m"
echo ""

gum style --foreground "$ACCENT" --border normal --border-foreground "$DIM" --padding "0 2" \
  "  PWR: $BATT%  •  STR: $STORAGE  •  TURBO: READY  "
echo ""

CHOICE=$(gum choose --cursor.foreground "$ACCENT" --padding "1" \
	" [01] TURBO MODE (Llama-3.2-3B) " \
	" [02] AGENT MODE (Hermes-3-8B)  " \
	" [03] LOGIC MODE (Gemma-2-9B)   " \
	" [04] DISCONNECT SESSION        ")

case "$CHOICE" in
    *"TURBO"*)
        $BIN -m "$MODELS/llama-3.2-3b.gguf" -cnv -t $THREADS -p "You are Aether-Turbo. Be fast and efficient." ;;
    *"AGENT"*)
        $BIN -m "$MODELS/hermes-3-8b.gguf" -cnv -t $THREADS -p "You are Aether-Agent. Use tools." ;;
    *"LOGIC"*)
        $BIN -m "$MODELS/gemma-2-9b.gguf" -cnv -t $THREADS ;;
    *"DISCONNECT"*)
        clear && exit 0 ;;
esac
