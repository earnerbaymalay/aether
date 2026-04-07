#!/usr/bin/env bash
# 🌌 Aether-AI Guided Onboarding // V 18.0
# Sets up the neural interface and dependencies with a premium UX.

set -e

# --- Configuration ---
ACCENT="#81a1c1"; SUC="#50fa7b"; ERR="#ff5555"
DIR="$HOME/aether"

# --- UI Helpers ---
header() {
    clear
    figlet -f small "  AETHER" | gum style --foreground "$ACCENT"
    echo -e "   \033[1;30mNEURAL OPERATING INTERFACE // DEPLOYMENT\033[0m\n"
}

# 1. Start Onboarding
header
gum style --foreground "$ACCENT" --border rounded "Welcome to the Aether Ecosystem."
echo "This installer will prepare your local neural environment."
gum confirm "Ready to begin deployment?" || exit 0

# 2. Update & Install Dependencies
header
gum spin --spinner dots --title "Initializing Core Systems..." -- sleep 1
echo -e "\033[1;34m[*]\033[0m Synchronizing repositories..."
pkg update -y && pkg upgrade -y

header
DEPS="git build-essential cmake ninja gum termux-api figlet ncurses-utils wget"
echo -e "\033[1;34m[*]\033[0m Installing neural dependencies: $DEPS"
pkg install $DEPS -y

# 3. Create Structure
header
echo -e "\033[1;34m[*]\033[0m Scaffolding neural environment..."
mkdir -p models knowledge/context7 scripts skills ~/.aether/sessions

# 4. Handle llama.cpp (The Engine)
header
if [ ! -f "$HOME/llama.cpp/build/bin/llama-cli" ]; then
    echo -e "\033[1;34m[*]\033[0m Building High-Performance C++ Engine..."
    cd ~
    [ ! -d "llama.cpp" ] && git clone https://github.com/ggerganov/llama.cpp --depth 1
    cd llama.cpp
    mkdir -p build && cd build
    cmake .. -G Ninja -DGGML_OPENMP=OFF # Optimized for Android stability
    ninja llama-cli
    cd "$DIR"
else
    echo -e "\033[1;32m[+]\033[0m Llama-CLI engine already synchronized."
fi

# 5. Global Shortcut
header
echo -e "\033[1;34m[*]\033[0m Configuring 'ai' global shortcut..."
cat << 'SHORTCUT' > $PREFIX/bin/ai
#!/usr/bin/env bash
# Aether AI Shortcut
cd ~/aether && ./aether.sh
SHORTCUT
chmod +x $PREFIX/bin/ai

# 6. Finalize & Optimize
header
gum style --foreground "$SUC" --border double "DEPLOYMENT COMPLETE"
echo -e "\n\033[1;34m[*]\033[0m Aether requires a hardware profile to optimize its neural engine."

if gum confirm "Run hardware profiling now? (Highly Recommended)"; then
    ./bench.sh
else
    echo -e "\033[1;33m[!]\033[0m Skipping profiling. Aether will use generic (slower) settings."
    echo "TIER=GENERIC" > "$DIR/.aether_config"
    echo "THREADS=4" >> "$DIR/.aether_config"
fi

echo -e "\n\033[1;32m[+]\033[0m You can now launch the interface by typing: \033[1;32mai\033[0m"
echo -e "\033[1;34m[*]\033[0m Aether is ready. Beyond the clouds."
