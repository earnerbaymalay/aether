#!/usr/bin/env bash
# obsidian_list_notes.sh
# Lists notes in the Obsidian vault.

VAULT_PATH="${OBSIDIAN_VAULT_PATH:-$HOME/storage/shared/Documents/Obsidian}"

if [ ! -d "$VAULT_PATH" ]; then
    echo "Error: Obsidian vault not found at $VAULT_PATH. Set OBSIDIAN_VAULT_PATH."
    exit 1
fi

find "$VAULT_PATH" -name "*.md" -type f | sed "s|$VAULT_PATH/||" | head -n 50
