#!/data/data/com.termux/files/usr/bin/bash
# agent_matrix.sh - Agent capability matrix and dynamic tool routing
# Usage: agent_matrix.sh [matrix|route <task>|capabilities|upgrade]

AETHER_DIR="$HOME/aether"
MATRIX_LOG="$HOME/.aether/sessions/agent_matrix.log"
ACTION="${1:-matrix}"

log_action() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$MATRIX_LOG"
}

# ============================================================
# AGENT CAPABILITY MATRIX
# ============================================================

show_capability_matrix() {
  echo "=== Agent Capability Matrix ==="
  echo ""
  echo "This matrix maps available agents to their optimal use cases and tool sets."
  echo ""
  
  echo "┌─────────────────────────────────────────────────────────────────────────────┐"
  echo "│                           AETHER AGENT MATRIX                               │"
  echo "├────────────┬──────────────┬───────────────────────┬─────────────────────────┤"
  echo "│ TIER       │ MODEL        │ CAPABILITIES          │ TOOL SET                │"
  echo "├────────────┼──────────────┼───────────────────────┼─────────────────────────┤"
  echo "│ TURBO      │ Llama-3.2    │ • Fast responses      │ • get_date              │"
  echo "│            │ 3B           │ • General Q&A         │ • get_battery           │"
  echo "│            │              │ • Simple tasks        │ • list_files            │"
  echo "│            │              │ • Summarization       │ • web_search            │"
  echo "├────────────┼──────────────┼───────────────────────┼─────────────────────────┤"
  echo "│ AGENT      │ Hermes-2     │ • Tool use            │ • All TURBO tools       │"
  echo "│            │ Pro 8B       │ • Multi-step tasks    │ • obsidian_*            │"
  echo "│            │              │ • Instruction follow  │ • web_read              │"
  echo "│            │              │ • Function calling    │ • learn (built-in)      │"
  echo "├────────────┼──────────────┼───────────────────────┼─────────────────────────┤"
  echo "│ CODE       │ Qwen2.5      │ • Code generation     │ • All TURBO tools       │"
  echo "│            │ Coder 3B     │ • Code review         │ • dependency_checker    │"
  echo "│            │              │ • Debugging           │ • list_files            │"
  echo "│            │              │ • Refactoring         │ • log_analyzer          │"
  echo "├────────────┼──────────────┼───────────────────────┼─────────────────────────┤"
  echo "│ LOGIC      │ DeepSeek     │ • Chain-of-thought    │ • All TURBO tools       │"
  echo "│            │ R1 1.5B      │ • Complex reasoning   │ • system_monitor        │"
  echo "│            │              │ • Planning            │ • model_router          │"
  echo "│            │              │ • Analysis            │ • logic_engine          │"
  echo "└────────────┴──────────────┴───────────────────────┴─────────────────────────┘"
  echo ""
  
  echo "┌─────────────────────────────────────────────────────────────────────────────┐"
  echo "│                          SKILL REGISTRY                                     │"
  echo "├──────────────────────┬──────────────────────────────────────────────────────┤"
  echo "│ SKILL                │ TRIGGERS                                             │"
  echo "├──────────────────────┼──────────────────────────────────────────────────────┤"
  echo "│ humanizer            │ Rewrite text, remove AI patterns, natural language   │"
  echo "│ code-review          │ Review code, PR review, code audit                   │"
  echo "│ security-audit       │ Security scan, vulnerability check, hardening        │"
  echo "│ data-analysis        │ Analyze data, statistics, visualization              │"
  echo "│ system-optimization  │ Optimize system, performance tuning, free resources  │"
  echo "│ architecture-design  │ System design, technical planning, refactoring       │"
  echo "│ project-planning     │ Plan project, task breakdown, sprint planning        │"
  echo "│ obsidian-companion   │ Obsidian vault management, note creation             │"
  echo "│ link-audit           │ Broken links, orphaned notes, vault health           │"
  echo "│ moc-update           │ MOC updates after note creation                      │"
  echo "│ knowledge            │ Cross-project knowledge synthesis                    │"
  echo "└──────────────────────┴──────────────────────────────────────────────────────┘"
  echo ""
  
  echo "┌─────────────────────────────────────────────────────────────────────────────┐"
  echo "│                          WORKFLOW PIPELINES                                 │"
  echo "├──────────────────────┬──────────────────────────────────────────────────────┤"
  echo "│ WORKFLOW             │ STAGES                                               │"
  echo "├──────────────────────┼──────────────────────────────────────────────────────┤"
  echo "│ code_review          │ security → quality → performance → documentation     │"
  echo "│ security_audit       │ recon → vuln → system → report                       │"
  echo "│ data_processing      │ ingest → validate → transform → analyze → report     │"
  echo "│ deploy               │ test → build → verify → deploy → monitor             │"
  echo "└──────────────────────┴──────────────────────────────────────────────────────┘"
  
  log_action "MATRIX capability_matrix_displayed"
}

# ============================================================
# DYNAMIC TASK ROUTING
# ============================================================

route_task() {
  local task="$1"
  
  echo "=== Dynamic Task Routing ==="
  echo "Task: $task"
  echo ""
  
  # Score each tier based on task keywords
  TURBO_SCORE=0
  AGENT_SCORE=0
  CODE_SCORE=0
  LOGIC_SCORE=0
  
  # Code indicators
  if echo "$task" | grep -qiE "code|implement|function|class|script|api|debug|fix|refactor|test"; then
    CODE_SCORE=$((CODE_SCORE + 40))
    AGENT_SCORE=$((AGENT_SCORE + 10))
  fi
  
  # Reasoning indicators
  if echo "$task" | grep -qiE "why|how|analyze|explain|compare|evaluate|plan|design|think"; then
    LOGIC_SCORE=$((LOGIC_SCORE + 40))
    AGENT_SCORE=$((AGENT_SCORE + 15))
  fi
  
  # Tool-use indicators
  if echo "$task" | grep -qiE "search|find|read|check|scan|list|show|get|fetch"; then
    AGENT_SCORE=$((AGENT_SCORE + 30))
    TURBO_SCORE=$((TURBO_SCORE + 10))
  fi
  
  # Speed indicators
  if echo "$task" | grep -qiE "quick|fast|simple|short|brief|summarize"; then
    TURBO_SCORE=$((TURBO_SCORE + 30))
  fi
  
  # Security indicators
  if echo "$task" | grep -qiE "security|vuln|scan|audit|hack|pentest"; then
    AGENT_SCORE=$((AGENT_SCORE + 25))
    LOGIC_SCORE=$((LOGIC_SCORE + 15))
  fi
  
  # Data indicators
  if echo "$task" | grep -qiE "data|statistic|chart|graph|number|calculate|metric"; then
    LOGIC_SCORE=$((LOGIC_SCORE + 30))
    AGENT_SCORE=$((AGENT_SCORE + 10))
  fi
  
  echo "--- Tier Scores ---"
  printf "  TURBO:  %d/100\n" "$TURBO_SCORE"
  printf "  AGENT:  %d/100\n" "$AGENT_SCORE"
  printf "  CODE:   %d/100\n" "$CODE_SCORE"
  printf "  LOGIC:  %d/100\n" "$LOGIC_SCORE"
  echo ""
  
  # Determine winner
  MAX_SCORE=0
  WINNER="agent"
  
  if [ "$TURBO_SCORE" -gt "$MAX_SCORE" ]; then
    MAX_SCORE=$TURBO_SCORE
    WINNER="turbo"
  fi
  if [ "$AGENT_SCORE" -gt "$MAX_SCORE" ]; then
    MAX_SCORE=$AGENT_SCORE
    WINNER="agent"
  fi
  if [ "$CODE_SCORE" -gt "$MAX_SCORE" ]; then
    MAX_SCORE=$CODE_SCORE
    WINNER="code"
  fi
  if [ "$LOGIC_SCORE" -gt "$MAX_SCORE" ]; then
    MAX_SCORE=$LOGIC_SCORE
    WINNER="logic"
  fi
  
  echo "--- Routing Decision ---"
  
  case "$WINNER" in
    turbo)
      echo "  Selected Tier: TURBO"
      echo "  Model: Llama-3.2-3B"
      echo "  Reason: Fast, simple task - prioritize speed"
      echo "  Skills: (none specific)"
      echo "  Tools: get_date, get_battery, list_files, web_search"
      ;;
    agent)
      echo "  Selected Tier: AGENT"
      echo "  Model: Hermes-2-Pro-8B"
      echo "  Reason: Multi-step task requiring tool use"
      echo "  Skills: (auto-detect from task)"
      echo "  Tools: All tools available"
      ;;
    code)
      echo "  Selected Tier: CODE"
      echo "  Model: Qwen2.5-Coder-3B"
      echo "  Reason: Code-related task - use specialized model"
      echo "  Skills: code-review"
      echo "  Tools: list_files, dependency_checker, log_analyzer"
      ;;
    logic)
      echo "  Selected Tier: LOGIC"
      echo "  Model: DeepSeek-R1-1.5B"
      echo "  Reason: Complex reasoning required"
      echo "  Skills: (auto-detect from task)"
      echo "  Tools: system_monitor, model_router, logic_engine"
      ;;
  esac
  
  echo ""
  
  # Recommend skills
  echo "--- Recommended Skills ---"
  if echo "$task" | grep -qiE "review|audit|check"; then
    echo "  • code-review"
  fi
  if echo "$task" | grep -qiE "security|vuln|scan"; then
    echo "  • security-audit"
  fi
  if echo "$task" | grep -qiE "data|analyz|statistic"; then
    echo "  • data-analysis"
  fi
  if echo "$task" | grep -qiE "optim|performance|speed"; then
    echo "  • system-optimization"
  fi
  if echo "$task" | grep -qiE "design|architect|plan"; then
    echo "  • architecture-design"
    echo "  • project-planning"
  fi
  
  log_action "ROUTE task='$task' tier=$WINNER score=$MAX_SCORE"
}

# ============================================================
# CAPABILITY UPGRADES
# ============================================================

show_upgrade_options() {
  echo "=== Capability Upgrade Options ==="
  echo ""
  
  echo "Available Upgrades:"
  echo ""
  
  echo "1. Add New Model"
  echo "   Download additional models for expanded capabilities"
  echo "   Command: model_router.sh list"
  echo "   Current Models: $(find "$HOME/.aether/models" -name "*.gguf" 2>/dev/null | wc -l)"
  echo ""
  
  echo "2. Install New Skills"
  echo "   Add specialized capabilities"
  echo "   Command: ~/aether/scripts/skill_market.sh"
  echo "   Current Skills: $(find "$HOME/aether/skills" -name "SKILL.md" 2>/dev/null | wc -l)"
  echo ""
  
  echo "3. Add New Tools"
  echo "   Expand toolbox with custom scripts"
  echo "   Location: ~/aether/toolbox/"
  echo "   Current Tools: $(python3 -c "import json; print(len(json.load(open('$HOME/aether/toolbox/manifest.json'))['tools']))" 2>/dev/null || echo "?")"
  echo ""
  
  echo "4. Create Custom Workflows"
  echo "   Define multi-step automation pipelines"
  echo "   Command: workflow_engine.sh create"
  echo "   Current Workflows: $(find "$HOME/aether/workflows" -name "*.workflow" 2>/dev/null | wc -l)"
  echo ""
  
  echo "5. Expand Knowledge Base"
  echo "   Add documentation to AetherVault"
  echo "   Location: ~/aether/knowledge/aethervault/"
  echo "   Current Docs: $(find "$HOME/aether/knowledge/aethervault" -name "*.md" 2>/dev/null | wc -l)"
  echo ""
  
  echo "6. Enable Auto-Scaling"
  echo "   Dynamic resource allocation based on system state"
  echo "   Command: auto_scaler.sh enable"
}

# ============================================================
# MAIN EXECUTION
# ============================================================

case "$ACTION" in
  matrix)
    show_capability_matrix
    ;;
    
  route)
    TASK="$2"
    if [ -z "$TASK" ]; then
      echo "Usage: agent_matrix.sh route '<task_description>'"
      exit 1
    fi
    route_task "$TASK"
    ;;
    
  capabilities)
    show_capability_matrix
    ;;
    
  upgrade)
    show_upgrade_options
    ;;
    
  *)
    echo "Usage: agent_matrix.sh [matrix|route|capabilities|upgrade]"
    echo ""
    echo "Commands:"
    echo "  matrix       - Show agent capability matrix"
    echo "  route <task> - Route a task to optimal tier"
    echo "  capabilities - Same as matrix"
    echo "  upgrade      - Show upgrade options"
    exit 1
    ;;
esac
