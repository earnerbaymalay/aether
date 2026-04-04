#!/usr/bin/env bash
BIN="$HOME/llama.cpp/build/bin/llama-cli"
MODELS="$HOME/termux-ai-workspace/models"
KNOWLEDGE=$(cat ~/termux-ai-workspace/knowledge/*.txt 2>/dev/null | tr '\n' ' ' | cut -c 1-500)
clear
figlet -f small "  AETHER"
gum style --border rounded --padding "0 1" " MEMORY: LOADED • V12.0 "
CHOICE=$(gum choose "TURBO (3B)" "AGENT (8B)" "LOGIC (9B)" "BENCHMARK" "EXIT")
case "$CHOICE" in
    *"TURBO"*) $BIN -m "$MODELS/llama-3.2-3b.gguf" -cnv -t 6 --mmap -p "Aether: $KNOWLEDGE" ;;
    *"AGENT"*) $BIN -m "$MODELS/hermes-3-8b.gguf" -cnv -t 6 --mmap -p "Agent: $KNOWLEDGE" ;;
    *"LOGIC"*) $BIN -m "$MODELS/gemma-2-9b.gguf" -cnv -t 6 --mmap -p "Logic: $KNOWLEDGE" ;;
    *"BENCHMARK"*) ./bench.sh ;;
    *) exit 0 ;;
esac
