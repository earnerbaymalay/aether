#!/usr/bin/env bash
# obsidian_read_note.sh
# Reads the content of a specific note.

VAULT_PATH="${OBSIDIAN_VAULT_PATH:-$HOME/storage/shared/Documents/Obsidian}"
NOTE_PATH="$1"

if [ -z "$NOTE_PATH" ]; then
    echo "Error: No note path provided."
    exit 1
fi

FULL_PATH="$VAULT_PATH/$NOTE_PATH"
[ ! -f "$FULL_PATH" ] && FULL_PATH="$VAULT_PATH/$NOTE_PATH.md"

if [ -f "$FULL_PATH" ]; then
    cat "$FULL_PATH"
else
    echo "Error: Note not found at $FULL_PATH"
    exit 1
fi
