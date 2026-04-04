#!/usr/bin/env bash
# Aether-AI v7.4: Professional System Build

# --- PALETTE ---
ACCENT="#81a1c1"; DIM="#4c566a"; WHITE="#eceff4"; CYAN="#88c0d0"

# --- CONFIG ---
BIN=$(find $HOME/llama.cpp -name "llama-cli" | head -n 1)
MODELS="$HOME/termux-ai-workspace/models"
THREADS=4

# --- SYSTEM METRICS ---
BATT=$(termux-battery-status 2>/dev/null | grep percentage | cut -d: -f2 | tr -d ' ,%')
[ -z "$BATT" ] && BATT="--"
STORAGE=$(df -h /data | awk 'NR==2 {print $4}')

clear

# 1. VERTICAL CENTERING
ROWS=$(tput lines); VPAD=$(( (ROWS - 15) / 2 ))
for i in $(seq 1 $VPAD); do echo ""; done

# 2. LOGO - RAW PRINTING (Fixed Alignment)
echo -ne "\033[1;34m"
figlet -f small "  A E T H E R"
echo -e "\033[0;34m  NEURAL OPERATING INTERFACE // V 7.4\033[0m"
echo ""

# 3. STATUS BAR (Fixed Syntax)
gum style --foreground "$ACCENT" --border rounded --border.foreground "$DIM" --padding "0 2" \
  "  PWR: $BATT%  •  STR: $STORAGE  •  NODE: NATIVE_C++  "
echo ""

# 4. THE INTERFACE
CHOICE=$(gum choose \
	--cursor.foreground "$ACCENT" \
	--item.foreground "$WHITE" \
	--selected.foreground "$CYAN" \
	--header "  [ SELECT NEURAL PATHWAY ]" \
	--header.foreground "$DIM" \
	--padding "1" \
	"  ●  HERMES-3  (AGENTIC TOOLS) " \
	"  ●  GEMMA-2   (LOGIC & REASONING) " \
	"  ●  SYSTEM DIAGNOSTICS " \
	"  ●  SHUTDOWN INTERFACE ")

case "$CHOICE" in
    *"HERMES-3"*)
        gum spin --spinner.foreground "$ACCENT" --title "Mounting Hermes-3..." -- sleep 2
        $BIN -m "$MODELS/hermes-3-8b.gguf" -cnv -t $THREADS -p "You are Aether, an expert AI agent. Use tools." ;;
    *"GEMMA-2"*)
        gum spin --spinner.foreground "$CYAN" --title "Mounting Gemma-2..." -- sleep 2
        $BIN -m "$MODELS/gemma-2-9b.gguf" -cnv -t $THREADS ;;
    *"DIAGNOSTICS"*)
        # FIXED SYNTAX: Using dot notation for border and cell colors
        gum table --columns "Metric,Value" \
            --border.foreground "$ACCENT" \
            --cell.foreground "$WHITE" \
            --header.foreground "$ACCENT" \
            <<< "Battery,$BATT%|Disk,$STORAGE|Cores,$THREADS|Engine,Llama-CLI|Status,Superior"
        read -p "Press Enter to return..." && ./aether.sh ;;
    *"SHUTDOWN"*) clear && termux-wake-unlock && exit 0 ;;
esac
