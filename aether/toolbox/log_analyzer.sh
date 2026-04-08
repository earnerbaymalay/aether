#!/data/data/com.termux/files/usr/bin/bash
# log_analyzer.sh - Analyze system and application logs for patterns and errors
# Usage: log_analyzer.sh [system|aether|sentinel|custom] [lines_count]

LOG_TYPE="${1:-system}"
LINES="${2:-100}"

case "$LOG_TYPE" in
  system)
    echo "=== System Log Analysis (last $LINES entries) ==="
    echo ""
    echo "--- Recent Errors/Warnings ---"
    logcat -d -t "$LINES" 2>/dev/null | grep -iE "error|warn|fail|exception|crash" | tail -20
    echo ""
    echo "--- Top Error Patterns ---"
    logcat -d -t 500 2>/dev/null | grep -ioE "[a-z]+error|[a-z]+exception" | sort | uniq -c | sort -rn | head -10
    ;;
    
  aether)
    echo "=== Aether Session Log Analysis ==="
    LOG_FILE="$HOME/.aether/sessions/last_session.log"
    if [ -f "$LOG_FILE" ]; then
      echo ""
      echo "--- Recent Errors ---"
      tail -"$LINES" "$LOG_FILE" 2>/dev/null | grep -iE "error|fail|oom|panic|exception" | tail -20
      echo ""
      echo "--- Session Statistics ---"
      echo "Total Lines: $(wc -l < "$LOG_FILE")"
      echo "Error Count: $(grep -ciE "error|fail" "$LOG_FILE" 2>/dev/null || echo 0)"
      echo "Warnings: $(grep -ciE "warn|caution" "$LOG_FILE" 2>/dev/null || echo 0)"
    else
      echo "No Aether session log found at $LOG_FILE"
    fi
    ;;
    
  sentinel)
    echo "=== Sentinel Log Analysis ==="
    LOG_FILE="$HOME/.aether/sessions/sentinel.log"
    if [ -f "$LOG_FILE" ]; then
      tail -"$LINES" "$LOG_FILE" 2>/dev/null
    else
      echo "No sentinel log found at $LOG_FILE"
    fi
    ;;
    
  audit)
    echo "=== Security Audit Log Analysis ==="
    LOG_DIR="$HOME/.audit_logs"
    if [ -d "$LOG_DIR" ]; then
      echo ""
      echo "--- Recent Audit Findings ---"
      find "$LOG_DIR" -name "*.log" -type f -exec tail -50 {} + 2>/dev/null | grep -iE "critical|high|vulnerability" | tail -20
      echo ""
      echo "--- Audit Log Files ---"
      ls -lh "$LOG_DIR"/*.log 2>/dev/null | tail -10
    else
      echo "No audit logs found at $LOG_DIR"
    fi
    ;;
    
  custom)
    echo "=== Custom Log: $3 ==="
    if [ -f "$3" ]; then
      tail -"$LINES" "$3" 2>/dev/null
    else
      echo "File not found: $3"
    fi
    ;;
    
  *)
    echo "Usage: log_analyzer.sh [system|aether|sentinel|audit|custom <file>] [lines]"
    exit 1
    ;;
esac
