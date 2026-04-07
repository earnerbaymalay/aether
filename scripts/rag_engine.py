import os, sys, glob, re
from pathlib import Path
import numpy as np

# Aether Neural Pathing
DIR = Path.home() / "aether"
VAULT = DIR / "knowledge" / "context7"

def clean_text(text):
    return re.sub(r'[^\w\s]', '', text.lower())

def simple_embedding(text):
    """
    Refined: Character n-gram hashing for better semantic overlap without external models.
    Uses 3-gram character windows to capture structural similarity.
    """
    vec = np.zeros(256)
    text = clean_text(text)
    
    # 3-gram character hashing
    for i in range(len(text) - 2):
        gram = text[i:i+3]
        idx = hash(gram) % 256
        vec[idx] += 1
        
    # Word-level overlap weight
    words = text.split()
    for w in words:
        if len(w) > 3:
            idx = (hash(w) ^ 0xFF) % 256
            vec[idx] += 2
            
    norm = np.linalg.norm(vec)
    return vec / norm if norm > 0 else vec

def get_relevant_context(query, top_k=5):
    files = list(VAULT.glob("**/*.md"))
    if not files:
        return "Vault is currently empty. No local knowledge available."
    
    query_vec = simple_embedding(query)
    scores = []
    
    for f in files:
        try:
            with open(f, 'r', encoding='utf-8') as content:
                text = content.read()
                # Metadata extraction (first 100 chars or title)
                title = f.name
                doc_vec = simple_embedding(text)
                score = np.dot(query_vec, doc_vec)
                
                # Boost if query words are in title
                if any(q.lower() in title.lower() for q in query.split()):
                    score += 0.2
                    
                scores.append((score, title, text))
        except Exception:
            continue
    
    # Sort by relevance
    scores.sort(key=lambda x: x[0], reverse=True)
    
    # Format output with source citations
    results = []
    for score, title, text in scores[:top_k]:
        if score > 0.15: # Significance threshold
            results.append(f"SOURCE: {title}\nRELEVANCE: {score:.2f}\nCONTENT: {text[:500]}...")
            
    return "\n---\n".join(results) if results else "No highly relevant context found in vault."

if __name__ == "__main__":
    if len(sys.argv) > 1:
        query = " ".join(sys.argv[1:])
        print(get_relevant_context(query))
    else:
        print("Aether RAG Engine Active. Provide a query string.")
