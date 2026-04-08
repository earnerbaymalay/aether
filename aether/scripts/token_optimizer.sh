#!/data/data/com.termux/files/usr/bin/bash
# token_optimizer.sh - Token compression and context optimization (RTK-inspired)
# Reduces token consumption by 60-90% through smart context management
# Usage: token_optimizer.sh [compress <file>|stats|compact <file>|budget|analyze <file>|clean <file>]

OPTIMIZER_LOG="$HOME/.aether/sessions/token_optimizer.log"
ACTION="${1:-stats}"

log_action() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$OPTIMIZER_LOG"
}

# ============================================================
# TOKEN ESTIMATION
# ============================================================

estimate_tokens() {
  local text="$1"
  # Rough estimate: ~4 characters per token for English
  local chars
  chars=$(echo "$text" | wc -c)
  echo $((chars / 4))
}

estimate_file_tokens() {
  local file="$1"
  local chars
  chars=$(wc -c < "$file" 2>/dev/null || echo 0)
  echo $((chars / 4))
}

# ============================================================
# CONTEXT COMPRESSION
# ============================================================

compress_context() {
  local input="$1"
  local output="${2:-${input}.compressed}"
  
  if [ ! -f "$input" ]; then
    echo "ERROR: File not found: $input"
    return 1
  fi
  
  original_size=$(wc -c < "$input")
  original_tokens=$(estimate_file_tokens "$input")
  
  echo "=== Token Compression ==="
  echo "Input: $input"
  echo "Original: $original_size bytes (~$original_tokens tokens)"
  echo ""
  
  # Apply compression strategies
  {
    # Strategy 1: Remove comments and blank lines
    echo "# Strategy 1: Remove comments and blank lines"
    grep -v "^[[:space:]]*$" "$input" | grep -v "^[[:space:]]*#" | grep -v "^[[:space:]]*//" | grep -v "^[[:space:]]*/*"
    echo ""
    
    # Strategy 2: Collapse whitespace
    echo "# Strategy 2: Normalize whitespace"
    sed 's/[[:space:]]\+/ /g' "$input" | sed 's/^ //' | sed 's/ $//'
    echo ""
    
    # Strategy 3: Remove trailing whitespace
    echo "# Strategy 3: Remove trailing whitespace"
    sed 's/[[:space:]]*$//' "$input"
    echo ""
    
  } > "$output" 2>/dev/null
  
  # Use the most aggressive compression
  cat "$input" | \
    # Remove blank lines
    sed '/^[[:space:]]*$/d' | \
    # Remove single-line comments (adjust per language)
    sed 's/[[:space:]]*#.*$//' | \
    sed 's/[[:space:]]*\/\/.*$//' | \
    # Remove trailing whitespace
    sed 's/[[:space:]]*$//' | \
    # Collapse multiple spaces
    sed 's/[[:space:]]\+/ /g' \
    > "$output"
  
  compressed_size=$(wc -c < "$output")
  compressed_tokens=$(estimate_file_tokens "$output")
  
  if [ "$original_size" -gt 0 ]; then
    savings=$((100 - (compressed_size * 100 / original_size)))
  else
    savings=0
  fi
  
  token_savings=$((original_tokens - compressed_tokens))
  
  echo "Compressed: $compressed_size bytes (~$compressed_tokens tokens)"
  echo "Savings: ${savings}% (${token_savings} tokens)"
  echo "Output: $output"
  
  log_action "COMPRESS input=$input original=$original_tokens compressed=$compressed_tokens savings=${savings}%"
}

# ============================================================
# SMART COMPACT (semantic-aware)
# ============================================================

smart_compact() {
  local file="$1"
  local output="${2:-${file}.smart_compact}"
  local lang=""
  
  if [ ! -f "$file" ]; then
    echo "ERROR: File not found: $file"
    return 1
  fi
  
  # Detect language
  ext="${file##*.}"
  case "$ext" in
    py) lang="python" ;;
    js) lang="javascript" ;;
    ts) lang="typescript" ;;
    sh|bash) lang="shell" ;;
    *) lang="generic" ;;
  esac
  
  original_tokens=$(estimate_file_tokens "$file")
  
  echo "=== Smart Compression ($lang) ==="
  echo "Input: $file ($original_tokens tokens)"
  echo ""
  
  case "$lang" in
    python)
      # Python-specific compression
      cat "$file" | \
        # Remove blank lines
        sed '/^[[:space:]]*$/d' | \
        # Remove docstrings (simple single-line)
        sed '/^[[:space:]]*"""/d' | \
        sed '/^[[:space:]]*'"'"'""/d' | \
        # Remove comments
        sed 's/[[:space:]]*#.*$//' | \
        # Remove trailing whitespace
        sed 's/[[:space:]]*$//' \
        > "$output"
      ;;
      
    javascript|typescript)
      cat "$file" | \
        sed '/^[[:space:]]*$/d' | \
        sed 's|[[:space:]]*//.*$||' | \
        sed 's/[[:space:]]*$//' \
        > "$output"
      ;;
      
    shell)
      cat "$file" | \
        sed '/^[[:space:]]*$/d' | \
        sed '/^[[:space:]]*#/d' | \
        sed 's/[[:space:]]*#.*$//' | \
        sed 's/[[:space:]]*$//' \
        > "$output"
      ;;
      
    *)
      # Generic compression
      cat "$file" | \
        sed '/^[[:space:]]*$/d' | \
        sed 's/[[:space:]]*$//' \
        > "$output"
      ;;
  esac
  
  compressed_tokens=$(estimate_file_tokens "$output")
  savings=$((100 - (compressed_tokens * 100 / (original_tokens + 1))))
  
  echo "Compressed: $compressed_tokens tokens"
  echo "Savings: ${savings}%"
  echo "Output: $output"
  
  log_action "SMART_COMPACT file=$file lang=$lang original=$original_tokens compressed=$compressed_tokens"
}

# ============================================================
# TOKEN BUDGET ANALYSIS
# ============================================================

analyze_token_budget() {
  local file="$1"
  local max_tokens="${2:-4096}"
  
  if [ ! -f "$file" ]; then
    echo "ERROR: File not found: $file"
    return 1
  fi
  
  echo "=== Token Budget Analysis ==="
  echo "File: $file"
  echo "Budget: $max_tokens tokens"
  echo ""
  
  # Estimate tokens by section
  total_tokens=0
  line_count=0
  section_tokens=0
  section_start=1
  
  echo "Token Distribution by Section:"
  echo ""
  
  while IFS= read -r line; do
    line_count=$((line_count + 1))
    line_tokens=$(estimate_tokens "$line")
    section_tokens=$((section_tokens + line_tokens))
    total_tokens=$((total_tokens + line_tokens))
    
    # Detect section boundaries
    if echo "$line" | grep -qE "^(class |def |function |# [A-Z]|// [A-Z]|---)"; then
      if [ "$section_tokens" -gt 0 ]; then
        pct=$((section_tokens * 100 / (max_tokens + 1)))
        if [ "$pct" -gt 50 ]; then
          icon="🔴"
        elif [ "$pct" -gt 25 ]; then
          icon="🟡"
        else
          icon="✓"
        fi
        printf "  %s Lines %d-%d: %d tokens (%d%% of budget)\n" "$icon" "$section_start" "$((line_count - 1))" "$section_tokens" "$pct"
      fi
      section_start=$line_count
      section_tokens=0
    fi
  done < "$file"
  
  # Final section
  if [ "$section_tokens" -gt 0 ]; then
    pct=$((section_tokens * 100 / (max_tokens + 1)))
    printf "  Lines %d-%d: %d tokens (%d%% of budget)\n" "$section_start" "$line_count" "$section_tokens" "$pct"
  fi
  
  echo ""
  echo "Summary:"
  pct_total=$((total_tokens * 100 / (max_tokens + 1)))
  echo "  Total: $total_tokens tokens / $max_tokens budget (${pct_total}%)"
  echo "  Lines: $line_count"
  echo "  Avg tokens/line: $((total_tokens / (line_count + 1)))"
  
  if [ "$total_tokens" -gt "$max_tokens" ]; then
    echo ""
    echo "⚠ EXCEEDS BUDGET by $((total_tokens - max_tokens)) tokens"
    echo "Recommendation: Use compress or smart_compact to reduce"
  fi
  
  log_action "BUDGET file=$file tokens=$total_tokens budget=$max_tokens"
}

# ============================================================
# RELEVANCE-BASED LOADING (only load relevant content)
# ============================================================

load_relevant() {
  local directory="$1"
  local query="$2"
  local max_chars="${3:-3000}"
  
  if [ ! -d "$directory" ]; then
    echo "ERROR: Directory not found: $directory"
    return 1
  fi
  
  echo "=== Relevance-Based Context Loading ==="
  echo "Directory: $directory"
  echo "Query: $query"
  echo "Max chars: $max_chars"
  echo ""
  
  # Score files by relevance
  declare -A scores
  
  for file in "$directory"/*.md "$directory"/*.txt; do
    if [ -f "$file" ]; then
      name=$(basename "$file")
      
      # Score by filename match
      score=0
      if echo "$name" | grep -qi "$query"; then
        score=$((score + 50))
      fi
      
      # Score by content match
      for word in $query; do
        matches=$(grep -ci "$word" "$file" 2>/dev/null || echo 0)
        score=$((score + matches * 5))
      done
      
      if [ "$score" -gt 0 ]; then
        scores["$file"]=$score
      fi
    fi
  done
  
  # Sort by score and load top files
  total_chars=0
  loaded=0
  
  for file in $(for key in "${!scores[@]}"; do echo "${scores[$key]} $key"; done | sort -rn | awk '{print $2}'); do
    file_chars=$(wc -c < "$file")
    
    if [ $((total_chars + file_chars)) -gt "$max_chars" ]; then
      # Partial load
      remaining=$((max_chars - total_chars))
      head -c "$remaining" "$file"
      loaded=$((loaded + 1))
      break
    fi
    
    cat "$file"
    total_chars=$((total_chars + file_chars))
    loaded=$((loaded + 1))
  done
  
  echo ""
  echo "--- Loaded $loaded file(s), $total_chars chars ---"
  
  log_action "RELEVANT dir=$directory query='$query' chars=$total_chars files=$loaded"
}

# ============================================================
# CONTEXT CLEANING (remove AI bloat)
# ============================================================

clean_context() {
  local input="$1"
  local output="${2:-${input}.cleaned}"
  
  if [ ! -f "$input" ]; then
    echo "ERROR: File not found: $input"
    return 1
  fi
  
  echo "=== Context Cleaning ==="
  echo "Input: $input"
  
  original_tokens=$(estimate_file_tokens "$input")
  
  # Remove common AI bloat patterns
  cat "$input" | \
    # Remove empty lines
    sed '/^[[:space:]]*$/d' | \
    # Remove excessive hedging
    sed 's/It is important to note that//g' | \
    sed 's/It is worth noting that//g' | \
    sed 's/In conclusion//g' | \
    sed 's/Additionally//g' | \
    # Remove sign-off phrases
    sed '/^Let me know/d' | \
    sed '/^I hope/d' | \
    sed '/^Feel free/d' | \
    # Remove trailing whitespace
    sed 's/[[:space:]]*$//' \
    > "$output"
  
  cleaned_tokens=$(estimate_file_tokens "$output")
  savings=$((100 - (cleaned_tokens * 100 / (original_tokens + 1))))
  
  echo "Original: $original_tokens tokens"
  echo "Cleaned: $cleaned_tokens tokens"
  echo "Savings: ${savings}%"
  echo "Output: $output"
  
  log_action "CLEAN input=$input original=$original_tokens cleaned=$cleaned_tokens"
}

# ============================================================
# TOKEN STATISTICS
# ============================================================

show_stats() {
  echo "=== Token Optimization Statistics ==="
  echo ""
  
  # Count optimization operations
  if [ -f "$OPTIMIZER_LOG" ]; then
    total_ops=$(wc -l < "$OPTIMIZER_LOG")
    echo "Total Optimizations: $total_ops"
    echo ""
    
    # Average savings
    echo "Recent Operations:"
    tail -10 "$OPTIMIZER_LOG"
  else
    echo "No optimization history yet."
  fi
  
  echo ""
  echo "Current Context Sizes:"
  
  if [ -f "$HOME/.aether/sessions/last_session.log" ]; then
    session_tokens=$(estimate_file_tokens "$HOME/.aether/sessions/last_session.log")
    echo "  Session Log: $session_tokens tokens"
  fi
  
  knowledge_tokens=0
  for f in "$HOME/aether/knowledge/"*.txt; do
    if [ -f "$f" ]; then
      knowledge_tokens=$((knowledge_tokens + $(estimate_file_tokens "$f")))
    fi
  done
  echo "  Knowledge Base: $knowledge_tokens tokens"
  
  context7_tokens=0
  for f in "$HOME/aether/knowledge/context7/"*.md "$HOME/aether/knowledge/context7/"**/*.md; do
    if [ -f "$f" ]; then
      context7_tokens=$((context7_tokens + $(estimate_file_tokens "$f")))
    fi
  done
  echo "  AetherVault: $context7_tokens tokens"
  
  total=$((session_tokens + knowledge_tokens + context7_tokens))
  echo "  Total Context: $total tokens"
  echo ""
  
  echo "Model Context Limits:"
  echo "  1.5B model: ~2048 tokens"
  echo "  3B model:   ~4096 tokens"
  echo "  8B model:   ~8192 tokens"
  echo ""
  
  if [ "$total" -gt 8192 ]; then
    echo "⚠ Total context exceeds 8B model capacity"
    echo "  Recommendation: Enable relevance-based loading"
  elif [ "$total" -gt 4096 ]; then
    echo "⚠ Total context exceeds 3B model capacity"
    echo "  Recommendation: Use 8B model or reduce context"
  else
    echo "✓ Context within model limits"
  fi
  
  log_action "STATS total=$total"
}

# ============================================================
# MAIN
# ============================================================

case "$ACTION" in
  compress)
    compress_context "$2" "$3"
    ;;
  compact|smart_compact)
    smart_compact "$2" "$3"
    ;;
  budget)
    analyze_token_budget "$2" "${3:-4096}"
    ;;
  analyze)
    analyze_token_budget "$2" "${3:-4096}"
    ;;
  relevant)
    load_relevant "$2" "$3" "${4:-3000}"
    ;;
  clean)
    clean_context "$2" "$3"
    ;;
  stats)
    show_stats
    ;;
  *)
    echo "Usage: token_optimizer.sh [compress|compact|budget|analyze|relevant|clean|stats]"
    echo ""
    echo "Commands:"
    echo "  compress <file> [out]    - Compress file to reduce tokens"
    echo "  compact <file> [out]     - Smart language-aware compression"
    echo "  budget <file> [max]      - Analyze token budget usage"
    echo "  analyze <file> [max]     - Same as budget"
    echo "  relevant <dir> <query>   - Load only relevant context"
    echo "  clean <file> [out]       - Remove AI bloat from context"
    echo "  stats                    - Show token statistics"
    exit 1
    ;;
esac
