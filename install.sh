#!/usr/bin/env bash
# 🌌 Aether-AI Installation Script // V 18.0
# Sets up the neural interface and dependencies on Termux.

set -e

# --- UI Helpers ---
INF="\033[1;34m[*]\033[0m"
SUC="\033[1;32m[+]\033[0m"
ERR="\033[1;31m[!]\033[0m"

echo -e "$INF Initializing Aether-AI Deployment..."

# 1. Update Packages
echo -e "$INF Updating system packages..."
pkg update -y && pkg upgrade -y

# 2. Install Dependencies
DEPS="git build-essential cmake ninja gum termux-api figlet ncurses-utils wget"
echo -e "$INF Installing core dependencies: $DEPS"
pkg install $DEPS -y

# 3. Create Structure
echo -e "$INF Scaffolding neural environment..."
mkdir -p models knowledge scripts skills ~/.aether/sessions

# 4. Handle llama.cpp (The Engine)
if [ ! -f "$HOME/llama.cpp/build/bin/llama-cli" ]; then
    echo -e "$INF Llama-CLI not found. Building engine from source..."
    cd ~
    [ ! -d "llama.cpp" ] && git clone https://github.com/ggerganov/llama.cpp
    cd llama.cpp
    mkdir -p build && cd build
    cmake .. -G Ninja -DGGML_OPENMP=OFF # Disable OpenMP for Android stability
    ninja llama-cli
    cd ~/aether
else
    echo -e "$SUC Llama-CLI engine detected."
fi

# 5. Global Shortcut
echo -e "$INF Configuring 'ai' global shortcut..."
cat << 'SHORTCUT' > $PREFIX/bin/ai
#!/usr/bin/env bash
# Aether AI Shortcut
cd ~/aether && ./aether.sh
SHORTCUT
chmod +x $PREFIX/bin/ai

# 6. Finalize
echo -e "\n$SUC Installation Complete!"
echo -e "$INF You can now launch the interface by typing: \033[1;32mai\033[0m"
echo -e "$INF Or run manually with: \033[1;34m./aether.sh\033[0m"
