# Contributing to Aether

Thank you for considering a contribution. Aether is built on the principle that local-first AI should be open, auditable, and community-driven.

## How to Contribute

### Report a Bug
- Check if it's already reported in [Issues](https://github.com/earnerbaymalay/aether/issues)
- If not, open a new issue with:
  - Device model and Android version
  - Termux version
  - Steps to reproduce
  - Expected vs actual behavior

### Suggest a Feature
- Start a [Discussion](https://github.com/earnerbaymalay/aether/discussions) first
- Describe the use case, not just the solution
- Tag it with `enhancement`

### Submit a Pull Request
1. Fork the repository
2. Create a branch: `git checkout -b feat/your-feature`
3. Make your changes
4. Test on a real device (not just emulator)
5. Submit the PR with a clear description

### Write a Skill
Skills are drop-in Markdown files that teach the AI new behaviors:
1. Create `skills/your-skill-name/SKILL.md`
2. Write clear instructions for the AI
3. Test by running Aether and verifying the AI follows your skill

## Coding Standards

### Shell Scripts
- Use `#!/usr/bin/env bash` shebang
- Quote all variables: `"$var"`
- Use `set -e` for scripts that should fail fast
- No trailing whitespace
- 4-space indentation

### Python
- Follow PEP 8
- Use type hints where practical
- No hardcoded secrets
- Memory-sensitive operations must zero sensitive data

### Documentation
- Use Markdown
- Keep lines under 120 characters
- Link to other docs with relative paths
- Update USAGE.md when adding features

## Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/):
- `feat: add new skill for code review`
- `fix: prevent IV reuse in encrypt loop`
- `docs: update architecture diagram`
- `chore: bump version to 18.1`

## Security

Found a security issue? See [SECURITY.md](SECURITY.md) for responsible disclosure.

## Code of Conduct

Be respectful, inclusive, and constructive. We're building something that gives people control over their AI — the community should reflect those values.
