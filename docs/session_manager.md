# Session Manager — User Guide

## Overview

The Session Manager adds persistent session tracking, transcript archiving, and project-isolated memory slots to Aether.

## Session IDs

Every Aether session gets a unique ID (format: `AETHER-xxxx-xxxx`).

### On First Use
You get a **fresh start** — new session ID, clean slate.

### On Return
You're presented with options:
1. **New Session** — Fresh start, new ID
2. **Resume Session** — Enter a past session ID to continue
3. **Load Memory Slot** — Start with project-specific context
4. **Manage Memory Slots** — Create/edit/delete isolated memory banks
5. **Browse Transcripts** — View saved session history

## Saving Transcripts

When you **exit Aether**, if you've had a meaningful conversation (10+ lines), you're asked:

```
=== Session Ending ===
Session ID: AETHER-ab12-cd34
Lines logged: 47

Save transcript for later resuming? (y/n):
```

If you say **yes**:
- The conversation is saved and **compressed** (if over 4KB)
- You're given the session ID to note down
- You can resume this exact conversation later

If you say **no**:
- The session is discarded

## Resuming Sessions

```bash
# Resume a saved session
~/aether/scripts/session_manager.sh resume AETHER-ab12-cd34
```

This restores the conversation history into Aether's active context. The AI picks up where it left off.

## Memory Slots

Memory slots let you **isolate context per project**. Instead of loading all system knowledge, you load only what's relevant.

### Create a Slot
```bash
~/aether/scripts/session_manager.sh create-slot webapp
~/aether/scripts/session_manager.sh create-slot security_audit
~/aether/scripts/session_manager.sh create-slot data_analysis
```

### Add Memories
```bash
~/aether/scripts/session_manager.sh add-memory webapp "Project uses FastAPI + React. DB: PostgreSQL. Auth: JWT. Key decisions: Use Pydantic v2, avoid SQLAlchemy 1.x"
~/aether/scripts/session_manager.sh add-memory webapp "Architecture: /api/ for REST, /ws/ for WebSocket. Deploy: Docker on VPS"
```

### Load Before Session
```bash
~/aether/scripts/session_manager.sh load-slot webapp
# Then launch Aether — the webapp memory is injected into context
```

### Use Cases
- **Project isolation**: Keep webapp context separate from security audit context
- **Lean context**: Only load what's relevant, save tokens
- **Decision tracking**: Record key architectural decisions per project
- **Pattern libraries**: Store coding patterns, conventions, gotchas per codebase

## Commands Reference

### Session Management
| Command | Description |
|---------|-------------|
| `session_manager.sh new` | Create new session |
| `session_manager.sh save` | Save current transcript |
| `session_manager.sh resume <id>` | Resume saved session |
| `session_manager.sh list` | List saved transcripts |
| `session_manager.sh view <id>` | View transcript content |
| `session_manager.sh status` | Show current session info |

### Memory Slots
| Command | Description |
|---------|-------------|
| `session_manager.sh slots` | List all memory slots |
| `session_manager.sh create-slot <name>` | Create new slot |
| `session_manager.sh add-memory <slot> <text>` | Add memory entry |
| `session_manager.sh load-slot <name>` | Load slot into session |
| `session_manager.sh unload-slot <name>` | Unload current slot |
| `session_manager.sh delete-slot <name>` | Delete a slot |

## Storage Locations

| Data | Path |
|------|------|
| Active session | `~/.aether/sessions/active_session.info` |
| Session log | `~/.aether/sessions/last_session.log` |
| Registry | `~/.aether/sessions/session_registry.json` |
| Transcripts | `~/.aether/transcripts/` |
| Memory slots | `~/.aether/memory_slots/` |

## Compression

Transcripts over 4KB are automatically gzipped. Typical savings: **60-80%**.

## Integration

Session Manager is integrated into:
- **aether.sh startup**: Offers resume/slot options if history exists
- **aether.sh exit**: Prompts to save transcript
- **aether_agent.py**: Loads active memory slot into system prompt
- **Tools menu**: "Session Manager" and "Memory Slots" entries
