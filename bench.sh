#!/usr/bin/env bash
# 🌌 Aether-AI Hardware Profiler // V 18.0 (Tier-Aware)
# Measures local inference performance and assigns a hardware profile.

# --- Colors ---
ACCENT="#81a1c1"; SUC="#50fa7b"; ERR="#ff5555"

# --- Setup ---
DIR="$HOME/aether"
BIN="$HOME/llama.cpp/build/bin/llama-cli"
MODEL="$DIR/models/llama-3.2-3b.gguf"
CONFIG_FILE="$DIR/.aether_config"

if [ ! -f "$BIN" ]; then
    echo -e "\033[1;31m[!] Llama-CLI engine missing. Run ./install.sh\033[0m"
    exit 1
fi

if [ ! -f "$MODEL" ]; then
    echo -e "\033[1;31m[!] Benchmark model (Llama-3.2-3B) missing.\033[0m"
    echo -e "Please download it first using the 'TURBO' option in ./aether.sh"
    exit 1
fi

clear
gum style --foreground "$ACCENT" --border double --padding "1" "SYSTEM PROFILER INITIATED"
echo "Profiling device capabilities for optimal neural routing..."

DEVICE=$(getprop ro.product.model || echo "Unknown Device")
SOC=$(getprop ro.board.platform || echo "Unknown SoC")
RAM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
RAM_HUMAN=$(free -h | awk '/Mem:/ {print $2}')

# Detect Cores
CORES=$(nproc)
OPTIMAL_THREADS=$((CORES - 2))
[ $OPTIMAL_THREADS -lt 1 ] && OPTIMAL_THREADS=1

TMP_LOG=$(mktemp)
# Performance evaluation (Limited context to prevent OOM)
$BIN -m "$MODEL" -c 128 -t "$OPTIMAL_THREADS" --mmap -n 30 -p "The future of mobile AI is" > /dev/null 2> "$TMP_LOG"

TPS=$(grep "eval time" "$TMP_LOG" | awk '{print $(NF-3)}')
[ -z "$TPS" ] && TPS="0.0"

# --- TIER ASSIGNMENT ---
# Bronze: < 4GB RAM or < 5 TPS
# Silver: 4-8GB RAM and 5-15 TPS
# Gold: > 8GB RAM and > 15 TPS

TIER="BRONZE"
TIER_COLOR="$ERR"

if (( $(echo "$RAM_TOTAL >= 4000" | bc -l) )) && (( $(echo "$TPS >= 5.0" | bc -l) )); then
    TIER="SILVER"
    TIER_COLOR="$ACCENT"
fi

if (( $(echo "$RAM_TOTAL >= 8000" | bc -l) )) && (( $(echo "$TPS >= 15.0" | bc -l) )); then
    TIER="GOLD"
    TIER_COLOR="$SUC"
fi

rm "$TMP_LOG"

clear
echo -e "\n\033[1;34m=== PROFILER RESULTS ===\033[0m"
echo -e "📱 Device:  $DEVICE ($SOC)"
echo -e "🧠 RAM:     $RAM_HUMAN"
echo -e "⚡ Speed:   $TPS Tokens/sec"
echo -e "🧵 Threads: $OPTIMAL_THREADS (Optimized)"
echo -e "🏆 Profile: $(gum style --foreground "$TIER_COLOR" --bold "$TIER")"
echo -e "=========================\n"

# --- SAVE CONFIGURATION ---
cat << EOF > "$CONFIG_FILE"
# Aether-AI Auto-Generated Hardware Config
TIER=$TIER
THREADS=$OPTIMAL_THREADS
RAM=$RAM_TOTAL
TPS=$TPS
DEVICE="$DEVICE"
DATE="$(date)"
EOF

echo "Device: $DEVICE | RAM: $RAM_HUMAN | Speed: $TPS t/s | Profile: $TIER | Date: $(date)" >> "$DIR/hardware_report.txt"

gum style --foreground "$SUC" "Hardware profile saved to .aether_config"
read -p "Press Enter to return..."
