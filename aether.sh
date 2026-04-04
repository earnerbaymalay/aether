#!/usr/bin/env bash
# Aether-AI v7.1
ACCENT="#81a1c1"; DIM="#4c566a"; WHITE="#eceff4"; SUCCESS="#50fa7b"
BIN=$(find $HOME/llama.cpp -name "llama-cli" | head -n 1)
MODELS="$HOME/termux-ai-workspace/models"
THREADS=4
BATT=$(termux-battery-status 2>/dev/null | grep percentage | cut -d: -f2 | tr -d ' ,%')
STORAGE=$(df -h /data | awk 'NR==2 {print $4}')
clear
ROWS=$(tput lines); VPAD=$(( (ROWS - 16) / 2 ))
for i in $(seq 1 $VPAD); do echo ""; done
figlet -f small "  AETHER" | gum style --foreground "$ACCENT" --bold
echo -e "\n1) TASK RUNNER\n2) HERMES CHAT\n3) GEMMA CHAT\n4) EXIT"
read -p "Select > " c
case $c in
  1) TASK=$(gum input); RESULT=$($BIN -m "$MODELS/hermes-3-8b.gguf" -t $THREADS -n 128 --quiet -p "Output only the bash command for: $TASK"); echo "$RESULT"; gum confirm "Run?" && eval "$RESULT" ;;
  2) $BIN -m "$MODELS/hermes-3-8b.gguf" -cnv -t $THREADS ;;
  3) $BIN -m "$MODELS/gemma-2-9b.gguf" -cnv -t $THREADS ;;
  *) exit 0 ;;
esac
