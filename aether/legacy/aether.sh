#!/bin/bash
# AetherAI Operator Interface v1.0 - Nokia XR20 Optimized
# Location: West Perth, WA | Device: ARM64

# --- Configuration ---
WORKSPACE="$HOME/aether"
LOGS="$HOME/.aether/sessions/last_chat.txt"
MODEL="qwen2.5-coder:1.5b"

# --- Palette ---
BL=$'\033[34m'; GR=$'\033[32m'; YL=$'\033[33m'; R=$'\033[0m'; B=$'\033[1m'

clear
echo "${BL}${B}  AETHER AI OPERATOR (Local)${R}"
echo "${BL}  --------------------------${R}"

# Ensure Ollama is running locally
if ! pgrep ollama >/dev/null; then
    echo "  ${YL}→ Starting local Ollama server...${R}"
    ollama serve > /dev/null 2>&1 &
    sleep 5
fi

# Check for model
if ! ollama list | grep -q "$MODEL"; then
    echo "  ${YL}→ Model not found. Pulling $MODEL...${R}"
    ollama pull "$MODEL"
fi

echo "  ${GR}✓ Ready.${R}"
echo ""

# Launch the Python Agent
python3 "$WORKSPACE/agent/chat.py"
