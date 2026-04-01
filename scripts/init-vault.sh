#!/bin/bash
DB_PATH="$HOME/termux-ai-workspace/vault/db/nexus.db"
read -s -p "BingBong216150!" VAULT_PASS
echo ""
sqlcipher "$DB_PATH" <<SQL
PRAGMA key = '$VAULT_PASS';
CREATE TABLE IF NOT EXISTS ai_memory (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    model TEXT,
    prompt TEXT,
    response TEXT
);
.exit
SQL

echo "Vault initialized and encrypted successfully."
