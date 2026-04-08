#!/data/data/com.termux/files/usr/bin/bash
# context_manager.sh - Gemini-style context import/export/management
# Usage: context_manager.sh [import <source>|export|list|clear|attach <file>|contexts]

CONTEXT_DIR="$HOME/aether/contexts"
ACTIVE_CONTEXT_FILE="$CONTEXT_DIR/active_context.txt"
CONTEXT_LOG="$HOME/.aether/sessions/context_manager.log"

mkdir -p "$CONTEXT_DIR"

log_action() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$CONTEXT_LOG"
}

# ============================================================
# CONTEXT IMPORT
# ============================================================

import_context() {
  local source="$1"
  local name="${2:-}"
  local timestamp
  timestamp=$(date +%Y%m%d_%H%M%S)
  
  echo "=== Context Import ==="
  
  if [ -z "$source" ]; then
    echo "Usage: context_manager.sh import <file|url|clipboard|stdin>"
    echo ""
    echo "Sources:"
    echo "  <file>     - Import from file"
    echo "  <url>      - Import from web page"
    echo "  clipboard  - Import from clipboard"
    echo "  -          - Import from stdin"
    return 1
  fi
  
  local content=""
  local source_type="unknown"
  
  # Detect source type
  if [ "$source" = "clipboard" ]; then
    if command -v termux-clipboard-get &>/dev/null; then
      content=$(termux-clipboard-get 2>/dev/null)
      source_type="clipboard"
    else
      echo "ERROR: termux-clipboard-get not available"
      return 1
    fi
    
  elif echo "$source" | grep -qE "^https?://"; then
    # URL import
    source_type="url"
    if command -v lynx &>/dev/null; then
      content=$(lynx -dump "$source" 2>/dev/null | head -c 16000)
    elif command -v curl &>/dev/null; then
      content=$(curl -sL "$source" 2>/dev/null | head -c 16000)
    else
      echo "ERROR: Install lynx or curl for URL import"
      return 1
    fi
    
  elif [ "$source" = "-" ]; then
    # stdin
    source_type="stdin"
    content=$(cat)
    
  elif [ -f "$source" ]; then
    source_type="file"
    content=$(cat "$source" | head -c 16000)
    
  elif [ -d "$source" ]; then
    source_type="directory"
    content=""
    file_count=0
    for f in "$source"/*.txt "$source"/*.md "$source"/*.py "$source"/*.sh "$source"/*.js "$source"/*.json; do
      if [ -f "$f" ]; then
        content+="=== File: $(basename "$f") ===\n"
        content+="$(cat "$f" | head -c 4000)\n\n"
        file_count=$((file_count + 1))
      fi
    done
    echo "Imported $file_count files from $source"
    
  else
    echo "ERROR: Source not found: $source"
    return 1
  fi
  
  if [ -z "$content" ]; then
    echo "ERROR: No content retrieved from source"
    return 1
  fi
  
  # Generate name if not provided
  if [ -z "$name" ]; then
    name="imported_${timestamp}"
  fi
  
  # Save context
  local context_file="$CONTEXT_DIR/${name}.ctx"
  cat > "$context_file" << EOF
# Context: $name
# Source: $source
# Type: $source_type
# Imported: $(date)
# Size: $(echo "$content" | wc -c) bytes

$content
EOF
  
  echo "✓ Context imported: $name"
  echo "  Source: $source ($source_type)"
  echo "  Size: $(echo "$content" | wc -c) bytes"
  echo "  File: $context_file"
  
  log_action "IMPORT name=$name source=$source type=$source_type size=$(echo "$content" | wc -c)"
}

# ============================================================
# CONTEXT ATTACH
# ============================================================

attach_context() {
  local file="$1"
  
  if [ ! -f "$file" ]; then
    echo "ERROR: File not found: $file"
    return 1
  fi
  
  # Add to active context
  echo "=== Attached: $(basename "$file") ===" >> "$ACTIVE_CONTEXT_FILE"
  echo "Source: $file" >> "$ACTIVE_CONTEXT_FILE"
  echo "---" >> "$ACTIVE_CONTEXT_FILE"
  cat "$file" >> "$ACTIVE_CONTEXT_FILE"
  echo "" >> "$ACTIVE_CONTEXT_FILE"
  echo "---" >> "$ACTIVE_CONTEXT_FILE"
  
  echo "✓ Attached $(basename "$file") to active context"
  log_action "ATTACH file=$file"
}

# ============================================================
# CONTEXT EXPORT
# ============================================================

export_context() {
  local dest="${1:-}"
  
  if [ -z "$dest" ]; then
    dest="$CONTEXT_DIR/export_$(date +%Y%m%d_%H%M%S).txt"
  fi
  
  # Export active context + session log
  {
    echo "# Aether Context Export"
    echo "# Date: $(date)"
    echo ""
    
    if [ -f "$ACTIVE_CONTEXT_FILE" ]; then
      echo "## Active Context"
      cat "$ACTIVE_CONTEXT_FILE"
      echo ""
    fi
    
    if [ -f "$HOME/.aether/sessions/last_session.log" ]; then
      echo "## Session Log"
      cat "$HOME/.aether/sessions/last_session.log"
      echo ""
    fi
    
    echo "## Imported Contexts"
    for ctx in "$CONTEXT_DIR"/*.ctx; do
      if [ -f "$ctx" ]; then
        echo "--- $(basename "$ctx") ---"
        cat "$ctx"
        echo ""
      fi
    done
  } > "$dest"
  
  echo "✓ Context exported to $dest"
  echo "  Size: $(du -h "$dest" | cut -f1)"
  log_action "EXPORT dest=$dest"
}

# ============================================================
# CONTEXT LIST
# ============================================================

list_contexts() {
  echo "=== Context Library ==="
  echo ""
  
  # Active context
  if [ -f "$ACTIVE_CONTEXT_FILE" ]; then
    active_size=$(wc -c < "$ACTIVE_CONTEXT_FILE")
    echo "📌 Active Context: $active_size bytes"
    echo ""
  fi
  
  # Imported contexts
  echo "Imported Contexts:"
  ctx_count=0
  for ctx in "$CONTEXT_DIR"/*.ctx; do
    if [ -f "$ctx" ]; then
      name=$(basename "$ctx" .ctx)
      size=$(du -h "$ctx" | cut -f1)
      source=$(grep "^# Source:" "$ctx" | cut -d: -f2- | xargs)
      imported=$(grep "^# Imported:" "$ctx" | cut -d: -f2- | xargs)
      
      printf "  📄 %-25s %6s | %s\n" "$name" "$size" "$source"
      printf "     Imported: %s\n" "$imported"
      ctx_count=$((ctx_count + 1))
    fi
  done
  
  if [ "$ctx_count" -eq 0 ]; then
    echo "  (none)"
  fi
  
  echo ""
  echo "Total: $ctx_count context(s)"
  echo ""
  echo "Commands:"
  echo "  context_manager.sh attach <file>  - Add to active context"
  echo "  context_manager.sh clear          - Clear active context"
  echo "  context_manager.sh import <src>   - Import new context"
  echo "  context_manager.sh show <name>    - View context content"
  
  log_action "LIST count=$ctx_count"
}

# ============================================================
# SHOW CONTEXT
# ============================================================

show_context() {
  local name="$1"
  
  if [ -z "$name" ]; then
    echo "Usage: context_manager.sh show <context_name>"
    list_contexts
    return 1
  fi
  
  local ctx_file="$CONTEXT_DIR/${name}.ctx"
  
  if [ -f "$ctx_file" ]; then
    echo "=== Context: $name ==="
    head -100 "$ctx_file"
    echo ""
    echo "..."
    echo "(Showing first 100 lines of $(wc -l < "$ctx_file") total)"
  else
    echo "Context not found: $name"
    list_contexts
  fi
}

# ============================================================
# CLEAR CONTEXT
# ============================================================

clear_context() {
  echo "Clearing active context..."
  > "$ACTIVE_CONTEXT_FILE"
  echo "✓ Active context cleared"
  log_action "CLEAR"
}

# ============================================================
# SMART CONTEXT (auto-suggest relevant contexts)
# ============================================================

smart_context() {
  local query="$1"
  
  if [ -z "$query" ]; then
    echo "Usage: context_manager.sh smart <query>"
    echo "Finds relevant imported contexts based on query keywords"
    return 1
  fi
  
  echo "=== Smart Context Search ==="
  echo "Query: $query"
  echo ""
  
  matches=0
  
  for ctx in "$CONTEXT_DIR"/*.ctx; do
    if [ -f "$ctx" ]; then
      name=$(basename "$ctx" .ctx)
      
      # Check for keyword matches
      match_count=0
      for word in $query; do
        if grep -qi "$word" "$ctx" 2>/dev/null; then
          match_count=$((match_count + 1))
        fi
      done
      
      if [ "$match_count" -gt 0 ]; then
        size=$(du -h "$ctx" | cut -f1)
        source=$(grep "^# Source:" "$ctx" | cut -d: -f2- | xargs)
        printf "  📄 %-25s %6s | %d matches | %s\n" "$name" "$size" "$match_count" "$source"
        matches=$((matches + 1))
      fi
    fi
  done
  
  if [ "$matches" -eq 0 ]; no
    echo "  No matching contexts found"
  else
    echo ""
    echo "Found $matches matching context(s)"
  fi
  
  log_action "SMART_QUERY query='$query' matches=$matches"
}

# ============================================================
# CONTEXT STATS
# ============================================================

context_stats() {
  echo "=== Context Statistics ==="
  echo ""
  
  total_size=0
  total_files=0
  
  for ctx in "$CONTEXT_DIR"/*.ctx; do
    if [ -f "$ctx" ]; then
      size=$(wc -c < "$ctx")
      total_size=$((total_size + size))
      total_files=$((total_files + 1))
    fi
  done
  
  if [ -f "$ACTIVE_CONTEXT_FILE" ]; then
    active_size=$(wc -c < "$ACTIVE_CONTEXT_FILE")
    echo "Active Context: $(numfmt --to=iec $active_size 2>/dev/null || echo "${active_size}B")"
  fi
  
  echo "Imported Contexts: $total_files"
  echo "Total Storage: $(numfmt --to=iec $total_size 2>/dev/null || echo "${total_size}B")"
  echo ""
  
  # By type
  echo "By Type:"
  for type in file url clipboard directory; do
    count=$(grep -l "^# Type: $type" "$CONTEXT_DIR"/*.ctx 2>/dev/null | wc -l)
    [ "$count" -gt 0 ] && echo "  $type: $count"
  done
  
  log_action "STATS files=$total_files size=$total_size"
}

# ============================================================
# MAIN
# ============================================================

ACTION="${1:-list}"

case "$ACTION" in
  import)
    import_context "$2" "$3"
    ;;
  attach)
    attach_context "$2"
    ;;
  export)
    export_context "$2"
    ;;
  list)
    list_contexts
    ;;
  show)
    show_context "$2"
    ;;
  clear)
    clear_context
    ;;
  smart)
    smart_context "$2"
    ;;
  stats)
    context_stats
    ;;
  *)
    echo "Usage: context_manager.sh [import|attach|export|list|show|clear|smart|stats]"
    echo ""
    echo "Commands:"
    echo "  import <source> [name]  - Import context from file/URL/clipboard"
    echo "  attach <file>           - Add file to active context"
    echo "  export [path]           - Export all context to file"
    echo "  list                    - List all contexts"
    echo "  show <name>             - View context content"
    echo "  clear                   - Clear active context"
    echo "  smart <query>           - Find relevant contexts"
    echo "  stats                   - Show context statistics"
    exit 1
    ;;
esac
