PREFIX ?= $(HOME)/../usr
BINDIR  = $(PREFIX)/bin
VAULT   = $(shell pwd)

.PHONY: install uninstall help

help:
	@echo "Termux-Vault Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  make install     Symlink tools into PATH and make executable"
	@echo "  make uninstall   Remove symlinks"
	@echo ""

install:
	@echo "==> Making scripts executable..."
	@chmod +x bin/*
	@chmod +x setup/bootstrap.sh
	@echo "==> Creating symlink: tvault -> $(BINDIR)/tvault"
	@mkdir -p $(BINDIR)
	@ln -sf $(VAULT)/bin/tvault $(BINDIR)/tvault
	@echo ""
	@echo "[+] Installed! Run 'tvault --help' to get started."
	@echo ""
	@echo "    All tools are accessible via 'tvault <tool>'."
	@echo "    Or run scripts directly from $(VAULT)/bin/"

uninstall:
	@echo "==> Removing tvault symlink..."
	@rm -f $(BINDIR)/tvault
	@echo "[+] Uninstalled."
