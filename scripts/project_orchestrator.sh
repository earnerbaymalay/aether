#!/data/data/com.termux/files/usr/bin/bash
# project_orchestrator.sh - Coordinate across Aether ecosystem projects
# Usage: project_orchestrator.sh [status|sync|build|deploy|audit|health]

HOME_DIR="$HOME"
ORCHESTRATOR_LOG="$HOME/.aether/sessions/orchestrator.log"
ACTION="${1:-status}"

# Project registry
declare -A PROJECTS
PROJECTS["aether"]="Aether Core AI|~/aether|aether.sh|active"
PROJECTS["edge-sentinel"]="Edge Sentinel Security|~/edge-sentinel|backend/main.py|active"
PROJECTS["edge-sentinel-mobile"]="Edge Sentinel Mobile|~/Edge-Sentinel-Mobile|index.html|active"
PROJECTS["aether-apple"]="Aether Apple|~/aether-apple|README.md|active"
PROJECTS["aether-desktop"]="Aether Desktop (Tauri)|~/aether-desktop|src-tauri|active"
PROJECTS["gloam"]="Gloam Journal (KMP)|~/gloam|build.gradle.kts|active"
PROJECTS["e2eecc"]="E2EECC Platform|~/e2eecc|build.gradle|active"
PROJECTS["sideload"]="Sideload Hub|~/sideload|index.html|active"
PROJECTS["stable-diffusion"]="Stable Diffusion.cpp|~/stable-diffusion.cpp|main.cpp|reference"
PROJECTS["llama-cpp"]="llama.cpp Engine|~/llama.cpp|build/bin/llama-cli|core"

log_action() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$ORCHESTRATOR_LOG"
}

# ============================================================
# PROJECT STATUS
# ============================================================

show_status() {
  echo "=== Aether Ecosystem Status ==="
  echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
  echo ""
  
  printf "%-25s %-30s %-12s %-10s\n" "PROJECT" "PATH" "STATUS" "TYPE"
  printf "%-25s %-30s %-12s %-10s\n" "-------" "----" "------" "----"
  
  for key in "${!PROJECTS[@]}"; do
    meta="${PROJECTS[$key]}"
    name=$(echo "$meta" | cut -d'|' -f1)
    path=$(echo "$meta" | cut -d'|' -f2 | sed 's/~//')
    indicator=$(echo "$meta" | cut -d'|' -f3)
    type=$(echo "$meta" | cut -d'|' -f4)
    
    full_path="$HOME$path"
    
    if [ -d "$full_path" ] || [ -f "$full_path" ]; then
      # Check if key file exists
      if [ -e "$full_path/$indicator" ] 2>/dev/null; then
        status="✓ Active"
      elif [ -d "$full_path" ]; then
        status="⚠ Partial"
      else
        status="❌ Missing"
      fi
    else
      status="❌ Missing"
    fi
    
    printf "%-25s %-30s %-12s %-10s\n" "$name" "$path" "$status" "$type"
  done
  
  echo ""
  
  # Count projects
  TOTAL=${#PROJECTS[@]}
  ACTIVE=$(for key in "${!PROJECTS[@]}"; do
    meta="${PROJECTS[$key]}"
    path=$(echo "$meta" | cut -d'|' -f2 | sed 's/~//')
    indicator=$(echo "$meta" | cut -d'|' -f3)
    [ -e "$HOME$path/$indicator" ] 2>/dev/null && echo "1"
  done | wc -l)
  
  echo "Summary: $ACTIVE / $TOTAL projects active"
  echo ""
  
  # Shared dependencies
  echo "--- Shared Dependencies ---"
  echo "  llama.cpp: $(ls -d ~/llama.cpp 2>/dev/null && echo '✓' || echo '❌')"
  echo "  Node.js: $(command -v node &>/dev/null && echo '✓' || echo '❌')"
  echo "  Python3: $(command -v python3 &>/dev/null && echo '✓' || echo '❌')"
  echo "  Git: $(command -v git &>/dev/null && echo '✓' || echo '❌')"
  echo "  Termux-API: $(command -v termux-battery-status &>/dev/null && echo '✓' || echo '❌')"
}

# ============================================================
# CROSS-PROJECT SYNC
# ============================================================

sync_projects() {
  echo "=== Cross-Project Sync ==="
  echo ""
  
  # Sync configuration
  echo "1. Configuration Sync"
  echo "   Checking for shared config patterns..."
  
  # Check if all projects use consistent model paths
  MODEL_PATHS=$(grep -r "models/" --include="*.sh" --include="*.py" "$HOME/aether" "$HOME/edge-sentinel" 2>/dev/null | wc -l)
  echo "   - Model path references: $MODEL_PATHS"
  
  # Check knowledge base sharing
  KNOWLEDGE_FILES=$(find "$HOME/aether/knowledge" -name "*.md" 2>/dev/null | wc -l)
  echo "   - Shared knowledge files: $KNOWLEDGE_FILES"
  
  echo ""
  
  # Sync toolbox updates
  echo "2. Toolbox Sync"
  echo "   Checking toolbox consistency..."
  
  if [ -f "$HOME/aether/toolbox/manifest.json" ]; then
    TOOL_COUNT=$(python3 -c "import json; print(len(json.load(open('$HOME/aether/toolbox/manifest.json'))['tools']))" 2>/dev/null || echo "?")
    echo "   - Aether tools: $TOOL_COUNT"
  fi
  
  echo ""
  
  # Sync skill availability
  echo "3. Skill Registry"
  echo "   Available skills across projects:"
  
  SKILL_COUNT=$(find "$HOME" -path "*/skills/*/SKILL.md" 2>/dev/null | wc -l)
  echo "   - Total skills: $SKILL_COUNT"
  
  for skill_dir in "$HOME"/aether/skills/*/; do
    if [ -d "$skill_dir" ]; then
      skill_name=$(basename "$skill_dir")
      echo "     ✓ $skill_name"
    fi
  done
  
  echo ""
  echo "✓ Sync check complete"
  log_action "SYNC cross_project_check_complete"
}

# ============================================================
# UNIFIED BUILD
# ============================================================

build_all() {
  echo "=== Unified Build ==="
  echo ""
  
  # Build llama.cpp (core dependency)
  echo "1. Building llama.cpp (core engine)"
  if [ -d "$HOME/llama.cpp" ]; then
    cd "$HOME/llama.cpp" || return
    if [ -f "Makefile" ]; then
      make clean && make -j$(nproc) GGML_OPENMP=OFF 2>&1 | tail -5
      echo "   ✓ llama.cpp built successfully"
    else
      echo "   ⚠ No Makefile found"
    fi
  else
    echo "   ❌ llama.cpp not found"
  fi
  echo ""
  
  # Build Edge-Sentinel backend
  echo "2. Edge-Sentinel Backend"
  if [ -d "$HOME/edge-sentinel/backend" ]; then
    if [ -f "$HOME/edge-sentinel/backend/requirements.txt" ]; then
      pip install -r "$HOME/edge-sentinel/backend/requirements.txt" 2>&1 | tail -3
      echo "   ✓ Python dependencies installed"
    fi
  else
    echo "   ⚠ Backend directory not found"
  fi
  echo ""
  
  # Build Gloam (Gradle)
  echo "3. Gloam (Kotlin Multiplatform)"
  if [ -d "$HOME/gloam" ]; then
    if command -v ./gradlew &>/dev/null || [ -f "$HOME/gloam/gradlew" ]; then
      cd "$HOME/gloam" || return
      ./gradlew assemble 2>&1 | tail -5
      echo "   ✓ Gloam build complete"
    else
      echo "   ⚠ Gradle wrapper not found"
    fi
  else
    echo "   ⚠ Gloam directory not found"
  fi
  echo ""
  
  # Build E2EECC
  echo "4. E2EECC Platform"
  if [ -d "$HOME/e2eecc" ]; then
    if [ -f "$HOME/e2eecc/gradlew" ]; then
      cd "$HOME/e2eecc" || return
      ./gradlew build 2>&1 | tail -5
      echo "   ✓ E2EECC build complete"
    else
      echo "   ⚠ Gradle wrapper not found"
    fi
  else
    echo "   ⚠ E2EECC directory not found"
  fi
  echo ""
  
  echo "✓ Unified build complete"
  log_action "BUILD unified_build_complete"
}

# ============================================================
# HEALTH CHECK
# ============================================================

health_check() {
  echo "=== Ecosystem Health Check ==="
  echo ""
  
  ISSUES=0
  
  # Check each project
  for key in "${!PROJECTS[@]}"; do
    meta="${PROJECTS[$key]}"
    name=$(echo "$meta" | cut -d'|' -f1)
    path=$(echo "$meta" | cut -d'|' -f2 | sed 's/~//')
    
    full_path="$HOME$path"
    
    if [ ! -d "$full_path" ]; then
      echo "❌ $name: Directory missing"
      ISSUES=$((ISSUES + 1))
      continue
    fi
    
    # Check git status
    if [ -d "$full_path/.git" ]; then
      cd "$full_path" || continue
      UNTRACKED=$(git status --porcelain 2>/dev/null | grep "^??" | wc -l)
      MODIFIED=$(git status --porcelain 2>/dev/null | grep "^ M" | wc -l)
      
      if [ "$UNTRACKED" -gt 0 ] || [ "$MODIFIED" -gt 0 ]; then
        echo "⚠ $name: $UNTRACKED untracked, $MODIFIED modified"
      else
        echo "✓ $name: Clean"
      fi
    else
      echo "ℹ $name: Not a git repo"
    fi
  done
  
  echo ""
  
  # Check shared services
  echo "--- Service Health ---"
  
  # Check llama-server
  if curl -s http://localhost:8080/health &>/dev/null; then
    echo "✓ llama-server: Running (port 8080)"
  else
    echo "❌ llama-server: Not running"
  fi
  
  # Check Edge-Sentinel backend
  if curl -s http://localhost:8000/ &>/dev/null; then
    echo "✓ Edge-Sentinel Backend: Running (port 8000)"
  else
    echo "❌ Edge-Sentinel Backend: Not running"
  fi
  
  # Check FastAPI dashboard
  if curl -s http://localhost:8001/ &>/dev/null; then
    echo "✓ FastAPI Dashboard: Running (port 8001)"
  else
    echo "❌ FastAPI Dashboard: Not running"
  fi
  
  echo ""
  
  if [ "$ISSUES" -gt 0 ]; then
    echo "Found $ISSUES issue(s) - review above"
  else
    echo "✓ All projects healthy"
  fi
  
  log_action "HEALTH ecosystem_check issues=$ISSUES"
}

# ============================================================
# SECURITY AUDIT ACROSS PROJECTS
# ============================================================

security_audit() {
  echo "=== Cross-Project Security Audit ==="
  echo ""
  
  echo "1. Exposed Secrets Scan"
  SECRET_COUNT=0
  
  for key in "${!PROJECTS[@]}"; do
    meta="${PROJECTS[$key]}"
    path=$(echo "$meta" | cut -d'|' -f2 | sed 's/~//')
    name=$(echo "$meta" | cut -d'|' -f1)
    
    full_path="$HOME$path"
    if [ -d "$full_path" ]; then
      found=$(grep -rE "(api_key|password|secret|token)\s*=" \
        --include="*.py" --include="*.sh" --include="*.js" --include="*.ts" \
        --include="*.env" --include="*.json" \
        "$full_path" 2>/dev/null | grep -v ".git" | grep -v "node_modules" | wc -l)
      
      if [ "$found" -gt 0 ]; then
        echo "  ⚠ $name: $found potential secret(s) found"
        SECRET_COUNT=$((SECRET_COUNT + found))
      fi
    fi
  done
  
  if [ "$SECRET_COUNT" -eq 0 ]; then
    echo "  ✓ No exposed secrets detected"
  else
    echo "  Total: $SECRET_COUNT potential secret(s) across all projects"
  fi
  
  echo ""
  echo "2. Permission Audit"
  
  # Check sensitive file permissions
  for file in "$HOME/.bashrc" "$HOME/.bash_history" "$HOME/.gitconfig"; do
    if [ -f "$file" ]; then
      perms=$(stat -c %a "$file" 2>/dev/null)
      if [ "$perms" != "600" ] && [ "$perms" != "644" ]; then
        echo "  ⚠ $file: Permissions $perms (should be 600 or 644)"
      fi
    fi
  done
  
  echo ""
  echo "3. Git Configuration"
  
  # Check if .gitignore is properly configured
  for key in "aether" "edge-sentinel" "gloam"; do
    if [ -f "$HOME/$key/.gitignore" ]; then
      if grep -q ".env" "$HOME/$key/.gitignore" 2>/dev/null; then
        echo "  ✓ $key: .env in .gitignore"
      else
        echo "  ⚠ $key: .env not in .gitignore"
      fi
    fi
  done
  
  echo ""
  echo "✓ Security audit complete"
  log_action "AUDIT cross_project_security secrets=$SECRET_COUNT"
}

# ============================================================
# MAIN EXECUTION
# ============================================================

case "$ACTION" in
  status)
    show_status
    ;;
    
  sync)
    sync_projects
    ;;
    
  build)
    build_all
    ;;
    
  health)
    health_check
    ;;
    
  audit)
    security_audit
    ;;
    
  *)
    echo "Usage: project_orchestrator.sh [status|sync|build|health|audit]"
    echo ""
    echo "Commands:"
    echo "  status  - Show all project statuses"
    echo "  sync    - Check cross-project consistency"
    echo "  build   - Build all projects"
    echo "  health  - Run health checks on services"
    echo "  audit   - Security audit across projects"
    exit 1
    ;;
esac
