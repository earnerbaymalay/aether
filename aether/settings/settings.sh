#!/data/data/com.termux/files/usr/bin/bash
# settings.sh - Central settings hub for Aether
# Usage: settings.sh [ui|import <file>|export <file>|reset|<section>]

SETTINGS_DIR="$HOME/aether/settings"
CONFIG_FILE="$SETTINGS_DIR/config.json"
AETHER_DIR="$HOME/aether"

mkdir -p "$SETTINGS_DIR"

# ============================================================
# CONFIG INITIALIZATION
# ============================================================

init_config() {
  if [ ! -f "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" << 'EOF'
{
  "version": "20.0",
  "profile": "balanced",
  "model": {
    "default_tier": "agent",
    "threads": 4,
    "context_size": 2048,
    "batch_size": 256,
    "temperature": 0.7,
    "top_p": 0.9,
    "repeat_penalty": 1.1,
    "gpu_layers": 0,
    "memory_map": true,
    "models": {
      "turbo": "llama",
      "agent": "hermes",
      "code": "qwen",
      "logic": "deepseek"
    }
  },
  "session": {
    "max_history_bytes": 4096,
    "max_messages": 20,
    "auto_save": true,
    "context_carry": true
  },
  "appearance": {
    "accent_color": "#00ff9d",
    "dim_color": "#888888",
    "show_banner": true,
    "show_tips": true
  },
  "features": {
    "lsp_enabled": false,
    "auto_scaler": false,
    "voice_io": false,
    "android_shortcuts": false,
    "context_import": true,
    "custom_commands": true,
    "skill_marketplace": false,
    "telemetry": false
  },
  "security": {
    "scan_on_start": false,
    "auto_heal": true,
    "vault_path": "$HOME/storage/shared/Documents/Obsidian",
    "audit_log_dir": "$HOME/.audit_logs"
  },
  "plugins": {
    "enabled": [],
    "registry": []
  },
  "custom_commands": []
}
EOF
    echo "Initialized default configuration at $CONFIG_FILE"
  fi
}

# Helper: read JSON value
get_config() {
  local path="$1"
  local default="${2:-}"
  python3 -c "
import json, sys
try:
    cfg = json.load(open('$CONFIG_FILE'))
    keys = '$path'.split('.')
    val = cfg
    for k in keys:
        val = val[k]
    print(val if val is not None else '$default')
except:
    print('$default')
" 2>/dev/null
}

set_config() {
  local path="$1"
  local value="$2"
  
  python3 -c "
import json

cfg = json.load(open('$CONFIG_FILE'))
keys = '$path'.split('.')
d = cfg
for k in keys[:-1]:
    d = d[k]

# Try to preserve type
current = d.get(keys[-1])
if isinstance(current, bool):
    d[keys[-1]] = '$value'.lower() in ('true', '1', 'yes')
elif isinstance(current, int):
    d[keys[-1]] = int('$value')
elif isinstance(current, float):
    d[keys[-1]] = float('$value')
else:
    d[keys[-1]] = '$value'

with open('$CONFIG_FILE', 'w') as f:
    json.dump(cfg, f, indent=2)
" 2>/dev/null
}

# ============================================================
# SETTINGS UI (gum-based)
# ============================================================

show_main_menu() {
  if ! command -v gum &>/dev/null; then
    echo "gum not installed - using text menu"
    show_text_menu
    return
  fi
  
  while true; do
    choice=$(gum choose \
      "⚙ Model Settings" \
      "📋 Session Settings" \
      "🎨 Appearance" \
      "🔧 Features" \
      "🛡 Security" \
      "📦 Plugins" \
      "⚡ Custom Commands" \
      "📤 Import/Export" \
      "🔄 Profiles" \
      "ℹ System Info" \
      "← Back to Aether" \
      --header "Aether Settings" --height 15 --cursor "→ ")
    
    case "$choice" in
      "⚙ Model Settings") show_model_settings ;;
      "📋 Session Settings") show_session_settings ;;
      "🎨 Appearance") show_appearance_settings ;;
      "🔧 Features") show_feature_toggles ;;
      "🛡 Security") show_security_settings ;;
      "📦 Plugins") show_plugin_manager ;;
      "⚡ Custom Commands") manage_custom_commands ;;
      "📤 Import/Export") show_import_export ;;
      "🔄 Profiles") show_profiles ;;
      "ℹ System Info") show_system_info ;;
      "← Back to Aether") break ;;
      *) break ;;
    esac
  done
}

show_text_menu() {
  echo "=== Aether Settings ==="
  echo ""
  echo "1. Model Settings"
  echo "2. Session Settings"
  echo "3. Appearance"
  echo "4. Feature Toggles"
  echo "5. Security"
  echo "6. Plugins"
  echo "7. Custom Commands"
  echo "8. Import/Export"
  echo "9. Profiles"
  echo "10. System Info"
  echo "0. Exit"
  echo ""
  read -p "Select: " choice
  
  case "$choice" in
    1) show_model_settings ;;
    2) show_session_settings ;;
    3) show_appearance_settings ;;
    4) show_feature_toggles ;;
    5) show_security_settings ;;
    6) show_plugin_manager ;;
    7) manage_custom_commands ;;
    8) show_import_export ;;
    9) show_profiles ;;
    10) show_system_info ;;
    *) ;;
  esac
}

# ============================================================
# MODEL SETTINGS
# ============================================================

show_model_settings() {
  if command -v gum &>/dev/null; then
    choice=$(gum choose \
      "Default Tier: $(get_config model.default_tier agent)" \
      "Threads: $(get_config model.threads 4)" \
      "Context Size: $(get_config model.context_size 2048)" \
      "Batch Size: $(get_config model.batch_size 256)" \
      "Temperature: $(get_config model.temperature 0.7)" \
      "Top-P: $(get_config model.top_p 0.9)" \
      "Memory Map: $(get_config model.memory_map true)" \
      "GPU Layers: $(get_config model.gpu_layers 0)" \
      "← Back" \
      --header "Model Settings" --height 12)
    
    case "$choice" in
      "Default Tier:"*)
        tier=$(gum choose "turbo" "agent" "code" "logic" --header "Default Tier")
        [ -n "$tier" ] && set_config model.default_tier "$tier"
        ;;
      "Threads:"*)
        threads=$(gum input --prompt "Threads: " --value "$(get_config model.threads 4)")
        [ -n "$threads" ] && set_config model.threads "$threads"
        ;;
      "Context Size:"*)
        ctx=$(gum input --prompt "Context Size: " --value "$(get_config model.context_size 2048)")
        [ -n "$ctx" ] && set_config model.context_size "$ctx"
        ;;
      "Batch Size:"*)
        batch=$(gum input --prompt "Batch Size: " --value "$(get_config model.batch_size 256)")
        [ -n "$batch" ] && set_config model.batch_size "$batch"
        ;;
      "Temperature:"*)
        temp=$(gum input --prompt "Temperature: " --value "$(get_config model.temperature 0.7)")
        [ -n "$temp" ] && set_config model.temperature "$temp"
        ;;
      "Top-P:"*)
        top_p=$(gum input --prompt "Top-P: " --value "$(get_config model.top_p 0.9)")
        [ -n "$top_p" ] && set_config model.top_p "$top_p"
        ;;
      "Memory Map:"*)
        current=$(get_config model.memory_map true)
        mmap=$(gum choose "true" "false" --header "Memory Map" --default "$current")
        [ -n "$mmap" ] && set_config model.memory_map "$mmap"
        ;;
      "GPU Layers:"*)
        layers=$(gum input --prompt "GPU Layers: " --value "$(get_config model.gpu_layers 0)")
        [ -n "$layers" ] && set_config model.gpu_layers "$layers"
        ;;
    esac
  else
    echo "--- Model Settings ---"
    echo "Current: tier=$(get_config model.default_tier agent) threads=$(get_config model.threads 4) ctx=$(get_config model.context_size 2048) temp=$(get_config model.temperature 0.7)"
    echo "Edit: $CONFIG_FILE"
    echo "Or run: ~/aether/toolbox/config_manager.sh"
  fi
}

# ============================================================
# SESSION SETTINGS
# ============================================================

show_session_settings() {
  if command -v gum &>/dev/null; then
    choice=$(gum choose \
      "Max History: $(get_config session.max_history_bytes 4096) bytes" \
      "Max Messages: $(get_config session.max_messages 20)" \
      "Auto Save: $(get_config session.auto_save true)" \
      "Context Carry: $(get_config session.context_carry true)" \
      "← Back" \
      --header "Session Settings" --height 8)
    
    case "$choice" in
      "Max History:"*)
        val=$(gum input --prompt "Max History (bytes): " --value "$(get_config session.max_history_bytes 4096)")
        [ -n "$val" ] && set_config session.max_history_bytes "$val"
        ;;
      "Max Messages:"*)
        val=$(gum input --prompt "Max Messages: " --value "$(get_config session.max_messages 20)")
        [ -n "$val" ] && set_config session.max_messages "$val"
        ;;
      "Auto Save:"*)
        val=$(gum choose "true" "false" --default "$(get_config session.auto_save true)")
        [ -n "$val" ] && set_config session.auto_save "$val"
        ;;
      "Context Carry:"*)
        val=$(gum choose "true" "false" --default "$(get_config session.context_carry true)")
        [ -n "$val" ] && set_config session.context_carry "$val"
        ;;
    esac
  else
    echo "--- Session Settings ---"
    echo "Edit: $CONFIG_FILE"
  fi
}

# ============================================================
# APPEARANCE
# ============================================================

show_appearance_settings() {
  if command -v gum &>/dev/null; then
    choice=$(gum choose \
      "Accent Color: $(get_config appearance.accent_color "#00ff9d")" \
      "Show Banner: $(get_config appearance.show_banner true)" \
      "Show Tips: $(get_config appearance.show_tips true)" \
      "← Back" \
      --header "Appearance" --height 6)
    
    case "$choice" in
      "Accent Color:"*)
        color=$(gum input --prompt "Hex Color: " --value "$(get_config appearance.accent_color "#00ff9d")")
        [ -n "$color" ] && set_config appearance.accent_color "$color"
        ;;
      "Show Banner:"*)
        val=$(gum choose "true" "false" --default "$(get_config appearance.show_banner true)")
        [ -n "$val" ] && set_config appearance.show_banner "$val"
        ;;
      "Show Tips:"*)
        val=$(gum choose "true" "false" --default "$(get_config appearance.show_tips true)")
        [ -n "$val" ] && set_config appearance.show_tips "$val"
        ;;
    esac
  else
    echo "--- Appearance ---"
    echo "Edit: $CONFIG_FILE"
  fi
}

# ============================================================
# FEATURE TOGGLES
# ============================================================

show_feature_toggles() {
  if command -v gum &>/dev/null; then
    while true; do
      choice=$(gum choose \
        "$(toggle_icon features.lsp_enabled) LSP Server" \
        "$(toggle_icon features.auto_scaler) Auto Scaler" \
        "$(toggle_icon features.voice_io) Voice I/O" \
        "$(toggle_icon features.android_shortcuts) Android Shortcuts" \
        "$(toggle_icon features.context_import) Context Import" \
        "$(toggle_icon features.custom_commands) Custom Commands" \
        "$(toggle_icon features.skill_marketplace) Skill Marketplace" \
        "$(toggle_icon features.telemetry) Telemetry" \
        "← Back" \
        --header "Feature Toggles (enable/disable)" --height 12)
      
      case "$choice" in
        *LSP\ Server*) toggle_feature features.lsp_enabled ;;
        *Auto\ Scaler*) toggle_feature features.auto_scaler ;;
        *Voice*) toggle_feature features.voice_io ;;
        *Android*) toggle_feature features.android_shortcuts ;;
        *Context\ Import*) toggle_feature features.context_import ;;
        *Custom\ Commands*) toggle_feature features.custom_commands ;;
        *Skill*) toggle_feature features.skill_marketplace ;;
        *Telemetry*) toggle_feature features.telemetry ;;
        *) break ;;
      esac
    done
  else
    echo "--- Feature Toggles ---"
    echo "Edit features.enabled in $CONFIG_FILE"
  fi
}

toggle_icon() {
  local val
  val=$(get_config "$1" false)
  if [ "$val" = "True" ] || [ "$val" = "true" ]; then
    echo "✓"
  else
    echo "○"
  fi
}

toggle_feature() {
  local path="$1"
  local current
  current=$(get_config "$path" false)
  
  if [ "$current" = "True" ] || [ "$current" = "true" ]; then
    set_config "$path" false
    echo "Disabled"
  else
    set_config "$path" true
    echo "Enabled"
  fi
  sleep 0.5
}

# ============================================================
# SECURITY SETTINGS
# ============================================================

show_security_settings() {
  if command -v gum &>/dev/null; then
    choice=$(gum choose \
      "Scan on Start: $(get_config security.scan_on_start false)" \
      "Auto Heal: $(get_config security.auto_heal true)" \
      "Vault Path: $(get_config security.vault_path)" \
      "← Back" \
      --header "Security" --height 6)
    
    case "$choice" in
      "Scan on Start:"*)
        val=$(gum choose "true" "false" --default "$(get_config security.scan_on_start false)")
        [ -n "$val" ] && set_config security.scan_on_start "$val"
        ;;
      "Auto Heal:"*)
        val=$(gum choose "true" "false" --default "$(get_config security.auto_heal true)")
        [ -n "$val" ] && set_config security.auto_heal "$val"
        ;;
      "Vault Path:"*)
        val=$(gum input --prompt "Vault Path: " --value "$(get_config security.vault_path)")
        [ -n "$val" ] && set_config security.vault_path "$val"
        ;;
    esac
  else
    echo "--- Security Settings ---"
    echo "Edit: $CONFIG_FILE"
  fi
}

# ============================================================
# PLUGIN MANAGER
# ============================================================

show_plugin_manager() {
  echo "=== Plugin Manager ==="
  echo ""
  
  PLUGINS_DIR="$HOME/aether/plugins"
  mkdir -p "$PLUGINS_DIR"
  
  # List installed plugins
  echo "Installed Plugins:"
  if [ -d "$PLUGINS_DIR" ] && [ "$(ls -A "$PLUGINS_DIR" 2>/dev/null)" ]; then
    for plugin in "$PLUGINS_DIR"/*/; do
      if [ -d "$plugin" ]; then
        name=$(basename "$plugin")
        if [ -f "$plugin/plugin.json" ]; then
          desc=$(python3 -c "import json; print(json.load(open('$plugin/plugin.json')).get('description',''))" 2>/dev/null)
          echo "  ✓ $name: $desc"
        else
          echo "  ✓ $name"
        fi
      fi
    done
  else
    echo "  (none installed)"
  fi
  
  echo ""
  echo "To install a plugin:"
  echo "  1. Clone into $PLUGINS_DIR/<plugin_name>"
  echo "  2. Create plugin.json with {\"name\": \"...\", \"description\": \"...\"}"
  echo "  3. Enable in settings"
  echo ""
  echo "Available plugin types:"
  echo "  - Tool plugins (add new toolbox scripts)"
  echo "  - Skill plugins (add new SKILL.md files)"
  echo "  - LSP plugins (add language support)"
  echo "  - Workflow plugins (add new workflows)"
}

# ============================================================
# IMPORT/EXPORT
# ============================================================

show_import_export() {
  if command -v gum &>/dev/null; then
    choice=$(gum choose \
      "📥 Import Configuration" \
      "📤 Export Configuration" \
      "📥 Import Context" \
      "📤 Export Context" \
      "🔄 Reset to Defaults" \
      "← Back" \
      --header "Import/Export" --height 8)
    
    case "$choice" in
      *Import\ Config*)
        file=$(gum input --prompt "Config file path: ")
        if [ -n "$file" ] && [ -f "$file" ]; then
          cp "$CONFIG_FILE" "$SETTINGS_DIR/config_backup_$(date +%Y%m%d).json"
          cp "$file" "$CONFIG_FILE"
          echo "✓ Configuration imported"
        else
          echo "File not found"
        fi
        ;;
      *Export\ Config*)
        dest=$(gum input --prompt "Export path: " --value "$SETTINGS_DIR/config_export_$(date +%Y%m%d).json")
        if [ -n "$dest" ]; then
          cp "$CONFIG_FILE" "$dest"
          echo "✓ Configuration exported to $dest"
        fi
        ;;
      *Import\ Context*)
        import_context_ui
        ;;
      *Export\ Context*)
        export_context_ui
        ;;
      *Reset*)
        confirm=$(gum confirm "Reset all settings to defaults?" 2>/dev/null)
        if [ "$confirm" = "true" ]; then
          rm -f "$CONFIG_FILE"
          init_config
          echo "✓ Settings reset to defaults"
        fi
        ;;
    esac
  else
    echo "--- Import/Export ---"
    echo "Import: cp <config_file> $CONFIG_FILE"
    echo "Export: cp $CONFIG_FILE <dest>"
    echo "Reset: rm $CONFIG_FILE (will regenerate on next run)"
  fi
}

# ============================================================
# CONTEXT IMPORT
# ============================================================

import_context_ui() {
  echo "=== Context Import ==="
  echo ""
  echo "Import context from:"
  echo ""
  echo "1. File (load file contents into context)"
  echo "2. URL (fetch and load web page content)"
  echo "3. Clipboard (import from clipboard)"
  echo "4. Directory (load all text files)"
  echo "5. Context7 Vault (add to knowledge base)"
  echo ""
  read -p "Select (1-5): " choice
  
  case "$choice" in
    1)
      echo "File path:"
      read -r filepath
      if [ -f "$filepath" ]; then
        content=$(cat "$filepath" | head -c 8000)
        mkdir -p "$HOME/aether/contexts"
        echo "$content" > "$HOME/aether/contexts/imported_$(date +%Y%m%d_%H%M%S).txt"
        echo "✓ Imported $(echo "$content" | wc -c) bytes from $filepath"
      else
        echo "File not found"
      fi
      ;;
    2)
      echo "URL:"
      read -r url
      if command -v lynx &>/dev/null; then
        content=$(lynx -dump "$url" 2>/dev/null | head -c 8000)
        mkdir -p "$HOME/aether/contexts"
        echo "Source: $url" > "$HOME/aether/contexts/imported_web_$(date +%Y%m%d_%H%M%S).txt"
        echo "$content" >> "$HOME/aether/contexts/imported_web_$(date +%Y%m%d_%H%M%S).txt"
        echo "✓ Imported $(echo "$content" | wc -c) bytes from $url"
      else
        echo "Install lynx: pkg install lynx"
      fi
      ;;
    3)
      if command -v termux-clipboard-get &>/dev/null; then
        content=$(termux-clipboard-get 2>/dev/null | head -c 8000)
        mkdir -p "$HOME/aether/contexts"
        echo "$content" > "$HOME/aether/contexts/imported_clipboard_$(date +%Y%m%d_%H%M%S).txt"
        echo "✓ Imported $(echo "$content" | wc -c) bytes from clipboard"
      else
        echo "termux-clipboard-get not available"
      fi
      ;;
    4)
      echo "Directory path:"
      read -r dirpath
      if [ -d "$dirpath" ]; then
        count=0
        mkdir -p "$HOME/aether/contexts/imported_dir"
        for f in "$dirpath"/*.txt "$dirpath"/*.md "$dirpath"/*.py "$dirpath"/*.sh; do
          if [ -f "$f" ]; then
            cp "$f" "$HOME/aether/contexts/imported_dir/"
            count=$((count + 1))
          fi
        done
        echo "✓ Imported $count files from $dirpath"
      else
        echo "Directory not found"
      fi
      ;;
    5)
      echo "Knowledge entry name:"
      read -r name
      echo "Content (Ctrl+D to finish):"
      content=$(cat)
      if [ -n "$name" ] && [ -n "$content" ]; then
        echo "$content" > "$HOME/aether/knowledge/context7/${name,,}.md"
        echo "✓ Added to Context7 vault as ${name,,}.md"
      fi
      ;;
  esac
}

export_context_ui() {
  echo "=== Context Export ==="
  echo ""
  echo "Export current context to:"
  echo ""
  echo "1. File"
  echo "2. Clipboard"
  echo "3. Context7 Vault"
  echo ""
  read -p "Select (1-3): " choice
  
  case "$choice" in
    1)
      echo "Export path:"
      read -r dest
      if [ -n "$dest" ]; then
        cat "$HOME/.aether/sessions/last_session.log" > "$dest" 2>/dev/null
        echo "✓ Exported to $dest"
      fi
      ;;
    2)
      if command -v termux-clipboard-set &>/dev/null; then
        cat "$HOME/.aether/sessions/last_session.log" | termux-clipboard-set 2>/dev/null
        echo "✓ Exported to clipboard"
      else
        echo "termux-clipboard-set not available"
      fi
      ;;
    3)
      echo "Entry name:"
      read -r name
      if [ -n "$name" ]; then
        cp "$HOME/.aether/sessions/last_session.log" "$HOME/aether/knowledge/context7/${name,,}.md" 2>/dev/null
        echo "✓ Saved to Context7 vault"
      fi
      ;;
  esac
}

# ============================================================
# PROFILES
# ============================================================

show_profiles() {
  if command -v gum &>/dev/null; then
    profile=$(gum choose \
      "⚡ Performance - Max threads, large context" \
      "🧠 Reasoning - Deep thinking, low temperature" \
      "💻 Coding - Code-optimized, precise output" \
      "🔋 Conservative - Low resource usage" \
      "⚖ Balanced - Default settings" \
      "← Back" \
      --header "Select Profile" --height 8)
    
    case "$profile" in
      *Performance*) apply_profile "performance" ;;
      *Reasoning*) apply_profile "reasoning" ;;
      *Coding*) apply_profile "coding" ;;
      *Conservative*) apply_profile "conservative" ;;
      *Balanced*) apply_profile "balanced" ;;
    esac
  else
    echo "--- Profiles ---"
    echo "Run: ~/aether/toolbox/config_manager.sh profile <name>"
    echo "Available: performance, reasoning, coding, conservative, balanced"
  fi
}

apply_profile() {
  local profile="$1"
  
  case "$profile" in
    performance)
      set_config model.threads 6
      set_config model.context_size 4096
      set_config model.batch_size 512
      set_config model.temperature 0.7
      ;;
    reasoning)
      set_config model.threads 4
      set_config model.context_size 4096
      set_config model.batch_size 256
      set_config model.temperature 0.3
      ;;
    coding)
      set_config model.threads 6
      set_config model.context_size 2048
      set_config model.batch_size 512
      set_config model.temperature 0.2
      ;;
    conservative)
      set_config model.threads 2
      set_config model.context_size 1024
      set_config model.batch_size 128
      set_config model.temperature 0.5
      ;;
    balanced)
      set_config model.threads 4
      set_config model.context_size 2048
      set_config model.batch_size 256
      set_config model.temperature 0.7
      ;;
  esac
  
  set_config profile "$profile"
  echo "✓ Applied '$profile' profile"
}

# ============================================================
# CUSTOM COMMANDS
# ============================================================

manage_custom_commands() {
  echo "=== Custom Commands ==="
  echo ""
  
  CMDS_FILE="$SETTINGS_DIR/custom_commands.json"
  
  # Initialize if needed
  if [ ! -f "$CMDS_FILE" ]; then
    echo "[]" > "$CMDS_FILE"
  fi
  
  # List commands
  count=$(python3 -c "import json; print(len(json.load(open('$CMDS_FILE'))))" 2>/dev/null)
  
  if [ "$count" -gt 0 ] 2>/dev/null; then
    echo "Registered Commands:"
    python3 -c "
import json
cmds = json.load(open('$CMDS_FILE'))
for i, cmd in enumerate(cmds, 1):
    print(f\"  {i}. {cmd.get('name', 'unnamed')}: {cmd.get('command', '')}\")
    if cmd.get('description'):
        print(f\"     {cmd['description']}\")
    if cmd.get('trigger'):
        print(f\"     Trigger: {cmd['trigger']}\")
" 2>/dev/null
    echo ""
  else
    echo "No custom commands defined."
  fi
  
  echo "1. Add Command"
  echo "2. Remove Command"
  echo "3. Run Command"
  echo "0. Back"
  echo ""
  read -p "Action: " action
  
  case "$action" in
    1)
      echo "Command name (no spaces):"
      read -r name
      echo "Command to execute:"
      read -r command
      echo "Description (optional):"
      read -r desc
      echo "Trigger keyword (optional, press enter to skip):"
      read -r trigger
      
      python3 -c "
import json
cmds = json.load(open('$CMDS_FILE'))
cmds.append({
    'name': '$name',
    'command': '$command',
    'description': '$desc',
    'trigger': '$trigger'
})
with open('$CMDS_FILE', 'w') as f:
    json.dump(cmds, f, indent=2)
print('✓ Command added')
"
      ;;
    2)
      echo "Command number to remove:"
      read -r num
      python3 -c "
import json
cmds = json.load(open('$CMDS_FILE'))
if 1 <= $num <= len(cmds):
    cmds.pop($num - 1)
    with open('$CMDS_FILE', 'w') as f:
        json.dump(cmds, f, indent=2)
    print('✓ Command removed')
else:
    print('Invalid number')
"
      ;;
    3)
      echo "Command number to run:"
      read -r num
      cmd=$(python3 -c "
import json
cmds = json.load(open('$CMDS_FILE'))
if 1 <= $num <= len(cmds):
    print(cmds[$num-1]['command'])
" 2>/dev/null)
      if [ -n "$cmd" ]; then
        echo "Running: $cmd"
        echo "---"
        eval "$cmd"
        echo "---"
        echo "Done"
      fi
      ;;
  esac
}

# ============================================================
# SYSTEM INFO
# ============================================================

show_system_info() {
  echo "=== System Information ==="
  echo ""
  echo "Aether Version: $(get_config version 20.0)"
  echo "Config File: $CONFIG_FILE"
  echo "Profile: $(get_config profile balanced)"
  echo ""
  
  echo "Device:"
  echo "  Model: $(getprop ro.product.model 2>/dev/null || echo 'unknown')"
  echo "  SoC: $(getprop ro.hardware 2>/dev/null || echo 'unknown')"
  echo "  RAM: $(free -h | awk '/^Mem:/{print $2}')"
  echo "  Cores: $(nproc)"
  echo "  Storage Free: $(df -h / | awk 'NR==2{print $4}')"
  echo ""
  
  echo "Aether:"
  echo "  Skills: $(find "$HOME/aether/skills" -name "SKILL.md" 2>/dev/null | wc -l)"
  echo "  Tools: $(python3 -c "import json; print(len(json.load(open('$HOME/aether/toolbox/manifest.json'))['tools']))" 2>/dev/null)"
  echo "  Models: $(find "$HOME/.aether/models" -name "*.gguf" 2>/dev/null | wc -l)"
  echo "  Context7 Docs: $(find "$HOME/aether/knowledge/context7" -name "*.md" 2>/dev/null | wc -l)"
  echo "  Custom Commands: $(python3 -c "import json; print(len(json.load(open('$CMDS_FILE'))))" 2>/dev/null || echo 0)"
  echo "  Plugins: $(find "$HOME/aether/plugins" -name "plugin.json" 2>/dev/null | wc -l)"
  echo ""
  
  echo "Enabled Features:"
  for feature in lsp_enabled auto_scaler voice_io context_import custom_commands; do
    val=$(get_config features.$feature false)
    if [ "$val" = "True" ] || [ "$val" = "true" ]; then
      echo "  ✓ $feature"
    fi
  done
}

# ============================================================
# MAIN
# ============================================================

ACTION="${1:-ui}"

case "$ACTION" in
  ui)
    init_config
    show_main_menu
    ;;
  import)
    init_config
    if [ -n "$2" ] && [ -f "$2" ]; then
      cp "$2" "$CONFIG_FILE"
      echo "✓ Configuration imported from $2"
    else
      echo "Usage: settings.sh import <config_file>"
    fi
    ;;
  export)
    init_config
    dest="${2:-$SETTINGS_DIR/config_export_$(date +%Y%m%d).json}"
    cp "$CONFIG_FILE" "$dest"
    echo "✓ Configuration exported to $dest"
    ;;
  reset)
    init_config
    rm -f "$CONFIG_FILE"
    init_config
    echo "✓ Settings reset to defaults"
    ;;
  get)
    init_config
    get_config "$2" "$3"
    ;;
  set)
    init_config
    set_config "$2" "$3"
    echo "✓ Set $2 = $3"
    ;;
  context-import)
    init_config
    import_context_ui
    ;;
  context-export)
    init_config
    export_context_ui
    ;;
  *)
    echo "Usage: settings.sh [ui|import|export|reset|get|set|context-import|context-export]"
    exit 1
    ;;
esac
