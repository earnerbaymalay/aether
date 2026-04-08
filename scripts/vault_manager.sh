#!/data/data/com.termux/files/usr/bin/bash
# vault_manager.sh - AetherVault management CLI
# Usage: vault_manager.sh [stats|list|search|add|reindex|clean|browse]

VAULT_DIR="$HOME/aether/knowledge/aethervault"
LOADER="$HOME/aether/knowledge/knowledge_loader.py"
ACTION="${1:-stats}"

check_python() {
  if ! command -v python3 &>/dev/null; then
    echo "ERROR: python3 not installed"
    exit 1
  fi
}

case "$ACTION" in
  stats)
    check_python
    echo "=== AetherVault Statistics ==="
    echo ""
    
    # Use Python loader for detailed stats
    python3 "$LOADER" stats 2>/dev/null || {
      # Fallback: manual count
      echo "Total files: $(find "$VAULT_DIR" -name "*.md" | wc -l)"
      echo "Total size: $(du -sh "$VAULT_DIR" 2>/dev/null | cut -f1)"
      echo ""
      echo "By Category:"
      for dir in protocols guides reference troubleshooting templates memories; do
        count=$(find "$VAULT_DIR/$dir" -name "*.md" 2>/dev/null | wc -l)
        [ "$count" -gt 0 ] && echo "  $dir: $count"
      done
    }
    ;;
    
  list)
    check_python
    category="$2"
    if [ -n "$category" ]; then
      python3 "$LOADER" list "$category" 2>/dev/null
    else
      python3 "$LOADER" list 2>/dev/null
    fi
    ;;
    
  search)
    check_python
    if [ -z "$2" ]; then
      echo "Usage: vault_manager.sh search <query>"
      exit 1
    fi
    python3 "$LOADER" search "$2" 2>/dev/null
    ;;
    
  add)
    check_python
    if [ -z "$2" ] || [ -z "$3" ]; then
      echo "Usage: vault_manager.sh add <title> <category> [tags]"
      echo "Categories: protocol, guide, reference, troubleshooting, template, memory"
      echo ""
      echo "Content is read from stdin:"
      echo "  echo 'content' | vault_manager.sh add 'My Topic' memory"
      exit 1
    fi
    
    if [ -t 0 ]; then
      echo "Enter content (Ctrl+D to finish):"
    fi
    
    python3 "$LOADER" add "$2" "$3" "${4:-}" 2>/dev/null
    ;;
    
  reindex)
    check_python
    python3 "$LOADER" reindex 2>/dev/null
    ;;
    
  clean)
    echo "=== AetherVault Cleanup ==="
    echo ""
    
    # Find empty files
    empty=$(find "$VAULT_DIR" -name "*.md" -empty 2>/dev/null | wc -l)
    if [ "$empty" -gt 0 ]; then
      echo "Empty files: $empty"
      find "$VAULT_DIR" -name "*.md" -empty -delete 2>/dev/null
      echo "  ✓ Removed"
    else
      echo "  ✓ No empty files"
    fi
    
    # Find very small files (<50 bytes)
    small=$(find "$VAULT_DIR" -name "*.md" -size -50c 2>/dev/null | wc -l)
    if [ "$small" -gt 0 ]; then
      echo ""
      echo "Very small files (<50 bytes): $small"
      find "$VAULT_DIR" -name "*.md" -size -50c -ls 2>/dev/null
      echo "  Consider removing or merging these"
    fi
    
    echo ""
    echo "✓ Cleanup complete"
    ;;
    
  browse)
    echo "=== AetherVault Browser ==="
    echo ""
    
    current_dir="$VAULT_DIR"
    
    while true; do
      echo "📂 $(echo "$current_dir" | sed "s|$VAULT_DIR|aethervault|")"
      echo ""
      
      # List directories
      dirs=()
      files=()
      
      for item in "$current_dir"/*; do
        [ -e "$item" ] || continue
        if [ -d "$item" ]; then
          dirs+=("$(basename "$item")/")
        elif [[ "$item" == *.md ]]; then
          files+=("$(basename "$item")")
        fi
      done
      
      # Show directories
      if [ ${#dirs[@]} -gt 0 ]; then
        echo "Directories:"
        for d in "${dirs[@]}"; do
          count=$(find "$current_dir/$d" -name "*.md" 2>/dev/null | wc -l)
          echo "  📁 $d ($count files)"
        done
        echo ""
      fi
      
      # Show files
      if [ ${#files[@]} -gt 0 ]; then
        echo "Files:"
        for f in "${files[@]}"; do
          size=$(wc -c < "$current_dir/$f")
          echo "  📄 $f (${size}b)"
        done
      fi
      
      echo ""
      echo "Navigate: cd <dir> | Back: cd .. | Read: cat <file> | Quit: q"
      read -p "> " cmd
      
      case "$cmd" in
        q|quit) break ;;
        cd\ ..)
          if [ "$current_dir" != "$VAULT_DIR" ]; then
            current_dir=$(dirname "$current_dir")
          fi
          ;;
        cd\ *)
          dir=$(echo "$cmd" | cut -d' ' -f2 | tr -d '/')
          if [ -d "$current_dir/$dir" ]; then
            current_dir="$current_dir/$dir"
          else
            echo "Directory not found"
          fi
          ;;
        cat\ *)
          file=$(echo "$cmd" | cut -d' ' -f2-)
          if [ -f "$current_dir/$file" ]; then
            echo ""
            head -50 "$current_dir/$file"
            echo ""
            echo "(Showing first 50 lines of $(wc -l < "$current_dir/$file") total)"
            read -p "Press Enter to continue..."
          fi
          ;;
        *)
          echo "Unknown command"
          ;;
      esac
      
      clear
    done
    ;;
    
  *)
    echo "AetherVault — Knowledge Vault Manager"
    echo ""
    echo "Usage: vault_manager.sh [stats|list|search|add|reindex|clean|browse]"
    echo ""
    echo "Commands:"
    echo "  stats              - Show vault statistics"
    echo "  list [category]    - List entries (optionally by category)"
    echo "  search <query>     - Search by relevance score"
    echo "  add <t> <c> [tags] - Add entry (content from stdin)"
    echo "  reindex            - Rebuild vault index"
    echo "  clean              - Remove empty/trivial files"
    echo "  browse             - Interactive vault browser"
    echo ""
    echo "Categories: protocol, guide, reference, troubleshooting, template, memory"
    exit 1
    ;;
esac
