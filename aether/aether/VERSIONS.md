# Aether — Version History

> **Versioning**: CalVer `YY.MM.patch` — year.month.patch number
> This replaces the arbitrary sequential numbering. Each month's work
> gets a new minor version, patches are incremental fixes within that month.

---

## Current: `26.04.2` (April 8, 2026)

### What's New
Voice I/O, real multi-agent swarm orchestration, version system overhaul.

### Details
| Component | Change |
|-----------|--------|
| **Voice I/O** | Whisper.cpp STT + Piper TTS integration. Voice mode toggle in TUI. Hands-free session initiation. Audio recording via termux-microphone-record with fallback to arecord. |
| **Swarm Orchestrator** | Replaced `sleep` stubs with actual llama-cli invocations. LOGIC tier generates structured plans → CODE tier implements → AGENT tier executes with tools. Output passed between stages via temp files. Error recovery with retry logic. |
| **Version System** | Dropped V20.0 → CalVer 26.04.2. Added VERSION file. Created VERSIONS.md (this file). Version shown in boot sequence, agent prompt, README. |
| **README** | Restructured with practical overview, version badge, VERSIONS.md link. Removed marketing fluff. Added navigation sections. |

### Files Changed
- `VERSION` (new)
- `VERSIONS.md` (new)
- `aether.sh` (version display, voice mode)
- `scripts/swarm_orchestrator.sh` (complete rewrite)
- `scripts/voice_handler.sh` (new)
- `README.md` (restructure)
- `CHANGELOG.md` (full version history)

---

## `26.04.1` (April 8, 2026)

### What's New
Settings Hub, LSP, Context Import, Token Optimization, Agentic Workflows.

### Details
| Component | Change |
|-----------|--------|
| **Settings Hub** | Central TUI with gum-based config management. 5 profiles (performance/reasoning/coding/conservative/balanced). Feature toggles. Import/export. Plugin manager. Custom commands UI. |
| **LSP Server** | Language Server Protocol bridge. Diagnostics, symbols, go-to-definition, hover info for Python, JS/TS, Shell, Rust, Go, C/C++. JSON-RPC server mode. |
| **Context Import** | Gemini-style import from files, URLs, clipboard, directories. Smart search. Attach/export/clear. Relevance-aware loading. |
| **Token Optimizer** | RTK-inspired compression (60-90% savings). Language-aware compacting. Token budget analysis. AI bloat removal. |
| **Agentic Workflows** | YAML-declarative orchestration. 6 workflow templates. 5 verbs (DEFINE/ROUTE/EXECUTE/EVALUATE/COMPOSE). Registry pattern. |
| **Extras Installer** | 17 optional features across 5 categories. Enable during install or anytime after. |

### Files Created
`settings/settings.sh`, `lsp/lsp_server.sh`, `contexts/context_manager.sh`,
`scripts/token_optimizer.sh`, `scripts/extras_installer.sh`,
`workflows/registry/workflows.yaml`

---

## `26.04.0` (April 8, 2026)

### What's New
Core system enhancements — skills, toolbox, scripts.

### Details
| Component | Change |
|-----------|--------|
| **Skills (+6)** | code-review, security-audit, data-analysis, system-optimization, architecture-design, project-planning |
| **Tools (+6)** | log_analyzer, dependency_checker, model_router, config_manager, backup_manager, system_monitor |
| **Scripts (+7)** | workflow_engine, logic_engine, auto_scaler, project_orchestrator, agent_matrix, task_decomposer, vault_manager |
| **Knowledge** | Context7 expansion: security best practices, performance tuning, agent tool-use protocol, troubleshooting |

---

## `26.03.0` (March 2026 — Earlier Development)

### What's New
AetherVault rebrand, Session Manager, Memory Slots.

### Details
| Component | Change |
|-----------|--------|
| **AetherVault** | Context7 → AetherVault rebrand. Smart Knowledge Loader with relevance scoring. 6 categorized tiers. Dynamic token budgeting. |
| **Session Manager** | Session IDs, transcript archive, resume by ID, selective memory slots. |
| **Agent Fix** | SKILL.md content now actually loaded (was only passing names). |

---

## `1.0.0-alpha` (Original — April 7, 2026)

### What It Was
Foundation release.

- 4-tier model routing (TURBO/AGENT/CODE/LOGIC)
- Python agent with tool-use
- 10+ toolbox scripts
- Skill system (names only, non-functional)
- Swarm orchestrator (stub)
- Background sentinel
- Debug console
- Librarian
- Benchmark
- Installer

---

## Quick Reference

| Version | Date | Theme |
|---------|------|-------|
| `26.04.2` | Apr 8 | Voice, Swarm, Versioning |
| `26.04.1` | Apr 8 | Settings, LSP, Context, Token |
| `26.04.0` | Apr 8 | Skills, Tools, Scripts |
| `26.03.0` | Mar | AetherVault, Sessions |
| `1.0.0-alpha` | Apr 7 | Foundation |
