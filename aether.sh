#!/usr/bin/env bash
# Aether-AI v9.0: Agentic Hub (Turbo/Agent/Logic)

# --- COLORS ---
ACCENT="#81a1c1"; DIM="#4c566a"; WHITE="#eceff4"; GOLD="#f1fa8c"

# --- CONFIG ---
BIN="$HOME/llama.cpp/build/bin/llama-cli"
MODELS="$HOME/termux-ai-workspace/models"
THREADS=6 # Max CPU push for Nokia

# --- MEMORY SCAN ---
MEMORY=$(ls ~/termux-ai-workspace/knowledge/*.txt 2>/dev/null | xargs cat 2>/dev/null)
SYSTEM_PROMPT="You are Aether. Current Knowledge: $MEMORY. You have shell access via bash blocks."

# --- METRICS ---
BATT=$(termux-battery-status 2>/dev/null | grep percentage | cut -d: -f2 | tr -d ' ,%')
clear
ROWS=$(tput lines); VPAD=$(( (ROWS - 18) / 2 ))
for i in $(seq 1 $VPAD); do echo ""; done

# --- LOGO & UI ---
echo -ne "\033[1;34m"
figlet -f small "  A E T H E R"
echo -e "\033[0;34m  NEURAL OPERATING INTERFACE // V 9.0\033[0m"
echo ""
gum style --foreground "$ACCENT" --border rounded --border-foreground "$DIM" --padding "0 2" \
  "  PWR: ${BATT:-0}%  •  MODE: NATIVE-SILICON  •  MEMORY: LOADED  "
echo ""

# --- THE 3-TIER MENU ---
CHOICE=$(gum choose --cursor.foreground "$ACCENT" --padding "1" \
	" [01] TURBO MODE (Llama-3.2-3B) - Instant Speed " \
	" [02] AGENT MODE (Hermes-3-8B)  - Best Tool Use " \
	" [03] LOGIC MODE (Gemma-2-9B)   - High Reasoning " \
	" [04] VOICE INTERFACE (Native TTS) " \
	" [05] DISCONNECT SESSION ")

case "$CHOICE" in
    *"TURBO"*)
        $BIN -m "$MODELS/llama-3.2-3b.gguf" -cnv -t $THREADS --mmap -p "$SYSTEM_PROMPT" ;;
    *"AGENT"*)
        $BIN -m "$MODELS/hermes-3-8b.gguf" -cnv -t $THREADS --mmap -p "$SYSTEM_PROMPT" ;;
    *"LOGIC"*)
        echo -e "\033[1;33m[ADVISORY] Logic mode requires heavy CPU. Tool-use speed may be limited.\033[0m"
        sleep 2
        $BIN -m "$MODELS/gemma-2-9b.gguf" -cnv -t $THREADS --mmap -p "$SYSTEM_PROMPT" ;;
    *"VOICE"*)
        INPUT=$(gum input --placeholder "Speak your command...")
        # Processing with Turbo for speed
        RESPONSE=$($BIN -m "$MODELS/llama-3.2-3b.gguf" -t $THREADS -p "$INPUT" -n 64 --quiet)
        echo -e "\nAether: $RESPONSE"
        termux-tts-speak "$RESPONSE"
        read -p "Press Enter..." && ./aether.sh ;;
    *) exit 0 ;;
esac
