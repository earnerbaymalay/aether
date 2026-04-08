#!/usr/bin/env python3
"""
�� Aether-AI Librarian // V 1.0
Maintenance script for the Context7 Knowledge Vault.
Uses the Logic tier (DeepSeek) to audit and organize knowledge.
"""

import os, sys, json, subprocess
from pathlib import Path

DIR = Path.home() / "aether"
CONTEXT7_DIR = DIR / "knowledge" / "aethervault"
LLAMA_BIN = Path.home() / "llama.cpp" / "build" / "bin" / "llama-cli"
MODEL_PATH = DIR / "models" / "deepseek-r1-1.5b.gguf"

def get_vault_files():
    return list(CONTEXT7_DIR.glob("**/*.md"))

def audit_vault():
    files = get_vault_files()
    if not files:
        print("Vault is empty. Nothing to audit.")
        return

    print(f"Librarian auditing {len(files)} files...")
    
    file_list = "\n".join([str(f.relative_to(CONTEXT7_DIR)) for f in files])
    
    audit_prompt = f"""You are the Aether Librarian. Your job is to organize the Context7 Knowledge Vault.
Here are the current files:
{file_list}

Rules:
1. Identify any files that look like duplicates or junk.
2. Suggest a cleaner directory structure if needed.
3. Provide a plan for merging or deleting low-value content.

Response format: JSON list of actions [{{ "action": "delete/move/merge", "path": "...", "reason": "..." }}]
"""

    # Use llama-cli to get the audit plan
    cmd = [
        str(LLAMA_BIN), "-m", str(MODEL_PATH),
        "-p", f"System: Librarian Protocol Active. Output JSON only.\nUser: {audit_prompt}\nAI: ",
        "-t", "6", "--mmap", "--quiet", "--log-disable", "-n", "512"
    ]

    try:
        result = subprocess.run(cmd, capture_output=True, text=True)
        # In a real scenario, we'd parse the JSON and execute. 
        # For now, we'll output the plan for the user to review.
        print("\n--- Librarian Audit Plan ---")
        print(result.stdout.strip())
        print("----------------------------\n")
    except Exception as e:
        print(f"Audit Error: {e}")

if __name__ == "__main__":
    if not MODEL_PATH.exists():
        print(f"Error: Logic model (DeepSeek) missing at {MODEL_PATH}")
        sys.exit(1)
    audit_vault()
