#!/usr/bin/env bash

DIR="$HOME/termux-ai-workspace"
BIN="$HOME/llama.cpp/build/bin/llama-cli"
MODELS="$DIR/models"
SYS_CONFIG="$DIR/knowledge/system.env"

# Load hardware config
source "$SYS_CONFIG"

PARAMS="-t 4 -c 2048 --mmap --log-disable"

# Safely load local Knowledge Base (RAG)
if ls "$DIR/knowledge/"*.txt 1> /dev/null 2>&1; then
    KNOWLEDGE=$(cat "$DIR/knowledge/"*.txt | head -c 1000)
else
    KNOWLEDGE="No external knowledge loaded."
fi

# --- DISTRIBUTABLE SYSTEM PROMPTS ---
# Styled as terminal boot logs so they look intentional when printed to the screen.

PROMPT_TURBO="[SYSTEM INITIALIZATION]
Module: Aether (⚡ Turbo Tier)
Host: $HW_DEVICE
Local Context: $KNOWLEDGE
Directives: You are a rapid-response offline Neural Interface. Provide extremely concise, factual answers. Do not use filler phrases like 'As an AI' or 'Here is your answer'. Await user input."

PROMPT_AGENT="[SYSTEM INITIALIZATION]
Module: Aether (🤖 Agent Tier)
Engine: Hermes-3 Tool-Use Framework
Host: Termux on $HW_DEVICE
Local Context: $KNOWLEDGE
Directives: You are an elite, autonomous task runner. You do not converse. Your sole function is to generate flawlessly formatted, copy-pasteable Bash code tailored for aarch64 Android. 
Rule 1: Never explain the code. 
Rule 2: Wrap all commands strictly in \`\`\`bash ... \`\`\` blocks. 
Rule 3: Use free/local tools. Await user task."

PROMPT_LOGIC="[SYSTEM INITIALIZATION]
Module: Aether (🧠 Logic Tier)
Engine: Gemma-2 Deep Reasoning
Host: $HW_DEVICE
Local Context: $KNOWLEDGE
Directives: You are a deep-reasoning engine. Break complex problems into logical, step-by-step deductions. Prioritize absolute technical accuracy over speed. Await user input."

# Menu Rendering
clear
figlet -f small "  AETHER"
gum style --border rounded --padding "0 1" " MEMORY: LOADED • DEVICE: $HW_DEVICE ($HW_RAM GB) "

CHOICE=$(gum choose "⚡ TURBO (3B)" "🤖 AGENT (8B)" "🧠 LOGIC (9B)" "📊 BENCHMARK" "❌ EXIT")

case "$CHOICE" in
    *"TURBO"*) 
        $BIN -m "$MODELS/llama-3.2-3b.gguf" -cnv $PARAMS -p "$PROMPT_TURBO" 
        ;;
    *"AGENT"*) 
        $BIN -m "$MODELS/hermes-3-8b.gguf" -cnv $PARAMS -p "$PROMPT_AGENT" 
        ;;
    *"LOGIC"*) 
        $BIN -m "$MODELS/gemma-2-9b.gguf" -cnv $PARAMS -p "$PROMPT_LOGIC" 
        ;;
    *"BENCHMARK"*) 
        bash "$DIR/bench.sh" 
        ;;
    *) 
        clear
        exit 0 
        ;;
esac
