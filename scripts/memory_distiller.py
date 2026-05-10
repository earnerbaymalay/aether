#!/usr/bin/env python3
"""
🧠 Aether-AI Memory Distiller // V 1.0.0
Consolidates fragmented memories into structured, distilled knowledge.
Reduces file bloat and improves RAG efficiency.
"""

import os
import json
import re
import requests
from pathlib import Path
from datetime import datetime

# --- Configuration ---
DIR = Path.home() / "aether"
VAULT_DIR = DIR / "knowledge" / "aethervault"
MEMORIES_DIR = VAULT_DIR  # The current location for memory fragments
DISTILLED_DIR = VAULT_DIR / "memories"
OLLAMA_API_URL = "http://127.0.0.1:11434/api/generate"

# Tiered Models
LOGIC_MODEL = "deepseek-r1:8b" # Best for reasoning and merging
TURBO_MODEL = "llama3.2:3b"    # Best for fast categorization

def generate_completion(prompt, model=LOGIC_MODEL):
    payload = {
        "model": model,
        "prompt": prompt,
        "stream": False,
        "options": {"temperature": 0.1}
    }
    try:
        r = requests.post(OLLAMA_API_URL, json=payload, timeout=180)
        return r.json().get("response", "").strip()
    except Exception as e:
        print(f"Error during distillation: {e}")
        return ""

def categorize_fragment(fragment_content):
    """Categorizes a memory fragment to find the right distillation target."""
    prompt = f"""Categorize this memory fragment into one of these topics: 
1. USER_PROFILE (preferences, bio, habits)
2. PROJECT_AETHER (architecture, development, ideas)
3. SYSTEM_CONFIG (local environment, paths, tools)
4. MISC (other)

Fragment: "{fragment_content}"

Output ONLY the category name."""
    
    category = generate_completion(prompt, model=TURBO_MODEL)
    for cat in ["USER_PROFILE", "PROJECT_AETHER", "SYSTEM_CONFIG"]:
        if cat in category.upper():
            return cat
    return "MISC"

def distill_topic(topic_name, fragments, existing_content=""):
    """Merges new fragments into existing topic content."""
    fragments_text = "\n".join([f"- {f}" for f in fragments])
    
    prompt = f"""You are the Aether Memory Distiller.
Topic: {topic_name}

Existing Knowledge:
{existing_content if existing_content else "No existing data."}

New Observations:
{fragments_text}

TASK:
1. Merge the new observations into the existing knowledge.
2. Update facts if new data is more recent or accurate.
3. Remove redundant or trivial information.
4. Keep the output as a concise, high-density Markdown list or table.
5. If a new observation contradicts an old one, prioritize the most logical/recent.

Output ONLY the distilled Markdown content."""

    return generate_completion(prompt, model=LOGIC_MODEL)

def run_distillation():
    print(f"🌌 Aether Memory Distillation starting...")
    
    if not DISTILLED_DIR.exists():
        DISTILLED_DIR.mkdir(parents=True, exist_ok=True)

    # 1. Collect all fragmented memory files
    fragments = []
    fragment_files = []
    
    # Existing fragments are memory_*.md and shadow_*.md in VAULT_DIR
    for pattern in ["memory_*.md", "shadow_*.md", "auto_*.md"]:
        for f in VAULT_DIR.glob(pattern):
            try:
                content = f.read_text()
                # Extract content after frontmatter or header
                lines = content.split('\n')
                data = "\n".join([l for l in lines if not l.startswith('#') and not l.startswith('---') and l.strip()])
                if data.strip():
                    fragments.append(data.strip())
                    fragment_files.append(f)
            except:
                continue

    if not fragments:
        print("✓ No memory fragments found to distill.")
        return

    print(f"  Found {len(fragments)} fragments. Categorizing...")

    # 2. Group fragments by topic
    buckets = {
        "USER_PROFILE": [],
        "PROJECT_AETHER": [],
        "SYSTEM_CONFIG": [],
        "MISC": []
    }

    for frag in fragments:
        topic = categorize_fragment(frag)
        buckets[topic].append(frag)

    # 3. Process each bucket
    for topic, topic_fragments in buckets.items():
        if not topic_fragments:
            continue
        
        target_file = DISTILLED_DIR / f"{topic.lower()}.md"
        existing_content = ""
        if target_file.exists():
            existing_content = target_file.read_text()
        
        print(f"  Distilling {len(topic_fragments)} items into {topic.lower()}.md...")
        distilled_content = distill_topic(topic, topic_fragments, existing_content)
        
        if distilled_content:
            # Clean up deepseek reasoning artifacts if present
            distilled_content = re.sub(r"<think>.*?</think>", "", distilled_content, flags=re.DOTALL).strip()
            
            # Ensure proper header
            header = f"# {topic.replace('_', ' ').title()}\nLast Updated: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n\n"
            target_file.write_text(header + distilled_content + "\n")
            print(f"  ✓ {topic.lower()}.md updated.")

    # 4. Cleanup fragment files
    print("  Cleaning up fragments...")
    for f in fragment_files:
        try:
            f.unlink()
        except:
            pass
    
    print("🌌 Distillation complete.")

if __name__ == "__main__":
    run_distillation()
