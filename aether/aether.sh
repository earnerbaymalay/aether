#!/usr/bin/env bash
# 🌌 Aether-AI Neural Interface System // V 18.0
# Optimized for ARM64 / Termux / Nokia & Pixel Devices
# Repository: https://github.com/earnerbaymalay/aether

# --- Configuration ---
# Load settings from config file if available
SETTINGS_FILE="$DIR/settings/config.json"
if [ -f "$SETTINGS_FILE" ]; then
    ACCENT=$(python3 -c "import json; print(json.load(open('$SETTINGS_FILE')).get('appearance',{}).get('accent_color','#00ff9d'))" 2>/dev/null || echo "#00ff9d")
    THREADS=$(python3 -c "import json; print(json.load(open('$SETTINGS_FILE')).get('model',{}).get('threads',6))" 2>/dev/null || echo 6)
    CTX_SIZE=$(python3 -c "import json; print(json.load(open('$SETTINGS_FILE')).get('model',{}).get('context_size',2048))" 2>/dev/null || echo 2048)
    TEMP=$(python3 -c "import json; print(json.load(open('$SETTINGS_FILE')).get('model',{}).get('temperature',0.7))" 2>/dev/null || echo 0.7)
else
    ACCENT="#00ff9d"; DIM="#4c566a"; WHITE="#eceff4"; RED="#ff5555"
    THREADS=6; CTX_SIZE=2048; TEMP=0.7
fi

DIR="$HOME/aether"
BIN="$HOME/llama.cpp/build/bin/llama-cli"
MODELS="$DIR/models"
THREADS=${THREADS:-6}
CTX_SIZE=${CTX_SIZE:-2048}
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

# --- PREMIUM BOOT SEQUENCE ---
boot_sequence() {
    clear
    echo -e "\n\n"
    figlet -f small "  AETHER" | gum style --foreground "$ACCENT"
    echo -e "   \033[1;30mNEURAL OPERATING INTERFACE // INITIALIZING\033[0m\n"
    
    local steps=("Kernel Check" "Neural Pathways" "Context7 Vault" "Hardware Sync")
    for step in "${steps[@]}"; do
        echo -ne "  \033[1;34m[●]\033[0m $step..."
        sleep 0.2
        echo -e " \033[1;32mDONE\033[0m"
    done
    sleep 0.5
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
        KNOWLEDGE=$(cat "$DIR/knowledge"/*.txt 2>/dev/null | tr '\n' ' ' | cut -c 1-2000)
        SKILL_LIST=$(ls "$DIR/skills" 2>/dev/null | tr '\n' ',' | sed 's/,$//')
        CONTEXT=$(get_context)

        clear
        gum style --foreground "$ACCENT" --border double "Connecting to Aether Neural Pathway: $mod..."

        # SYSTEM PROMPT BRANDING
        SYSTEM_PROMPT="You are Aether-AI, a local-first Neural Operating Interface. $role. Current Environment: ARM64 Termux. Status: High Performance. Threads: $THREADS. Context: ${CTX_SIZE}. Skills: [$SKILL_LIST]. Previous Session Context: $CONTEXT."

        $BIN -m "$MODELS/$mod" -cnv -t $THREADS --mmap -c $CTX_SIZE --temp $TEMP \
          --log-file "$SESSION_DIR/last_session.log" \
          -p "$SYSTEM_PROMPT"
    fi
}

# --- Main Entry ---
check_deps

# Session startup flow
SESSION_ID=""
if [ -f "$SESSION_DIR/session_registry.json" ] || [ -f "$ACTIVE_SESSION_FILE" ]; then
  # User has session history — offer resume/slot options
  startup_output=$(bash "$DIR/scripts/session_manager.sh" startup 2>/dev/null)
  startup_exit=$?
  if [ $startup_exit -ne 0 ]; then
    exit 0
  fi
  
  # Extract session ID if created (last line)
  SESSION_ID=$(echo "$startup_output" | grep -E "^AETHER-" | tail -1)
fi

boot_sequence

BATT=$(termux-battery-status 2>/dev/null | grep percentage | cut -d: -f2 | tr -d ' ,%')
STR=$(df -h /data | awk 'NR==2 {print $4}')
mkdir -p "$SESSION_DIR"

while true; do
    clear
    ROWS=$(tput lines); VPAD=$(( (ROWS - 18) / 2 ))
    [ $VPAD -lt 0 ] && VPAD=0
    for i in $(seq 1 $VPAD); do echo ""; done
    
    echo -e "\n\033[1;34m"
    figlet -f small "   AETHER"
    echo -e "\033[0;34m   NEURAL OPERATING INTERFACE // V 20.0\033[0m\n"

    # SYSTEM STATUS COMPACT
    STATUS_LINE=" 🔋 BATT: ${BATT:-N/A}%  •  💾 STR: $STR  •  🧠 VAULT: ACTIVE"
    if [ -n "$SESSION_ID" ]; then
      STATUS_LINE="$STATUS_LINE  •  📋 $SESSION_ID"
    fi
    gum style --foreground "$ACCENT" --border rounded --border-foreground "$DIM" --padding "0 2" --width 60 \
      "$STATUS_LINE"

    echo -e "\n"
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
            TOOL=$(gum choose \
                " 🧹 PURGE (Clear Memory) " \
                " 📖 LIBRARIAN (Audit Vault) " \
                " 📏 BENCHMARK (Hardware) " \
                " 🛒 SKILL MARKET (Extensions) " \
                " ⚙ SETTINGS (Configuration) " \
                " 📦 CONTEXT IMPORT " \
                " 🔄 WORKFLOWS " \
                " 🗜 TOKEN OPTIMIZER " \
                " 📋 SESSION MANAGER " \
                " 🧠 MEMORY SLOTS " \
                " 🐞 DEBUG CONSOLE (Self-Healing) " \
                " 🔙 BACK ")
            case "$TOOL" in
                *"PURGE"*) rm -f "$SESSION_DIR/last_session.log" && gum toast "Memory Wiped." ;;
                *"LIBRARIAN"*) python3 "$DIR/scripts/librarian.py" | gum pager ;;
                *"BENCHMARK"*) ./bench.sh ;;
                *"MARKET"*) ./scripts/skill_market.sh ;;
                *"SETTINGS"*) bash "$DIR/settings/settings.sh" ui ;;
                *"CONTEXT"*) bash "$DIR/contexts/context_manager.sh" list ;;
                *"WORKFLOWS"*) bash "$DIR/scripts/workflow_engine.sh" list ;;
                *"TOKEN"*) bash "$DIR/scripts/token_optimizer.sh" stats ;;
                *"SESSION"*) bash "$DIR/scripts/session_manager.sh" list ;;
                *"MEMORY"*) bash "$DIR/scripts/session_manager.sh" slots ;;
                *"DEBUG"*) ./scripts/debug_console.sh ;;
            esac
            ;;
        *) exit 0 ;;
    esac
done
