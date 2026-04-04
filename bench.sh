#!/usr/bin/env bash

DIR="$HOME/termux-ai-workspace"
BIN="$HOME/llama.cpp/build/bin/llama-cli"
MODEL="$DIR/models/llama-3.2-3b.gguf"

clear
echo -e "\n=== AETHER HARDWARE PROFILER ==="
echo "Gathering device metrics..."

DEVICE=$(getprop ro.product.model || echo "Unknown Device")
SOC=$(getprop ro.board.platform || echo "Unknown SoC")
RAM=$(free -m | awk '/Mem:/ {print $3" MB used / "$2" MB total"}')

echo "Running Llama-3.2-3B evaluation..."
echo "This will take a moment."

TMP_LOG=$(mktemp)
# Added -c 128 and --mmap to prevent Android OOM (Out Of Memory) process kills
$BIN -m "$MODEL" -c 128 -t 4 --mmap -n 15 -p "1 2 3" > /dev/null 2> "$TMP_LOG"

TPS=$(grep "eval time" "$TMP_LOG" | awk '{print $(NF-3)}')

if [ -z "$TPS" ]; then
    TPS="ERROR: Process killed by Android (OOM)"
fi
rm "$TMP_LOG"

clear
echo -e "\n=== BENCHMARK RESULTS ==="
echo -e "📱 Device:  $DEVICE"
echo -e "⚙️ Chipset: $SOC"
echo -e "🧠 RAM:     $RAM"
echo -e "⚡ Speed:   $TPS Tokens/sec"
echo -e "📅 Date:    $(date +'%Y-%m-%d %H:%M')"
echo -e "=========================\n"

echo "Device: $DEVICE | RAM: $RAM | Speed: $TPS t/s | Date: $(date)" >> "$DIR/hardware_report.txt"

read -p "Press Enter to return to main menu..."
bash "$DIR/aether.sh"
