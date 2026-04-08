#!/data/data/com.termux/files/usr/bin/bash
# config_manager.sh - Manage Aether configuration profiles and settings
# Usage: config_manager.sh [view|set <key> <value>|profile <name>|reset|export|import <file>]

CONFIG_DIR="$HOME/.aether/config"
CONFIG_FILE="$CONFIG_DIR/aether.conf"
ACTION="${1:-view}"

# Ensure config directory exists
mkdir -p "$CONFIG_DIR"

# Initialize config file if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
  cat > "$CONFIG_FILE" << 'EOF'
# Aether Configuration
# Format: KEY=VALUE
# Lines starting with # are comments

# Model Configuration
DEFAULT_TIER=agent
MODEL_THREADS=4
CONTEXT_SIZE=2048
BATCH_SIZE=256
TEMPERATURE=0.7

# Session Configuration
MAX_HISTORY_BYTES=4096
MAX_MESSAGES=20
AUTO_SAVE_SESSION=true

# System Configuration
VAULT_PATH="$HOME/storage/shared/Documents/Obsidian"
AUDIT_LOG_DIR="$HOME/.audit_logs"
SESSION_DIR="$HOME/.aether/sessions"

# Performance
ENABLE_GPU=false
GPU_LAYERS=0
MEMORY_MAP=true

# Security
SCAN_ON_START=false
AUTO_HEAL=true
EOF
  echo "Created default configuration at $CONFIG_FILE"
fi

# Helper: read config value
get_config() {
  local key="$1"
  local default="${2:-}"
  local value
  value=$(grep "^${key}=" "$CONFIG_FILE" 2>/dev/null | head -1 | cut -d'=' -f2- | sed 's/^"//;s/"$//')
  echo "${value:-$default}"
}

# Helper: set config value
set_config() {
  local key="$1"
  local value="$2"
  
  if grep -q "^${key}=" "$CONFIG_FILE" 2>/dev/null; then
    # Update existing
    if [[ "$value" =~ [[:space:]] ]]; then
      sed -i "s|^${key}=.*|${key}=\"${value}\"|" "$CONFIG_FILE"
    else
      sed -i "s|^${key}=.*|${key}=${value}|" "$CONFIG_FILE"
    fi
  else
    # Add new
    echo "${key}=${value}" >> "$CONFIG_FILE"
  fi
}

case "$ACTION" in
  view)
    echo "=== Aether Configuration ==="
    echo "Config file: $CONFIG_FILE"
    echo ""
    
    # Group by category
    echo "--- Model Settings ---"
    echo "  DEFAULT_TIER:      $(get_config DEFAULT_TIER)"
    echo "  MODEL_THREADS:     $(get_config MODEL_THREADS)"
    echo "  CONTEXT_SIZE:      $(get_config CONTEXT_SIZE)"
    echo "  BATCH_SIZE:        $(get_config BATCH_SIZE)"
    echo "  TEMPERATURE:       $(get_config TEMPERATURE)"
    echo ""
    
    echo "--- Session Settings ---"
    echo "  MAX_HISTORY_BYTES: $(get_config MAX_HISTORY_BYTES)"
    echo "  MAX_MESSAGES:      $(get_config MAX_MESSAGES)"
    echo "  AUTO_SAVE_SESSION: $(get_config AUTO_SAVE_SESSION)"
    echo ""
    
    echo "--- System Settings ---"
    echo "  VAULT_PATH:        $(get_config VAULT_PATH)"
    echo "  AUDIT_LOG_DIR:     $(get_config AUDIT_LOG_DIR)"
    echo "  SESSION_DIR:       $(get_config SESSION_DIR)"
    echo ""
    
    echo "--- Performance Settings ---"
    echo "  ENABLE_GPU:        $(get_config ENABLE_GPU)"
    echo "  GPU_LAYERS:        $(get_config GPU_LAYERS)"
    echo "  MEMORY_MAP:        $(get_config MEMORY_MAP)"
    echo ""
    
    echo "--- Security Settings ---"
    echo "  SCAN_ON_START:     $(get_config SCAN_ON_START)"
    echo "  AUTO_HEAL:         $(get_config AUTO_HEAL)"
    ;;
    
  set)
    KEY="$2"
    VALUE="$3"
    
    if [ -z "$KEY" ] || [ -z "$VALUE" ]; then
      echo "Usage: config_manager.sh set <key> <value>"
      echo "Example: config_manager.sh set CONTEXT_SIZE 4096"
      exit 1
    fi
    
    set_config "$KEY" "$VALUE"
    echo "✓ Set $KEY = $VALUE"
    ;;
    
  profile)
    PROFILE_NAME="$2"
    
    if [ -z "$PROFILE_NAME" ]; then
      echo "Available profiles:"
      echo "  conservative - Low resource usage, small context"
      echo "  balanced     - Default settings for most devices"
      echo "  performance  - Maximum performance, larger context"
      echo "  reasoning    - Optimized for complex reasoning tasks"
      echo "  coding       - Optimized for code generation"
      exit 0
    fi
    
    case "$PROFILE_NAME" in
      conservative)
        set_config MODEL_THREADS 2
        set_config CONTEXT_SIZE 1024
        set_config BATCH_SIZE 128
        set_config TEMPERATURE 0.5
        echo "✓ Applied 'conservative' profile (low resource usage)"
        ;;
      balanced)
        set_config MODEL_THREADS 4
        set_config CONTEXT_SIZE 2048
        set_config BATCH_SIZE 256
        set_config TEMPERATURE 0.7
        echo "✓ Applied 'balanced' profile (default settings)"
        ;;
      performance)
        set_config MODEL_THREADS 6
        set_config CONTEXT_SIZE 4096
        set_config BATCH_SIZE 512
        set_config TEMPERATURE 0.7
        echo "✓ Applied 'performance' profile (maximum throughput)"
        ;;
      reasoning)
        set_config MODEL_THREADS 4
        set_config CONTEXT_SIZE 4096
        set_config BATCH_SIZE 256
        set_config TEMPERATURE 0.3
        echo "✓ Applied 'reasoning' profile (deep thinking, low temperature)"
        ;;
      coding)
        set_config MODEL_THREADS 6
        set_config CONTEXT_SIZE 2048
        set_config BATCH_SIZE 512
        set_config TEMPERATURE 0.2
        echo "✓ Applied 'coding' profile (precise code generation)"
        ;;
      *)
        echo "Unknown profile: $PROFILE_NAME"
        echo "Run without arguments to see available profiles"
        exit 1
        ;;
    esac
    ;;
    
  reset)
    echo "WARNING: This will reset all configuration to defaults."
    echo "Proceeding with reset..."
    rm -f "$CONFIG_FILE"
    # Recreate defaults
    "$0" view > /dev/null
    echo "✓ Configuration reset to defaults"
    ;;
    
  export)
    OUTPUT_FILE="${2:-$CONFIG_DIR/aether_backup_$(date +%Y%m%d).conf}"
    cp "$CONFIG_FILE" "$OUTPUT_FILE"
    echo "✓ Configuration exported to $OUTPUT_FILE"
    ;;
    
  import)
    INPUT_FILE="$2"
    
    if [ -z "$INPUT_FILE" ]; then
      echo "Usage: config_manager.sh import <config_file>"
      exit 1
    fi
    
    if [ ! -f "$INPUT_FILE" ]; then
      echo "ERROR: File not found: $INPUT_FILE"
      exit 1
    fi
    
    cp "$CONFIG_FILE" "$CONFIG_DIR/aether_backup_$(date +%Y%m%d_%H%M%S).conf"
    cp "$INPUT_FILE" "$CONFIG_FILE"
    echo "✓ Configuration imported from $INPUT_FILE"
    echo "  Previous config backed up"
    ;;
    
  *)
    echo "Usage: config_manager.sh [view|set|profile|reset|export|import]"
    echo ""
    echo "Commands:"
    echo "  view              - Show current configuration"
    echo "  set <k> <v>       - Set a configuration value"
    echo "  profile <name>    - Apply a preset profile"
    echo "  reset             - Reset to default configuration"
    echo "  export [file]     - Export configuration to file"
    echo "  import <file>     - Import configuration from file"
    exit 1
    ;;
esac
