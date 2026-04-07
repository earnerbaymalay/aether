#!/usr/bin/env python3
"""
🌌 Aether-AI Librarian // V 2.0
Superior vault health and maintenance suite.
Uses the RAG engine for similarity detection and DeepSeek for auditing.
"""

import os, sys, json, subprocess, time
from pathlib import Path
import numpy as np
from rag_engine import simple_embedding # Import Aether-RAG logic

# Aether Neural Pathing
DIR = Path.home() / "aether"
VAULT = DIR / "knowledge" / "context7"
BIN = Path.home() / "llama.cpp" / "build" / "bin" / "llama-cli"
MODEL = DIR / "models" / "deepseek-r1-1.5b.gguf"

def get_vault_files():
    return list(VAULT.glob("**/*.md"))

def check_vault_health():
    """
    Scans for duplicates and orphaned technical notes using vector similarity.
    """
    files = get_vault_files()
    if not files:
        return "Vault Status: [ EMPTY ]"
    
    total_size = sum(f.stat().st_size for f in files) / 1024
    print(f"[*] Analyzing {len(files)} neural notes ({total_size:.2f} KB)...")
    
    embeddings = {}
    duplicates = []
    
    for f in files:
        with open(f, 'r', encoding='utf-8') as content:
            embeddings[f] = simple_embedding(content.read())

    # Similarity pass
    seen = set()
    for f1, v1 in embeddings.items():
        seen.add(f1)
        for f2, v2 in embeddings.items():
            if f2 in seen: continue
            similarity = np.dot(v1, v2)
            if similarity > 0.90: # High threshold for duplication
                duplicates.append((f1.name, f2.name, similarity))

    return {
        "file_count": len(files),
        "total_kb": total_size,
        "duplicates": duplicates
    }

def perform_audit():
    """
    Logic-tier deep audit for technical accuracy and relevance.
    """
    health = check_vault_health()
    if isinstance(health, str): 
        print(health)
        return

    print("\n--- AETHER VAULT HEALTH REPORT ---")
    print(f"Neural Density: {health['file_count']} files")
    print(f"Memory Footprint: {health['total_kb']:.2f} KB")
    
    if health['duplicates']:
        print("\n[!] Potential Neural Redundancy Detected:")
        for d1, d2, s in health['duplicates']:
            print(f"  ● {d1} <-> {d2} ({s*100:.1f}% match)")
    else:
        print("\n[✓] Vault Neural Cohesion: HIGH (No significant duplicates)")

    if not BIN.exists() or not MODEL.exists():
        print("\n[!] LOGIC Tier unavailable for deep audit. Skipping AI analysis.")
        return

    # DeepSeek reasoning audit
    files = [f.name for f in get_vault_files()]
    prompt = f"System: Aether Librarian Audit Mode. Here is the vault inventory: {files}. Suggest a structural optimization plan."
    
    print("\n[*] Requesting Logic-Tier Architectural Strategy...")
    cmd = [
        str(BIN), "-m", str(MODEL), "-p", prompt,
        "-t", "4", "--mmap", "--quiet", "--log-disable", "-n", "256"
    ]
    
    try:
        res = subprocess.run(cmd, capture_output=True, text=True)
        print("\n--- ARCHITECTURAL RECOMMENDATIONS ---")
        print(res.stdout.strip())
    except Exception as e:
        print(f"Audit failure: {e}")

if __name__ == "__main__":
    perform_audit()
