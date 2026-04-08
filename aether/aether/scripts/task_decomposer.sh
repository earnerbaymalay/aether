#!/data/data/com.termux/files/usr/bin/bash
# task_decomposer.sh - Break complex tasks into executable subtasks with dependency mapping
# Usage: task_decomposer.sh [decompose '<task>'|plan|execute|status|templates]

DECOMPOSER_LOG="$HOME/.aether/sessions/task_decomposer.log"
TASK_DIR="$HOME/.aether/tasks"
ACTION="${1:-status}"

mkdir -p "$TASK_DIR"

log_action() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$DECOMPOSER_LOG"
}

# ============================================================
# TASK DECOMPOSITION ENGINE
# ============================================================

decompose_task() {
  local task="$1"
  local task_id="task_$(date +%Y%m%d_%H%M%S)"
  
  echo "=== Task Decomposition Engine ==="
  echo "Task ID: $task_id"
  echo "Task: $task"
  echo ""
  
  # Analyze task complexity
  WORD_COUNT=$(echo "$task" | wc -w)
  
  echo "--- Complexity Analysis ---"
  if [ "$WORD_COUNT" -le 10 ]; then
    echo "  Complexity: SIMPLE"
    echo "  Decomposition: Not needed (single-step task)"
    echo "  Est. Effort: < 30 min"
    log_action "DECOMPOSE simple task=$task"
    return
  elif [ "$WORD_COUNT" -le 25 ]; then
    echo "  Complexity: MODERATE"
    echo "  Decomposition: 3-5 subtasks"
    echo "  Est. Effort: 1-3 hours"
  else
    echo "  Complexity: HIGH"
    echo "  Decomposition: 5-10 subtasks"
    echo "  Est. Effort: 3+ hours"
  fi
  echo ""
  
  # Task type classification
  echo "--- Task Classification ---"
  
  TASK_TYPE="general"
  
  if echo "$task" | grep -qiE "build|create|develop|implement|code|write"; then
    TASK_TYPE="implementation"
    echo "  Type: IMPLEMENTATION"
    echo "  Pattern: Design → Develop → Test → Deploy"
    
  elif echo "$task" | grep -qiE "analyz|investigat|research|explore|understand"; then
    TASK_TYPE="analysis"
    echo "  Type: ANALYSIS"
    echo "  Pattern: Scope → Gather Data → Analyze → Report"
    
  elif echo "$task" | grep -qiE "fix|debug|resolve|troubleshoot|repair"; then
    TASK_TYPE="debugging"
    echo "  Type: DEBUGGING"
    echo "  Pattern: Reproduce → Isolate → Fix → Verify"
    
  elif echo "$task" | grep -qiE "optim|improve|enhance|speed|performance"; then
    TASK_TYPE="optimization"
    echo "  Type: OPTIMIZATION"
    echo "  Pattern: Baseline → Identify → Optimize → Measure"
    
  elif echo "$task" | grep -qiE "migrat|move|convert|upgrade|transform"; then
    TASK_TYPE="migration"
    echo "  Type: MIGRATION"
    echo "  Pattern: Assess → Plan → Migrate → Validate"
    
  else
    echo "  Type: GENERAL"
    echo "  Pattern: Plan → Execute → Verify"
  fi
  
  echo ""
  
  # Generate task breakdown
  echo "--- Task Breakdown ---"
  echo ""
  
  case "$TASK_TYPE" in
    implementation)
      echo "Phase 1: Planning & Design"
      echo "  ├─ 1.1 Requirements clarification"
      echo "  ├─ 1.2 Architecture/structure design"
      echo "  └─ 1.3 Technology/tool selection"
      echo ""
      echo "Phase 2: Core Implementation"
      echo "  ├─ 2.1 Set up project structure"
      echo "  ├─ 2.2 Implement core functionality"
      echo "  └─ 2.3 Implement supporting features"
      echo ""
      echo "Phase 3: Integration & Testing"
      echo "  ├─ 3.1 Integration with existing systems"
      echo "  ├─ 3.2 Unit testing"
      echo "  └─ 3.3 Integration testing"
      echo ""
      echo "Phase 4: Deployment & Documentation"
      echo "  ├─ 4.1 Deploy to target environment"
      echo "  ├─ 4.2 Verify functionality"
      echo "  └─ 4.3 Document changes"
      ;;
      
    analysis)
      echo "Phase 1: Scope Definition"
      echo "  ├─ 1.1 Define analysis objectives"
      echo "  ├─ 1.2 Identify data sources"
      echo "  └─ 1.3 Determine success criteria"
      echo ""
      echo "Phase 2: Data Collection"
      echo "  ├─ 2.1 Gather relevant data/files"
      echo "  ├─ 2.2 Clean and organize data"
      echo "  └─ 2.3 Validate data quality"
      echo ""
      echo "Phase 3: Analysis"
      echo "  ├─ 3.1 Apply analytical methods"
      echo "  ├─ 3.2 Identify patterns/trends"
      echo "  └─ 3.3 Validate findings"
      echo ""
      echo "Phase 4: Reporting"
      echo "  ├─ 4.1 Synthesize key findings"
      echo "  ├─ 4.2 Generate recommendations"
      echo "  └─ 4.3 Create summary report"
      ;;
      
    debugging)
      echo "Phase 1: Reproduction"
      echo "  ├─ 1.1 Understand reported issue"
      echo "  ├─ 1.2 Reproduce the bug consistently"
      echo "  └─ 1.3 Document reproduction steps"
      echo ""
      echo "Phase 2: Isolation"
      echo "  ├─ 2.1 Review relevant code/logs"
      echo "  ├─ 2.2 Narrow down root cause"
      echo "  └─ 2.3 Identify affected components"
      echo ""
      echo "Phase 3: Fix Implementation"
      echo "  ├─ 3.1 Design fix approach"
      echo "  ├─ 3.2 Implement the fix"
      echo "  └─ 3.3 Test the fix"
      echo ""
      echo "Phase 4: Verification"
      echo "  ├─ 4.1 Verify fix resolves issue"
      echo "  ├─ 4.2 Check for regressions"
      echo "  └─ 4.3 Document fix for future reference"
      ;;
      
    optimization)
      echo "Phase 1: Baseline Measurement"
      echo "  ├─ 1.1 Measure current performance"
      echo "  ├─ 1.2 Identify bottlenecks"
      echo "  └─ 1.3 Set improvement targets"
      echo ""
      echo "Phase 2: Analysis"
      echo "  ├─ 2.1 Profile resource usage"
      echo "  ├─ 2.2 Identify optimization opportunities"
      echo "  └─ 2.3 Prioritize by impact"
      echo ""
      echo "Phase 3: Optimization"
      echo "  ├─ 3.1 Apply quick wins first"
      echo "  ├─ 3.2 Implement structural improvements"
      echo "  └─ 3.3 Tune parameters"
      echo ""
      echo "Phase 4: Validation"
      echo "  ├─ 4.1 Re-measure performance"
      echo "  ├─ 4.2 Compare against baseline"
      echo "  └─ 4.3 Document optimizations"
      ;;
      
    migration)
      echo "Phase 1: Assessment"
      echo "  ├─ 1.1 Inventory current state"
      echo "  ├─ 1.2 Define target state"
      echo "  └─ 1.3 Identify migration risks"
      echo ""
      echo "Phase 2: Planning"
      echo "  ├─ 2.1 Design migration strategy"
      echo "  ├─ 2.2 Create backup plan"
      echo "  └─ 2.3 Set up test environment"
      echo ""
      echo "Phase 3: Execution"
      echo "  ├─ 3.1 Migrate data/configuration"
      echo "  ├─ 3.2 Update dependencies"
      echo "  └─ 3.3 Test in staging"
      echo ""
      echo "Phase 4: Validation"
      echo "  ├─ 4.1 Verify functionality"
      echo "  ├─ 4.2 Performance testing"
      echo "  └─ 4.3 Switch to production"
      ;;
      
    *)
      echo "Phase 1: Planning"
      echo "  ├─ 1.1 Clarify requirements"
      echo "  ├─ 1.2 Identify resources needed"
      echo "  └─ 1.3 Define success criteria"
      echo ""
      echo "Phase 2: Execution"
      echo "  ├─ 2.1 Execute first subtask"
      echo "  ├─ 2.2 Execute second subtask"
      echo "  └─ 2.3 Execute remaining subtasks"
      echo ""
      echo "Phase 3: Verification"
      echo "  ├─ 3.1 Verify against requirements"
      echo "  ├─ 3.2 Test functionality"
      echo "  └─ 3.3 Document results"
      ;;
  esac
  
  echo ""
  
  # Save task definition
  cat > "$TASK_DIR/${task_id}.task" << EOF
id: $task_id
task: $task
type: $TASK_TYPE
created: $(date)
status: planned
complexity: $([ "$WORD_COUNT" -le 10 ] && echo "simple" || ([ "$WORD_COUNT" -le 25 ] && echo "moderate" || echo "high"))
EOF
  
  echo "--- Task Dependencies ---"
  echo "  Sequential execution required (each phase depends on previous)"
  echo "  Parallel opportunities: Within phases, subtasks may be parallelized"
  echo ""
  
  echo "--- Risk Assessment ---"
  echo "  Unknowns: Task-specific details may reveal additional complexity"
  echo "  Dependencies: External tools/libraries may need installation"
  echo "  Mitigation: Start with exploration phase before committing to approach"
  
  log_action "DECOMPOSE id=$task_id type=$TASK_TYPE complexity=$WORD_COUNT"
}

# ============================================================
# TASK PLANNING
# ============================================================

show_planning_templates() {
  echo "=== Task Planning Templates ==="
  echo ""
  echo "Available Templates:"
  echo ""
  
  echo "1. Feature Implementation"
  echo "   Pattern: Requirements → Design → Implement → Test → Document"
  echo "   Best for: New functionality, features, capabilities"
  echo ""
  
  echo "2. Bug Fix"
  echo "   Pattern: Reproduce → Isolate → Fix → Verify → Document"
  echo "   Best for: Debugging, fixing issues, resolving errors"
  echo ""
  
 echo "3. System Optimization"
  echo "   Pattern: Baseline → Profile → Optimize → Measure → Document"
  echo "   Best for: Performance improvements, resource optimization"
  echo ""
  
  echo "4. Research & Analysis"
  echo "   Pattern: Scope → Gather → Analyze → Synthesize → Report"
  echo "   Best for: Investigations, data analysis, understanding"
  echo ""
  
  echo "5. Migration/Upgrade"
  echo "   Pattern: Assess → Plan → Migrate → Validate → Document"
  echo "   Best for: System migrations, version upgrades, conversions"
  echo ""
  
  echo "6. Security Hardening"
  echo "   Pattern: Scan → Assess → Fix → Verify → Monitor"
  echo "   Best for: Security improvements, vulnerability remediation"
  echo ""
  
  echo "Usage: task_decomposer.sh decompose '<your task>'"
  echo "The engine will auto-select the appropriate template"
}

# ============================================================
# TASK EXECUTION TRACKER
# ============================================================

execute_task() {
  local task_id="$1"
  
  if [ -z "$task_id" ]; then
    echo "Usage: task_decomposer.sh execute <task_id>"
    echo ""
    echo "Available tasks:"
    ls -1 "$TASK_DIR"/*.task 2>/dev/null | while read -r f; do
      id=$(basename "$f" .task)
      status=$(grep "^status:" "$f" | cut -d' ' -f2)
      task=$(grep "^task:" "$f" | cut -d' ' -f2-)
      echo "  $id: $task [$status]"
    done
    exit 0
  fi
  
  TASK_FILE="$TASK_DIR/${task_id}.task"
  
  if [ ! -f "$TASK_FILE" ]; then
    echo "ERROR: Task not found: $task_id"
    exit 1
  fi
  
  echo "=== Executing Task: $task_id ==="
  echo ""
  
  # Update status
  sed -i 's/status: .*/status: in_progress/' "$TASK_FILE"
  
  task=$(grep "^task:" "$TASK_FILE" | cut -d' ' -f2-)
  task_type=$(grep "^type:" "$TASK_FILE" | cut -d' ' -f2)
  
  echo "Task: $task"
  echo "Type: $task_type"
  echo "Status: IN PROGRESS"
  echo ""
  
  echo "Execution Guide:"
  echo "1. Follow the phase breakdown shown in decomposition"
  echo "2. Complete each subtask sequentially"
  echo "3. Use appropriate tools for each phase"
  echo "4. Update status when complete: task_decomposer.sh complete $task_id"
  echo ""
  
  log_action "EXECUTE id=$task_id task=$task"
}

complete_task() {
  local task_id="$1"
  
  if [ -z "$task_id" ]; then
    echo "Usage: task_decomposer.sh complete <task_id>"
    exit 1
  fi
  
  TASK_FILE="$TASK_DIR/${task_id}.task"
  
  if [ ! -f "$TASK_FILE" ]; then
    echo "ERROR: Task not found: $task_id"
    exit 1
  fi
  
  sed -i 's/status: .*/status: completed/' "$TASK_FILE"
  echo "completed: $(date)" >> "$TASK_FILE"
  
  echo "✓ Task $task_id marked as completed"
  log_action "COMPLETE id=$task_id"
}

# ============================================================
# TASK STATUS
# ============================================================

show_task_status() {
  echo "=== Task Status ==="
  echo ""
  
  if [ ! -d "$TASK_DIR" ] || [ -z "$(ls "$TASK_DIR"/*.task 2>/dev/null)" ]; then
    echo "No tasks defined yet."
    echo "Run: task_decomposer.sh decompose '<task>'"
    exit 0
  fi
  
  TOTAL=0
  PLANNED=0
  IN_PROGRESS=0
  COMPLETED=0
  
  for task_file in "$TASK_DIR"/*.task; do
    id=$(basename "$task_file" .task)
    status=$(grep "^status:" "$task_file" | cut -d' ' -f2)
    task=$(grep "^task:" "$task_file" | cut -d' ' -f2-)
    created=$(grep "^created:" "$task_file" | cut -d' ' -f2-3)
    
    TOTAL=$((TOTAL + 1))
    case "$status" in
      planned) PLANNED=$((PLANNED + 1)) ;;
      in_progress) IN_PROGRESS=$((IN_PROGRESS + 1)) ;;
      completed) COMPLETED=$((COMPLETED + 1)) ;;
    esac
    
    # Status icon
    case "$status" in
      planned) icon="○" ;;
      in_progress) icon="◐" ;;
      completed) icon="✓" ;;
      *) icon="?" ;;
    esac
    
    echo "  $icon $id"
    echo "    Task: $task"
    echo "    Status: $status"
    echo "    Created: $created"
    echo ""
  done
  
  echo "--- Summary ---"
  echo "  Total: $TOTAL"
  echo "  Planned: $PLANNED"
  echo "  In Progress: $IN_PROGRESS"
  echo "  Completed: $COMPLETED"
  echo ""
  
  if [ "$TOTAL" -gt 0 ]; then
    COMPLETION_RATE=$((COMPLETED * 100 / TOTAL))
    echo "  Completion Rate: ${COMPLETION_RATE}%"
  fi
}

# ============================================================
# MAIN EXECUTION
# ============================================================

case "$ACTION" in
  decompose)
    TASK="$2"
    if [ -z "$TASK" ]; then
      echo "Usage: task_decomposer.sh decompose '<task_description>'"
      exit 1
    fi
    decompose_task "$TASK"
    ;;
    
  plan)
    show_planning_templates
    ;;
    
  execute)
    execute_task "$2"
    ;;
    
  complete)
    complete_task "$2"
    ;;
    
  status)
    show_task_status
    ;;
    
  templates)
    show_planning_templates
    ;;
    
  *)
    echo "Usage: task_decomposer.sh [decompose|plan|execute|complete|status|templates]"
    echo ""
    echo "Commands:"
    echo "  decompose '<task>' - Break down a complex task"
    echo "  plan               - Show planning templates"
    echo "  execute <id>       - Start executing a task"
    echo "  complete <id>      - Mark task as completed"
    echo "  status             - Show all tasks and status"
    echo "  templates          - Show available templates"
    exit 1
    ;;
esac
