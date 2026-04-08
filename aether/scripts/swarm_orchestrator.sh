#!/data/data/com.termux/files/usr/bin/bash
# swarm_orchestrator.sh — Real Multi-Agent Swarm Orchestration
# LOGIC plans → CODE implements → AGENT executes with tools
# Usage: swarm_orchestrator.sh [run <task>|status]

SWARM_DIR="$HOME/.aether/swarm"
SWARM_LOG="$SWARM_DIR/swarm.log"
LLAMA_BIN="$HOME/llama.cpp/build/bin/llama-cli"

mkdir -p "$SWARM_DIR"

# ============================================================
# MODEL PATHS
# ============================================================

MODEL_LOGIC="$HOME/aether/models/DeepSeek-R1-Distill-Qwen-1.5B-GGUF/deepseek-r1-distill-qwen-1.5b-q4_k_m.gguf"
MODEL_CODE="$HOME/aether/models/Qwen2.5-Coder-3B-Instruct-GGUF/qwen2.5-coder-3b-instruct-q4_k_m.gguf"
MODEL_AGENT="$HOME/aether/models/Hermes-2-Pro-Llama-3-8B-GGUF/hermes-2-pro-llama-3-8b-q4_k_m.gguf"

THREADS=4
CTX_SIZE=2048

# ============================================================
# HELPER: Run inference with any model
# ============================================================

run_inference() {
  local model_path="$1"
  local prompt="$2"
  local output_file="$3"
  local max_tokens="${4:-512}"

  if [ ! -f "$model_path" ]; then
    echo "  ⚠ Model not found: $(basename "$model_path")"
    echo "  → Stage skipped (model not downloaded)"
    return 1
  fi

  if [ ! -f "$LLAMA_BIN" ]; then
    echo "  ⚠ llama-cli not found at $LLAMA_BIN"
    return 1
  fi

  local threads=$THREADS

  # Use fewer threads for smaller models
  if echo "$model_path" | grep -q "1.5b"; then
    threads=2
  fi

  # Run inference
  "$LLAMA_BIN" \
    -m "$model_path" \
    -p "$prompt" \
    -n "$max_tokens" \
    -t "$threads" \
    -c "$CTX_SIZE" \
    --mmap \
    --temp 0.3 \
    --top_p 0.9 \
    --repeat_penalty 1.1 \
    --no-display-prompt \
    2>/dev/null > "$output_file"

  if [ -s "$output_file" ]; then
    return 0
  else
    echo "  ⚠ Inference produced no output"
    return 1
  fi
}

# ============================================================
# SWARM STAGE 1: LOGIC — Plan
# ============================================================

stage_logic_plan() {
  local task="$1"
  local plan_file="$SWARM_DIR/stage1_plan.txt"

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  STAGE 1: LOGIC (DeepSeek-R1) — Planning"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  local prompt="You are the LOGIC tier of Aether's swarm. Your job is to PLAN, not implement.

TASK: $task

Analyze this task and produce a structured plan with:
1. Key steps needed to accomplish it
2. Technical approach for each step
3. Files/components that need to be modified or created
4. Potential risks or edge cases
5. Success criteria

Format your response as a numbered list. Be specific and actionable.
Do NOT write code. Only produce a plan."

  if run_inference "$MODEL_LOGIC" "$prompt" "$plan_file" 256; then
    echo "  ✓ Plan generated"
    echo ""
    echo "  Plan:"
    head -30 "$plan_file" | sed 's/^/    /'
    echo ""
    echo "$(date): STAGE1 complete task='$task'" >> "$SWARM_LOG"
    return 0
  else
    echo "  ✗ Planning failed"
    echo "$(date): STAGE1 FAILED task='$task'" >> "$SWARM_LOG"
    return 1
  fi
}

# ============================================================
# SWARM STAGE 2: CODE — Implement
# ============================================================

stage_code_implement() {
  local task="$1"
  local plan_file="$SWARM_DIR/stage1_plan.txt"
  local code_file="$SWARM_DIR/stage2_code.txt"

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  STAGE 2: CODE (Qwen-Coder) — Implementation"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  if [ ! -f "$plan_file" ]; then
    echo "  ⚠ No plan from Stage 1 — generating from task directly"
    local plan_content=""
  else
    local plan_content
    plan_content=$(cat "$plan_file")
  fi

  local prompt="You are the CODE tier of Aether's swarm. Your job is to WRITE CODE based on the plan.

TASK: $task

PLAN FROM LOGIC TIER:
$plan_content

Write the actual implementation code. Include:
- Proper file structure
- Comments explaining key sections
- Error handling
- Use Termux-compatible paths (~/aether)

Output ONLY the code, no explanations.
Use clear section headers like: === filename.py ==="

  if run_inference "$MODEL_CODE" "$prompt" "$code_file" 1024; then
    echo "  ✓ Implementation generated"
    echo ""
    echo "  Code (first 40 lines):"
    head -40 "$code_file" | sed 's/^/    /'
    echo ""
    echo "$(date): STAGE2 complete" >> "$SWARM_LOG"
    return 0
  else
    echo "  ✗ Implementation failed"
    echo "$(date): STAGE2 FAILED" >> "$SWARM_LOG"
    return 1
  fi
}

# ============================================================
# SWARM STAGE 3: AGENT — Execute & Report
# ============================================================

stage_agent_execute() {
  local task="$1"
  local plan_file="$SWARM_DIR/stage1_plan.txt"
  local code_file="$SWARM_DIR/stage2_code.txt"
  local report_file="$SWARM_DIR/stage3_report.txt"

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  STAGE 3: AGENT (Hermes-8B) — Execution & Analysis"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  local plan_content=""
  local code_content=""
  [ -f "$plan_file" ] && plan_content=$(cat "$plan_file")
  [ -f "$code_file" ] && code_content=$(cat "$code_file")

  local prompt="You are the AGENT tier of Aether's swarm. Your job is to ANALYZE the output from the previous stages and provide actionable guidance.

TASK: $task

PLAN (from LOGIC tier):
$plan_content

CODE (from CODE tier):
$code_content

Your analysis should cover:
1. Does the code follow the plan? What's missing or extra?
2. Are there bugs, security issues, or performance problems?
3. What would you fix before deploying?
4. What commands should the user run to test this?
5. Rate the overall quality (1-10) and explain why.

Be direct and technical. No fluff."

  if run_inference "$MODEL_AGENT" "$prompt" "$report_file" 768; then
    echo "  ✓ Analysis complete"
    echo ""
    echo "  Agent Report:"
    head -40 "$report_file" | sed 's/^/    /'
    echo ""
    echo "$(date): STAGE3 complete" >> "$SWARM_LOG"
    return 0
  else
    echo "  ⚠ Analysis failed (non-critical)"
    echo "$(date): STAGE3 non-critical failure" >> "$SWARM_LOG"
    return 0  # Non-critical — plan and code still valuable
  fi
}

# ============================================================
# RECOVERY: Retry a failed stage
# ============================================================

retry_stage() {
  local stage="$1"
  local task="$2"

  echo ""
  echo "  ⚡ Retrying Stage $stage..."
  echo ""

  case "$stage" in
    1) stage_logic_plan "$task" ;;
    2) stage_code_implement "$task" ;;
    3) stage_agent_execute "$task" ;;
  esac
}

# ============================================================
# MAIN SWARM EXECUTION
# ============================================================

run_swarm() {
  local task="$1"
  local start_time
  start_time=$(date +%s)

  echo ""
  echo "╔═══════════════════════════════════════╗"
  echo "║   AETHER SWARM ORCHESTRATOR           ║"
  echo "║   LOGIC → CODE → AGENT               ║"
  echo "╚═══════════════════════════════════════╝"
  echo ""
  echo "Task: $task"
  echo ""

  # Stage 1: Plan
  if ! stage_logic_plan "$task"; then
    echo ""
    echo "❌ Swarm aborted at Stage 1 (Planning)"
    echo "   Check that the LOGIC model is downloaded:"
    echo "   $MODEL_LOGIC"
    return 1
  fi

  echo ""

  # Stage 2: Implement
  if ! stage_code_implement "$task"; then
    echo ""
    echo "⚠ Swarm completed with Stage 2 failure (Implementation)"
    echo "  The plan from Stage 1 is still available:"
    echo "  $SWARM_DIR/stage1_plan.txt"
    echo ""
    read -p "Retry Stage 2? (y/n): " retry
    if [[ "$retry" =~ ^[Yy] ]]; then
      retry_stage 2 "$task"
    else
      return 1
    fi
  fi

  echo ""

  # Stage 3: Analyze
  stage_agent_execute "$task"

  # Summary
  local end_time
  end_time=$(date +%s)
  local duration=$((end_time - start_time))

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  SWARM COMPLETE (${duration}s)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Artifacts:"
  [ -f "$SWARM_DIR/stage1_plan.txt" ] && echo "  📋 Plan: $SWARM_DIR/stage1_plan.txt"
  [ -f "$SWARM_DIR/stage2_code.txt" ] && echo "  💻 Code: $SWARM_DIR/stage2_code.txt"
  [ -f "$SWARM_DIR/stage3_report.txt" ] && echo "  📊 Report: $SWARM_DIR/stage3_report.txt"
  echo ""

  echo "$(date): SWARM_COMPLETE duration=${duration}s task='$task'" >> "$SWARM_LOG"
}

# ============================================================
# STATUS
# ============================================================

show_status() {
  echo "=== Swarm Orchestrator Status ==="
  echo ""

  echo "Models:"
  [ -f "$MODEL_LOGIC" ] && echo "  ✓ LOGIC (DeepSeek-R1-1.5B)" || echo "  ❌ LOGIC model missing"
  [ -f "$MODEL_CODE" ] && echo "  ✓ CODE (Qwen-Coder-3B)" || echo "  ❌ CODE model missing"
  [ -f "$MODEL_AGENT" ] && echo "  ✓ AGENT (Hermes-8B)" || echo "  ❌ AGENT model missing"
  echo ""

  echo "Engine: $([ -f "$LLAMA_BIN" ] && echo "✓ llama-cli" || echo "❌ llama-cli not found")"
  echo ""

  if [ -f "$SWARM_LOG" ]; then
    echo "Recent Swarms:"
    tail -10 "$SWARM_LOG"
  else
    echo "No swarm executions yet."
  fi
}

# ============================================================
# MAIN
# ============================================================

ACTION="${1:-status}"

case "$ACTION" in
  run)
    TASK="${2:-}"
    if [ -z "$TASK" ]; then
      echo "Usage: swarm_orchestrator.sh run '<task description>'"
      echo ""
      echo "Examples:"
      echo "  swarm_orchestrator.sh run 'Create a Python script that monitors disk usage'"
      echo "  swarm_orchestrator.sh run 'Build a bash tool to search files by content'"
      exit 1
    fi
    run_swarm "$TASK"
    ;;
  status)
    show_status
    ;;
  *)
    echo "Aether Swarm Orchestrator — Real Multi-Agent Pipeline"
    echo ""
    echo "Usage: swarm_orchestrator.sh [run|status]"
    echo ""
    echo "Commands:"
    echo "  run '<task>'  - Execute 3-stage swarm (LOGIC→CODE→AGENT)"
    echo "  status        - Show swarm status and history"
    exit 1
    ;;
esac
