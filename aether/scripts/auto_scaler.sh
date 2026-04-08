#!/data/data/com.termux/files/usr/bin/bash
# auto_scaler.sh - Dynamic resource allocation and auto-scaling for AI models
# Usage: auto_scaler.sh [monitor|scale|status|policy]

AETHER_DIR="$HOME/aether"
SCALER_LOG="$HOME/.aether/sessions/auto_scaler.log"
POLICY_FILE="$HOME/.aether/config/scaling_policy.conf"
METRICS_LOG="$HOME/.aether/sessions/system_metrics.log"

# Default thresholds
RAM_SCALE_DOWN_THRESHOLD=85
RAM_SCALE_UP_THRESHOLD=60
BATTERY_CRITICAL=15
BATTERY_LOW=30

# Ensure directories exist
mkdir -p "$HOME/.aether/config"

log_action() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$SCALER_LOG"
}

# ============================================================
# RESOURCE MONITORING
# ============================================================

get_metrics() {
  RAM_TOTAL=$(free -m | awk '/^Mem:/{print $2}')
  RAM_USED=$(free -m | awk '/^Mem:/{print $3}')
  RAM_FREE=$(free -m | awk '/^Mem:/{print $4}')
  RAM_PERCENT=$((RAM_USED * 100 / RAM_TOTAL))
  
  BATTERY_PCT=0
  if command -v termux-battery-status &>/dev/null; then
    BATTERY_PCT=$(termux-battery-status 2>/dev/null | grep "percentage" | grep -o '[0-9]*')
  fi
  
  CPU_LOAD=$(uptime | awk -F'load average:' '{gsub(/^ */, "", $2); print $2}' | cut -d',' -f1)
  CPU_CORES=$(nproc)
  
  STORAGE_FREE_GB=$(df -h / | awk 'NR==2{print $4}' | sed 's/G//')
  
  # Check if llama processes are running
  LLAMA_RUNNING=$(pgrep -f "llama-" | wc -l)
}

# ============================================================
# SCALING POLICIES
# ============================================================

create_default_policy() {
  if [ ! -f "$POLICY_FILE" ]; then
    cat > "$POLICY_FILE" << 'EOF'
# Auto-Scaling Policy
# Format: KEY=VALUE

# Memory thresholds (%)
RAM_SCALE_DOWN_THRESHOLD=85
RAM_SCALE_UP_THRESHOLD=60

# Battery thresholds (%)
BATTERY_CRITICAL=15
BATTERY_LOW=30

# Scaling actions
SCALE_DOWN_ACTION=reduce_context
SCALE_UP_ACTION=increase_context

# Context size steps
CONTEXT_MIN=512
CONTEXT_DEFAULT=2048
CONTEXT_MAX=4096

# Thread count limits
THREADS_MIN=2
THREADS_MAX=6

# Battery behavior
BATTERY_CRITICAL_ACTION=stop_all
BATTERY_LOW_ACTION=reduce_to_turbo

# Monitoring interval (seconds)
MONITOR_INTERVAL=30

# Enable auto-scaling (true/false)
AUTO_SCALE_ENABLED=false
EOF
    echo "Created default scaling policy at $POLICY_FILE"
  fi
}

load_policy() {
  create_default_policy
  
  # Source policy values
  RAM_SCALE_DOWN_THRESHOLD=$(grep "^RAM_SCALE_DOWN_THRESHOLD=" "$POLICY_FILE" | cut -d'=' -f2)
  RAM_SCALE_UP_THRESHOLD=$(grep "^RAM_SCALE_UP_THRESHOLD=" "$POLICY_FILE" | cut -d'=' -f2)
  BATTERY_CRITICAL=$(grep "^BATTERY_CRITICAL=" "$POLICY_FILE" | cut -d'=' -f2)
  BATTERY_LOW=$(grep "^BATTERY_LOW=" "$POLICY_FILE" | cut -d'=' -f2)
  AUTO_SCALE_ENABLED=$(grep "^AUTO_SCALE_ENABLED=" "$POLICY_FILE" | cut -d'=' -f2)
  MONITOR_INTERVAL=$(grep "^MONITOR_INTERVAL=" "$POLICY_FILE" | cut -d'=' -f2)
}

# ============================================================
# SCALING DECISIONS
# ============================================================

evaluate_scaling() {
  get_metrics
  
  echo "=== Scaling Evaluation ==="
  echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
  echo ""
  echo "Current State:"
  echo "  RAM: ${RAM_USED}MB / ${RAM_TOTAL}MB (${RAM_PERCENT}%)"
  echo "  Battery: ${BATTERY_PCT}%"
  echo "  CPU Load: $CPU_LOAD (${CPU_CORES} cores)"
  echo "  Storage Free: ${STORAGE_FREE_GB}GB"
  echo "  LLaMA Processes: $LLAMA_RUNNING"
  echo ""
  
  # Determine action
  ACTION="none"
  REASON=""
  
  # Battery-critical: Stop everything
  if [ "$BATTERY_PCT" -le "$BATTERY_CRITICAL" ] 2>/dev/null; then
    ACTION="stop_all"
    REASON="Battery critical: ${BATTERY_PCT}%"
    log_action "SCALE_DOWN stop_all battery=${BATTERY_PCT}%"
    
  # Battery low: Reduce to turbo only
  elif [ "$BATTERY_PCT" -le "$BATTERY_LOW" ] 2>/dev/null; then
    ACTION="reduce_to_turbo"
    REASON="Battery low: ${BATTERY_PCT}%"
    log_action "SCALE_DOWN reduce_to_turbo battery=${BATTERY_PCT}%"
    
  # RAM high: Scale down context
  elif [ "$RAM_PERCENT" -ge "$RAM_SCALE_DOWN_THRESHOLD" ]; then
    ACTION="reduce_context"
    REASON="RAM usage high: ${RAM_PERCENT}%"
    log_action "SCALE_DOWN reduce_context ram=${RAM_PERCENT}%"
    
  # RAM low: Scale up if possible
  elif [ "$RAM_PERCENT" -le "$RAM_SCALE_UP_THRESHOLD" ] && [ "$LLAMA_RUNNING" -gt 0 ]; then
    ACTION="increase_context"
    REASON="RAM usage low: ${RAM_PERCENT}% - can increase capacity"
    log_action "SCALE_UP increase_context ram=${RAM_PERCENT}%"
  fi
  
  echo "Decision: $ACTION"
  echo "Reason: $REASON"
  echo ""
  
  # Execute scaling action
  case "$ACTION" in
    stop_all)
      echo "⚠ STOPPING all AI services"
      if [ -f "$AETHER_DIR/../stop.sh" ]; then
        bash "$AETHER_DIR/../stop.sh"
      fi
      echo "All services stopped"
      ;;
      
    reduce_to_turbo)
      echo "⚡ Reducing to TURBO tier only"
      echo "  - Kill agent server (AGENT tier)"
      pkill -f "aether_agent.py" 2>/dev/null
      echo "  - Keep llama-server for TURBO tier"
      echo "  Consider switching to smaller model"
      ;;
      
    reduce_context)
      echo "⚡ Reducing context size"
      echo "  Current context should be reduced to prevent OOM"
      echo "  Recommended: Reduce -c parameter by 50%"
      echo "  Example: -c 2048 → -c 1024"
      ;;
      
    increase_context)
      echo "⚡ Can increase context size"
      echo "  RAM usage is low - safe to increase capacity"
      echo "  Recommended: Increase -c parameter"
      echo "  Example: -c 2048 → -c 4096"
      ;;
      
    none)
      echo "✓ No scaling needed"
      echo "  System resources within acceptable range"
      ;;
  esac
}

# ============================================================
# CONTINUOUS MONITORING
# ============================================================

start_monitoring() {
  load_policy
  
  if [ "$AUTO_SCALE_ENABLED" != "true" ]; then
    echo "⚠ Auto-scaling is DISABLED"
    echo "  Enable it: Edit $POLICY_FILE and set AUTO_SCALE_ENABLED=true"
    echo ""
    echo "Starting monitoring mode (no automatic scaling)..."
  fi
  
  echo "=== Auto-Scaler Monitoring ==="
  echo "Interval: ${MONITOR_INTERVAL}s"
  echo "Press Ctrl+C to stop"
  echo ""
  
  while true; do
    get_metrics
    
    # Log metrics
    echo "$(date '+%Y-%m-%d %H:%M:%S') ram=${RAM_PERCENT} battery=${BATTERY_PCT} load=${CPU_LOAD} llama=${LLAMA_RUNNING}" >> "$METRICS_LOG"
    
    # Check thresholds and alert
    if [ "$RAM_PERCENT" -ge "$RAM_SCALE_DOWN_THRESHOLD" ]; then
      echo "[$(date '+%H:%M:%S')] 🔴 RAM HIGH: ${RAM_PERCENT}%"
      log_action "ALERT ram_high ${RAM_PERCENT}%"
    fi
    
    if [ "$BATTERY_PCT" -le "$BATTERY_CRITICAL" ] 2>/dev/null; then
      echo "[$(date '+%H:%M:%S')] 🔴 BATTERY CRITICAL: ${BATTERY_PCT}%"
      log_action "ALERT battery_critical ${BATTERY_PCT}%"
      
      if [ "$AUTO_SCALE_ENABLED" = "true" ]; then
        evaluate_scaling
      fi
    elif [ "$BATTERY_PCT" -le "$BATTERY_LOW" ] 2>/dev/null; then
      echo "[$(date '+%H:%M:%S')] 🟡 Battery Low: ${BATTERY_PCT}%"
      log_action "ALERT battery_low ${BATTERY_PCT}%"
    fi
    
    if [ "$AUTO_SCALE_ENABLED" = "true" ]; then
      evaluate_scaling > /dev/null 2>&1
    fi
    
    sleep "$MONITOR_INTERVAL"
  done
}

# ============================================================
# MAIN EXECUTION
# ============================================================

ACTION="${1:-status}"

case "$ACTION" in
  monitor)
    start_monitoring
    ;;
    
  scale)
    load_policy
    evaluate_scaling
    ;;
    
  status)
    get_metrics
    
    echo "=== Auto-Scaler Status ==="
    echo ""
    echo "Current Resources:"
    echo "  RAM: ${RAM_USED}MB / ${RAM_TOTAL}MB (${RAM_PERCENT}%)"
    echo "  Battery: ${BATTERY_PCT}%"
    echo "  CPU Load: $CPU_LOAD (${CPU_CORES} cores)"
    echo "  Storage Free: ${STORAGE_FREE_GB}GB"
    echo "  LLaMA Processes: $LLAMA_RUNNING"
    echo ""
    
    load_policy
    echo "Scaling Policy:"
    echo "  Auto-Scale: $AUTO_SCALE_ENABLED"
    echo "  RAM Scale-Down Threshold: ${RAM_SCALE_DOWN_THRESHOLD}%"
    echo "  RAM Scale-Up Threshold: ${RAM_SCALE_UP_THRESHOLD}%"
    echo "  Battery Critical: ${BATTERY_CRITICAL}%"
    echo "  Battery Low: ${BATTERY_LOW}%"
    echo ""
    
    if [ -f "$SCALER_LOG" ]; then
      echo "Recent Scaling Events:"
      tail -10 "$SCALER_LOG"
    fi
    ;;
    
  policy)
    echo "=== Current Scaling Policy ==="
    if [ -f "$POLICY_FILE" ]; then
      cat "$POLICY_FILE"
    else
      echo "No policy file found. Run auto-scaler to create defaults."
    fi
    ;;
    
  enable)
    load_policy
    sed -i 's/AUTO_SCALE_ENABLED=false/AUTO_SCALE_ENABLED=true/' "$POLICY_FILE"
    echo "✓ Auto-scaling enabled"
    echo "Run: auto_scaler.sh monitor"
    log_action "POLICY auto_scaling_enabled"
    ;;
    
  disable)
    load_policy
    sed -i 's/AUTO_SCALE_ENABLED=true/AUTO_SCALE_ENABLED=false/' "$POLICY_FILE"
    echo "✓ Auto-scaling disabled"
    log_action "POLICY auto_scaling_disabled"
    ;;
    
  *)
    echo "Usage: auto_scaler.sh [monitor|scale|status|policy|enable|disable]"
    echo ""
    echo "Commands:"
    echo "  monitor  - Continuous monitoring mode"
    echo "  scale    - Evaluate and execute scaling"
    echo "  status   - Show current status and metrics"
    echo "  policy   - View scaling policy"
    echo "  enable   - Enable auto-scaling"
    echo "  disable  - Disable auto-scaling"
    exit 1
    ;;
esac
