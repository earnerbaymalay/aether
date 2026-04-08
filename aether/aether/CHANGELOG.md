# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows **CalVer**: `YY.MM.patch` (year.month.patch).

---

## [Unreleased]

---

## [26.04.2] — 2026-04-08
### Phase 3 — Voice I/O, Real Swarm, Version Revision

#### Voice I/O Pipeline
- **Whisper.cpp integration** for speech-to-text (STT)
- **Piper TTS integration** for text-to-speech (TTS)
- Voice mode toggle in aether.sh — hands-free operation
- Audio recording via `termux-microphone-record` or `arecord`
- Voice-triggered session start option

#### Real Swarm Orchestrator
- **Actual multi-agent pipeline**: LOGIC plans → CODE implements → AGENT executes
- Each tier invokes real `llama-cli` with structured prompts
- Output passed between stages via temp files
- Progress tracking with stage-by-stage status
- Error recovery: if a stage fails, the swarm retries with adjusted prompts

#### Version System Revision
- **Dropped arbitrary V20.0** → adopting CalVer `YY.MM.patch`
- **VERSION file** added at project root
- **Per-version documentation** in `VERSIONS.md` — detailed changelog
  with what was done, why, and by whom for every release
- Version displayed in aether.sh boot, agent prompt, and README
- Current: `26.04.2` (April 2026, patch 2)

#### Readme & Navigation
- README restructured with clear sections, version badge, quick-start
- Removed marketing fluff, added practical "what this does" overview
- Added `VERSIONS.md` link prominently in README

---

## [26.04.1] — 2026-04-08
### Phase 2 — Settings Hub, LSP, Context Import, Token Optimization

#### New Systems
- **Settings Hub** (`settings/settings.sh`): Central gum-based TUI for
  config management, profiles (performance/reasoning/coding/conservative/
  balanced), feature toggles, import/export, plugin manager, custom commands
- **LSP Server** (`lsp/lsp_server.sh`): Language Server Protocol bridge
  with diagnostics, symbol extraction, go-to-definition, hover info,
  JSON-RPC server mode. Supports Python, JS/TS, Shell, Rust, Go, C/C++
- **Context Import** (`contexts/context_manager.sh`): Gemini-style context
  import from files, URLs, clipboard, directories
- **Token Optimizer** (`scripts/token_optimizer.sh`): RTK-inspired token
  compression (60-90% savings), smart language-aware compacting, budget
  analysis, relevance-based loading, AI bloat removal
- **Agentic Workflows** (`workflows/registry/workflows.yaml`): YAML-
  declarative multi-agent orchestration (ThibautMelen nika pattern).
  6 workflow templates, 5 verbs: DEFINE, ROUTE, EXECUTE, EVALUATE, COMPOSE
- **Optional Extras Installer** (`scripts/extras_installer.sh`): Modular
  feature selection during install, enableable later. 17 extras across
  5 categories
- **Testing Framework**: Automated test suite for all components

#### Enhancements
- Skills system fixed: SKILL.md content now fully loaded into agent prompt
- Agent reads settings config, injects profile/parameters
- aether.sh reads config.json for threads, context, temperature, colors
- install.sh rewritten with modular extras selection
- Toolbox expanded to 17 tools

---

## [26.04.0] — 2026-04-08
### Phase 1 — Core Enhancements

#### New Skills (6)
- `code-review`: Multi-phase code review (security, quality, perf, architecture)
- `security-audit`: Network, process, file, application security scanning
- `data-analysis`: Statistical analysis, data processing, visualization
- `system-optimization`: Performance tuning for Termux/Android
- `architecture-design`: System design, component modeling, decision matrices
- `project-planning`: Task decomposition, milestone tracking, estimation

#### New Toolbox (6 tools)
- `log_analyzer`: System/application/security log analysis
- `dependency_checker`: Project dependency health checks
- `model_router`: Model routing config, optimization, benchmarking
- `config_manager`: Configuration profiles and settings management
- `backup_manager`: Comprehensive backup/restore for entire ecosystem
- `system_monitor`: Real-time monitoring with alerts and metrics

#### New Scripts (7)
- `workflow_engine.sh`: Multi-stage workflow automation
- `logic_engine.sh`: Decision trees, fallback routing, error recovery
- `auto_scaler.sh`: Dynamic resource allocation
- `project_orchestrator.sh`: Cross-project coordination
- `agent_matrix.sh`: Capability matrix and dynamic task routing
- `task_decomposer.sh`: Task breakdown with dependency mapping
- `context7/` knowledge expansion: security, performance, agent protocol,
  troubleshooting docs

---

## [26.03.0] — 2026-03-01
### AetherVault & Session Management (Earlier Development)

#### AetherVault (formerly Context7)
- Rebranded Context7 → **AetherVault**
- Smart Knowledge Loader with relevance scoring
- 6 categorized tiers: protocol, guide, reference, troubleshooting,
  template, memory
- Dynamic token budgeting based on model context window
- YAML frontmatter support for tags and metadata
- Access tracking for popularity-aware loading
- Vault management CLI (`vault_manager.sh`)
- Directory restructured: `knowledge/aethervault/`

#### Session Manager
- Unique session IDs (`AETHER-xxxx-xxxx`)
- Transcript archive with gzip compression
- Resume by session ID
- Selective memory slots for project isolation
- Startup/exit prompts integrated into aether.sh
- Memory slot injection into agent system prompt

---

## [1.0.0-alpha] — 2026-04-07 (Original Release)
### Foundation

- Multi-tier AI routing: TURBO (Llama-3.2-3B), AGENT (Hermes-3-8B),
  CODE (Qwen-Coder-3B), LOGIC (DeepSeek-R1)
- Python agent core with tool-use execution
- Toolbox with 10+ tools
- Skill Marketplace
- Swarm Orchestrator (stub)
- Background Sentinel
- Debug Console
- Librarian for vault auditing
- Hardware benchmark
- Guided installer
- Terminal-native TUI
