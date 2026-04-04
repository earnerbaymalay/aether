#!/usr/bin/env bash
# Aether-AI v7.2: Studio Precision Build

# --- COLORS ---
INDIGO="\033[38;5;111m"
SLATE="\033[38;5;60m"
WHITE="\033[38;5;255m"
NC="\033[0m"

# --- CONFIG ---
BIN=$(find $HOME/llama.cpp -name "llama-cli" | head -n 1)
MODELS="$HOME/termux-ai-workspace/models"
THREADS=4

# --- SYSTEM METRICS ---
BATT=$(termux-battery-status 2>/dev/null | grep percentage | cut -d: -f2 | tr -d ' ,%')
[ -z "$BATT" ] && BATT="--"
STORAGE=$(df -h /data | awk 'NR==2 {print $4}')

clear

# 1. VERTICAL CENTERING (Nokia Optimized)
ROWS=$(tput lines)
VPAD=$(( (ROWS - 15) / 2 ))
for i in $(seq 1 $VPAD); do echo ""; done

# 2. LOGO - RAW PRINTING (Bypasses gum to fix alignment)
echo -e "${INDIGO}"
figlet -f mini "    A E T H E R"
echo -e "${SLATE}    NEURAL OPERATING INTERFACE // V 7.2${NC}"
echo ""

# 3. STATUS BAR (Gum-compatible border)
gum style --foreground "#81a1c1" --border normal --border-foreground "#4c566a" --padding "0 2" \
  "  PWR: $BATT%  •  STR: $STORAGE  •  NODE: NATIVE_C++  "
echo ""

# 4. THE INTERFACE
CHOICE=$(gum choose \
	--cursor.foreground "#81a1c1" \
	--item.foreground "#eceff4" \
	--selected.foreground "#88c0d0" \
	--header "  [ SELECT NEURAL PATH ]" \
	--header.foreground "#4c566a" \
	--padding "1" \
	"  ●  HERMES-3  (AGENTIC TOOLS) " \
	"  ●  GEMMA-2   (LOGIC & REASONING) " \
	"  ●  SYSTEM DIAGNOSTICS " \
	"  ●  SHUTDOWN INTERFACE ")

case "$CHOICE" in
    *"HERMES-3"*)
        gum spin --spinner.foreground "#81a1c1" --title "Mounting Hermes-3..." -- sleep 2
        $BIN -m "$MODELS/hermes-3-8b.gguf" -cnv -t $THREADS -p "You are Aether. Use tools." ;;
    *"GEMMA-2"*)
        gum spin --spinner.foreground "#88c0d0" --title "Mounting Gemma-2..." -- sleep 2
        $BIN -m "$MODELS/gemma-2-9b.gguf" -cnv -t $THREADS ;;
    *"DIAGNOSTICS"*)
        gum table --border normal --border-foreground "#4c566a" --columns "Metric,Value" <<< "Power,$BATT%|Disk,$STORAGE|Cores,$THREADS|Engine,Llama-CLI"
        read -p "Press Enter to return..." && ./aether.sh ;;
    *"SHUTDOWN"*) clear && exit 0 ;;
esac
