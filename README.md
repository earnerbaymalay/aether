# Termux-Vault

A collection of helper tools and setup scripts for Termux that automate tasks
which are difficult, tedious, or error-prone to configure manually.

## What's Included

| Tool | Description |
|------|-------------|
| `tvault` | Main entry point — run any tool by name |
| `setup-dev` | One-command dev environment setup (Python, Node, Rust, Go, C/C++) |
| `pkg-bundle` | Install curated package bundles in one shot |
| `storage-fix` | Fix storage permissions and symlinks |
| `keygen` | Generate and manage SSH/GPG keys |
| `dotfiles` | Shell config manager (zsh, bash, aliases, prompt) |
| `netkit` | Network utilities (proxy, port-forward, API test) |
| `tbackup` | Backup and restore Termux environment |
| `proot-distro-setup` | Automated Linux distro install via proot-distro |

## Quick Start

```bash
# Clone and install
git clone https://github.com/earnerbaymalay/Termux-Vault.git
cd Termux-Vault
make install

# Or one-liner bootstrap (curl)
curl -fsSL https://raw.githubusercontent.com/earnerbaymalay/Termux-Vault/main/setup/bootstrap.sh | bash
```

After install, all tools are available via the `tvault` command:

```bash
tvault setup-dev python node   # install Python + Node dev environments
tvault pkg-bundle dev-core     # install core dev packages
tvault keygen ssh               # generate SSH key pair
tvault tbackup save            # backup your Termux setup
```

Or run any script directly from `bin/`.

## Requirements

- [Termux](https://termux.dev) (F-Droid version recommended)
- `bash` 4+ (comes with Termux)
- Internet connection for package installs

## Project Structure

```
Termux-Vault/
├── bin/            # All executable tools
├── lib/            # Shared functions and helpers
├── setup/          # Bootstrap and first-run scripts
├── config/         # Default config templates
├── backups/        # Backup storage (gitignored)
├── Makefile        # Install/uninstall targets
└── README.md
```

## Uninstall

```bash
make uninstall
```

## License

MIT
