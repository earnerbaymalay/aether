#!/usr/bin/env bash

echo "[*] Updating packages..."
pkg update -y && pkg upgrade -y

echo "[*] Installing dependencies..."
pkg install git build-essential cmake ninja gum termux-api figlet ncurses-utils wget -y

echo "[*] Creating environment..."
mkdir -p models knowledge ~/.aether/sessions

echo "[*] Setting up global 'ai' shortcut..."
cat << 'SHORTCUT' > $PREFIX/bin/ai
#!/usr/bin/env bash
cd ~/termux-ai-workspace && ./aether.sh
SHORTCUT
chmod +x $PREFIX/bin/ai

echo -e "\n[+] Installation complete! Type 'ai' from anywhere to launch Aether."
