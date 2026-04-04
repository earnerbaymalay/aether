#!/usr/bin/env bash
# Aether-AI v8.3: Silicon Stability Edition

# --- COLORS ---
ACCENT="#81a1c1"; DIM="#4c566a"; WHITE="#eceff4"; BLUE="#89b4fa"
BIN="$HOME/llama.cpp/build/bin/llama-cli"
MODELS="$HOME/termux-ai-workspace/models"

# --- HARDWARE OPTIMIZATION ---
# Since GPU is unsupported, we use 6 threads for maximum CPU push
THREADS=6 

# --- SYSTEM METRICS ---
BATT=$(termux-battery-status 2>/dev/null | grep percentage | cut -d: -f2 | tr -d ' ,%')
STORAGE=$(df -h /data | awk 'NR==2 {print $4}')

clear
ROWS=$(tput lines); VPAD=$(( (ROWS - 16) / 2 ))
for i in $(seq 1 $VPAD); do echo ""; done

# --- LOGO ---
echo -ne "\033[1;34m"
figlet -f small "  A E T H E R"
echo -e "\033[0;34m  NEURAL OPERATING INTERFACE // V 8.3 (STABILITY)\033[0m"
echo ""

# --- STATUS BAR ---
gum style --foreground "$ACCENT" --border rounded --border-foreground "$DIM" --padding "0 2" \
  "  PWR: ${BATT:-0}%  •  STR: $STORAGE  •  MODE: SILICON-STABLE  "
echo ""

# --- THE INTERFACE ---
CHOICE=$(gum choose --cursor.foreground "$ACCENT" --padding "1" \
	" [01] AGENTIC MODE (Hermes-3-8B) " \
	" [02] LOGICAL MODE (Gemma-2-9B)  " \
	" [03] SYSTEM DIAGNOSTICS         " \
	" [04] DISCONNECT SESSION         ")

case "$CHOICE" in
    *"AGENT"*)
        # -ngl 0 avoids the Vulkan crash completely
        # --mmap enables fast memory mapping
        $BIN -m "$MODELS/hermes-3-8b.gguf" -cnv -t $THREADS -ngl 0 --mmap -p "You are Aether, a high-performance assistant." ;;
    *"LOGIC"*)
        $BIN -m "$MODELS/gemma-2-9b.gguf" -cnv -t $THREADS -ngl 0 --mmap ;;
    *"DIAGNOSTICS"*)
        printf "Metric,Value\nArchitecture,ARM64\nThreads,$THREADS\nGPU,Bypassed (Stability)\nStatus,Superior" | gum table --border.foreground "$ACCENT"
        read -p "Press Enter to return..." && ./aether.sh ;;
    *"DISCONNECT"*)
        termux-wake-unlock
        clear && exit 0 ;;
esac
