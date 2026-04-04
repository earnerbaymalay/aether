#!/usr/bin/env bash
# Aether-AI v8.2: Adaptive GPU Edition

# --- COLORS ---
ACCENT="#81a1c1"; DIM="#4c566a"; WHITE="#eceff4"; RED="#ff5555"
BIN="$HOME/llama.cpp/build/bin/llama-cli"
MODELS="$HOME/termux-ai-workspace/models"

# --- ENGINE VALIDATION ---
if [ ! -f "$BIN" ]; then
    echo "ERROR: Engine missing. Rebuild in ~/llama.cpp/build"
    exit 1
fi

# --- SYSTEM METRICS ---
BATT=$(termux-battery-status 2>/dev/null | grep percentage | cut -d: -f2 | tr -d ' ,%')
STORAGE=$(df -h /data | awk 'NR==2 {print $4}')

clear
ROWS=$(tput lines); VPAD=$(( (ROWS - 16) / 2 ))
for i in $(seq 1 $VPAD); do echo ""; done

# --- LOGO ---
echo -ne "\033[1;34m"
figlet -f small "  A E T H E R"
echo -e "\033[0;34m  NEURAL OPERATING INTERFACE // V 8.2 (ADAPTIVE)\033[0m"
echo ""

# --- STATUS BAR ---
# Note: We show 'ADAPTIVE' because we aren't using 100% GPU
gum style --foreground "$ACCENT" --border rounded --border-foreground "$DIM" --padding "0 2" \
  "  PWR: ${BATT:-0}%  |  STR: $STORAGE  |  GPU: ADAPTIVE (15L)  "
echo ""

# --- THE INTERFACE ---
CHOICE=$(gum choose --cursor.foreground "$ACCENT" --padding "1" \
	" [01] AGENTIC MODE (Hermes-3-8B) " \
	" [02] LOGICAL MODE (Gemma-2-9B)  " \
	" [03] EMERGENCY CPU MODE        " \
	" [04] DISCONNECT SESSION        ")

case "$CHOICE" in
    *"AGENT"*)
        # -ngl 15 uses the GPU for some work without hitting the 16-bit limit
        $BIN -m "$MODELS/hermes-3-8b.gguf" -cnv -t 4 -ngl 15 -p "You are Aether." ;;
    *"LOGIC"*)
        $BIN -m "$MODELS/gemma-2-9b.gguf" -cnv -t 4 -ngl 15 ;;
    *"EMERGENCY"*)
        # 0 layers on GPU (Pure CPU - guaranteed to work)
        gum style --foreground "$RED" "Entering CPU-only mode for stability..."
        $BIN -m "$MODELS/hermes-3-8b.gguf" -cnv -t 4 -ngl 0 ;;
    *) exit 0 ;;
esac
