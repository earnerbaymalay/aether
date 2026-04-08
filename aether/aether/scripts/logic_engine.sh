#!/data/data/com.termux/files/usr/bin/bash
# logic_engine.sh - Advanced decision trees, fallback routing, error recovery, and self-optimization
# Usage: logic_engine.sh [decision_tree <task>|fallback|recover|optimize|evaluate]

AETHER_DIR="$HOME/aether"
LOGIC_LOG="$HOME/.aether/sessions/logic_engine.log"
ACTION="${1:-evaluate}"

log_action() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOGIC_LOG"
}

# ============================================================
# DECISION TREE ENGINE
# ============================================================

evaluate_decision_tree() {
  local task="$1"
  
  echo "=== Decision Tree Evaluation ==="
  echo "Task: $task"
  echo ""
  
  # Task classification
  echo "--- Task Classification ---"
  
  if echo "$task" | grep -qiE "code|implement|function|class|script|api|endpoint"; then
    echo "  Type: CODING TASK"
    echo "  Recommended Tier: CODE (Qwen-Coder)"
    echo "  Skills: code-review"
    echo "  Tools: list_files, dependency_checker"
    log_action "DECISION code_task: $task"
    
  elif echo "$task" | grep -qiE "scan|security|vuln|audit|hack|pentest|nmap"; then
    echo "  Type: SECURITY TASK"
    echo "  Recommended Tier: AGENT (Hermes)"
    echo "  Skills: security-audit"
    echo "  Tools: vault-scan, nmap, system_monitor"
    log_action "DECISION security_task: $task"
    
  elif echo "$task" | grep -qiE "analyz|data|statistic|chart|graph|report|metric"; then
    echo "  Type: DATA ANALYSIS TASK"
    echo "  Recommended Tier: LOGIC (DeepSeek-R1)"
    echo "  Skills: data-analysis"
    echo "  Tools: log_analyzer, system_monitor"
    log_action "DECISION analysis_task: $task"
    
  elif echo "$task" | grep -qiE "design|architect|plan|structur|pattern|refactor"; then
    echo "  Type: ARCHITECTURE TASK"
    echo "  Recommended Tier: LOGIC (DeepSeek-R1)"
    echo "  Skills: architecture-design"
    echo "  Tools: list_files, grep_search"
    log_action "DECISION architecture_task: $task"
    
  elif echo "$task" | grep -qiE "optim|speed|fast|performance|memory|cpu|lag"; then
    echo "  Type: OPTIMIZATION TASK"
    echo "  Recommended Tier: LOGIC (DeepSeek-R1)"
    echo "  Skills: system-optimization"
    echo "  Tools: system_monitor, model_router, bench"
    log_action "DECISION optimization_task: $task"
    
  elif echo "$task" | grep -qiE "review|check|inspect|examine|look at"; then
    echo "  Type: REVIEW TASK"
    echo "  Recommended Tier: LOGIC (DeepSeek-R1)"
    echo "  Skills: code-review"
    echo "  Tools: list_files, read_file, grep_search"
    log_action "DECISION review_task: $task"
    
  else
    echo "  Type: GENERAL TASK"
    echo "  Recommended Tier: AGENT (Hermes)"
    echo "  Skills: (none specific)"
    echo "  Tools: web_search, web_read, list_files"
    log_action "DECISION general_task: $task"
  fi
  
  echo ""
  
  # Complexity assessment
  echo "--- Complexity Assessment ---"
  WORD_COUNT=$(echo "$task" | wc -w)
  
  if [ "$WORD_COUNT" -le 10 ]; then
    echo "  Complexity: SIMPLE (direct execution)"
    echo "  Est. Steps: 1-3"
    echo "  Confidence: HIGH"
  elif [ "$WORD_COUNT" -le 25 ]; then
    echo "  Complexity: MODERATE (may require clarification)"
    echo "  Est. Steps: 3-7"
    echo "  Confidence: MEDIUM"
  else
    echo "  Complexity: HIGH (task decomposition recommended)"
    echo "  Est. Steps: 7+"
    echo "  Confidence: LOW - consider breaking into subtasks"
  fi
  
  echo ""
  
  # Risk assessment
  echo "--- Risk Assessment ---"
  
  if echo "$task" | grep -qiE "delete|remove|drop|destroy|rm |kill|wipe"; then
    echo "  ⚠ DESTRUCTIVE OPERATION - Require explicit confirmation"
    echo "  Risk Level: HIGH"
    log_action "RISK destructive_operation_detected"
  elif echo "$task" | grep -qiE "install|download|fetch|pull|clone"; then
    echo "  ⚠ EXTERNAL RESOURCE - Check disk space first"
    echo "  Risk Level: MEDIUM"
    log_action "RISK external_resource_needed"
  elif echo "$task" | grep -qiE "config|setting|parameter|tune|adjust"; then
    echo "  ℹ CONFIGURATION CHANGE - Backup before modifying"
    echo "  Risk Level: LOW-MEDIUM"
    log_action "RISK config_change"
  else
    echo "  Risk Level: LOW (read-only or safe operations)"
  fi
}

# ============================================================
# FALLBACK ROUTING ENGINE
# ============================================================

execute_fallback_routing() {
  echo "=== Fallback Routing Engine ==="
  echo ""
  echo "This engine determines the optimal execution path based on:"
  echo "  - Model availability"
  echo "  - System resource constraints"
  echo "  - Task requirements"
  echo "  - Historical performance"
  echo ""
  
  # Check model availability
  echo "--- Model Availability ---"
  
  MODELS_STATUS=""
  FALLBACK_CHAIN=""
  
  # Check Hermes-8B
  if [ -f "$HOME/.aether/models/Hermes-2-Pro-Llama-3-8B-GGUF/hermes-2-pro-llama-3-8b-q4_k_m.gguf" ]; then
    echo "  ✓ Hermes-8B (AGENT tier)"
    MODELS_STATUS="${MODELS_STATUS}hermes,"
    FALLBACK_CHAIN="hermes"
  else
    echo "  ❌ Hermes-8B not available"
  fi
  
  # Check Qwen-Coder-3B
  if [ -f "$HOME/.aether/models/Qwen2.5-Coder-3B-Instruct-GGUF/qwen2.5-coder-3b-instruct-q4_k_m.gguf" ]; then
    echo "  ✓ Qwen-Coder-3B (CODE tier)"
    MODELS_STATUS="${MODELS_STATUS}qwen,"
    FALLBACK_CHAIN="${FALLBACK_CHAIN},qwen"
  else
    echo "  ❌ Qwen-Coder-3B not available"
  fi
  
  # Check DeepSeek-R1-1.5B
  if [ -f "$HOME/.aether/models/DeepSeek-R1-Distill-Qwen-1.5B-GGUF/deepseek-r1-distill-qwen-1.5b-q4_k_m.gguf" ]; then
    echo "  ✓ DeepSeek-R1-1.5B (LOGIC tier)"
    MODELS_STATUS="${MODELS_STATUS}deepseek,"
    FALLBACK_CHAIN="${FALLBACK_CHAIN},deepseek"
  else
    echo "  ❌ DeepSeek-R1-1.5B not available"
  fi
  
  # Check Llama-3.2-3B
  if [ -f "$HOME/.aether/models/Llama-3.2-3B-Instruct-GGUF/llama-3.2-3b-instruct-q4_k_m.gguf" ]; then
    echo "  ✓ Llama-3.2-3B (TURBO tier)"
    MODELS_STATUS="${MODELS_STATUS}llama,"
    FALLBACK_CHAIN="${FALLBACK_CHAIN},llama"
  else
    echo "  ❌ Llama-3.2-3B not available"
  fi
  
  echo ""
  echo "--- Fallback Chain ---"
  echo "  Primary → Secondary → Tertiary → Quaternary"
  echo "  $(echo $FALLBACK_CHAIN | tr ',' ' → ')"
  echo ""
  
  # Resource-based routing
  echo "--- Resource-Based Routing ---"
  RAM=$(free -m | awk '/^Mem:/{print $2}')
  
  if [ "$RAM" -ge 6000 ]; then
    echo "  RAM: ${RAM}MB (HIGH) - Can run 7B-8B models"
    echo "  Routing: No restrictions"
  elif [ "$RAM" -ge 4000 ]; then
    echo "  RAM: ${RAM}MB (MEDIUM) - Stick to 3B models"
    echo "  Routing: Exclude 8B models if memory pressure detected"
  else
    echo "  RAM: ${RAM}MB (LOW) - Use 1.5B-3B models only"
    echo "  Routing: Force DeepSeek-R1 or Llama-3.2"
  fi
  
  log_action "FALLBACK chain: $FALLBACK_CHAIN"
}

# ============================================================
# ERROR RECOVERY ENGINE
# ============================================================

execute_recovery() {
  echo "=== Error Recovery Engine ==="
  echo ""
  
  # Scan for recent errors
  echo "--- Recent Error Analysis ---"
  
  ERROR_SOURCES=(
    "$HOME/.aether/sessions/last_session.log:Aether Session"
    "$HOME/.aether/sessions/sentinel.log:Sentinel"
    "$HOME/.aether/sessions/system_alerts.log:System Alerts"
    "$HOME/.aether/sessions/logic_engine.log:Logic Engine"
  )
  
  TOTAL_ERRORS=0
  
  for source_def in "${ERROR_SOURCES[@]}"; do
    log_file=$(echo "$source_def" | cut -d':' -f1)
    log_name=$(echo "$source_def" | cut -d':' -f2)
    
    if [ -f "$log_file" ]; then
      error_count=$(grep -ciE "error|fail|exception|panic" "$log_file" 2>/dev/null || echo 0)
      
      if [ "$error_count" -gt 0 ]; then
        echo "  📄 $log_name: $error_count errors"
        TOTAL_ERRORS=$((TOTAL_ERRORS + error_count))
        
        # Show recent errors
        echo "    Recent:"
        grep -iE "error|fail|exception|panic" "$log_file" 2>/dev/null | tail -3 | sed 's/^/      /'
      fi
    fi
  done
  
  echo ""
  echo "Total Errors Found: $TOTAL_ERRORS"
  echo ""
  
  if [ "$TOTAL_ERRORS" -gt 0 ]; then
    echo "--- Recovery Recommendations ---"
    
    # Common error patterns and fixes
    echo ""
    echo "1. OOM (Out of Memory) Errors:"
    echo "   Fix: Reduce context size or switch to smaller model"
    echo "   Command: model_router.sh optimize"
    echo ""
    echo "2. Model Not Found Errors:"
    echo "   Fix: Download model or switch to available model"
    echo "   Command: model_router.sh list"
    echo ""
    echo "3. Dependency Errors:"
    echo "   Fix: Run dependency check and install missing packages"
    echo "   Command: dependency_checker.sh"
    echo ""
    echo "4. Permission Errors:"
    echo "   Fix: Check file permissions and ownership"
    echo "   Command: chmod +x <script>"
    echo ""
    echo "5. Network Errors:"
    echo "   Fix: Verify connectivity and retry"
    echo "   Command: ping 8.8.8.8"
    
    log_action "RECOVERY analyzed $TOTAL_ERRORS errors"
  else
    echo "✓ No errors detected - System healthy"
    log_action "RECOVERY no_errors_detected"
  fi
}

# ============================================================
# SELF-OPTIMIZATION ENGINE
# ============================================================

execute_optimization() {
  echo "=== Self-Optimization Engine ==="
  echo ""
  
  # Analyze historical performance
  echo "--- Performance Analysis ---"
  
  if [ -f "$LOGIC_LOG" ]; then
    TOTAL_OPS=$(wc -l < "$LOGIC_LOG")
    echo "  Total Operations Logged: $TOTAL_OPS"
    
    # Most common operations
    echo ""
    echo "  Top Operations:"
    awk '{print $3}' "$LOGIC_LOG" | sort | uniq -c | sort -rn | head -5 | while read -r count op; do
      printf "    %-30s %d times\n" "$op" "$count"
    done
  else
    echo "  No performance history yet"
  fi
  
  echo ""
  
  # Optimization recommendations
  echo "--- Optimization Recommendations ---"
  
  # Check current resource usage
  RAM_USED=$(free | awk '/^Mem:/{printf "%.0f", ($3/$2)*100}')
  CORES=$(nproc)
  LOAD=$(uptime | awk -F'load average:' '{print $2}' | xargs | cut -d',' -f1 | tr -d ' ')
  
  echo ""
  echo "1. Model Loading:"
  if [ "$RAM_USED" -gt 70 ]; then
    echo "   ⚡ Current RAM usage is high (${RAM_USED}%)"
    echo "   → Use --mmap flag for memory-efficient loading"
    echo "   → Close unnecessary applications"
  else
    echo "   ✓ RAM usage is acceptable (${RAM_USED}%)"
    echo "   → Can use standard loading"
  fi
  
  echo ""
  echo "2. Thread Allocation:"
  if [ "$CORES" -le 4 ]; then
    OPTIMAL_THREADS=$((CORES - 1))
    echo "   Device has $CORES cores"
    echo "   → Recommended threads: $OPTIMAL_THREADS"
  else
    OPTIMAL_THREADS=$((CORES / 2 + 1))
    echo "   Device has $CORES cores"
    echo "   → Recommended threads: $OPTIMAL_THREADS (balance performance/responsiveness)"
  fi
  
  echo ""
  echo "3. Context Window:"
  if [ "$RAM_USED" -gt 80 ]; then
    echo "   → Reduce context to 1024-2048 tokens"
  elif [ "$RAM_USED" -gt 60 ]; then
    echo "   → Context 2048-4096 tokens is safe"
  else
    echo "   → Can use larger context (4096+ tokens)"
  fi
  
  echo ""
  echo "4. Caching:"
  echo "   → Enable session persistence for repeated interactions"
  echo "   → Use context carry-over between sessions"
  echo "   Current session log: $(du -h "$HOME/.aether/sessions/last_session.log" 2>/dev/null | cut -f1 || echo '0B')"
  
  echo ""
  echo "5. Workflow Optimization:"
  echo "   → Use workflow_engine.sh for repetitive multi-step tasks"
  echo "   → Create custom workflows for common operations"
  
  log_action "OPTIMIZATION analysis_complete"
}

# ============================================================
# MAIN EXECUTION
# ============================================================

case "$ACTION" in
  decision_tree)
    TASK="$2"
    if [ -z "$TASK" ]; then
      echo "Usage: logic_engine.sh decision_tree '<task_description>'"
      exit 1
    fi
    evaluate_decision_tree "$TASK"
    ;;
    
  fallback)
    execute_fallback_routing
    ;;
    
  recover)
    execute_recovery
    ;;
    
  optimize)
    execute_optimization
    ;;
    
  evaluate)
    echo "=== Logic Engine Evaluation ==="
    echo ""
    echo "Available modes:"
    echo "  decision_tree <task> - Classify task and recommend execution path"
    echo "  fallback            - Show model fallback chain"
    echo "  recover             - Analyze errors and suggest fixes"
    echo "  optimize            - Self-optimization recommendations"
    echo ""
    echo "Run: logic_engine.sh <mode>"
    ;;
    
  *)
    echo "Usage: logic_engine.sh [decision_tree|fallback|recover|optimize|evaluate]"
    exit 1
    ;;
esac
