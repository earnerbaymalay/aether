#!/usr/bin/env bash
# Aether-AI v17.0: Persistence Edition
ACCENT="#81a1c1"; DIM="#4c566a"; WHITE="#eceff4"; RED="#ff5555"
BIN="$HOME/llama.cpp/build/bin/llama-cli"
MODELS="$HOME/termux-ai-workspace/models"
THREADS=6
SESSION_DIR="$HOME/.aether/sessions"

# --- PERSISTENCE ENGINE ---
# This reads the last 1000 characters of your previous chat
get_context() {
    if [ -f "$SESSION_DIR/last_session.log" ]; then
        tail -c 1000 "$SESSION_DIR/last_session.log" | tr '\n' ' ' | sed 's/"/\\"/g'
    else
        echo "No previous context."
    fi
}
launch_ai() {
    local mod="$1"
    local url="$2"
    local role="$3"
    
    if [ ! -f "$MODELS/$mod" ]; then
        clear
        gum style --foreground "$RED" "Model Missing."
        gum confirm "Download now?" && wget -O "$MODELS/$mod" "$url" || return
    fi
    
    # LOAD PREVIOUS MEMORY
    CONTEXT=$(get_context)
    
    # LAUNCH WITH LOGGING ENABLED
    $BIN -m "$MODELS/$mod" -cnv -t $THREADS --mmap \
      --log-file "$SESSION_DIR/last_session.log" \
      -p "Role: $role. Previous Context: $CONTEXT"
}

BATT=$(termux-battery-status 2>/dev/null | grep percentage | cut -d: -f2 | tr -d ' ,%')
STR=$(df -h /data | awk 'NR==2 {print $4}')
clear
ROWS=$(tput lines); VPAD=$(( (ROWS - 18) / 2 ))
for i in $(seq 1 $VPAD); do echo ""; done
echo -ne "\033[1;34m"
figlet -f small "   AETHER"
echo -e "\033[0;34m   NEURAL INTERFACE SYSTEM // V 17.0\033[0m\n"
gum style --foreground "$ACCENT" --border rounded --border-foreground "$DIM" --padding "0 1" --width 36 \
  " PWR: ${BATT:-0}%  •  STR: $STR  •  VAULT: ON "
CHOICE=$(gum choose --cursor.foreground "$ACCENT" --header "      [ SELECT NEURAL PATHWAY ]" \
	" 🤖 AGENT   (Hermes-8B) " " ⚡ TURBO   (Llama-3B) " \
	" 🧠 LOGIC   (DeepSeek) " " 💻 CODE    (Qwen-3B) " \
	" 🧹 PURGE   (Clear Memory) " " ❌ EXIT ")

case "$CHOICE" in
    *"AGENT"*) launch_ai "hermes-3-8b.gguf" "https://huggingface.co/bartowski/Hermes-3-Llama-3.1-8B-GGUF/resolve/main/Hermes-3-Llama-3.1-8B-Q4_K_M.gguf" "Uncensored Agent" ;;
    *"TURBO"*) launch_ai "llama-3.2-3b.gguf" "https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf" "Fast Assistant" ;;
    *"LOGIC"*) launch_ai "deepseek-r1-1.5b.gguf" "https://huggingface.co/unsloth/DeepSeek-R1-Distill-Qwen-1.5B-GGUF/resolve/main/DeepSeek-R1-Distill-Qwen-1.5B-Q4_K_M.gguf" "Deep Thinker" ;;
    *"CODE"*)  launch_ai "qwen-coder-3b.gguf" "https://huggingface.co/bartowski/Qwen2.5-Coder-3B-Instruct-GGUF/resolve/main/Qwen2.5-Coder-3B-Instruct-Q4_K_M.gguf" "Expert Coder" ;;
    *"PURGE"*) rm -f "$SESSION_DIR/last_session.log" && gum toast "Memory Wiped."; ./aether.sh ;;
    *) exit 0 ;;
esac
