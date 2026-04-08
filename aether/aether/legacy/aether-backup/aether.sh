#!/bin/bash
# AetherAI Operator Interface v2.0 - Robust Edition
# Nokia XR20 Optimized | ARM64 | Local-First

WORKSPACE="$HOME/aether"
MODEL="${AETHER_MODEL:-qwen2.5-coder:1.5b}"
SESSION_LOG="$HOME/.aether/sessions/last_session.log"

# Colors
BL=$'\033[34m'; GR=$'\033[32m'; YL=$'\033[33m'; RD=$'\033[31m'
R=$'\033[0m'; B=$'\033[1m'; DIM=$'\033[2m'

echo "${BL}${B}  AETHER AI OPERATOR v2.0${R}"
echo "${BL}  -------------------------${R}"

# --- 1. Ensure Ollama is running (robust wait) ---
if ! pgrep -x ollama > /dev/null 2>&1; then
    echo "  ${YL}[1/3] Starting Ollama server...${R}"
    ollama serve > /dev/null 2>&1 &
    # Poll until ready (max 15s)
    for i in $(seq 1 15); do
        if ollama list &>/dev/null; then
            echo "  ${GR}       Ollama ready (${i}s)${R}"
            break
        fi
        sleep 1
    done
    if ! ollama list &>/dev/null; then
        echo "  ${RD}[FAIL] Ollama did not start. Run 'ollama serve' manually.${R}"
        exit 1
    fi
else
    echo "  ${GR}[1/3] Ollama already running${R}"
fi

# --- 2. Ensure model is available ---
mkdir -p "$HOME/.aether/sessions"
if ! ollama list | grep -q "$MODEL" 2>/dev/null; then
    echo "  ${YL}[2/3] Pulling model: $MODEL (first time may take a while)...${R}"
    ollama pull "$MODEL" || {
        echo "  ${RD}[FAIL] Could not pull $MODEL. Check connectivity.${R}"
        exit 1
    }
else
    echo "  ${GR}[2/3] Model $MODEL ready${R}"
fi

# --- 3. Launch agent ---
echo "  ${GR}[3/3] Launching AetherAI Agent...${R}"
echo ""
cd "$WORKSPACE" || exit 1
exec python3 "$WORKSPACE/agent/chat.py"
