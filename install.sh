#!/usr/bin/env bash
# 🌌 Aether-AI Guided Onboarding // V 20.0
# Sets up the neural interface with modular optional extras

set -e

if [ -z "$PREFIX" ]; then
    echo "[ERROR] \$PREFIX is not set. This script must be run inside Termux."
    exit 1
fi

# --- Configuration ---
ACCENT="#00ff9d"; SUC="#50fa7b"; ERR="#ff5555"; DIM="#888"
DIR="$HOME/aether"
HAS_GUM=false
command -v gum &>/dev/null && HAS_GUM=true

# --- UI Helpers ---
header() {
    clear
    if command -v figlet &>/dev/null; then
        figlet -f small "AETHER" 2>/dev/null || echo "AETHER"
    else
        echo "=== AETHER ==="
    fi
    echo "   NEURAL OPERATING INTERFACE // V20.0"
    echo "   Your Phone. Your AI. Your Rules."
    echo ""
}

spin() {
    if $HAS_GUM; then
        gum spin --spinner dot --title "$1" -- sleep 2
    else
        echo "[*] $1..."
    fi
}

info() { echo -e "\033[1;32m[+]\033[0m $1"; }
warn() { echo -e "\033[1;33m[!]\033[0m $1"; }

prompt() {
    if $HAS_GUM; then
        gum confirm "$1" 2>/dev/null
    else
        read -p "$1 (y/n): " ans
        [[ "$ans" =~ ^[Yy] ]]
    fi
}

# ============================================================
# 1. WELCOME — EXISTING INSTALL DETECTION
# ============================================================
header

# Detect existing Aether install
AETHER_INSTALLED=false
LLAMA_INSTALLED=false
SHORTCUT_EXISTS=false
INSTALL_TYPE=""

if [ -d "$DIR" ] && [ -f "$DIR/aether.sh" ]; then
    AETHER_INSTALLED=true
    # Read existing version
    if [ -f "$DIR/VERSION" ]; then
        OLD_VER=$(cat "$DIR/VERSION" 2>/dev/null || echo "unknown")
    else
        OLD_VER="pre-26.04"
    fi
fi
[ -f "$HOME/llama.cpp/build/bin/llama-cli" ] && LLAMA_INSTALLED=true
[ -f "$PREFIX/bin/ai" ] && SHORTCUT_EXISTS=true

if [ "$AETHER_INSTALLED" = true ]; then
    echo ""
    echo "  An existing Aether installation was found (v$OLD_VER)."
    echo "  llama.cpp: $(if $LLAMA_INSTALLED; then echo '✅'; else echo '❌'; fi)    Shortcut: $(if $SHORTCUT_EXISTS; then echo '✅'; else echo '❌'; fi)"
    echo ""
    echo "  What would you like to do?"
    echo ""
    if $HAS_GUM; then
        INSTALL_TYPE=$(gum choose "Update (refresh scripts & config)" "Reinstall (full clean install)" "Quick fix (repair only)" "Exit")
    else
        echo "  1) Update (refresh scripts & config)"
        echo "  2) Reinstall (full clean install)"
        echo "  3) Quick fix (repair only)"
        echo "  4) Exit"
        read -p "  Choose [1-4]: " choice
        case "$choice" in
            1) INSTALL_TYPE="Update (refresh scripts & config)" ;;
            2) INSTALL_TYPE="Reinstall (full clean install)" ;;
            3) INSTALL_TYPE="Quick fix (repair only)" ;;
            *) exit 0 ;;
        esac
    fi

    case "$INSTALL_TYPE" in
        *"Update"*)
            info "Refreshing Aether installation..."
            # Only refresh scripts, shortcuts, and config — skip heavy deps
            SKIP_HEAVY=true
            ;;
        *"Reinstall"*)
            info "Full reinstall — all components will be rebuilt..."
            SKIP_HEAVY=false
            ;;
        *"Quick fix"*)
            info "Running repairs only..."
            SKIP_HEAVY=true
            # Fix shortcut
            cat << 'SHORTCUT' > $PREFIX/bin/ai
#!/usr/bin/env bash
cd ~/aether && ./aether.sh
SHORTCUT
            chmod +x $PREFIX/bin/ai
            info "Shortcut repaired"
            echo ""
            echo "Done. Type 'ai' to launch Aether."
            exit 0
            ;;
        *) exit 0 ;;
    esac
else
    echo "Welcome to the Aether Ecosystem."
    echo "This installer sets up a local-first AI neural interface"
    echo "that runs entirely on-device. No cloud. No tracking."
    echo ""
    SKIP_HEAVY=false
    if ! prompt "Begin installation?"; then
        echo "Installation cancelled."
        exit 0
    fi
fi

# ============================================================
# 2. SYSTEM UPDATE (skip on update/repair)
# ============================================================
if [ "$SKIP_HEAVY" != "true" ]; then
header
spin "Initializing package manager"
echo "[*] Synchronizing repositories..."
pkg update -y 2>&1 | tail -3
fi

# ============================================================
# 3. CORE DEPENDENCIES (skip on update/repair)
# ============================================================
if [ "$SKIP_HEAVY" != "true" ]; then
header
CORE_DEPS="git build-essential cmake ninja termux-api figlet ncurses-utils wget curl python"
echo "[*] Installing core dependencies..."
pkg install $CORE_DEPS -y 2>&1 | tail -3
info "Core dependencies installed"

# Optional: gum (for enhanced TUI)
if ! command -v gum &>/dev/null; then
    echo ""
    echo "[!] gum (enhanced TUI) is recommended but requires Go"
    if prompt "Install gum for better UI?"; then
        pkg install gum -y 2>&1 | tail -2
        HAS_GUM=true
        info "gum installed"
    else
        warn "Using text-based UI (gum not installed)"
    fi
fi
else
header
info "Skipping core dependencies (already installed)"
fi

# ============================================================
# 4. DIRECTORY STRUCTURE
# ============================================================
header
echo "[*] Scaffolding neural environment..."
mkdir -p "$DIR/models" "$DIR/knowledge/aethervault" "$DIR/scripts" "$DIR/skills"
mkdir -p "$DIR/toolbox" "$DIR/settings" "$DIR/lsp" "$DIR/contexts"
mkdir -p "$DIR/plugins" "$DIR/workflows/registry" "$DIR/user_commands"
mkdir -p "$HOME/.aether/sessions" "$HOME/.aether/config" "$HOME/.aether/backups"
info "Directory structure created"

# ============================================================
# 5. LLAMA.CPP ENGINE (skip on update/repair)
# ============================================================
if [ "$SKIP_HEAVY" != "true" ]; then
header
if [ ! -f "$HOME/llama.cpp/build/bin/llama-cli" ]; then
    echo "[*] Building llama.cpp inference engine..."
    cd ~
    if [ ! -d "llama.cpp" ]; then
        git clone https://github.com/ggerganov/llama.cpp --depth 1
    fi
    cd llama.cpp
    mkdir -p build && cd build
    cmake .. -G Ninja -DGGML_OPENMP=OFF 2>&1 | tail -3
    ninja llama-cli llama-server 2>&1 | tail -5
    cd "$DIR"
    info "llama.cpp engine built successfully"
else
    info "llama.cpp engine already exists"

    # Offer to update
    if prompt "Update llama.cpp to latest version?"; then
        cd ~/llama.cpp
        git pull 2>&1 | tail -3
        cd build && ninja llama-cli llama-server 2>&1 | tail -3
        cd "$DIR"
        info "llama.cpp updated"
    fi
fi
else
header
if [ -f "$HOME/llama.cpp/build/bin/llama-cli" ]; then
    info "llama.cpp engine is ready ($(~/llama.cpp/build/bin/llama-cli --version 2>&1 | head -1 || echo 'ok'))"
else
    warn "llama.cpp not found — run a full install to build it"
fi
fi

# ============================================================
# 6. MODEL DOWNLOAD (Optional at install time)
# ============================================================
header
echo "Model Downloads (can be done later from within Aether)"
echo ""
echo "Available models:"
echo "  1. Llama-3.2-3B (TURBO - fast, lightweight)"
echo "  2. DeepSeek-R1-1.5B (LOGIC - reasoning specialist)"
echo "  3. Qwen2.5-Coder-3B (CODE - code generation)"
echo "  4. Hermes-2-Pro-8B (AGENT - tool use, general)"
echo ""

if prompt "Download the lightweight Llama-3.2-3B model now? (~2GB)"; then
    MODEL_DIR="$DIR/models/Llama-3.2-3B-Instruct-GGUF"
    mkdir -p "$MODEL_DIR"
    MODEL_FILE="$MODEL_DIR/llama-3.2-3b-instruct-q4_k_m.gguf"
    
    if [ ! -f "$MODEL_FILE" ]; then
        echo "[*] Downloading Llama-3.2-3B..."
        MODEL_URL="https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf"
        if ! wget -O "$MODEL_FILE" "$MODEL_URL" 2>&1 | tail -5; then
            warn "Model download failed. You can retry later with Aether's model manager."
            rm -f "$MODEL_FILE"
        else
            info "Model downloaded to $MODEL_FILE"
        fi
    else
        info "Model already exists"
    fi
else
    warn "Skipping model download - download later from Aether's model manager"
fi

# ============================================================
# 7. OPTIONAL EXTRAS
# ============================================================
header
echo "=== Optional Extras ==="
echo "These can be enabled later from: ~/aether/settings/settings.sh"
echo ""

EXTRAS_ENABLED=""

# Voice I/O
if prompt "Enable Voice I/O (speech-to-text + text-to-speech)?"; then
    EXTRAS_ENABLED="$EXTRAS_ENABLED voice_stt voice_tts"
    info "Voice I/O enabled"
fi

# LSP Server
if prompt "Enable LSP Server (code intelligence)?"; then
    EXTRAS_ENABLED="$EXTRAS_ENABLED lsp_server"
    info "LSP Server enabled"
fi

# Auto Scaler
if prompt "Enable Auto Scaler (dynamic resource management)?"; then
    EXTRAS_ENABLED="$EXTRAS_ENABLED auto_scaler"
    info "Auto Scaler enabled"
fi

# Context Import
if prompt "Enable Context Import (Gemini-style context management)?"; then
    EXTRAS_ENABLED="$EXTRAS_ENABLED context_import"
    info "Context Import enabled"
fi

# Testing Framework
if prompt "Enable Testing Framework (automated tests)?"; then
    EXTRAS_ENABLED="$EXTRAS_ENABLED testing_framework"
    info "Testing Framework enabled"
fi

# Android Shortcuts
if prompt "Create Android home screen shortcuts?"; then
    EXTRAS_ENABLED="$EXTRAS_ENABLED android_shortcuts"
    info "Android shortcuts created"
fi

# Nmap
if prompt "Install nmap for security scanning?"; then
    pkg install nmap -y 2>&1 | tail -2
    EXTRAS_ENABLED="$EXTRAS_ENABLED nmap_full"
    info "nmap installed"
fi

# Install enabled extras
if [ -n "$EXTRAS_ENABLED" ]; then
    for extra in $EXTRAS_ENABLED; do
        if [ -f "$DIR/scripts/extras_installer.sh" ]; then
            bash "$DIR/scripts/extras_installer.sh" enable "$extra" 2>/dev/null || true
        else
            warn "extras_installer.sh not found — skipping extra: $extra"
        fi
    done
fi

# ============================================================
# 8. GLOBAL SHORTCUT
# ============================================================
header
echo "[*] Configuring 'ai' global shortcut..."
cat << 'SHORTCUT' > $PREFIX/bin/ai
#!/usr/bin/env bash
# Aether AI Shortcut
cd ~/aether && ./aether.sh
SHORTCUT
chmod +x $PREFIX/bin/ai
info "Global 'ai' shortcut created"

# ============================================================
# 9. CONFIGURATION
# ============================================================
header
echo "[*] Setting up configuration..."

# Create default config
if [ -f "$DIR/settings/settings.sh" ]; then
    bash "$DIR/settings/settings.sh" ui 2>/dev/null || echo "  (Settings available at: ~/aether/settings/settings.sh)"
else
    warn "settings.sh not found — skipping UI configuration"
fi

# Initialize extras config
if [ -f "$DIR/scripts/extras_installer.sh" ]; then
    bash "$DIR/scripts/extras_installer.sh" status 2>/dev/null || true
else
    warn "extras_installer.sh not found — skipping status check"
fi

info "Configuration initialized"

# ============================================================
# 10. FINALIZE
# ============================================================
header

if $HAS_GUM; then
    gum style --foreground "$SUC" --border double --padding "1 2" "DEPLOYMENT COMPLETE"
else
    echo "==============================="
    echo "   DEPLOYMENT COMPLETE"
    echo "==============================="
fi

echo ""
echo "Quick Start:"
echo "  ai                          Launch Aether"
echo "  ~/aether/settings/settings.sh  Open Settings"
echo "  ~/aether/scripts/extras_installer.sh  Manage Extras"
echo ""
echo "Documentation:"
echo "  ~/aether/README.md          User guide"
echo "  ~/aether/ROADMAP.md         Future plans"
echo "  ~/aether/USAGE.md           Usage examples"
echo ""

if prompt "Run hardware benchmark now?"; then
    if [ -f "$DIR/bench.sh" ]; then
        bash "$DIR/bench.sh"
    else
        warn "bench.sh not found — skipping benchmark"
    fi
fi

echo ""
echo "Aether V20.0 is ready. Beyond the clouds."
