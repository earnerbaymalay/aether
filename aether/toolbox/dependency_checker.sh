#!/data/data/com.termux/files/usr/bin/bash
# dependency_checker.sh - Check project dependencies and flag missing/outdated packages
# Usage: dependency_checker.sh [project_path]

PROJECT_PATH="${1:-.}"
ISSUES_FOUND=0

echo "=== Dependency Health Check ==="
echo "Project: $PROJECT_PATH"
echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Check if directory exists
if [ ! -d "$PROJECT_PATH" ]; then
  echo "ERROR: Directory not found: $PROJECT_PATH"
  exit 1
fi

cd "$PROJECT_PATH" || exit 1

# Python dependencies
if [ -f "requirements.txt" ]; then
  echo "--- Python Dependencies (requirements.txt) ---"
  while IFS= read -r line; do
    # Skip comments and empty lines
    [[ "$line" =~ ^#.*$ ]] && continue
    [[ -z "$line" ]] && continue
    
    # Extract package name (remove version specifiers)
    pkg=$(echo "$line" | sed -E 's/[><=!~].*//')
    
    # Check if installed
    if ! pip show "$pkg" &>/dev/null; then
      echo "  ❌ MISSING: $pkg"
      ISSUES_FOUND=$((ISSUES_FOUND + 1))
    else
      echo "  ✓ $pkg"
    fi
  done < requirements.txt
  echo ""
fi

# Node.js dependencies
if [ -f "package.json" ]; then
  echo "--- Node.js Dependencies (package.json) ---"
  
  # Check if node is available
  if command -v node &>/dev/null; then
    # Check dependencies
    for pkg in $(python3 -c "import json; data=json.load(open('package.json')); [print(d) for d in list(data.get('dependencies',{}).keys()) + list(data.get('devDependencies',{}).keys())]" 2>/dev/null); do
      if [ -d "node_modules/$pkg" ]; then
        echo "  ✓ $pkg"
      else
        echo "  ❌ MISSING: $pkg"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
      fi
    done
  else
    echo "  ⚠ Node.js not installed"
  fi
  echo ""
fi

# Termux packages
echo "--- Termux System Packages ---"
CRITICAL_PACKS="git curl wget build-essential cmake python"
for pkg in $CRITICAL_PACKS; do
  if dpkg -l "$pkg" &>/dev/null; then
    echo "  ✓ $pkg"
  else
    echo "  ⚠ NOT INSTALLED: $pkg (may not be needed)"
  fi
done
echo ""

# Check for common tools
echo "--- Tool Availability ---"
TOOLS="gum nmap figlet llama-cli llama-server termux-battery-status"
for tool in $TOOLS; do
  if command -v "$tool" &>/dev/null; then
    echo "  ✓ $tool: $(which $tool)"
  else
    echo "  ❌ MISSING: $tool"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
  fi
done
echo ""

# llama.cpp version check
if command -v llama-cli &>/dev/null; then
  echo "--- llama.cpp Status ---"
  echo "  llama-cli: $(llama-cli --version 2>&1 | head -1)"
  echo ""
fi

# Summary
echo "=== Summary ==="
if [ "$ISSUES_FOUND" -gt 0 ]; then
  echo "⚠ Found $ISSUES_FOUND issue(s) - review above for details"
else
  echo "✓ All checked dependencies are satisfied"
fi
