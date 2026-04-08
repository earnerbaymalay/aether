#!/usr/bin/env python3
"""
AetherVault — Smart Knowledge Loader
Replaces naive Context7 loading with relevance-scoped, category-aware,
tiered knowledge injection for optimal context window usage.

Usage:
  from knowledge_loader import AetherVault
  vault = AetherVault()
  knowledge = vault.load_for_query("how do I optimize llama.cpp performance?")
  # or
  knowledge = vault.load_all(budget=8000)
  # or
  vault.add_entry("my_topic", "content here", category="guide")
"""

import json
import os
import re
from pathlib import Path
from datetime import datetime
from typing import Optional


class AetherVault:
    """Smart knowledge vault with categorized, relevance-scored loading."""

    # Vault location (legacy path support)
    VAULT_DIR = Path.home() / "aether" / "knowledge" / "context7"
    METADATA_FILE = Path.home() / "aether" / "knowledge" / "vault_index.json"

    # Category definitions
    CATEGORIES = {
        "protocol": {
            "label": "Protocols",
            "description": "Rules and standards the AI must follow",
            "priority": "always",  # Always loaded
            "dir": "protocols",
            "max_chars": 1000,
        },
        "guide": {
            "label": "Guides",
            "description": "How-to documentation and best practices",
            "priority": "high",
            "dir": "guides",
            "max_chars": 800,
        },
        "reference": {
            "label": "Reference",
            "description": "Technical reference material",
            "priority": "medium",
            "dir": "reference",
            "max_chars": 600,
        },
        "troubleshooting": {
            "label": "Troubleshooting",
            "description": "Error diagnosis and fixes",
            "priority": "on_demand",  # Only loaded when query matches
            "dir": "troubleshooting",
            "max_chars": 500,
        },
        "template": {
            "label": "Templates",
            "description": "Reusable formats and structures",
            "priority": "low",
            "dir": "templates",
            "max_chars": 400,
        },
        "memory": {
            "label": "Learned Memories",
            "description": "Knowledge the AI saved from sessions",
            "priority": "medium",
            "dir": "memories",
            "max_chars": 500,
        },
    }

    # Directory alias mapping (old names → new names)
    DIR_ALIASES = {
        "protocols": "protocols",
        "guides": "guides",
        "reference": "reference",
        "troubleshooting": "troubleshooting",
        "templates": "templates",
        "memories": "memories",
        # Legacy aliases
        "examples": "reference",
    }

    def __init__(self):
        self.entries = []
        self._index = None
        self._build_index()

    def _build_index(self):
        """Scan vault and build metadata index."""
        self.entries = []

        if not self.VAULT_DIR.exists():
            return

        # Load or create index
        if self.METADATA_FILE.exists():
            try:
                self._index = json.loads(self.METADATA_FILE.read_text())
            except:
                self._index = {"entries": {}, "last_scan": None}
        else:
            self._index = {"entries": {}, "last_scan": None}

        # Scan all markdown files
        for md_file in self.VAULT_DIR.rglob("*.md"):
            rel_path = md_file.relative_to(self.VAULT_DIR)
            parts = rel_path.parts

            # Determine category from directory
            if len(parts) > 1:
                dir_name = parts[0]
                category = self.DIR_ALIASES.get(dir_name, "reference")
            else:
                category = "guide"  # Root-level files default to guide

            # Get or create entry
            key = str(rel_path)
            if key not in self._index["entries"]:
                self._index["entries"][key] = {
                    "path": key,
                    "category": category,
                    "tags": [],
                    "created": datetime.now().isoformat(),
                    "last_accessed": None,
                    "access_count": 0,
                    "size": 0,
                }

            entry_meta = self._index["entries"][key]
            entry_meta["size"] = md_file.stat().st_size

            # Read content and extract frontmatter if present
            try:
                content = md_file.read_text()
                title = md_file.stem.replace("_", " ").title()
                tags = []

                # Parse YAML frontmatter for tags
                if content.startswith("---"):
                    parts = content.split("---", 2)
                    if len(parts) >= 3:
                        frontmatter = parts[1].strip()
                        content = parts[2].strip()
                        # Extract tags
                        tag_match = re.search(r"tags:\s*\[([^\]]+)\]", frontmatter)
                        if tag_match:
                            tags = [t.strip() for t in tag_match.group(1).split(",")]
                        # Extract title
                        title_match = re.search(r"title:\s*(.+)", frontmatter)
                        if title_match:
                            title = title_match.group(1).strip()

                # Extract keywords from content for relevance scoring
                keywords = self._extract_keywords(content)

                self.entries.append({
                    "path": key,
                    "full_path": md_file,
                    "title": title,
                    "category": category,
                    "tags": tags,
                    "keywords": keywords,
                    "size": entry_meta["size"],
                    "content": content,
                    "last_accessed": entry_meta.get("last_accessed"),
                    "access_count": entry_meta.get("access_count", 0),
                })
            except:
                continue

        # Save index
        self._index["last_scan"] = datetime.now().isoformat()
        try:
            self.METADATA_FILE.write_text(json.dumps(self._index, indent=2))
        except:
            pass

    def _extract_keywords(self, text):
        """Extract meaningful keywords from text for relevance scoring."""
        # Remove code blocks, URLs, and punctuation
        text = re.sub(r"```[\s\S]*?```", "", text)
        text = re.sub(r"https?://\S+", "", text)
        text = re.sub(r"[^\w\s]", " ", text.lower())

        # Common words to exclude
        stop_words = {
            "the", "a", "an", "is", "are", "was", "were", "be", "been",
            "being", "have", "has", "had", "do", "does", "did", "will",
            "would", "could", "should", "may", "might", "shall", "can",
            "to", "of", "in", "for", "on", "with", "at", "by", "from",
            "as", "into", "through", "during", "before", "after", "and",
            "but", "or", "nor", "not", "so", "yet", "both", "either",
            "neither", "each", "every", "all", "any", "few", "more",
            "most", "other", "some", "such", "no", "only", "own",
            "same", "than", "too", "very", "just", "because", "if",
            "when", "where", "which", "while", "who", "whom", "what",
            "how", "this", "that", "these", "those", "it", "its",
            "you", "your", "we", "our", "they", "their", "he", "she",
            "his", "her", "i", "me", "my",
        }

        words = text.split()
        # Count word frequencies
        freq = {}
        for word in words:
            if word not in stop_words and len(word) > 3:
                freq[word] = freq.get(word, 0) + 1

        # Return top keywords by frequency
        return sorted(freq.keys(), key=lambda w: freq[w], reverse=True)[:20]

    def _score_relevance(self, entry, query):
        """Score how relevant an entry is to the query."""
        if not query:
            return 50  # Default mid score for non-query loading

        query_lower = query.lower()
        query_words = set(query_lower.split())
        score = 0

        # Title match (highest weight)
        if any(w in entry["title"].lower() for w in query_words):
            score += 40

        # Tag match
        if entry["tags"]:
            for tag in entry["tags"]:
                if tag.lower() in query_lower:
                    score += 30
                # Partial tag match
                for w in query_words:
                    if w in tag.lower() or tag.lower() in w:
                        score += 15

        # Keyword match
        for kw in entry["keywords"][:10]:  # Top 10 keywords
            if kw in query_lower:
                score += 20
            # Partial match
            for w in query_words:
                if len(w) > 4 and (w in kw or kw in w):
                    score += 8

        # Content snippet match
        content_snippet = entry["content"][:500].lower()
        for w in query_words:
            if w in content_snippet:
                score += 5

        # Recency boost (recently accessed entries get slight boost)
        if entry["access_count"] > 0:
            score += min(entry["access_count"] * 2, 10)

        return score

    def load_for_query(self, query: str, budget: int = 4000) -> str:
        """
        Load knowledge relevant to a query within a token budget.
        Returns formatted knowledge string ready for system prompt injection.
        """
        # 1. Always load protocol entries (highest priority)
        loaded = []
        used_chars = 0

        protocols = [e for e in self.entries if e["category"] == "protocol"]
        for entry in protocols:
            max_chars = self.CATEGORIES["protocol"]["max_chars"]
            content = entry["content"][:max_chars]
            loaded.append(f"## {entry['title']}\n{content}")
            used_chars += len(content)

        # 2. Score remaining entries by relevance
        scored = []
        for entry in self.entries:
            if entry["category"] == "protocol":
                continue  # Already loaded
            score = self._score_relevance(entry, query)
            scored.append((score, entry))

        # Sort by score descending
        scored.sort(key=lambda x: x[0], reverse=True)

        # 3. Load entries by score until budget reached
        for score, entry in scored:
            # Skip on_demand entries with low relevance
            cat_info = self.CATEGORIES.get(entry["category"], {})
            priority = cat_info.get("priority", "low")

            if priority == "on_demand" and score < 30:
                continue

            if priority == "low" and score < 20:
                continue

            max_chars = cat_info.get("max_chars", 500)
            content = entry["content"][:max_chars]

            if used_chars + len(content) > budget:
                break

            loaded.append(f"## {entry['title']} [{entry['category']}, score:{score}]\n{content}")
            used_chars += len(content)

            # Update access metadata
            self._update_access(entry["path"])

        # 4. Format output
        if not loaded:
            return ""

        result = "# AetherVault Knowledge\n"
        result += f"# Query: {query}\n" if query else ""
        result += f"# Entries: {len(loaded)} | ~{used_chars // 4} tokens\n"
        result += "=" * 50 + "\n\n"
        result += "\n\n".join(loaded)

        return result

    def load_all(self, budget: int = 4000) -> str:
        """Load all knowledge entries within a budget (no query filtering)."""
        return self.load_for_query("", budget)

    def load_by_category(self, category: str, budget: int = 3000) -> str:
        """Load all entries from a specific category."""
        loaded = []
        used_chars = 0

        entries = [e for e in self.entries if e["category"] == category]

        for entry in entries:
            max_chars = self.CATEGORIES.get(category, {}).get("max_chars", 500)
            content = entry["content"][:max_chars]

            if used_chars + len(content) > budget:
                break

            loaded.append(f"## {entry['title']}\n{content}")
            used_chars += len(content)
            self._update_access(entry["path"])

        if not loaded:
            return ""

        result = f"# AetherVault: {self.CATEGORIES.get(category, {}).get('label', category)}\n"
        result += "=" * 50 + "\n\n"
        result += "\n\n".join(loaded)
        return result

    def add_entry(self, title: str, content: str, category: str = "memory",
                  tags: Optional[list] = None):
        """Add a new knowledge entry to the vault."""
        # Sanitize title for filename
        safe_title = re.sub(r"[^\w\s-]", "", title.lower()).strip().replace(" ", "_")
        filename = f"{safe_title}_{datetime.now().strftime('%Y%m%d')}.md"

        # Determine directory
        dir_name = self.CATEGORIES.get(category, {}).get("dir", "memories")
        target_dir = self.VAULT_DIR / dir_name
        target_dir.mkdir(parents=True, exist_ok=True)

        filepath = target_dir / filename

        # Write with frontmatter
        tags_str = f"tags: [{', '.join(tags)}]" if tags else "tags: []"
        frontmatter = f"""---
title: {title}
category: {category}
{tags_str}
created: {datetime.now().isoformat()}
---

"""
        filepath.write_text(frontmatter + content.strip() + "\n")

        # Update index
        key = str(filepath.relative_to(self.VAULT_DIR))
        self._index["entries"][key] = {
            "path": key,
            "category": category,
            "tags": tags or [],
            "created": datetime.now().isoformat(),
            "last_accessed": None,
            "access_count": 0,
            "size": filepath.stat().st_size,
        }
        self._save_index()

        # Git commit if in a repo
        try:
            import subprocess
            subprocess.run(
                ["git", "-C", str(self.VAULT_DIR), "add", "."],
                capture_output=True
            )
            subprocess.run(
                ["git", "-C", str(self.VAULT_DIR), "commit", "-m", f"vault: {title}"],
                capture_output=True
            )
        except:
            pass

        return filepath

    def search(self, query: str, limit: int = 10) -> list:
        """Search vault entries by relevance score."""
        scored = []
        for entry in self.entries:
            score = self._score_relevance(entry, query)
            if score > 0:
                scored.append((score, entry))

        scored.sort(key=lambda x: x[0], reverse=True)
        return scored[:limit]

    def list_entries(self, category: Optional[str] = None) -> list:
        """List all vault entries, optionally filtered by category."""
        if category:
            return [e for e in self.entries if e["category"] == category]
        return self.entries

    def stats(self) -> dict:
        """Return vault statistics."""
        by_category = {}
        total_size = 0

        for entry in self.entries:
            cat = entry["category"]
            by_category[cat] = by_category.get(cat, 0) + 1
            total_size += entry["size"]

        return {
            "total_entries": len(self.entries),
            "total_size": total_size,
            "total_tokens_estimate": total_size // 4,
            "by_category": by_category,
            "categories_available": list(self.CATEGORIES.keys()),
        }

    def _update_access(self, path: str):
        """Update access metadata for an entry."""
        if path in self._index.get("entries", {}):
            entry = self._index["entries"][path]
            entry["last_accessed"] = datetime.now().isoformat()
            entry["access_count"] = entry.get("access_count", 0) + 1

    def _save_index(self):
        """Persist the metadata index."""
        self._index["last_scan"] = datetime.now().isoformat()
        try:
            self.METADATA_FILE.write_text(json.dumps(self._index, indent=2))
        except:
            pass


# ============================================================
# CLI Interface
# ============================================================

def main():
    import sys

    vault = AetherVault()

    if len(sys.argv) < 2:
        print("AetherVault — Smart Knowledge Loader")
        print("")
        print("Usage: python3 knowledge_loader.py <command> [args]")
        print("")
        print("Commands:")
        print("  stats                    - Show vault statistics")
        print("  list [category]          - List entries")
        print("  search <query>           - Search by relevance")
        print("  query <text> [budget]    - Load knowledge for query")
        print("  category <name> [budget] - Load entries by category")
        print("  add <title> <category>   - Add entry (reads stdin)")
        print("  reindex                  - Rebuild vault index")
        return

    cmd = sys.argv[1]

    if cmd == "stats":
        stats = vault.stats()
        print("=== AetherVault Statistics ===")
        print(f"Total Entries: {stats['total_entries']}")
        print(f"Total Size: {stats['total_size']} bytes (~{stats['total_tokens_estimate']} tokens)")
        print(f"Categories: {', '.join(stats['categories_available'])}")
        print("")
        print("By Category:")
        for cat, count in stats["by_category"].items():
            label = vault.CATEGORIES.get(cat, {}).get("label", cat)
            print(f"  {label}: {count}")

    elif cmd == "list":
        category = sys.argv[2] if len(sys.argv) > 2 else None
        entries = vault.list_entries(category)
        print(f"=== AetherVault Entries ({len(entries)}) ===")
        for e in entries:
            cat_label = vault.CATEGORIES.get(e["category"], {}).get("label", e["category"])
            print(f"  [{cat_label:15s}] {e['title']} ({e['size']}b, {e['access_count']} accesses)")

    elif cmd == "search":
        if len(sys.argv) < 3:
            print("Usage: search <query>")
            return
        query = " ".join(sys.argv[2:])
        results = vault.search(query)
        print(f"=== Search: {query} ===")
        for score, entry in results:
            print(f"  [{score:3d}] {entry['title']} ({entry['category']})")
        if not results:
            print("  No matches found")

    elif cmd == "query":
        if len(sys.argv) < 3:
            print("Usage: query <text> [budget]")
            return
        query = " ".join(sys.argv[2:-1]) if len(sys.argv) > 3 else sys.argv[2]
        budget = int(sys.argv[-1]) if len(sys.argv) > 3 and sys.argv[-1].isdigit() else 4000
        knowledge = vault.load_for_query(query, budget)
        print(knowledge)
        if not knowledge:
            print("No relevant knowledge found")

    elif cmd == "category":
        if len(sys.argv) < 3:
            print("Usage: category <name> [budget]")
            return
        category = sys.argv[2]
        budget = int(sys.argv[3]) if len(sys.argv) > 3 else 3000
        knowledge = vault.load_by_category(category, budget)
        print(knowledge)
        if not knowledge:
            print(f"No entries in category: {category}")

    elif cmd == "add":
        if len(sys.argv) < 4:
            print("Usage: add <title> <category> [tag1,tag2,...]")
            return
        title = sys.argv[2]
        category = sys.argv[3]
        tags = sys.argv[4].split(",") if len(sys.argv) > 4 else None
        content = sys.stdin.read()
        if content.strip():
            path = vault.add_entry(title, content, category, tags)
            print(f"✓ Added: {path}")
        else:
            print("ERROR: No content provided (use stdin)")

    elif cmd == "reindex":
        vault._build_index()
        print(f"✓ Vault reindexed: {len(vault.entries)} entries")

    else:
        print(f"Unknown command: {cmd}")


if __name__ == "__main__":
    main()
