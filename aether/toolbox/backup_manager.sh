#!/data/data/com.termux/files/usr/bin/bash
# backup_manager.sh - Comprehensive backup and restore for Aether and related projects
# Usage: backup_manager.sh [create|list|restore <backup_name>|cleanup|schedule]

BACKUP_DIR="$HOME/.aether/backups"
AETHER_DIR="$HOME/aether"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ACTION="${1:-list}"

# Projects to include in backup
PROJECTS=(
  "aether:Aether Core"
  "edge-sentinel:Edge Sentinel"
  "aether-apple:Aether Apple"
  "aether-desktop:Aether Desktop"
  "gloam:Gloam Journal"
  "e2eecc:E2EECC"
)

# Directories to always backup
CRITICAL_DIRS=(
  "$HOME/.aether/sessions"
  "$HOME/.aether/config"
  "$HOME/.aether/models"
  "$HOME/.audit_logs"
)

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

case "$ACTION" in
  create)
    BACKUP_NAME="aether_backup_${TIMESTAMP}"
    BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"
    mkdir -p "$BACKUP_PATH"
    
    echo "=== Creating Backup: $BACKUP_NAME ==="
    echo ""
    
    # Backup Aether core
    echo "--- Backing up Aether Core ---"
    if [ -d "$AETHER_DIR" ]; then
      tar czf "$BACKUP_PATH/aether_core.tar.gz" \
        -C "$HOME" \
        --exclude='aether/.git' \
        --exclude='aether/legacy' \
        --exclude='aether/marketing' \
        aether/ 2>/dev/null
      SIZE=$(du -h "$BACKUP_PATH/aether_core.tar.gz" | cut -f1)
      echo "  ✓ Aether core backed up ($SIZE)"
    fi
    
    # Backup critical directories
    echo "--- Backing up Critical Data ---"
    for dir in "${CRITICAL_DIRS[@]}"; do
      if [ -d "$dir" ]; then
        dirname=$(basename "$dir")
        tar czf "$BACKUP_PATH/${dirname}.tar.gz" -C "$(dirname "$dir")" "$dirname" 2>/dev/null
        SIZE=$(du -h "$BACKUP_PATH/${dirname}.tar.gz" | cut -f1)
        echo "  ✓ $dirname ($SIZE)"
      fi
    done
    
    # Backup other projects (optional, large)
    echo "--- Backing up Related Projects ---"
    for project in "${PROJECTS[@]}"; do
      proj_name=$(echo "$project" | cut -d':' -f1)
      proj_label=$(echo "$project" | cut -d':' -f2)
      
      if [ -d "$HOME/$proj_name" ]; then
        tar czf "$BACKUP_PATH/${proj_name}.tar.gz" \
          -C "$HOME" \
          --exclude="${proj_name}/.git" \
          --exclude="${proj_name}/node_modules" \
          "${proj_name}/" 2>/dev/null
        SIZE=$(du -h "$BACKUP_PATH/${proj_name}.tar.gz" | cut -f1)
        echo "  ✓ $proj_label ($SIZE)"
      fi
    done
    
    # Create manifest
    echo "--- Creating Backup Manifest ---"
    cat > "$BACKUP_PATH/manifest.txt" << EOF
Backup: $BACKUP_NAME
Created: $(date)
Hostname: $(hostname)
Device: $(getprop ro.product.model 2>/dev/null || echo "unknown")

Contents:
$(ls -lh "$BACKUP_PATH/" | tail -n +2)

Total Size: $(du -sh "$BACKUP_PATH" | cut -f1)
EOF
    
    TOTAL_SIZE=$(du -sh "$BACKUP_PATH" | cut -f1)
    echo ""
    echo "=== Backup Complete ==="
    echo "Location: $BACKUP_PATH"
    echo "Total Size: $TOTAL_SIZE"
    ;;
    
  list)
    echo "=== Available Backups ==="
    echo ""
    
    if [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
      echo "No backups found."
      echo "Run: backup_manager.sh create"
      exit 0
    fi
    
    printf "%-30s %-12s %-30s\n" "BACKUP NAME" "SIZE" "CREATED"
    printf "%-30s %-12s %-30s\n" "-----------" "----" "-------"
    
    for backup in "$BACKUP_DIR"/*/; do
      if [ -d "$backup" ]; then
        name=$(basename "$backup")
        size=$(du -sh "$backup" | cut -f1)
        created=$(stat -c %y "$backup" 2>/dev/null | cut -d'.' -f1 || echo "unknown")
        printf "%-30s %-12s %-30s\n" "$name" "$size" "$created"
      fi
    done
    
    echo ""
    echo "Total Backup Storage: $(du -sh "$BACKUP_DIR" | cut -f1)"
    ;;
    
  restore)
    BACKUP_NAME="$2"
    
    if [ -z "$BACKUP_NAME" ]; then
      echo "Usage: backup_manager.sh restore <backup_name>"
      echo "Run 'backup_manager.sh list' to see available backups"
      exit 1
    fi
    
    BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"
    
    if [ ! -d "$BACKUP_PATH" ]; then
      echo "ERROR: Backup not found: $BACKUP_NAME"
      exit 1
    fi
    
    echo "=== Restoring Backup: $BACKUP_NAME ==="
    echo "WARNING: This will overwrite existing files."
    echo ""
    
    # Show what will be restored
    echo "Contents to restore:"
    cat "$BACKUP_PATH/manifest.txt"
    echo ""
    
    # Restore Aether core
    if [ -f "$BACKUP_PATH/aether_core.tar.gz" ]; then
      echo "--- Restoring Aether Core ---"
      tar xzf "$BACKUP_PATH/aether_core.tar.gz" -C "$HOME" 2>/dev/null
      echo "  ✓ Aether core restored"
    fi
    
    # Restore critical directories
    echo "--- Restoring Critical Data ---"
    for dir in "${CRITICAL_DIRS[@]}"; do
      dirname=$(basename "$dir")
      if [ -f "$BACKUP_PATH/${dirname}.tar.gz" ]; then
        mkdir -p "$dir"
        tar xzf "$BACKUP_PATH/${dirname}.tar.gz" -C "$(dirname "$dir")" 2>/dev/null
        echo "  ✓ $dirname restored"
      fi
    done
    
    echo ""
    echo "=== Restore Complete ==="
    echo "Restart Aether to apply changes."
    ;;
    
  cleanup)
    echo "=== Backup Cleanup ==="
    echo ""
    
    # Show current usage
    TOTAL_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
    BACKUP_COUNT=$(ls -d "$BACKUP_DIR"/*/ 2>/dev/null | wc -l)
    
    echo "Current backups: $BACKUP_COUNT"
    echo "Total size: $TOTAL_SIZE"
    echo ""
    
    # Keep only the 3 most recent backups
    echo "Keeping 3 most recent backups..."
    ls -dt "$BACKUP_DIR"/*/ 2>/dev/null | tail -n +4 | while read -r old_backup; do
      echo "  Removing: $(basename "$old_backup")"
      rm -rf "$old_backup"
    done
    
    NEW_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
    echo ""
    echo "✓ Cleanup complete. New size: $NEW_SIZE"
    ;;
    
  schedule)
    echo "=== Backup Scheduling ==="
    echo ""
    echo "To schedule automatic backups, add to crontab:"
    echo ""
    echo "# Daily backup at 3 AM"
    echo "0 3 * * * $HOME/aether/toolbox/backup_manager.sh create"
    echo ""
    echo "# Weekly cleanup on Sunday at 4 AM"
    echo "0 4 * * 0 $HOME/aether/toolbox/backup_manager.sh cleanup"
    echo ""
    echo "Or use the background_sentinel.sh for passive monitoring."
    ;;
    
  *)
    echo "Usage: backup_manager.sh [create|list|restore|cleanup|schedule]"
    echo ""
    echo "Commands:"
    echo "  create            - Create a new backup"
    echo "  list              - List available backups"
    echo "  restore <name>    - Restore from a backup"
    echo "  cleanup           - Remove old backups (keep 3 most recent)"
    echo "  schedule          - Show cron scheduling examples"
    exit 1
    ;;
esac
