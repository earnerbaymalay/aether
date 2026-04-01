# Plan: Kimi Code Setup in Termux

This plan outlines the steps to install and configure Kimi Code CLI in a Termux environment on Android, leveraging the `uv` package manager and supporting browser-based OAuth.

## Prerequisites
- **Termux** installed and updated.
- **uv** package manager installed (confirmed by user).
- **Python 3.12 or 3.13** (handled by `uv`).
- **termux-api** package (optional but recommended for `termux-open`).

## Proposed Steps

### 1. Environment Preparation
Ensure that Termux can interact with the Android browser and has storage permissions.
- Run `termux-setup-storage` to allow Kimi Code to access files if needed.
- Verify `termux-open` is functional for OAuth redirection.

### 2. Install Kimi Code CLI
Use `uv` to install the CLI as a tool. This ensures it's isolated and uses the recommended Python version.
```bash
uv tool install --python 3.13 kimi-cli
```
*Note: If Python 3.13 is not yet installed, `uv` will attempt to fetch it or you may need to install it via `pkg install python`.*

### 3. Verify Installation
Check that the `kimi` command is available in the PATH.
```bash
kimi --version
```

### 4. Initial Login & OAuth
Initialize the CLI and perform the OAuth handshake.
```bash
kimi login
```
- When prompted, select **Kimi Code** platform.
- The CLI will attempt to open a browser link. Since "Browser Support" was selected, ensure `termux-open` is used or manually copy the URL to a browser.

### 5. Post-Installation Configuration
- Add `kimi` to shell aliases if `uv tool` paths are not automatically added to `$PATH`.
- Test a simple query to ensure the API is responding.

## Considerations for Termux
- **Architecture:** Kimi CLI is Python-based, so it should be architecture-agnostic (ARM64 supported).
- **Background Tasks:** Ensure Termux is excluded from battery optimization if Kimi is expected to run long-running tasks.
- **Node.js:** Some advanced Kimi features might require Node.js for certain tool executions; verify if `pkg install nodejs` is needed later.
