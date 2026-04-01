# Device Compatibility

## Tested: Nokia XR20
- Chipset: Qualcomm Snapdragon 480 5G (ARM64)
- RAM: 6 GB
- Non-root only — all scripts must work without root
- Termux from F-Droid (NOT Google Play)
- Storage: use ~/storage/shared for Syncthing sync path

## Constraints
- Ollama models: max ~4B param recommended (RAM limit)
  - Recommended: qwen2:1.5b or tinyllama for on-device
  - qwen3:latest may OOM — use qwen2.5:3b instead
- No X11/GUI tools (XR20 display setup not tested)
- NetGuard: whitelist termux to allow Ollama localhost

## Pixel 8 Pro (secondary/reference device)
- ARM64, 12 GB RAM — can run 7B models locally
- Non-root (Magisk removed)
