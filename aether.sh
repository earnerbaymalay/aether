#!/usr/bin/env bash
# Aether-AI: Refined Studio Edition v5.7
INDIGO="#81a1c1"; CYAN="#88c0d0"; GRAY="#4c566a"; WHITE="#eceff4"
BIN=$(find $HOME/llama.cpp -name "llama-cli" | head -n 1)
MODELS="$HOME/termux-ai-workspace/models"
THREADS=4

# System Metrics
BATT=$(termux-battery-status 2>/dev/null | grep percentage | cut -d: -f2 | tr -d ' ,%')
[ -z "$BATT" ] && BATT="--"
STORAGE=$(df -h /data | awk 'NR==2 {print $4}')

clear
# Vertical Centering for Premium Look
ROWS=$(tput lines); VPAD=$(( (ROWS - 16) / 2 ))
for i in $(seq 1 $VPAD); do echo ""; done

# Perfectly Aligned Logo
echo -e "\033[1;34m"
figlet -f small "   A E T H E R"
echo -e "\033[0;34m   NEURAL INTELLIGENCE SYSTEM // V 5.7\033[0m"
echo ""

# Minimalist Status Bar
gum style --foreground "$GRAY" --border normal --border-foreground "$GRAY" --padding "0 2" \
  "  PWR: $BATT%  •  STR: $STORAGE  •  NODE: NATIVE_C++  "
echo ""

# Tool-First Menu
CHOICE=$(gum choose --cursor.foreground "$INDIGO" --item.foreground "$WHITE" --selected.foreground "$CYAN" --header "  [ DISCOVER PATHWAY ]" --header.foreground "$GRAY" --padding "1" "  ●  HERMES-3  (AGENTIC TOOLS) " "  ●  GEMMA-2   (LOGIC & REASONING) " "  ●  SYSTEM DIAGNOSTICS " "  ●  SHUTDOWN INTERFACE ")

case "$CHOICE" in
    *"HERMES-3"*)
        gum spin --spinner.foreground "$INDIGO" --title "Mounting Hermes-3..." -- sleep 2
        $BIN -m "$MODELS/hermes-3-8b.gguf" -cnv -t $THREADS -p "You are Aether, an expert AI agent. Use bash tools and be professional." ;;
    *"GEMMA-2"*)
        gum spin --spinner.foreground "$CYAN" --title "Mounting Gemma-2..." -- sleep 2
        $BIN -m "$MODELS/gemma-2-9b.gguf" -cnv -t $THREADS ;;
    *"DIAGNOSTICS"*)
        gum table --border normal --border-foreground "$GRAY" --columns "Metric,Value" <<< "Power,$BATT%|Disk,$STORAGE|Cores,$THREADS|Engine,Llama-CLI"
        read -p "Press Enter to return..." && ./aether.sh ;;
    *"SHUTDOWN"*) clear && termux-wake-unlock && exit 0 ;;
esac
