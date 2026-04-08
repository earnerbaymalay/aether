#!/data/data/com.termux/files/usr/bin/bash
# system_monitor.sh - Real-time system monitoring with alerts
# Usage: system_monitor.sh [status|watch|alert|history]

ALERT_LOG="$HOME/.aether/sessions/system_alerts.log"
METRICS_LOG="$HOME/.aether/sessions/system_metrics.log"
ACTION="${1:-status}"

# Thresholds
BATTERY_CRITICAL=10
BATTERY_WARNING=20
STORAGE_WARNING_GB=1
RAM_WARNING_PERCENT=85
TEMP_WARNING_C=75

case "$ACTION" in
  status)
    echo "=== System Status ==="
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    # Battery
    if command -v termux-battery-status &>/dev/null; then
      BATTERY_INFO=$(termux-battery-status 2>/dev/null)
      BATTERY_PCT=$(echo "$BATTERY_INFO" | grep "percentage" | grep -o '[0-9]*')
      BATTERY_STATUS=$(echo "$BATTERY_INFO" | grep "status" | cut -d':' -f2 | tr -d ' "')
      BATTERY_HEALTH=$(echo "$BATTERY_INFO" | grep "health" | cut -d':' -f2 | tr -d ' "')
      
      echo "--- Battery ---"
      echo "  Level: ${BATTERY_PCT}%"
      echo "  Status: $BATTERY_STATUS"
      echo "  Health: $BATTERY_HEALTH"
      
      if [ "$BATTERY_PCT" -le "$BATTERY_CRITICAL" ] 2>/dev/null; then
        echo "  🔴 CRITICAL: Charge immediately!"
      elif [ "$BATTERY_PCT" -le "$BATTERY_WARNING" ] 2>/dev/null; then
        echo "  🟡 WARNING: Low battery"
      else
        echo "  ✓ Battery OK"
      fi
    else
      echo "--- Battery ---"
      echo "  ⚠ termux-battery-status not available"
    fi
    echo ""
    
    # Memory
    echo "--- Memory ---"
    free -h | awk '/^Mem:/{printf "  Total: %s, Used: %s, Free: %s\n", $2, $3, $4}'
    free -h | awk '/^Mem:/{pct=($3/$2)*100; printf "  Usage: %.0f%%\n", pct}'
    
    RAM_PCT=$(free | awk '/^Mem:/{printf "%.0f", ($3/$2)*100}')
    if [ "$RAM_PCT" -ge "$RAM_WARNING_PERCENT" ] 2>/dev/null; then
      echo "  🟡 WARNING: High memory usage"
    else
      echo "  ✓ Memory OK"
    fi
    echo ""
    
    # Storage
    echo "--- Storage ---"
    df -h / | awk 'NR==2{printf "  Total: %s, Used: %s, Available: %s\n", $2, $3, $4}'
    df / | awk 'NR==2{printf "  Usage: %s\n", $5}'
    
    STORAGE_AVAIL=$(df / | awk 'NR==2{print $4}')
    STORAGE_AVAIL_GB=$((STORAGE_AVAIL / 1024 / 1024))
    if [ "$STORAGE_AVAIL_GB" -le "$STORAGE_WARNING_GB" ] 2>/dev/null; then
      echo "  🟡 WARNING: Low storage (${STORAGE_AVAIL_GB}GB remaining)"
    else
      echo "  ✓ Storage OK"
    fi
    echo ""
    
    # CPU
    echo "--- CPU ---"
    CORES=$(nproc)
    LOAD=$(uptime | awk -F'load average:' '{print $2}' | xargs)
    echo "  Cores: $CORES"
    echo "  Load: $LOAD"
    echo ""
    
    # Top processes
    echo "--- Top 5 Processes (CPU) ---"
    ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "  %-8s %5s%%  %s\n", $11, $3, $NF}'
    echo ""
    
    echo "--- Top 5 Processes (Memory) ---"
    ps aux --sort=-%mem | head -6 | tail -5 | awk '{printf "  %-8s %5s%%  %s\n", $11, $4, $NF}'
    echo ""
    
    # Network
    echo "--- Network ---"
    if command -v nmap &>/dev/null; then
      ACTIVE_CONN=$(netstat -an 2>/dev/null | grep ESTABLISHED | wc -l)
      echo "  Active Connections: $ACTIVE_CONN"
    else
      echo "  ⚠ nmap not installed"
    fi
    ;;
    
  watch)
    echo "=== Real-time Monitor (Ctrl+C to exit) ==="
    echo "Refreshing every 5 seconds..."
    echo ""
    
    while true; do
      clear
      echo "=== System Monitor [$(date '+%H:%M:%S')] ==="
      echo ""
      
      # Battery
      if command -v termux-battery-status &>/dev/null; then
        BATTERY_PCT=$(termux-battery-status 2>/dev/null | grep "percentage" | grep -o '[0-9]*')
        printf "Battery: [%-20s] %3d%%\n" "$(printf '%*s' $((BATTERY_PCT / 5)) '' | tr ' ' '=')${BATTERY_PCT}" "$BATTERY_PCT"
      fi
      
      # Memory
      RAM_PCT=$(free | awk '/^Mem:/{printf "%.0f", ($3/$2)*100}')
      printf "Memory:  [%-20s] %3d%%\n" "$(printf '%*s' $((RAM_PCT / 5)) '' | tr ' ' '=')${RAM_PCT}"
      
      # Storage
      STORAGE_PCT=$(df / | awk 'NR==2{gsub(/%/,""); print $5}')
      printf "Storage: [%-20s] %3d%%\n" "$(printf '%*s' $((STORAGE_PCT / 5)) '' | tr ' ' '=')${STORAGE_PCT}"
      
      # Load
      LOAD=$(uptime | awk -F'load average:' '{gsub(/^ */, "", $2); print $2}')
      printf "Load:    %s\n" "$LOAD"
      
      # Log metrics
      echo "$(date '+%Y-%m-%d %H:%M:%S') battery=${BATTERY_PCT:-0} ram=${RAM_PCT:-0} storage=${STORAGE_PCT:-0}" >> "$METRICS_LOG"
      
      sleep 5
    done
    ;;
    
  alert)
    echo "=== System Alerts ==="
    echo ""
    
    if [ -f "$ALERT_LOG" ]; then
      echo "Recent alerts:"
      tail -50 "$ALERT_LOG"
    else
      echo "No alert log found."
    fi
    
    echo ""
    echo "--- Current Threshold Checks ---"
    
    # Check battery
    if command -v termux-battery-status &>/dev/null; then
      BATTERY_PCT=$(termux-battery-status 2>/dev/null | grep "percentage" | grep -o '[0-9]*')
      if [ "$BATTERY_PCT" -le "$BATTERY_WARNING" ] 2>/dev/null; then
        echo "🔴 BATTERY: ${BATTERY_PCT}% (threshold: ${BATTERY_WARNING}%)"
        echo "$(date) BATTERY_LOW: ${BATTERY_PCT}%" >> "$ALERT_LOG"
      else
        echo "✓ Battery: ${BATTERY_PCT}%"
      fi
    fi
    
    # Check RAM
    RAM_PCT=$(free | awk '/^Mem:/{printf "%.0f", ($3/$2)*100}')
    if [ "$RAM_PCT" -ge "$RAM_WARNING_PERCENT" ] 2>/dev/null; then
      echo "🟡 MEMORY: ${RAM_PCT}% (threshold: ${RAM_WARNING_PERCENT}%)"
      echo "$(date) MEMORY_HIGH: ${RAM_PCT}%" >> "$ALERT_LOG"
    else
      echo "✓ Memory: ${RAM_PCT}%"
    fi
    
    # Check storage
    STORAGE_AVAIL_GB=$(df / | awk 'NR==2{printf "%d", $4/1024/1024}')
    if [ "$STORAGE_AVAIL_GB" -le "$STORAGE_WARNING_GB" ] 2>/dev/null; then
      echo "🟡 STORAGE: ${STORAGE_AVAIL_GB}GB free (threshold: ${STORAGE_WARNING_GB}GB)"
      echo "$(date) STORAGE_LOW: ${STORAGE_AVAIL_GB}GB" >> "$ALERT_LOG"
    else
      echo "✓ Storage: ${STORAGE_AVAIL_GB}GB free"
    fi
    ;;
    
  history)
    echo "=== System Metrics History ==="
    
    if [ ! -f "$METRICS_LOG" ]; then
      echo "No metrics history found. Run 'system_monitor.sh watch' to start logging."
      exit 0
    fi
    
    LINES="${2:-50}"
    echo "Last $LINES entries:"
    echo ""
    
    tail -"$LINES" "$METRICS_LOG" | while IFS= read -r line; do
      timestamp=$(echo "$line" | cut -d' ' -f1-2)
      battery=$(echo "$line" | grep -o 'battery=[0-9]*' | cut -d'=' -f2)
      ram=$(echo "$line" | grep -o 'ram=[0-9]*' | cut -d'=' -f2)
      storage=$(echo "$line" | grep -o 'storage=[0-9]*' | cut -d'=' -f2)
      
      printf "%s | B:%3s%% | M:%3s%% | S:%3s%%\n" "$timestamp" "$battery" "$ram" "$storage"
    done
    ;;
    
  *)
    echo "Usage: system_monitor.sh [status|watch|alert|history]"
    echo ""
    echo "Commands:"
    echo "  status   - Show current system status"
    echo "  watch    - Real-time monitoring (continuous)"
    echo "  alert    - Check thresholds and show alerts"
    echo "  history  - Show metrics history"
    exit 1
    ;;
esac
