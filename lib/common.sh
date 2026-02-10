#!/data/data/com.termux/files/usr/bin/bash
# Shared functions for Termux-Vault tools

# --- Colors ---
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
RESET='\033[0m'

# --- Output helpers ---
info()    { printf "${BLUE}[*]${RESET} %s\n" "$*"; }
ok()      { printf "${GREEN}[+]${RESET} %s\n" "$*"; }
warn()    { printf "${YELLOW}[!]${RESET} %s\n" "$*"; }
err()     { printf "${RED}[-]${RESET} %s\n" "$*" >&2; }
step()    { printf "${CYAN}==> %s${RESET}\n" "$*"; }

# --- Guard: must be running in Termux ---
require_termux() {
    if [ ! -d "/data/data/com.termux" ] 2>/dev/null; then
        err "Not running inside Termux. Aborting."
        exit 1
    fi
}

# --- Install packages quietly ---
pkg_install() {
    info "Installing: $*"
    pkg install -y "$@" 2>&1 | tail -1
}

# --- Check if a command exists ---
has() {
    command -v "$1" >/dev/null 2>&1
}

# --- Prompt yes/no (default yes) ---
confirm() {
    local prompt="${1:-Continue?}"
    printf "${YELLOW}%s [Y/n] ${RESET}" "$prompt"
    read -r ans
    case "$ans" in
        [nN]*) return 1 ;;
        *) return 0 ;;
    esac
}

# --- Ensure $PREFIX/bin is in PATH ---
ensure_path() {
    local dir="$1"
    case ":$PATH:" in
        *":$dir:"*) ;;
        *) export PATH="$dir:$PATH" ;;
    esac
}

# --- Resolve VAULT_ROOT (directory containing this lib) ---
VAULT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VAULT_BIN="$VAULT_ROOT/bin"
VAULT_LIB="$VAULT_ROOT/lib"
VAULT_CONFIG="$VAULT_ROOT/config"
