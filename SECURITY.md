# Security Policy

## Supported Versions

| Version | Supported |
|---|---|
| Latest (main) | ✅ Yes |

## Reporting a Vulnerability

**Do NOT open a public issue for security vulnerabilities.**

1. **Email:** [security@earnerbaymalay.com](mailto:security@earnerbaymalay.com) *(placeholder)*
2. **Include:**
   - A description of the vulnerability
   - Steps to reproduce
   - Potential impact assessment
   - Suggested fix (if you have one)

## Response Timeline

- **Acknowledgment:** Within 48 hours
- **Initial assessment:** Within 7 days
- **Fix or mitigation:** Within 30 days (critical: 7 days)
- **Public disclosure:** Coordinated with reporter, after fix is deployed

## What We Consider a Vulnerability

- Cryptographic weaknesses (e.g., predictable IVs, weak key derivation)
- Key extraction possibilities (e.g., keys left in memory, Keystore bypass)
- Information leakage (e.g., plaintext written to disk, logs in release builds)
- Authentication bypasses
- Tool sandbox escapes

## What Is NOT a Vulnerability

- UI glitches that don't leak data
- Feature requests (please use GitHub Issues)
- Dependency vulnerabilities we've already addressed
- Model-specific performance issues

## Security Design

Aether's security model:

- **AI models run locally** — no data sent to external servers (unless you explicitly use web search tools)
- **Keys managed by Android Keystore** — hardware-backed, non-exportable where available
- **Session logs stored on device** — `~/.aether/sessions/`
- **No telemetry or analytics** — nothing phones home
- **Release builds strip debug logging** — `BuildConfig.DEBUG` is `false`

---

*Thank you for keeping Aether secure.*
