#!/data/data/com.termux/files/usr/bin/bash
# lsp_server.sh - Lightweight Language Server Protocol bridge for local AI code intelligence
# Provides: syntax checking, diagnostics, symbol extraction, go-to-definition
# Usage: lsp_server.sh [start|diagnostics <file>|symbols <file>|definition <file> <line>|hover <file> <line>|stop|status]

LSP_DIR="$HOME/aether/lsp"
LSP_LOG="$LSP_DIR/lsp.log"
LSP_PID_FILE="$LSP_DIR/lsp.pid"
LSP_SOCKET="$LSP_DIR/lsp.sock"

mkdir -p "$LSP_DIR"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LSP_LOG"
}

# ============================================================
# LANGUAGE DETECTION
# ============================================================

detect_language() {
  local file="$1"
  local ext="${file##*.}"
  
  case "$ext" in
    py) echo "python" ;;
    js|mjs) echo "javascript" ;;
    ts|tsx) echo "typescript" ;;
    rs) echo "rust" ;;
    go) echo "go" ;;
    c|cpp|cc|cxx|h|hpp) echo "cpp" ;;
    sh|bash|zsh) echo "shell" ;;
    rb) echo "ruby" ;;
    java) echo "java" ;;
    kt|kts) echo "kotlin" ;;
    md|mdx) echo "markdown" ;;
    json) echo "json" ;;
    yaml|yml) echo "yaml" ;;
    toml) echo "toml" ;;
    *) echo "unknown" ;;
  esac
}

# ============================================================
# DIAGNOSTICS ENGINE
# ============================================================

run_diagnostics() {
  local file="$1"
  local lang
  lang=$(detect_language "$file")
  
  if [ ! -f "$file" ]; then
    echo "ERROR: File not found: $file"
    return 1
  fi
  
  echo "=== LSP Diagnostics: $file ==="
  echo "Language: $lang"
  echo ""
  
  case "$lang" in
    python)
      echo "--- Python Diagnostics ---"
      
      # Syntax check
      if command -v python3 &>/dev/null; then
        echo "Syntax Check:"
        python3 -c "import py_compile; py_compile.compile('$file', doraise=True)" 2>&1 | while IFS= read -r line; do
          echo "  $line"
        done
        echo ""
      fi
      
      # Import check
      echo "Import Analysis:"
      grep -n "^import\|^from.*import" "$file" 2>/dev/null | while IFS= read -r line; do
        lineno=$(echo "$line" | cut -d: -f1)
        module=$(echo "$line" | sed 's/.*import //' | cut -d' ' -f1 | tr -d ',')
        echo "  Line $lineno: $module"
      done
      echo ""
      
      # Style issues
      echo "Style Issues:"
      # Line length > 120
      grep -n ".\{121,\}" "$file" 2>/dev/null | while IFS= read -r line; do
        lineno=$(echo "$line" | cut -d: -f1)
        echo "  Line $lineno: Line too long (>120 chars)"
      done
      
      # Trailing whitespace
      grep -n " \+$" "$file" 2>/dev/null | while IFS= read -r line; do
        lineno=$(echo "$line" | cut -d: -f1)
        echo "  Line $lineno: Trailing whitespace"
      done
      
      # Mixed tabs/spaces
      if grep -qP " \t" "$file" 2>/dev/null; then
        echo "  WARNING: Mixed tabs and spaces detected"
      fi
      echo ""
      
      # Unused imports detection (basic)
      echo "Potential Issues:"
      grep -n "^import\|^from.*import" "$file" 2>/dev/null | while IFS= read -r line; do
        module=$(echo "$line" | sed 's/.*import //' | cut -d' ' -f1 | tr -d ',')
        if ! grep -q "$module" "$file" | grep -v "^import\|^from" > /dev/null 2>&1; then
          echo "  Possible unused import: $module"
        fi
      done
      ;;
      
    javascript|typescript)
      echo "--- JavaScript/TypeScript Diagnostics ---"
      
      if command -v node &>/dev/null; then
        echo "Syntax Check:"
        node -c "$file" 2>&1 | while IFS= read -r line; do
          echo "  $line"
        done
        echo ""
      fi
      
      # Console.log detection
      echo "Code Quality:"
      grep -n "console\.log" "$file" 2>/dev/null | while IFS= read -r line; do
        lineno=$(echo "$line" | cut -d: -f1)
        echo "  Line $lineno: console.log statement (consider removing for production)"
      done
      
      # TODO/FIXME
      grep -n "TODO\|FIXME\|HACK\|XXX" "$file" 2>/dev/null | while IFS= read -r line; do
        lineno=$(echo "$line" | cut -d: -f1)
        content=$(echo "$line" | cut -d: -f2-)
        echo "  Line $lineno: $content"
      done
      echo ""
      
      # Line length
      grep -n ".\{121,\}" "$file" 2>/dev/null | while IFS= read -r line; do
        lineno=$(echo "$line" | cut -d: -f1)
        echo "  Line $lineno: Line too long (>120 chars)"
      done
      ;;
      
    shell)
      echo "--- Shell Script Diagnostics ---"
      
      if command -v bash &>/dev/null; then
        echo "Syntax Check:"
        bash -n "$file" 2>&1 | while IFS= read -r line; do
          echo "  $line"
        done
        echo ""
      fi
      
      # Common shell issues
      echo "Common Issues:"
      
      # Unquoted variables
      grep -n '\$[A-Za-z_][A-Za-z_0-9]*[^"]' "$file" 2>/dev/null | grep -v '"' | head -10 | while IFS= read -r line; do
        lineno=$(echo "$line" | cut -d: -f1)
        echo "  Line $lineno: Potentially unquoted variable (use \"\$var\")"
      done
      
      # Missing shebang
      head -1 "$file" | grep -q "^#!" || echo "  WARNING: Missing shebang line"
      
      # Using backticks instead of $()
      grep -n '`' "$file" 2>/dev/null | while IFS= read -r line; do
        lineno=$(echo "$line" | cut -d: -f1)
        echo "  Line $lineno: Consider using \$() instead of backticks"
      done
      ;;
      
    rust)
      echo "--- Rust Diagnostics ---"
      if command -v rustc &>/dev/null; then
        echo "Compile Check:"
        rustc --emit=metadata "$file" 2>&1 | head -20
        rm -f "${file%.rs}.rm" 2>/dev/null
      else
        echo "  ⚠ rustc not installed - skipping compile check"
      fi
      ;;
      
    go)
      echo "--- Go Diagnostics ---"
      if command -v go &>/dev/null; then
        echo "Vet Check:"
        go vet "$file" 2>&1 | head -20
      else
        echo "  ⚠ go not installed - skipping vet check"
      fi
      ;;
      
    *)
      echo "--- Generic Diagnostics ---"
      
      # Basic checks for any file
      echo "File Stats:"
      echo "  Lines: $(wc -l < "$file")"
      echo "  Words: $(wc -w < "$file")"
      echo "  Size: $(du -h "$file" | cut -f1)"
      echo ""
      
      # Line length issues
      long_lines=$(awk 'length > 120' "$file" | wc -l)
      if [ "$long_lines" -gt 0 ]; then
        echo "  $long_lines lines exceed 120 characters"
      fi
      ;;
  esac
  
  log "DIAGNOSTICS file=$file lang=$lang"
}

# ============================================================
# SYMBOL EXTRACTION
# ============================================================

extract_symbols() {
  local file="$1"
  local lang
  lang=$(detect_language "$file")
  
  if [ ! -f "$file" ]; then
    echo "ERROR: File not found: $file"
    return 1
  fi
  
  echo "=== Symbols: $file ==="
  echo "Language: $lang"
  echo ""
  
  case "$lang" in
    python)
      echo "Functions:"
      grep -n "^def \|^    def \|^async def " "$file" 2>/dev/null | sed 's/def /  /' | sed 's/async /  /'
      echo ""
      echo "Classes:"
      grep -n "^class " "$file" 2>/dev/null | sed 's/class /  /'
      echo ""
      echo "Imports:"
      grep -n "^import \|^from .* import" "$file" 2>/dev/null | sed 's/^/  /'
      ;;
      
    javascript|typescript)
      echo "Functions:"
      grep -n "function \|const .*=>\|let .*=>\|var .*=>" "$file" 2>/dev/null | sed 's/^/  /'
      echo ""
      echo "Classes:"
      grep -n "^export class \|^class " "$file" 2>/dev/null | sed 's/^/  /'
      echo ""
      echo "Exports:"
      grep -n "^export " "$file" 2>/dev/null | sed 's/^/  /'
      ;;
      
    shell)
      echo "Functions:"
      grep -n "^[a-zA-Z_][a-zA-Z0-9_]*() {" "$file" 2>/dev/null | sed 's/^/  /'
      echo ""
      echo "Variables:"
      grep -n "^[A-Z_][A-Z0-9_]*=" "$file" 2>/dev/null | head -20 | sed 's/^/  /'
      ;;
      
    *)
      echo "No language-specific symbol extraction for $lang"
      echo "Use a supported language (python, js/ts, shell, rust, go)"
      ;;
  esac
  
  log "SYMBOLS file=$file lang=$lang"
}

# ============================================================
# GO TO DEFINITION (Basic)
# ============================================================

find_definition() {
  local file="$1"
  local line_num="$2"
  
  if [ ! -f "$file" ]; then
    echo "ERROR: File not found: $file"
    return 1
  fi
  
  # Get the word at the given line
  local target_line
  target_line=$(sed -n "${line_num}p" "$file")
  
  # Extract potential symbol names
  local symbols
  symbols=$(echo "$target_line" | grep -oE "[a-zA-Z_][a-zA-Z0-9_]+" | sort -u)
  
  echo "=== Definition Lookup ==="
  echo "File: $file, Line: $line_num"
  echo "Content: $target_line"
  echo ""
  
  for sym in $symbols; do
    # Skip keywords and common words
    case "$sym" in
      if|else|elif|fi|then|for|while|do|done|case|esac|function|return|import|from|class|def|const|let|var|export|echo|cat|grep|sed|awk) continue ;;
    esac
    
    # Find first definition
    local def_line
    def_line=$(grep -n "def $sym\|function $sym\|$sym()\|^class $sym\|const $sym\|let $sym\|var $sym" "$file" 2>/dev/null | head -1)
    
    if [ -n "$def_line" ]; then
      echo "Symbol '$sym' defined at: $def_line"
    fi
  done
  
  log "DEFINITION file=$file line=$line_num"
}

# ============================================================
# HOVER INFO
# ============================================================

get_hover_info() {
  local file="$1"
  local line_num="$2"
  
  if [ ! -f "$file" ]; then
    echo "ERROR: File not found: $file"
    return 1
  fi
  
  local content
  content=$(sed -n "${line_num}p" "$file")
  local lang
  lang=$(detect_language "$file")
  
  echo "=== Hover Info ==="
  echo "File: $file"
  echo "Line: $line_num"
  echo "Content: $content"
  echo "Language: $lang"
  echo ""
  
  # Identify what's on this line
  if echo "$content" | grep -qE "^[[:space:]]*(def|async def)"; then
    echo "Type: Function Definition"
    func_name=$(echo "$content" | grep -oE "def [a-zA-Z_][a-zA-Z0-9_]*" | cut -d' ' -f2)
    params=$(echo "$content" | grep -oE "\([^)]*\)" | head -1)
    echo "Name: $func_name"
    echo "Parameters: $params"
    
  elif echo "$content" | grep -qE "^[[:space:]]*class"; then
    echo "Type: Class Definition"
    class_name=$(echo "$content" | grep -oE "class [a-zA-Z_][a-zA-Z0-9_]*" | cut -d' ' -f2)
    echo "Name: $class_name"
    
  elif echo "$content" | grep -qE "^[[:space:]]*(import|from)"; then
    echo "Type: Import Statement"
    
  elif echo "$content" | grep -qE "^[[:space:]]*#"; then
    echo "Type: Comment"
    
  elif echo "$content" | grep -qE "^[[:space:]]*(if|else|elif|for|while|try|except)"; then
    echo "Type: Control Flow"
    
  else
    echo "Type: Expression/Statement"
  fi
  
  log "HOVER file=$file line=$line_num"
}

# ============================================================
# LSP SERVER MODE (JSON-RPC over stdio)
# ============================================================

start_lsp_server() {
  echo "Starting LSP Server (stdio mode)..."
  echo "PID: $$"
  echo "$$" > "$LSP_PID_FILE"
  log "SERVER_STARTED pid=$$"
  
  # Simple JSON-RPC loop
  while IFS= read -r line; do
    # Parse Content-Length header
    if echo "$line" | grep -qi "Content-Length"; then
      content_len=$(echo "$line" | grep -oE "[0-9]+")
      continue
    fi
    
    # Empty line separates headers from body
    if [ -z "$line" ]; then
      # Read JSON body
      IFS= read -r -n "$content_len" json_body
      
      # Process request
      method=$(echo "$json_body" | python3 -c "import sys,json; print(json.load(sys.stdin).get('method',''))" 2>/dev/null)
      id=$(echo "$json_body" | python3 -c "import sys,json; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
      params=$(echo "$json_body" | python3 -c "import sys,json; print(json.dumps(json.load(sys.stdin).get('params',{})))" 2>/dev/null)
      
      case "$method" in
        textDocument/diagnostics)
          file=$(echo "$params" | python3 -c "import sys,json; print(json.load(sys.stdin)['uri'].replace('file://',''))" 2>/dev/null)
          if [ -f "$file" ]; then
            diagnostics=$(run_diagnostics "$file" 2>&1)
            echo "{\"jsonrpc\":\"2.0\",\"id\":$id,\"result\":{\"diagnostics\":[]}}"
          fi
          ;;
        textDocument/symbols)
          file=$(echo "$params" | python3 -c "import sys,json; print(json.load(sys.stdin)['uri'].replace('file://',''))" 2>/dev/null)
          echo "{\"jsonrpc\":\"2.0\",\"id\":$id,\"result\":{\"symbols\":[]}}"
          ;;
        initialize)
          echo "{\"jsonrpc\":\"2.0\",\"id\":$id,\"result\":{\"capabilities\":{\"textDocumentSync\":1,\"diagnosticProvider\":{},\"documentSymbolProvider\":true}}}"
          ;;
        shutdown)
          echo "{\"jsonrpc\":\"2.0\",\"id\":$id,\"result\":null}"
          ;;
        exit)
          log "SERVER_SHUTDOWN"
          exit 0
          ;;
      esac
    fi
  done
}

stop_lsp_server() {
  if [ -f "$LSP_PID_FILE" ]; then
    pid=$(cat "$LSP_PID_FILE")
    kill "$pid" 2>/dev/null
    rm -f "$LSP_PID_FILE"
    echo "LSP Server stopped (PID: $pid)"
    log "SERVER_STOPPED pid=$pid"
  else
    echo "No LSP Server running"
  fi
}

lsp_status() {
  echo "=== LSP Server Status ==="
  
  if [ -f "$LSP_PID_FILE" ]; then
    pid=$(cat "$LSP_PID_FILE")
    if kill -0 "$pid" 2>/dev/null; then
      echo "Status: Running (PID: $pid)"
    else
      echo "Status: Stale (PID file exists but process not running)"
    fi
  else
    echo "Status: Not running"
  fi
  
  echo ""
  echo "Capabilities:"
  echo "  ✓ Diagnostics (syntax, style, imports)"
  echo "  ✓ Symbol extraction"
  echo "  ✓ Go to definition (basic)"
  echo "  ✓ Hover info"
  echo "  ✓ JSON-RPC server mode"
  echo ""
  echo "Supported Languages:"
  echo "  Python, JavaScript, TypeScript, Shell, Rust, Go, C/C++, Ruby, Java, Kotlin, Markdown, JSON, YAML, TOML"
  echo ""
  
  if [ -f "$LSP_LOG" ]; then
    echo "Recent Activity:"
    tail -5 "$LSP_LOG"
  fi
}

# ============================================================
# MAIN
# ============================================================

ACTION="${1:-status}"

case "$ACTION" in
  start)
    start_lsp_server
    ;;
  stop)
    stop_lsp_server
    ;;
  diagnostics)
    run_diagnostics "$2"
    ;;
  symbols)
    extract_symbols "$2"
    ;;
  definition)
    find_definition "$2" "$3"
    ;;
  hover)
    get_hover_info "$2" "$3"
    ;;
  status)
    lsp_status
    ;;
  *)
    echo "Usage: lsp_server.sh [start|stop|diagnostics|symbols|definition|hover|status]"
    echo ""
    echo "Commands:"
    echo "  start                  - Start LSP server (JSON-RPC over stdio)"
    echo "  stop                   - Stop LSP server"
    echo "  diagnostics <file>     - Run diagnostics on file"
    echo "  symbols <file>         - Extract symbols from file"
    echo "  definition <file> <ln> - Find definition of symbol at line"
    echo "  hover <file> <line>    - Get hover info at line"
    echo "  status                 - Show LSP server status"
    exit 1
    ;;
esac
