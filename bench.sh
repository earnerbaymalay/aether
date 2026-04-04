#!/usr/bin/env bash
# Aether-AI Hardware Profiler
BIN="$HOME/llama.cpp/build/bin/llama-cli"
MODEL="$HOME/termux-ai-workspace/models/llama-3.2-3b.gguf"

clear
gum style --foreground "#81a1c1" --border double --padding "1" "SYSTEM BENCHMARK INITIATED"

echo "Profiling hardware performance... please wait."
# Run a fixed prompt and capture the timing output
# We use the Turbo model for the benchmark
RESULT=$($BIN -m "$MODEL" -p "Write a 50 word story about a robot." -n 50 -t 6 --quiet --log-disable 2>&1 | grep "eval time")

TPS=$(echo "$RESULT" | awk '{print $11}')
gum style --foreground "#50fa7b" "RESULT: $TPS Tokens Per Second on ARM64"

# Save to a local report for the user
echo "Device: $(uname -m) | Speed: $TPS t/s | Date: $(date)" >> hardware_report.txt
read -p "Report saved. Press Enter..."
