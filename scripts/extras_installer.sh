#!/data/data/com.termux/files/usr/bin/bash
# extras_installer.sh - Optional extras installer for Aether
# Presents optional features during install, can be enabled later
# Usage: extras_installer.sh [install|menu|enable <extra>|disable <extra>|list|status]

EXTRAS_DIR="$HOME/aether/settings"
EXTRAS_CONFIG="$EXTRAS_DIR/extras.json"
EXTRAS_LOG="$HOME/.aether/sessions/extras_installer.log"

mkdir -p "$EXTRAS_DIR"

log_action() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$EXTRAS_LOG"
}

# ============================================================
# EXTRA DEFINITIONS
# ============================================================

# Each extra has:
#   name: identifier
#   label: display name
#   description: what it does
#   dependencies: what's needed
#   install_cmd: how to install
#   status_cmd: how to check if installed
#   category: grouping
#   size: estimated install size

declare -A EXTRAS

# Category: AI Enhancement
EXTRAS["voice_stt"]="label:Voice STT|desc:Speech-to-text with Whisper.cpp|deps:build-essential,cmake|install:install_whisper|cat:AI Enhancement|size:~500MB"
EXTRAS["voice_tts"]="label:Voice TTS|desc:Text-to-speech with Piper|deps:python3|install:install_piper|cat:AI Enhancement|size:~200MB"
EXTRAS["image_gen"]="label:Image Generation|desc:Local image generation with Stable Diffusion|deps:llama.cpp dependencies|install:install_sd|cat:AI Enhancement|size:~4GB"
EXTRAS["embedding_model"]="label:Embedding Model|desc:Semantic search with local embeddings|deps:python3|install:install_embeddings|cat:AI Enhancement|size:~100MB"

# Category: Integration
EXTRAS["lsp_server"]="label:LSP Server|desc:Language Server Protocol for code intelligence|deps:bash|install:install_lsp|cat:Integration|size:~0MB"
EXTRAS["obsidian_sync"]="label:Obsidian Sync|desc:Two-way sync with Obsidian vault|deps:termux-setup-storage|install:install_obsidian|cat:Integration|size:~0MB"
EXTRAS["github_integration"]="label:GitHub Integration|desc:GitHub CLI integration for repo management|deps:git,gh|install:install_gh|cat:Integration|size:~50MB"
EXTRAS["android_shortcuts"]="label:Android Shortcuts|desc:Home screen shortcuts for quick AI access|deps:termux-api|install:install_shortcuts|cat:Integration|size:~0MB"

# Category: Security
EXTRAS["nmap_full"]="label:Nmap Full Scan|desc:Full nmap with vulnerability scripts|deps:nmap|install:install_nmap|cat:Security|size:~10MB"
EXTRAS["vault_encryption"]="label:Vault Encryption|desc:Encrypt knowledge vault with GPG|deps:gnupg|install:install_gpg|cat:Security|size:~5MB"
EXTRAS["audit_automation"]="label:Audit Automation|desc:Automated security audit scheduling|deps:nmap,cron|install:install_audit|cat:Security|size:~0MB"

# Category: Performance
EXTRAS["auto_scaler"]="label:Auto Scaler|desc:Dynamic resource allocation|deps:bash|install:install_scaler|cat:Performance|size:~0MB"
EXTRAS["gpu_accel"]="label:GPU Acceleration|desc:Vulkan GPU acceleration for llama.cpp|deps:vulkan|install:install_gpu|cat:Performance|size:~0MB"
EXTRAS["model_cache"]="label:Model Cache|desc:Smart model caching for faster loading|deps:bash|install:install_cache|cat:Performance|size:~0MB"

# Category: Development
EXTRAS["custom_commands"]="label:Custom Commands|desc:User-defined command system|deps:bash|install:install_custom_cmds|cat:Development|size:~0MB"
EXTRAS["context_import"]="label:Context Import|desc:Gemini-style context import/export|deps:bash|install:install_context|cat:Development|size:~0MB"
EXTRAS["workflow_engine"]="label:Workflow Engine|desc:Multi-stage workflow automation|deps:bash|install:install_workflows|cat:Development|size:~0MB"
EXTRAS["testing_framework"]="label:Testing Framework|desc:Automated testing for Aether components|deps:bash,python3|install:install_tests|cat:Development|size:~0MB"
EXTRAS["session_manager"]="label:Session Manager|desc:Session IDs, transcript archive, memory slots|deps:bash,python3|install:install_session_mgr|cat:Development|size:~0MB"

# ============================================================
# INSTALL FUNCTIONS
# ============================================================

install_whisper() {
  echo "Installing Whisper.cpp for speech-to-text..."
  if [ -d "$HOME/whisper.cpp" ]; then
    echo "  Whisper.cpp already cloned"
  else
    cd "$HOME" && git clone https://github.com/ggerganov/whisper.cpp.git 2>/dev/null
  fi
  cd "$HOME/whisper.cpp" && make -j$(nproc) 2>&1 | tail -3
  echo "  Downloading small model..."
  bash models/download-ggml-model.sh small 2>/dev/null
  echo "✓ Voice STT installed"
}

install_piper() {
  echo "Installing Piper TTS..."
  pip install piper-tts 2>&1 | tail -3
  echo "✓ Voice TTS installed"
}

install_sd() {
  echo "Installing Stable Diffusion..."
  echo "  Note: Requires ~4GB storage"
  if [ -d "$HOME/stable-diffusion.cpp" ]; then
    echo "  Already installed"
  else
    echo "  Clone stable-diffusion.cpp manually"
  fi
}

install_embeddings() {
  echo "Installing embedding model support..."
  pip install sentence-transformers 2>&1 | tail -3
  echo "✓ Embedding model installed"
}

install_lsp() {
  echo "Enabling LSP Server..."
  echo "  LSP server already installed in aether/lsp/"
  echo "  Enable with: ~/aether/settings/settings.sh (Features → LSP Server)"
}

install_obsidian() {
  echo "Setting up Obsidian integration..."
  echo "  Ensure storage access: termux-setup-storage"
  echo "  Set vault path in settings"
}

install_gh() {
  echo "Installing GitHub CLI..."
  pkg install gh 2>&1 | tail -3
  echo "  Authenticating..."
  gh auth login 2>/dev/null
  echo "✓ GitHub integration installed"
}

install_shortcuts() {
  echo "Creating Android shortcuts..."
  mkdir -p "$HOME/.termux/tasker"
  
  cat > "$HOME/.termux/tasker/aether_turbo.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
cd ~/aether && ./aether.sh turbo
EOF
  
  cat > "$HOME/.termux/tasker/aether_agent.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
cd ~/aether && ./aether.sh agent
EOF
  
  chmod +x "$HOME/.termux/tasker"/*.sh
  echo "✓ Android shortcuts created"
}

install_nmap() {
  echo "Installing nmap..."
  pkg install nmap 2>&1 | tail -3
  echo "✓ Nmap installed"
}

install_gpg() {
  echo "Installing GPG..."
  pkg install gnupg 2>&1 | tail -3
  echo "✓ GPG installed"
}

install_audit() {
  echo "Setting up audit automation..."
  echo "  Already available via vault-scan.sh"
  echo "  Schedule with: crontab -e"
}

install_scaler() {
  echo "Enabling Auto Scaler..."
  echo "  Already installed: ~/aether/scripts/auto_scaler.sh"
  echo "  Enable: auto_scaler.sh enable"
}

install_gpu() {
  echo "Setting up GPU acceleration..."
  echo "  Rebuild llama.cpp with Vulkan:"
  echo "  cd ~/llama.cpp && make GGML_VULKAN=1"
}

install_cache() {
  echo "Setting up model cache..."
  mkdir -p "$HOME/.aether/model_cache"
  echo "✓ Model cache enabled"
}

install_custom_cmds() {
  echo "Enabling custom commands..."
  mkdir -p "$HOME/aether/user_commands"
  echo "  Already available via settings UI"
}

install_context() {
  echo "Enabling context import..."
  echo "  Already installed: ~/aether/contexts/context_manager.sh"
}

install_workflows() {
  echo "Enabling workflow engine..."
  echo "  Already installed: ~/aether/scripts/workflow_engine.sh"
}

install_tests() {
  echo "Installing testing framework..."
  mkdir -p "$HOME/aether/tests"
  
  cat > "$HOME/aether/tests/run_tests.sh" << 'TESTEOF'
#!/data/data/com.termux/files/usr/bin/bash
# Aether Test Suite

PASS=0
FAIL=0
TOTAL=0

test_case() {
  local name="$1"
  local result="$2"
  TOTAL=$((TOTAL + 1))
  if [ "$result" -eq 0 ]; then
    echo "  ✓ $name"
    PASS=$((PASS + 1))
  else
    echo "  ✗ $name"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== Aether Test Suite ==="
echo ""

# Toolbox tests
echo "Toolbox:"
[ -f "$HOME/aether/toolbox/manifest.json" ] && test_case "manifest.json exists" 0 || test_case "manifest.json exists" 1
python3 -c "import json; json.load(open('$HOME/aether/toolbox/manifest.json'))" 2>/dev/null
test_case "manifest.json valid" $?

# Skills tests
echo "Skills:"
skill_count=$(find "$HOME/aether/skills" -name "SKILL.md" 2>/dev/null | wc -l)
[ "$skill_count" -gt 0 ] && test_case "$skill_count skills installed" 0 || test_case "skills installed" 1

# Knowledge tests
echo "Knowledge:"
[ -f "$HOME/aether/knowledge/bio.txt" ] && test_case "bio.txt exists" 0 || test_case "bio.txt exists" 1
[ -d "$HOME/aether/knowledge/aethervault" ] && test_case "aethervault exists" 0 || test_case "aethervault exists" 1

# Script tests
echo "Scripts:"
for script in workflow_engine.sh logic_engine.sh auto_scaler.sh task_decomposer.sh agent_matrix.sh project_orchestrator.sh token_optimizer.sh session_manager.sh; do
  [ -f "$HOME/aether/scripts/$script" ] && test_case "$script exists" 0 || test_case "$script exists" 1
done

# Tool tests
echo "Tools:"
for tool in get_date.sh get_battery.sh list_files.sh web_search.sh; do
  [ -f "$HOME/aether/toolbox/$tool" ] && test_case "$tool exists" 0 || test_case "$tool exists" 1
done

echo ""
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && echo "✓ All tests passed"
TESTEOF

  chmod +x "$HOME/aether/tests/run_tests.sh"
  echo "✓ Testing framework installed"
  echo "  Run: ~/aether/tests/run_tests.sh"
}

install_session_mgr() {
  echo "Enabling Session Manager..."
  echo "  Already installed: ~/aether/scripts/session_manager.sh"
  echo "  Features: Session IDs, transcript archive, memory slots"
  echo "  Integrated into aether.sh startup/exit flows"
}

# ============================================================
# UI FUNCTIONS
# ============================================================

show_extras_menu() {
  if command -v gum &>/dev/null; then
    show_gum_menu
  else
    show_text_menu
  fi
}

show_gum_menu() {
  while true; do
    # Build list of extras by category
    options=()
    current_cat=""
    
    for key in "${!EXTRAS[@]}"; do
      meta="${EXTRAS[$key]}"
      cat=$(echo "$meta" | sed 's/.*cat:\([^|]*\).*/\1/')
      
      if [ "$cat" != "$current_cat" ]; then
        options+=("--- $cat ---")
        current_cat="$cat"
      fi
      
      label=$(echo "$meta" | sed 's/.*label:\([^|]*\).*/\1/')
      status=$(get_extra_status "$key")
      
      if [ "$status" = "enabled" ]; then
        options+=("✓ $label")
      else
        options+=("○ $label")
      fi
    done
    
    options+=("← Back")
    
    choice=$(gum choose "${options[@]}" --header "Optional Extras" --height 25)
    
    case "$choice" in
      ---*|←\ Back) break ;;
      *)
        # Extract extra name from choice
        label=$(echo "$choice" | sed 's/^[✓○] //')
        for key in "${!EXTRAS[@]}"; do
          meta="${EXTRAS[$key]}"
          extra_label=$(echo "$meta" | sed 's/.*label:\([^|]*\).*/\1/')
          if [ "$extra_label" = "$label" ]; then
            toggle_extra "$key"
            break
          fi
        done
        ;;
    esac
  done
}

show_text_menu() {
  echo "=== Optional Extras ==="
  echo ""
  
  current_cat=""
  for key in "${!EXTRAS[@]}"; do
    meta="${EXTRAS[$key]}"
    cat=$(echo "$meta" | sed 's/.*cat:\([^|]*\).*/\1/')
    
    if [ "$cat" != "$current_cat" ]; then
      echo "--- $cat ---"
      current_cat="$cat"
    fi
    
    label=$(echo "$meta" | sed 's/.*label:\([^|]*\).*/\1/')
    desc=$(echo "$meta" | sed 's/.*desc:\([^|]*\).*/\1/')
    status=$(get_extra_status "$key")
    size=$(echo "$meta" | sed 's/.*size:\([^|]*\).*/\1/')
    
    if [ "$status" = "enabled" ]; then
      printf "  [%s] %-20s %s (%s)\n" "✓" "$label" "$desc" "$size"
    else
      printf "  [%s] %-20s %s (%s)\n" " " "$label" "$desc" "$size"
    fi
  done
  
  echo ""
  echo "Enable:  extras_installer.sh enable <name>"
  echo "Disable: extras_installer.sh disable <name>"
  echo "Install: extras_installer.sh install <name>"
}

get_extra_status() {
  local key="$1"
  
  # Initialize config
  if [ ! -f "$EXTRAS_CONFIG" ]; then
    echo '{"enabled":[]}' > "$EXTRAS_CONFIG"
  fi
  
  # Check if enabled
  python3 -c "
import json
cfg = json.load(open('$EXTRAS_CONFIG'))
if '$key' in cfg.get('enabled', []):
    print('enabled')
else:
    print('disabled')
" 2>/dev/null || echo "disabled"
}

toggle_extra() {
  local key="$1"
  local status
  status=$(get_extra_status "$key")
  
  if [ "$status" = "enabled" ]; then
    disable_extra "$key"
  else
    enable_extra "$key"
  fi
}

enable_extra() {
  local key="$1"
  
  if [ ! -f "$EXTRAS_CONFIG" ]; then
    echo '{"enabled":[]}' > "$EXTRAS_CONFIG"
  fi
  
  python3 -c "
import json
cfg = json.load(open('$EXTRAS_CONFIG'))
if '$key' not in cfg.get('enabled', []):
    cfg.setdefault('enabled', []).append('$key')
with open('$EXTRAS_CONFIG', 'w') as f:
    json.dump(cfg, f, indent=2)
print('✓ Extra enabled: $key')
"
  
  log_action "ENABLE extra=$key"
}

disable_extra() {
  local key="$1"
  
  python3 -c "
import json
cfg = json.load(open('$EXTRAS_CONFIG'))
cfg['enabled'] = [e for e in cfg.get('enabled', []) if e != '$key']
with open('$EXTRAS_CONFIG', 'w') as f:
    json.dump(cfg, f, indent=2)
print('Extra disabled: $key')
"
  
  log_action "DISABLE extra=$key"
}

# ============================================================
# INSTALLATION
# ============================================================

install_extra() {
  local key="$1"
  
  if [ -z "${EXTRAS[$key]}" ]; then
    echo "Unknown extra: $key"
    list_extras
    return 1
  fi
  
  meta="${EXTRAS[$key]}"
  label=$(echo "$meta" | sed 's/.*label:\([^|]*\).*/\1/')
  install_cmd=$(echo "$meta" | sed 's/.*install:\([^|]*\).*/\1/')
  
  echo "=== Installing: $label ==="
  echo ""
  
  # Run install function
  $install_cmd
  
  enable_extra "$key"
  log_action "INSTALL extra=$key"
}

# ============================================================
# LIST AND STATUS
# ============================================================

list_extras() {
  echo "=== Available Extras ==="
  echo ""
  
  current_cat=""
  for key in $(echo "${!EXTRAS[@]}" | tr ' ' '\n' | sort); do
    meta="${EXTRAS[$key]}"
    cat=$(echo "$meta" | sed 's/.*cat:\([^|]*\).*/\1/')
    
    if [ "$cat" != "$current_cat" ]; then
      echo "--- $cat ---"
      current_cat="$cat"
    fi
    
    label=$(echo "$meta" | sed 's/.*label:\([^|]*\).*/\1/')
    desc=$(echo "$meta" | sed 's/.*desc:\([^|]*\).*/\1/')
    status=$(get_extra_status "$key")
    
    if [ "$status" = "enabled" ]; then
      echo "  ✓ $key: $desc"
    else
      echo "  ○ $key: $desc"
    fi
  done
}

show_status() {
  echo "=== Extras Status ==="
  echo ""
  
  enabled_count=0
  total_count=${#EXTRAS[@]}
  
  for key in "${!EXTRAS[@]}"; do
    status=$(get_extra_status "$key")
    if [ "$status" = "enabled" ]; then
      enabled_count=$((enabled_count + 1))
    fi
  done
  
  echo "Enabled: $enabled_count / $total_count"
  echo ""
  
  if [ -f "$EXTRAS_CONFIG" ]; then
    echo "Enabled extras:"
    python3 -c "
import json
cfg = json.load(open('$EXTRAS_CONFIG'))
for extra in cfg.get('enabled', []):
    print(f'  ✓ {extra}')
" 2>/dev/null
  fi
}

# ============================================================
# MAIN
# ============================================================

ACTION="${1:-menu}"

case "$ACTION" in
  install)
    if [ -n "$2" ]; then
      install_extra "$2"
    else
      echo "Usage: extras_installer.sh install <extra_name>"
      list_extras
    fi
    ;;
  menu)
    show_extras_menu
    ;;
  enable)
    enable_extra "$2"
    ;;
  disable)
    disable_extra "$2"
    ;;
  list)
    list_extras
    ;;
  status)
    show_status
    ;;
  *)
    echo "Usage: extras_installer.sh [install|menu|enable|disable|list|status]"
    exit 1
    ;;
esac
