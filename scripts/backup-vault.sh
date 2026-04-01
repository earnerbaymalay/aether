#!/bin/bash
# Backup Configuration
VAULT_DIR="$HOME/termux-ai-workspace/vault"
BACKUP_DIR="$HOME/termux-ai-workspace/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="nexus_backup_$TIMESTAMP.tar.gz"

mkdir -p "$BACKUP_DIR"

echo "🔐 Securing Nexus Vault..."
tar -czf "$BACKUP_DIR/$BACKUP_FILE" -C "$VAULT_DIR" .

# Keep only the last 5 backups to save space on the XR20
ls -tp "$BACKUP_DIR"/nexus_backup_*.tar.gz | grep -v '/$' | tail -n +6 | xargs -I {} rm -- {}

echo "✅ Backup complete: $BACKUP_FILE"
echo "📂 Saved to: $BACKUP_DIR"
