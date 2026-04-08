#!/data/data/com.termux/files/usr/bin/bash
# session_manager.sh - Session ID tracking, transcript archive, and selective memory slots
# Usage: session_manager.sh [new|save|resume|list|slots|create-slot|delete-slot|load-slot|status]

SESSIONS_DIR="$HOME/.aether/sessions"
TRANSCRIPTS_DIR="$HOME/.aether/transcripts"
MEMORY_DIR="$HOME/.aether/memory_slots"
ACTIVE_SESSION_FILE="$SESSIONS_DIR/active_session.info"
SESSION_LOG="$SESSIONS_DIR/last_session.log"
SESSION_REGISTRY="$SESSIONS_DIR/session_registry.json"

mkdir -p "$SESSIONS_DIR" "$TRANSCRIPTS_DIR" "$MEMORY_DIR"

# ============================================================
# SESSION ID MANAGEMENT
# ============================================================

generate_session_id() {
  # Generate a short, memorable session ID
  # Format: AETHER-XXXX-XXXX (8 hex chars, easy to type)
  local id
  id=$(od -An -tx1 -N4 /dev/urandom 2>/dev/null | tr -d ' ' | head -c 8)
  echo "AETHER-${id:0:4}-${id:4:4}"
}

create_session() {
  local mode="${1:-fresh}"  # fresh, resume, memory-slot
  
  local session_id
  session_id=$(generate_session_id)
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  
  # Clear previous session log for fresh start
  if [ "$mode" = "fresh" ]; then
    > "$SESSION_LOG"
  fi
  
  # Write active session info
  cat > "$ACTIVE_SESSION_FILE" << EOF
{
  "session_id": "$session_id",
  "started": "$timestamp",
  "mode": "$mode",
  "status": "active"
}
EOF
  
  echo "$session_id"
}

get_active_session() {
  if [ -f "$ACTIVE_SESSION_FILE" ]; then
    cat "$ACTIVE_SESSION_FILE"
  else
    echo '{"session_id":"none","mode":"unknown","status":"inactive"}'
  fi
}

# ============================================================
# TRANSCRIPT ARCHIVE
# ============================================================

save_transcript() {
  local session_id
  session_id=$(python3 -c "import json; print(json.load(open('$ACTIVE_SESSION_FILE'))['session_id'])" 2>/dev/null)
  
  if [ -z "$session_id" ] || [ "$session_id" = "none" ]; then
    echo "No active session to save"
    return 1
  fi
  
  if [ ! -f "$SESSION_LOG" ] || [ ! -s "$SESSION_LOG" ]; then
    echo "Session log is empty - nothing to save"
    return 1
  fi
  
  local original_size
  original_size=$(wc -c < "$SESSION_LOG")
  local transcript_file="$TRANSCRIPTS_DIR/${session_id}.transcript"
  local compressed_file="$TRANSCRIPTS_DIR/${session_id}.transcript.gz"
  
  # Create structured transcript
  {
    echo "# Aether Session Transcript"
    echo "# Session ID: $session_id"
    echo "# Started: $(python3 -c "import json; print(json.load(open('$ACTIVE_SESSION_FILE'))['started'])" 2>/dev/null)"
    echo "# Saved: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "# Original Size: $original_size bytes"
    echo "---"
    cat "$SESSION_LOG"
  } > "$transcript_file"
  
  # Compress if over threshold (default: 4KB)
  local threshold=${1:-4096}
  
  if [ "$original_size" -gt "$threshold" ]; then
    gzip -c "$transcript_file" > "$compressed_file"
    local compressed_size
    compressed_size=$(wc -c < "$compressed_file")
    local savings=$((100 - (compressed_size * 100 / original_size)))
    
    # Remove uncompressed version to save space
    rm -f "$transcript_file"
    
    echo "✓ Transcript saved: $session_id"
    echo "  Original: $(numfmt --to=iec $original_size 2>/dev/null || echo "${original_size}B")"
    echo "  Compressed: $(numfmt --to=iec $compressed_size 2>/dev/null || echo "${compressed_size}B")"
    echo "  Savings: ${savings}%"
    echo "  File: $compressed_file"
  else
    echo "✓ Transcript saved: $session_id"
    echo "  Size: $(numfmt --to=iec $original_size 2>/dev/null || echo "${original_size}B") (below compression threshold)"
    echo "  File: $transcript_file"
  fi
  
  # Update registry
  update_registry "$session_id" "saved"
  
  # Mark session as closed
  if [ -f "$ACTIVE_SESSION_FILE" ]; then
    python3 -c "
import json
cfg = json.load(open('$ACTIVE_SESSION_FILE'))
cfg['status'] = 'closed'
cfg['closed'] = '$(date '+%Y-%m-%d %H:%M:%S')'
cfg['transcript_saved'] = True
with open('$ACTIVE_SESSION_FILE', 'w') as f:
    json.dump(cfg, f, indent=2)
" 2>/dev/null
  fi
}

# ============================================================
# SESSION RESUME
# ============================================================

resume_session() {
  local session_id="$1"
  
  if [ -z "$session_id" ]; then
    echo "Usage: session_manager.sh resume <session_id>"
    list_transcripts
    return 1
  fi
  
  # Find transcript file (compressed or uncompressed)
  local transcript_file=""
  
  if [ -f "$TRANSCRIPTS_DIR/${session_id}.transcript.gz" ]; then
    transcript_file="$TRANSCRIPTS_DIR/${session_id}.transcript.gz"
  elif [ -f "$TRANSCRIPTS_DIR/${session_id}.transcript" ]; then
    transcript_file="$TRANSCRIPTS_DIR/${session_id}.transcript"
  fi
  
  if [ -z "$transcript_file" ]; then
    echo "ERROR: Session not found: $session_id"
    echo "Run: session_manager.sh list to see available sessions"
    return 1
  fi
  
  # Restore transcript as session log
  if [[ "$transcript_file" == *.gz ]]; then
    gunzip -c "$transcript_file" | tail -n +7 > "$SESSION_LOG"
    # Skip the 7 header lines
  else
    tail -n +7 "$transcript_file" > "$SESSION_LOG"
  fi
  
  # Create new active session (resumed)
  local new_id
  new_id=$(create_session "resume")
  
  echo "✓ Session resumed: $session_id"
  echo "  Lines restored: $(wc -l < "$SESSION_LOG")"
  echo "  New session ID: $new_id"
  echo ""
  echo "The conversation history has been loaded."
  echo "Aether will continue from where you left off."
  
  update_registry "$session_id" "resumed"
}

# ============================================================
# SESSION REGISTRY
# ============================================================

update_registry() {
  local session_id="$1"
  local action="$2"
  
  # Initialize registry if needed
  if [ ! -f "$SESSION_REGISTRY" ]; then
    echo '{"sessions":[]}' > "$SESSION_REGISTRY"
  fi
  
  # Get current session info
  local mode="fresh"
  local started=""
  if [ -f "$ACTIVE_SESSION_FILE" ]; then
    mode=$(python3 -c "import json; print(json.load(open('$ACTIVE_SESSION_FILE')).get('mode','fresh'))" 2>/dev/null)
    started=$(python3 -c "import json; print(json.load(open('$ACTIVE_SESSION_FILE')).get('started',''))" 2>/dev/null)
  fi
  
  # Update registry entry
  python3 << PYEOF
import json, os

registry = json.load(open('$SESSION_REGISTRY'))
sessions = registry.get('sessions', [])

# Find existing entry
found = False
for s in sessions:
    if s.get('session_id') == '$session_id':
        s['last_action'] = '$action'
        s['last_action_time'] = '$(date '+%Y-%m-%d %H:%M:%S')'
        found = True
        break

if not found:
    sessions.append({
        'session_id': '$session_id',
        'started': '$started',
        'mode': '$mode',
        'last_action': '$action',
        'last_action_time': '$(date '+%Y-%m-%d %H:%M:%S')'
    })

registry['sessions'] = sessions
with open('$SESSION_REGISTRY', 'w') as f:
    json.dump(registry, f, indent=2)
PYEOF
}

list_transcripts() {
  echo "=== Session Transcript Archive ==="
  echo ""
  
  if [ ! -d "$TRANSCRIPTS_DIR" ] || [ -z "$(ls "$TRANSCRIPTS_DIR" 2>/dev/null)" ]; then
    echo "No saved transcripts found."
    echo "Save a session when exiting Aether to build history."
    return 0
  fi
  
  printf "%-22s %-10s %-12s %-8s %s\n" "SESSION ID" "SIZE" "DATE" "STATUS" "MODE"
  printf "%-22s %-10s %-12s %-8s %s\n" "----------" "----" "----" "------" "----"
  
  for file in "$TRANSCRIPTS_DIR"/*.transcript "$TRANSCRIPTS_DIR"/*.transcript.gz; do
    [ -f "$file" ] || continue
    
    session_id=$(basename "$file" | sed 's/.transcript.gz//;s/.transcript//')
    size=$(du -h "$file" | cut -f1)
    date=$(stat -c %y "$file" 2>/dev/null | cut -d'.' -f1 | cut -d' ' -f1)
    
    if [[ "$file" == *.gz ]]; then
      echo "$session_id" | grep -q "^AETHER-" && printf "%-22s %-10s %-12s %-8s %s\n" "$session_id" "$size" "$date" "compressed" "archived"
    else
      echo "$session_id" | grep -q "^AETHER-" && printf "%-22s %-10s %-12s %-8s %s\n" "$session_id" "$size" "$date" "plain" "archived"
    fi
  done
  
  echo ""
  echo "Resume: session_manager.sh resume <session_id>"
}

# ============================================================
# MEMORY SLOTS
# ============================================================

create_memory_slot() {
  local slot_name="$1"
  
  if [ -z "$slot_name" ]; then
    echo "Usage: session_manager.sh create-slot <name>"
    return 1
  fi
  
  # Sanitize name
  slot_name=$(echo "$slot_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -cd '[:alnum:]_')
  
  local slot_dir="$MEMORY_DIR/$slot_name"
  
  if [ -d "$slot_dir" ]; then
    echo "Memory slot already exists: $slot_name"
    return 1
  fi
  
  mkdir -p "$slot_dir"
  
  # Create slot metadata
  cat > "$slot_dir/slot.json" << EOF
{
  "name": "$slot_name",
  "created": "$(date '+%Y-%m-%d %H:%M:%S')",
  "description": "",
  "entries": 0,
  "loaded": false
}
EOF
  
  echo "✓ Memory slot created: $slot_name"
  echo "  Location: $slot_dir"
  echo "  Add memories: session_manager.sh add-memory $slot_name <text>"
}

add_to_slot() {
  local slot_name="$1"
  local memory_text="$2"
  
  if [ -z "$slot_name" ] || [ -z "$memory_text" ]; then
    echo "Usage: session_manager.sh add-memory <slot> <text>"
    return 1
  fi
  
  local slot_dir="$MEMORY_DIR/$slot_name"
  
  if [ ! -d "$slot_dir" ]; then
    echo "Memory slot not found: $slot_name"
    echo "Create it: session_manager.sh create-slot $slot_name"
    return 1
  fi
  
  # Add memory entry
  local entry_file="$slot_dir/entry_$(date +%Y%m%d_%H%M%S).mem"
  
  cat > "$entry_file" << EOF
# Memory Entry
# Added: $(date '+%Y-%m-%d %H:%M:%S')
# Slot: $slot_name

$memory_text
EOF
  
  # Update entry count
  local count
  count=$(ls "$slot_dir"/entry_*.mem 2>/dev/null | wc -l)
  
  python3 -c "
import json
slot = json.load(open('$slot_dir/slot.json'))
slot['entries'] = $count
with open('$slot_dir/slot.json', 'w') as f:
    json.dump(slot, f, indent=2)
" 2>/dev/null
  
  echo "✓ Memory added to slot: $slot_name"
}

load_memory_slot() {
  local slot_name="$1"
  
  if [ -z "$slot_name" ]; then
    echo "Usage: session_manager.sh load-slot <slot_name>"
    list_memory_slots
    return 1
  fi
  
  local slot_dir="$MEMORY_DIR/$slot_name"
  
  if [ ! -d "$slot_dir" ]; then
    echo "Memory slot not found: $slot_name"
    return 1
  fi
  
  # Load all memory entries into active context
  local loaded_file="$SESSIONS_DIR/loaded_memory.txt"
  
  {
    echo "# Memory Slot: $slot_name"
    echo "# Loaded: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "---"
    
    for entry in "$slot_dir"/entry_*.mem; do
      [ -f "$entry" ] || continue
      tail -n +6 "$entry"
      echo ""
    done
  } > "$loaded_file"
  
  # Mark slot as loaded
  python3 -c "
import json
slot = json.load(open('$slot_dir/slot.json'))
slot['loaded'] = True
slot['loaded_at'] = '$(date '+%Y-%m-%d %H:%M:%S')'
with open('$slot_dir/slot.json', 'w') as f:
    json.dump(slot, f, indent=2)
" 2>/dev/null
  
  local entries
  entries=$(ls "$slot_dir"/entry_*.mem 2>/dev/null | wc -l)
  local size
  size=$(wc -c < "$loaded_file")
  
  echo "✓ Memory slot loaded: $slot_name"
  echo "  Entries: $entries"
  echo "  Size: $(numfmt --to=iec $size 2>/dev/null || echo "${size}B")"
  echo "  This memory will be injected into the next session"
}

unload_memory_slot() {
  local slot_name="$1"
  
  if [ -z "$slot_name" ]; then
    echo "Usage: session_manager.sh unload-slot <slot_name>"
    return 1
  fi
  
  local slot_dir="$MEMORY_DIR/$slot_name"
  
  if [ -d "$slot_dir" ]; then
    python3 -c "
import json
slot = json.load(open('$slot_dir/slot.json'))
slot['loaded'] = False
with open('$slot_dir/slot.json', 'w') as f:
    json.dump(slot, f, indent=2)
" 2>/dev/null
  fi
  
  rm -f "$SESSIONS_DIR/loaded_memory.txt"
  
  echo "✓ Memory slot unloaded: $slot_name"
}

list_memory_slots() {
  echo "=== Memory Slots ==="
  echo ""
  
  if [ ! -d "$MEMORY_DIR" ] || [ -z "$(ls -d "$MEMORY_DIR"/*/ 2>/dev/null)" ]; then
    echo "No memory slots created."
    echo "Create one: session_manager.sh create-slot <name>"
    echo ""
    echo "Memory slots let you isolate knowledge per project:"
    echo "  - Create a slot per project (e.g., 'webapp', 'security_audit')"
    echo "  - Add relevant context, decisions, patterns to each slot"
    echo "  - Load only the slots you need for the current session"
    echo "  - Keeps context lean and relevant"
    return 0
  fi
  
  printf "%-20s %-8s %-12s %s\n" "SLOT NAME" "ENTRIES" "CREATED" "STATUS"
  printf "%-20s %-8s %-12s %s\n" "---------" "-------" "-------" "------"
  
  for slot_dir in "$MEMORY_DIR"/*/; do
    [ -d "$slot_dir" ] || continue
    
    slot_name=$(basename "$slot_dir")
    
    if [ -f "$slot_dir/slot.json" ]; then
      entries=$(python3 -c "import json; print(json.load(open('$slot_dir/slot.json')).get('entries', 0))" 2>/dev/null)
      created=$(python3 -c "import json; print(json.load(open('$slot_dir/slot.json')).get('created',''))" 2>/dev/null)
      loaded=$(python3 -c "import json; print('loaded' if json.load(open('$slot_dir/slot.json')).get('loaded',False) else 'idle')" 2>/dev/null)
      
      printf "%-20s %-8s %-12s %s\n" "$slot_name" "$entries" "$created" "$loaded"
    fi
  done
  
  echo ""
  echo "Commands:"
  echo "  create-slot <name>     - Create new memory slot"
  echo "  add-memory <slot> <txt>- Add memory to slot"
  echo "  load-slot <name>       - Load slot into next session"
  echo "  unload-slot <name>     - Unload current slot"
  echo "  delete-slot <name>     - Delete a slot"
}

delete_memory_slot() {
  local slot_name="$1"
  
  if [ -z "$slot_name" ]; then
    echo "Usage: session_manager.sh delete-slot <name>"
    return 1
  fi
  
  local slot_dir="$MEMORY_DIR/$slot_name"
  
  if [ -d "$slot_dir" ]; then
    rm -rf "$slot_dir"
    echo "✓ Memory slot deleted: $slot_name"
  else
    echo "Slot not found: $slot_name"
  fi
}

# ============================================================
# SESSION STARTUP FLOW
# ============================================================

show_startup_prompt() {
  echo "=== Aether Session Startup ==="
  echo ""
  
  # Check if there's a previous active session
  local prev_session="none"
  if [ -f "$ACTIVE_SESSION_FILE" ]; then
    prev_status=$(python3 -c "import json; print(json.load(open('$ACTIVE_SESSION_FILE')).get('status','inactive'))" 2>/dev/null)
    prev_id=$(python3 -c "import json; print(json.load(open('$ACTIVE_SESSION_FILE')).get('session_id','none'))" 2>/dev/null)
    
    if [ "$prev_status" = "closed" ]; then
      prev_session="$prev_id"
    fi
  fi
  
  # Count available transcripts and memory slots
  transcript_count=$(ls "$TRANSCRIPTS_DIR"/*.transcript* 2>/dev/null | wc -l)
  slot_count=$(ls -d "$MEMORY_DIR"/*/ 2>/dev/null | wc -l)
  
  echo "Available resources:"
  echo "  Saved Transcripts: $transcript_count"
  echo "  Memory Slots: $slot_count"
  echo ""
  echo "1. New Session (fresh start)"
  echo "2. Resume Session (enter session ID)"
  echo "3. Load Memory Slot (project-specific context)"
  echo "4. Memory Slots Management"
  
  if [ "$transcript_count" -gt 0 ]; then
    echo "5. Browse Saved Transcripts"
  fi
  
  echo "0. Cancel"
  echo ""
  
  read -p "Select: " choice
  
  case "$choice" in
    1)
      local new_id
      new_id=$(create_session "fresh")
      echo ""
      echo "✓ New session started"
      echo "  Session ID: $new_id"
      echo ""
      echo "MEMORY LOADING:"
      echo "  a) Fresh (no memory)"
      echo "  b) Load system memory (default)"
      echo "  c) Load memory slot"
      read -p "Memory mode (a/b/c): " mem_choice
      case "$mem_choice" in
        a) echo "  → Fresh start, no memory loaded" ;;
        b) echo "  → System memory will be loaded" ;;
        c)
          echo "Available slots:"
          list_memory_slots
          read -p "Slot name: " slot_name
          load_memory_slot "$slot_name"
          ;;
      esac
      echo "$new_id"
      ;;
      
    2)
      echo "Enter Session ID (e.g., AETHER-ab12-cd34):"
      read -r session_id
      resume_session "$session_id"
      ;;
      
    3)
      list_memory_slots
      echo ""
      read -p "Slot name to load: " slot_name
      load_memory_slot "$slot_name"
      local new_id
      new_id=$(create_session "memory-slot")
      echo ""
      echo "✓ Session started with memory slot: $slot_name"
      echo "  Session ID: $new_id"
      echo "$new_id"
      ;;
      
    4)
      list_memory_slots
      ;;
      
    5)
      list_transcripts
      ;;
      
    *)
      echo "Cancelled"
      return 1
      ;;
  esac
}

# ============================================================
# SESSION EXIT PROMPT
# ============================================================

show_exit_prompt() {
  local session_id
  session_id=$(python3 -c "import json; print(json.load(open('$ACTIVE_SESSION_FILE'))['session_id'])" 2>/dev/null)
  
  if [ -z "$session_id" ] || [ "$session_id" = "none" ]; then
    return
  fi
  
  local lines=0
  if [ -f "$SESSION_LOG" ]; then
    lines=$(wc -l < "$SESSION_LOG")
  fi
  
  echo ""
  echo "=== Session Ending ==="
  echo "Session ID: $session_id"
  echo "Lines logged: $lines"
  echo ""
  
  if [ "$lines" -gt 10 ]; then
    read -p "Save transcript for later resuming? (y/n): " save_choice
    
    if [[ "$save_choice" =~ ^[Yy] ]]; then
      save_transcript
      echo ""
      echo "Your session has been saved."
      echo "To resume later, use this ID: $session_id"
      echo "Run: session_manager.sh resume $session_id"
    else
      echo "Session discarded."
    fi
  else
    echo "Session too short to save (under 10 lines)."
  fi
  
  # Mark session as closed
  if [ -f "$ACTIVE_SESSION_FILE" ]; then
    python3 -c "
import json
cfg = json.load(open('$ACTIVE_SESSION_FILE'))
cfg['status'] = 'closed'
cfg['closed'] = '$(date '+%Y-%m-%d %H:%M:%S')'
with open('$ACTIVE_SESSION_FILE', 'w') as f:
    json.dump(cfg, f, indent=2)
" 2>/dev/null
  fi
}

# ============================================================
# STATUS
# ============================================================

show_status() {
  echo "=== Session Manager Status ==="
  echo ""
  
  # Active session
  echo "Active Session:"
  if [ -f "$ACTIVE_SESSION_FILE" ]; then
    python3 -c "
import json
s = json.load(open('$ACTIVE_SESSION_FILE'))
print(f\"  ID: {s.get('session_id', 'none')}\")
print(f\"  Started: {s.get('started', 'unknown')}\")
print(f\"  Mode: {s.get('mode', 'unknown')}\")
print(f\"  Status: {s.get('status', 'unknown')}\")
" 2>/dev/null
  else
    echo "  No active session"
  fi
  
  echo ""
  echo "Session Log: $(wc -l < "$SESSION_LOG" 2>/dev/null || echo 0) lines, $(du -h "$SESSION_LOG" 2>/dev/null | cut -f1 || echo 0B)"
  echo "Transcripts: $(ls "$TRANSCRIPTS_DIR"/*.transcript* 2>/dev/null | wc -l) saved"
  echo "Memory Slots: $(ls -d "$MEMORY_DIR"/*/ 2>/dev/null | wc -l) created"
  
  # Loaded memory
  if [ -f "$SESSIONS_DIR/loaded_memory.txt" ]; then
    echo "Loaded Memory: $(du -h "$SESSIONS_DIR/loaded_memory.txt" | cut -f1)"
  fi
}

# ============================================================
# VIEW TRANSCRIPT
# ============================================================

view_transcript() {
  local session_id="$1"
  
  if [ -z "$session_id" ]; then
    echo "Usage: session_manager.sh view <session_id>"
    return 1
  fi
  
  if [ -f "$TRANSCRIPTS_DIR/${session_id}.transcript.gz" ]; then
    gunzip -c "$TRANSCRIPTS_DIR/${session_id}.transcript.gz"
  elif [ -f "$TRANSCRIPTS_DIR/${session_id}.transcript" ]; then
    cat "$TRANSCRIPTS_DIR/${session_id}.transcript"
  else
    echo "Transcript not found: $session_id"
  fi
}

# ============================================================
# MAIN
# ============================================================

ACTION="${1:-status}"

case "$ACTION" in
  new)
    create_session "fresh"
    ;;
  save)
    save_transcript "${2:-4096}"
    ;;
  resume)
    resume_session "$2"
    ;;
  list)
    list_transcripts
    ;;
  view)
    view_transcript "$2"
    ;;
  slots)
    list_memory_slots
    ;;
  create-slot)
    create_memory_slot "$2"
    ;;
  add-memory)
    add_to_slot "$2" "$3"
    ;;
  load-slot)
    load_memory_slot "$2"
    ;;
  unload-slot)
    unload_memory_slot "$2"
    ;;
  delete-slot)
    delete_memory_slot "$2"
    ;;
  startup)
    show_startup_prompt
    ;;
  exit)
    show_exit_prompt
    ;;
  status)
    show_status
    ;;
  *)
    echo "Usage: session_manager.sh [new|save|resume|list|view|slots|create-slot|add-memory|load-slot|unload-slot|delete-slot|startup|exit|status]"
    echo ""
    echo "Session Management:"
    echo "  new              - Create new session"
    echo "  save [threshold] - Save transcript (compress if over threshold bytes)"
    echo "  resume <id>      - Resume a saved session"
    echo "  list             - List saved transcripts"
    echo "  view <id>        - View transcript content"
    echo "  startup          - Interactive startup prompt"
    echo "  exit             - Interactive exit prompt (save transcript)"
    echo ""
    echo "Memory Slots:"
    echo "  slots            - List memory slots"
    echo "  create-slot <n>  - Create new memory slot"
    echo "  add-memory <s> <t> - Add memory to slot"
    echo "  load-slot <name> - Load slot into session"
    echo "  unload-slot <n>  - Unload current slot"
    echo "  delete-slot <n>  - Delete a slot"
    echo ""
    echo "Info:"
    echo "  status           - Show current session status"
    exit 1
    ;;
esac
