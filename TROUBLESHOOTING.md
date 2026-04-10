# Aether troubleshooting guide

Common issues and solutions.

---

## Common Termux Issues

1. **Storage Access:** Run `termux-setup-storage` before installation to enable file and directory access.
2. **Package Conflicts:** Run `pkg update && pkg upgrade` before install to ensure all package versions are compatible.
3. **Build Failures:** If `llama.cpp` build fails with "ninja: command not found" — run `pkg install ninja`.
4. **Model Compatibility (ARM64):**
   - **6GB+ RAM:** Q4_K_M quantisation is recommended for optimal balance.
   - **4GB RAM:** Use Q2_K quantisation.
   - **8B+ models:** Do not attempt on devices with less than 6GB RAM.
5. **Command Not Found:** If `ai` command not found after install — run `source ~/.bashrc` or restart Termux.

---

## Installation issues

### Missing dependencies
Re-run `./install.sh`.

### `ai` command not found
The installer may have failed to update your `.bashrc`. Run:
```bash
echo "alias ai='$HOME/aether/aether.sh'" >> ~/.bashrc && source ~/.bashrc
```

---

## Performance issues

### AI is slow
Run `./bench.sh`. If results are below 5 tokens per second, try a smaller model or close background apps.

### Out of memory
Reduce the `THREADS` variable in `aether.sh` to 4 or 2.

---

## System issues

### Engine failed to start
Check the logs at `~/.aether/sessions/llama_server.log`.

### Obsidian can't find the vault
Ensure the path is exactly `~/aether/knowledge/aethervault/`.

---

## FAQ

**Is Aether truly offline?**
Yes. After model download, no data leaves your device unless you use web search tools.

**Are the models censored?**
No. These are raw, open-source models.

**How do I update?**
Run `git pull` then `./install.sh`.
