#!/data/data/com.termux/files/usr/bin/bash
# model_router.sh - Display and manage AI model routing configuration
# Usage: model_router.sh [status|switch <model_name>|benchmark|list]

AETHER_DIR="$HOME/aether"
ACTION="${1:-status}"
MODEL_NAME="$2"

# Model registry with metadata
declare -A MODEL_META
MODEL_META["hermes"]="Hermes-8B|8B|logic|Balanced reasoning and instruction following"
MODEL_META["llama"]="Llama-3.2-3B|3B|turbo|Fast responses, lightweight, general purpose"
MODEL_META["deepseek"]="DeepSeek-R1-1.5B|1.5B|logic|Chain-of-thought reasoning specialist"
MODEL_META["qwen"]="Qwen-Coder-3B|3B|code|Code generation and understanding"
MODEL_META["qwen7b"]="Qwen-Coder-7B|7B|code|Advanced code generation (if available)"

# Model file paths
declare -A MODEL_PATHS
MODEL_PATHS["hermes"]="$HOME/.aether/models/Hermes-2-Pro-Llama-3-8B-GGUF/hermes-2-pro-llama-3-8b-q4_k_m.gguf"
MODEL_PATHS["llama"]="$HOME/.aether/models/Llama-3.2-3B-Instruct-GGUF/llama-3.2-3b-instruct-q4_k_m.gguf"
MODEL_PATHS["deepseek"]="$HOME/.aether/models/DeepSeek-R1-Distill-Qwen-1.5B-GGUF/deepseek-r1-distill-qwen-1.5b-q4_k_m.gguf"
MODEL_PATHS["qwen"]="$HOME/.aether/models/Qwen2.5-Coder-3B-Instruct-GGUF/qwen2.5-coder-3b-instruct-q4_k_m.gguf"
MODEL_PATHS["qwen7b"]="$HOME/.aether/models/Qwen2.5-Coder-7B-Instruct-GGUF/qwen2.5-coder-7b-instruct-q4_k_m.gguf"

# Model routing tiers (from aether.sh)
declare -A MODEL_TIERS
MODEL_TIERS["turbo"]="llama"
MODEL_TIERS["agent"]="hermes"
MODEL_TIERS["code"]="qwen"
MODEL_TIERS["logic"]="deepseek"

case "$ACTION" in
  status)
    echo "=== Model Routing Configuration ==="
    echo ""
    echo "Current Tier Assignments:"
    echo "  TURBO  → ${MODEL_TIERS[turbo]} ($(echo ${MODEL_META[${MODEL_TIERS[turbo]}]} | cut -d'|' -f3-4))"
    echo "  AGENT  → ${MODEL_TIERS[agent]} ($(echo ${MODEL_META[${MODEL_TIERS[agent]}]} | cut -d'|' -f3-4))"
    echo "  CODE   → ${MODEL_TIERS[code]} ($(echo ${MODEL_META[${MODEL_TIERS[code]}]} | cut -d'|' -f3-4))"
    echo "  LOGIC  → ${MODEL_TIERS[logic]} ($(echo ${MODEL_META[${MODEL_TIERS[logic]}]} | cut -d'|' -f3-4))"
    echo ""
    echo "Model Status:"
    for key in "${!MODEL_PATHS[@]}"; do
      path="${MODEL_PATHS[$key]}"
      meta="${MODEL_META[$key]}"
      name=$(echo "$meta" | cut -d'|' -f1)
      size=$(echo "$meta" | cut -d'|' -f2)
      
      if [ -f "$path" ]; then
        file_size=$(du -h "$path" | cut -f1)
        echo "  ✓ $name ($size) - $file_size"
      else
        echo "  ❌ $name ($size) - NOT DOWNLOADED"
      fi
    done
    ;;
    
  switch)
    if [ -z "$MODEL_NAME" ]; then
      echo "Usage: model_router.sh switch <model_key>"
      echo "Available: ${!MODEL_PATHS[*]}"
      exit 1
    fi
    
    if [ -z "${MODEL_PATHS[$MODEL_NAME]}" ]; then
      echo "ERROR: Unknown model: $MODEL_NAME"
      echo "Available: ${!MODEL_PATHS[*]}"
      exit 1
    fi
    
    path="${MODEL_PATHS[$MODEL_NAME]}"
    if [ ! -f "$path" ]; then
      echo "ERROR: Model file not found: $path"
      echo "Download the model first or choose a different one"
      exit 1
    fi
    
    echo "Switching default model to: ${MODEL_META[$MODEL_NAME]}"
    echo "Model path: $path"
    echo ""
    echo "To apply this change, restart Aether and select the desired tier."
    echo "Or run: ~/aether/aether.sh"
    ;;
    
  list)
    echo "=== Available Models ==="
    echo ""
    printf "%-12s %-8s %-8s %-40s %s\n" "KEY" "SIZE" "TIER" "NAME" "STATUS"
    printf "%-12s %-8s %-8s %-40s %s\n" "---" "----" "----" "----" "------"
    
    for key in "${!MODEL_META[@]}"; do
      meta="${MODEL_META[$key]}"
      name=$(echo "$meta" | cut -d'|' -f1)
      size=$(echo "$meta" | cut -d'|' -f2)
      tier=$(echo "$meta" | cut -d'|' -f3)
      desc=$(echo "$meta" | cut -d'|' -f4)
      path="${MODEL_PATHS[$key]}"
      
      if [ -f "$path" ]; then
        status="✓"
      else
        status="❌"
      fi
      
      printf "%-12s %-8s %-8s %-40s %s\n" "$key" "$size" "$tier" "$name" "$status"
    done
    ;;
    
  benchmark)
    echo "=== Model Benchmark ==="
    echo "Running hardware benchmark..."
    echo ""
    
    if [ -f "$AETHER_DIR/bench.sh" ]; then
      bash "$AETHER_DIR/bench.sh"
    else
      echo "Benchmark script not found at $AETHER_DIR/bench.sh"
    fi
    ;;
    
  optimize)
    echo "=== Model Optimization Analysis ==="
    echo ""
    
    # Get device info
    RAM=$(free -m | awk '/^Mem:/{print $2}')
    CORES=$(nproc)
    
    echo "Device Resources:"
    echo "  RAM: ${RAM}MB"
    echo "  CPU Cores: $CORES"
    echo ""
    
    # Recommend optimal settings
    echo "Recommended llama.cpp Settings:"
    
    # Thread recommendation
    if [ "$CORES" -le 4 ]; then
      THREADS=$((CORES - 1))
    else
      THREADS=$((CORES / 2 + 1))
    fi
    echo "  Threads: $THREADS (based on $CORES cores)"
    
    # Context size recommendation based on RAM
    if [ "$RAM" -ge 6000 ]; then
      CTX_SIZE=4096
      echo "  Context: $CTX_SIZE tokens (6GB+ RAM available)"
    elif [ "$RAM" -ge 4000 ]; then
      CTX_SIZE=2048
      echo "  Context: $CTX_SIZE tokens (4-6GB RAM)"
    else
      CTX_SIZE=1024
      echo "  Context: $CTX_SIZE tokens (<4GB RAM, conservative)"
    fi
    
    # Batch size
    if [ "$RAM" -ge 6000 ]; then
      BATCH=512
    else
      BATCH=256
    fi
    echo "  Batch Size: $BATCH"
    echo "  Memory Map: enabled (recommended for Android)"
    echo ""
    
    # Model recommendations
    echo "Model Recommendations:"
    if [ "$RAM" -ge 6000 ]; then
      echo "  ✓ Can run 7B-8B models comfortably"
      echo "  → Primary: hermes (8B)"
      echo "  → Fallback: qwen (3B)"
    elif [ "$RAM" -ge 4000 ]; then
      echo "  ✓ Can run 3B models well"
      echo "  → Primary: qwen (3B)"
      echo "  → Fallback: llama (3B)"
    else
      echo "  ⚠ Limited RAM - stick to 1.5B-3B models"
      echo "  → Primary: deepseek (1.5B)"
      echo "  → Fallback: llama (3B)"
    fi
    ;;
    
  *)
    echo "Usage: model_router.sh [status|switch <model>|benchmark|list|optimize]"
    echo ""
    echo "Commands:"
    echo "  status    - Show current routing and model availability"
    echo "  list      - List all available models"
    echo "  switch    - Switch to a different model"
    echo "  benchmark - Run hardware benchmark"
    echo "  optimize  - Get optimization recommendations for your device"
    exit 1
    ;;
esac
