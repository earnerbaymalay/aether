#!/usr/bin/env bash
# Aether-AI v15.0: Resilient Intelligence Edition

# --- CONFIG ---
ACCENT="#81a1c1"; DIM="#4c566a"; WHITE="#eceff4"; SUCCESS="#50fa7b"; RED="#ff5555"
BIN="$HOME/llama.cpp/build/bin/llama-cli"
MODELS="$HOME/termux-ai-workspace/models"
THREADS=6

# --- RESILIENCE: ENGINE CHECK ---
if [ ! -f "$BIN" ]; then
    clear
    gum style --border double --margin "1" --padding "1 2" --border-foreground "$RED" "🌌 AETHER-AI: ERROR" "Engine (llama-cli) not found."
    gum confirm "Execute native build now?" && ./install.sh || exit 1
fi

# --- AETHER MEMORY (RAG) ---
# Injects up to 1000 characters of local knowledge into the AI's prompt
KNOWLEDGE=$(cat ~/termux-ai-workspace/knowledge/*.txt 2>/dev/null | tr '\n' ' ' | cut -c 1-1000)
BASE_PROMPT="You are Aether. Knowledge Base: $KNOWLEDGE. You have shell access."

# --- METRICS ---
BATT=$(termux-battery-status 2>/dev/null | grep percentage | cut -d: -f2 | tr -d ' ,%')
STR=$(df -h /data | awk 'NR==2 {print $4}')

clear
ROWS=$(tput lines); VPAD=$(( (ROWS - 18) / 2 ))
for i in $(seq 1 $VPAD); do echo ""; done

# LOGO
echo -ne "\033[1;34m"
figlet -f small "   AETHER"
echo -e "\033[0;34m   NEURAL OPERATING INTERFACE // V 15.0\033[0m\n"

gum style --foreground "$ACCENT" --border rounded --border-foreground "$DIM" --padding "0 1" --width 38 \
  " PWR: ${BATT:-0}%  •  STR: $STR  •  MEM: ACTIVE "

CHOICE=$(gum choose --cursor.foreground "$ACCENT" --header "      [ SELECT NEURAL PATHWAY ]" \
	" 🤖 AGENT   (Hermes / Shell Tools) " \
	" 🧠 LOGIC   (DeepSeek / Reasoning) " \
	" 🛠️  TOOLBOX (System Utilities)     " \
	" 🎤 VOICE   (Native Offline TTS)   " \
	" ❌ DISCONNECT SESSION             ")

case "$CHOICE" in
    *"AGENT"*) $BIN -m "$MODELS/hermes-3-8b.gguf" -cnv -t $THREADS --mmap -p "$BASE_PROMPT" ;;
    *"LOGIC"*) $BIN -m "$MODELS/deepseek-r1-1.5b.gguf" -cnv -t $THREADS --mmap -p "$BASE_PROMPT" ;;
    *"TOOLBOX"*)
        TOOL=$(gum choose --header "UTILITY TOOLBOX" "📡 Network Scan" "🧹 System Cleanup" "🔙 Back")
        case "$TOOL" in
            *"Network"*) 
                TARGET=$(gum input --placeholder "IP or Domain")
                nmap -F "$TARGET" | $BIN -m "$MODELS/llama-3.2-3b.gguf" -t $THREADS -p "Explain these port results:" ;;
            *"Cleanup"*)
                echo -e "\033[1;33m[PROCESS] Running System Physician...\033[0m"
                pkg clean -y
                [ -d "$HOME/
cat << 'EOF' > README.md
# 🌌 Aether-AI: The Neural Multitool (v15.0)

A high-performance, agentic AI ecosystem for Android. Aether-AI transforms Termux into a **Local Intelligence Hub** optimized for ARM64 silicon.

---

### 📑 Navigation
- [🚀 Rapid Onboarding](#-rapid-onboarding)
- [🧠 Model Tier System](#-model-tier-system)
- [🛠️ Integrated Toolbox](#-integrated-toolbox)
- [📈 Roadmap](#-roadmap)
