#!/usr/bin/env bash
# 🌌 Aether-AI Neural Interface System // V 18.0
# Optimized for ARM64 / Termux / Nokia & Pixel Devices
# Repository: https://github.com/earnerbaymalay/aether

# --- Configuration ---
ACCENT="#81a1c1"; DIM="#4c566a"; WHITE="#eceff4"; RED="#ff5555"
DIR="$HOME/aether"
BIN="$HOME/llama.cpp/build/bin/llama-cli"
MODELS="$DIR/models"
THREADS=6
SESSION_DIR="$HOME/.aether/sessions"

# --- Dependencies Check ---
check_deps() {
    local missing=()
    for dep in gum figlet llama-cli termux-battery-status; do
        if ! command -v "$dep" &>/dev/null; then
            if [ "$dep" == "llama-cli" ]; then
                [ ! -f "$BIN" ] && missing+=("llama.cpp")
            else
                missing+=("$dep")
            fi
        fi
    done

    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "\033[1;31m[!] Missing dependencies: ${missing[*]}\033[0m"
        echo -e "Please run './install.sh' to fix."
        exit 1
    fi
}

# --- PERSISTENCE ENGINE ---
get_context() {
    if [ -f "$SESSION_DIR/last_session.log" ]; then
        tail -c 1000 "$SESSION_DIR/last_session.log" | tr '\n' ' ' | sed 's/"/\\"/g'
    else
        echo "Starting fresh session."
    fi
}

launch_ai() {
    local mod="$1"
    local url="$2"
    local role="$3"
    local is_agent="$4"
    
    if [ ! -f "$MODELS/$mod" ]; then
        clear
        gum style --foreground "$RED" "Model Missing: $mod"
        gum confirm "Download now? (Requires ~2-5GB)" && {
            mkdir -p "$MODELS"
            wget -O "$MODELS/$mod" "$url"
        } || return
    fi
    
    if [ "$is_agent" == "true" ]; then
        python3 "$DIR/agent/aether_agent.py" --model "$mod"
    else
        # LOAD KNOWLEDGE & SKILLS
        KNOWLEDGE=$(cat "$DIR/knowledge"/*.txt 2>/dev/null | tr '\n' ' ' | cut -c 1-1000)
        SKILL_LIST=$(ls "$DIR/skills" 2>/dev/null | tr '\n' ',' | sed 's/,$//')
        CONTEXT=$(get_context)
        
        clear
        gum style --foreground "$ACCENT" --border double "Connecting to $mod..."
        
        $BIN -m "$MODELS/$mod" -cnv -t $THREADS --mmap \
          --log-file "$SESSION_DIR/last_session.log" \
          -p "Role: $role. System State: Aether V18.0. Knowledge: $KNOWLEDGE. Skills: [$SKILL_LIST]. Previous Context: $CONTEXT"
    fi
}

# --- Main Entry ---
check_deps

BATT=$(termux-battery-status 2>/dev/null | grep percentage | cut -d: -f2 | tr -d ' ,%')
STR=$(df -h /data | awk 'NR==2 {print $4}')
mkdir -p "$SESSION_DIR"

while true; do
    clear
    ROWS=$(tput lines); VPAD=$(( (ROWS - 18) / 2 ))
    [ $VPAD -lt 0 ] && VPAD=0
    for i in $(seq 1 $VPAD); do echo ""; done
    
    echo -ne "\033[1;34m"
    figlet -f small "   AETHER"
    echo -e "\033[0;34m   NEURAL INTERFACE SYSTEM // V 18.0\033[0m\n"
    
    gum style --foreground "$ACCENT" --border rounded --border-foreground "$DIM" --padding "0 1" --width 40 \
      " PWR: ${BATT:-N/A}%  •  STR: $STR  •  VAULT: ON "
    
    CHOICE=$(gum choose --cursor.foreground "$ACCENT" --header "      [ SELECT NEURAL PATHWAY ]" \
        " 🤖 AGENT   (Hermes-8B) " \
        " ⚡ TURBO   (Llama-3B) " \
        " 🧠 LOGIC   (DeepSeek) " \
        " 💻 CODE    (Qwen-3B) " \
        " 🛡️ SECURITY (Sentinel Hub) " \
        " 🛠 TOOLS   (Skills & Maintenance) " \
        " ❌ EXIT ")

    case "$CHOICE" in
        *"AGENT"*) launch_ai "hermes-3-8b.gguf" "https://huggingface.co/bartowski/Hermes-3-Llama-3.1-8B-GGUF/resolve/main/Hermes-3-Llama-3.1-8B-Q4_K_M.gguf" "Uncensored Agent" "true" ;;
        *"TURBO"*) launch_ai "llama-3.2-3b.gguf" "https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf" "Fast Assistant" "false" ;;
        *"LOGIC"*) launch_ai "deepseek-r1-1.5b.gguf" "https://huggingface.co/unsloth/DeepSeek-R1-Distill-Qwen-1.5B-GGUF/resolve/main/DeepSeek-R1-Distill-Qwen-1.5B-Q4_K_M.gguf" "Deep Thinker" "false" ;;
        *"CODE"*)  launch_ai "qwen-coder-3b.gguf" "https://huggingface.co/bartowski/Qwen2.5-Coder-3B-Instruct-GGUF/resolve/main/Qwen2.5-Coder-3B-Instruct-Q4_K_M.gguf" "Expert Coder" "false" ;;
        *"SECURITY"*) ./scripts/launch_sentinel.sh ;;
        *"TOOLS"*) 
            TOOL=$(gum choose " 🧹 PURGE (Clear Memory) " " 📖 LIBRARIAN (Audit Vault) " " 📏 BENCHMARK (Hardware) " " 📘 SKILLS (View Installed) " " 🔙 BACK ")
            case "$TOOL" in
                *"PURGE"*) rm -f "$SESSION_DIR/last_session.log" && gum toast "Memory Wiped." ;;
                *"LIBRARIAN"*) python3 "$DIR/scripts/librarian.py" | gum pager ;;
                *"BENCHMARK"*) ./bench.sh ;;
                *"SKILLS"*) ls -R skills/ | gum pager ;;
            esac
            ;;
        *) exit 0 ;;
    esac
done
