#!/usr/bin/env bash
# web_read.sh
# Reads the text content of a URL using Lynx (FOSS & Privacy-First).

URL="$1"

if [ -z "$URL" ]; then
    echo "Error: No URL provided."
    exit 1
fi

if ! command -v lynx &>/dev/null; then
    echo "[*] Lynx not found. Installing..."
    pkg install lynx -y >/dev/null
fi

# -dump converts the page to clean markdown-like text
# -hiddenlinks=ignore prevents privacy-leaking tracker links
# -nonumbers simplifies the output for the AI
lynx -dump -hiddenlinks=ignore -nonumbers "$URL" | head -c 5000
