#!/bin/bash
echo "🚀 Starting Nexus AI Workspace Setup..."

# 1. System Dependencies
pkg update && pkg upgrade -y
pkg install python nodejs-lts git sqlcipher termux-api -y
pip install flask requests

# 2. Directory Structure
mkdir -p ~/termux-ai-workspace/vault/db
mkdir -p ~/termux-ai-workspace/vault/keys
mkdir -p ~/termux-ai-workspace/scripts
mkdir -p ~/termux-ai-workspace/backups

# 3. Environment Checks
if ! command -v ollama &> /dev/null; then
    echo "⚠️  Ollama not found. Please install it separately via: pkg install ollama"
fi

echo "✅ Setup Complete. Run 'python scripts/nexus_engine.py' to start the backend."
