#!/data/data/com.termux/files/usr/bin/bash
# Termux-Vault bootstrap installer
# Usage: curl -fsSL <raw-url>/setup/bootstrap.sh | bash

set -euo pipefail

REPO="https://github.com/earnerbaymalay/Termux-Vault.git"
INSTALL_DIR="$HOME/Termux-Vault"

info()  { printf '\033[1;34m[*]\033[0m %s\n' "$*"; }
ok()    { printf '\033[1;32m[+]\033[0m %s\n' "$*"; }
err()   { printf '\033[1;31m[-]\033[0m %s\n' "$*" >&2; }

# --- preflight ---
if [ ! -d "/data/data/com.termux" ] 2>/dev/null; then
    err "This script is intended for Termux. Exiting."
    exit 1
fi

info "Updating package lists..."
pkg update -y -q 2>/dev/null || apt-get update -y -qq

info "Installing git if missing..."
command -v git >/dev/null || pkg install -y git

# --- clone / update ---
if [ -d "$INSTALL_DIR/.git" ]; then
    info "Termux-Vault already cloned — pulling latest..."
    git -C "$INSTALL_DIR" pull --ff-only origin main || true
else
    info "Cloning Termux-Vault..."
    git clone "$REPO" "$INSTALL_DIR"
fi

# --- install ---
cd "$INSTALL_DIR"
make install

ok "Termux-Vault installed successfully!"
ok "Run 'tvault --help' to get started."
