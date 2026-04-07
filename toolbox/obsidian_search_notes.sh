#!/usr/bin/env bash
# obsidian_search_notes.sh
# Searches for a keyword across all notes in the vault.

VAULT_PATH="${OBSIDIAN_VAULT_PATH:-$HOME/storage/shared/Documents/Obsidian}"
QUERY="$1"

if [ -z "$QUERY" ]; then
    echo "Error: No search query provided."
    exit 1
fi

grep -rli "$QUERY" "$VAULT_PATH" --include="*.md" | sed "s|$VAULT_PATH/||" | head -n 20
