#!/usr/bin/env bash
# 🌌 Aether-AI Hardware Profiler // V 18.0
# Measures local inference performance on Android.

# --- Colors ---
ACCENT="#81a1c1"; SUC="#50fa7b"; ERR="#ff5555"

# --- Setup ---
DIR="$HOME/aether"
BIN="$HOME/llama.cpp/build/bin/llama-cli"
MODEL="$DIR/models/llama-3.2-3b.gguf"

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
gum style --foreground "$ACCENT" --border double --padding "1" "SYSTEM BENCHMARK INITIATED"
echo "Gathering device metrics and profiling performance..."

DEVICE=$(getprop ro.product.model || echo "Unknown Device")
SOC=$(getprop ro.board.platform || echo "Unknown SoC")
RAM=$(free -m | awk '/Mem:/ {print $3" MB used / "$2" MB total"}')

TMP_LOG=$(mktemp)
# Performance evaluation (Limited context to prevent OOM)
$BIN -m "$MODEL" -c 128 -t 6 --mmap -n 20 -p "The future of mobile AI is" > /dev/null 2> "$TMP_LOG"

TPS=$(grep "eval time" "$TMP_LOG" | awk '{print $(NF-3)}')

if [ -z "$TPS" ]; then
    TPS="ERROR: Inference Failed (OOM?)"
fi
rm "$TMP_LOG"

clear
echo -e "\n\033[1;34m=== BENCHMARK RESULTS ===\033[0m"
echo -e "📱 Device:  $DEVICE"
echo -e "⚙️ Chipset: $SOC"
echo -e "🧠 RAM:     $RAM"
echo -e "⚡ Speed:   \033[1;32m$TPS Tokens/sec\033[0m"
echo -e "📅 Date:    $(date +'%Y-%m-%d %H:%M')"
echo -e "=========================\n"

# Save report
echo "Device: $DEVICE | RAM: $RAM | Speed: $TPS t/s | Date: $(date)" >> "$DIR/hardware_report.txt"

gum style --foreground "$SUC" "Report saved to hardware_report.txt"
read -p "Press Enter to return..."
