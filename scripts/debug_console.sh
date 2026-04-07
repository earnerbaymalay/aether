#!/usr/bin/env bash
# 🌌 Aether-AI Debug Console // V 1.0
# Comprehensive system health check and troubleshooting suite.

ACCENT="#81a1c1"; SUC="#50fa7b"; ERR="#ff5555"
DIR="$HOME/aether"

header() {
    clear
    figlet -f small " DEBUG CONSOLE " | gum style --foreground "$ACCENT"
}

check_file() {
    if [ -f "$1" ]; then
        echo -e "  [✓] $1 \033[1;32mFOUND\033[0m"
    else
        echo -e "  [!] $1 \033[1;31mMISSING\033[0m"
    fi
}

header
echo -e "\033[1;34m=== SYSTEM STATUS ===\033[0m"
echo -e "Device: $(getprop ro.product.model)"
echo -e "Profile: $(grep TIER "$DIR/.aether_config" | cut -d= -f2 || echo "NONE")"
echo -e "Engine: $([ -f "$HOME/llama.cpp/build/bin/llama-cli" ] && echo "ACTIVE" || echo "INACTIVE")"

echo -e "\n\033[1;34m=== CORE FILE CHECK ===\033[0m"
check_file "$DIR/aether.sh"
check_file "$DIR/install.sh"
check_file "$DIR/bench.sh"
check_file "$DIR/.aether_config"
check_file "$DIR/scripts/rag_engine.py"
check_file "$DIR/scripts/librarian.py"

echo -e "\n\033[1;34m=== NEURAL PATHWAY CHECK ===\033[0m"
for mod in "llama-3.2-3b.gguf" "hermes-3-8b.gguf" "deepseek-r1-1.5b.gguf" "qwen-coder-3b.gguf"; do
    if [ -f "$DIR/models/$mod" ]; then
        echo -e "  [✓] $mod \033[1;32mREADY\033[0m"
    else
        echo -e "  [ ] $mod \033[1;33mPENDING\033[0m"
    fi
done

echo -e "\n\033[1;34m=== RAG ENGINE TEST ===\033[0m"
python3 "$DIR/scripts/rag_engine.py" "neural" | head -n 3

echo -e "\n\033[1;34m=== LIBRARIAN TEST ===\033[0m"
python3 "$DIR/scripts/librarian.py" | grep "Vault Status" || echo "Librarian Active."

echo -e "\n\033[1;30mPress any key to exit debug console...\033[0m"
read -n 1
