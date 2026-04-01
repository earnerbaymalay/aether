#!/bin/bash

CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${CYAN}${BOLD}====================================================${NC}"
echo -e "${CYAN}${BOLD}       NEXUS AI WORKSPACE - DEPLOYMENT WIZARD       ${NC}"
echo -e "${CYAN}${BOLD}====================================================${NC}"
echo -e "${YELLOW}Target Environment:${NC} Termux (Android/AArch64)"
echo -e "${YELLOW}Architect:${NC} KHEMM\n"

# 1. Hardware & OS Check
echo -e "${CYAN}[1/5] Analyzing System Architecture...${NC}"
if [ "$(uname -m)" = "aarch64" ]; then
    echo -e "${GREEN}  ✓ AArch64 detected. Mobile optimization active.${NC}"
else
    echo -e "${YELLOW}  ⚠ Warning: Non-AArch64 environment detected.${NC}"
fi
sleep 1

# 2. Dependency Resolution
echo -e "\n${CYAN}[2/5] Verifying Core Dependencies...${NC}"
for pkg in python nmap termux-services; do
    if dpkg -s $pkg &> /dev/null; then
        echo -e "${GREEN}  ✓ $pkg is installed.${NC}"
    else
        echo -e "${YELLOW}  ⚠ $pkg missing. Installing...${NC}"
        pkg install $pkg -y < /dev/null
    fi
done

pip install --quiet flask requests
echo -e "${GREEN}  ✓ Python microservices (Flask, Requests) secured.${NC}"

# 3. AI Engine Bootstrapping
echo -e "\n${CYAN}[3/5] Bootstrapping AI Engine (Ollama)...${NC}"
if command -v ollama &> /dev/null; then
    echo -e "${GREEN}  ✓ Ollama detected. Verifying Dolphin-phi model...${NC}"
    # Silently pull to ensure it exists or updates
    ollama pull dolphin-phi &> /dev/null &
    echo -e "${GREEN}  ✓ Dolphin-phi synchronization initiated in background.${NC}"
else
    echo -e "${RED}  ✗ Ollama is not installed. Please install Ollama manually for Termux.${NC}"
fi

# 4. Persistent Daemonization (Future Plan 1 Implemented)
echo -e "\n${CYAN}[4/5] Configuring Persistent Daemon...${NC}"
mkdir -p ~/.termux/boot
cat << 'SERVICE' > ~/.termux/boot/nexus-hub
#!/bin/bash
termux-wake-lock
cd ~/termux-ai-workspace
nohup python3 nexus_engine.py > /dev/null 2>&1 &
SERVICE
chmod +x ~/.termux/boot/nexus-hub
echo -e "${GREEN}  ✓ Nexus Hub added to Termux boot sequence.${NC}"

# 5. CLI Integration
echo -e "\n${CYAN}[5/5] Integrating Nexus CLI to Global PATH...${NC}"
if grep -q "alias nexus=" ~/.bashrc; then
    echo -e "${GREEN}  ✓ 'nexus' alias already exists in .bashrc.${NC}"
else
    echo "alias nexus='$HOME/termux-ai-workspace/nexus_cli.py'" >> ~/.bashrc
    echo -e "${GREEN}  ✓ Nexus command injected.${NC}"
fi

echo -e "\n${CYAN}${BOLD}====================================================${NC}"
echo -e "${GREEN}${BOLD} SYSTEM DEPLOYMENT COMPLETE ${NC}"
echo -e " To finalize, run: ${YELLOW}source ~/.bashrc${NC}"
echo -e " The Nexus Hub will now start automatically upon Termux launch."
echo -e "${CYAN}${BOLD}====================================================${NC}"
