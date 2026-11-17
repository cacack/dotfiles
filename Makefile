################################################################################
# Main make configuration file
#
# Modules under .make.d/*.mk are auto-included in lexical order. Personal
# or host-specific targets that should not be committed publicly go in
# .make.d/99_local.mk (gitignored). The numeric prefix ensures the local
# overrides load last and can replace earlier definitions if needed.
################################################################################


# Source the modular make files
include .make.d/*.mk


################################################################################

# Make help the default target when running 'make' without arguments
.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "Dotfiles Management System"
	@echo "=========================="
	@echo ""
	@echo "INSTALLATION COMMANDS:"
	@echo "  make install              - CLI installation, no root needed (stow, mise base tools, neovim config)"
	@echo "  make desktop              - Full desktop (install + desktop tools, GUI apps, fonts, settings)"
	@echo "  make install-desktop      - Desktop installation (fonts, GUI apps, settings)"
	@echo "  make install-apps         - Application installation (homebrew, ghostty config)"
	@echo ""
	@echo "CONFIGURATION MANAGEMENT:"
	@echo "  make stow                 - Symlink dotfiles to \$$HOME"
	@echo "  make clean-stow           - Remove symlinked dotfiles"
	@echo ""
	@echo "UPDATES & MAINTENANCE:"
	@echo "  make update               - Update all configured tools"
	@echo "  make clean                - Clean temporary files"
	@echo "  make clean-all            - Deep clean including configurations"
	@echo "  make zinit-update         - Sync zinit and plugins to their pinned commits"
	@echo "  make tools                - Install locked tool versions (mise)"
	@echo "  make mise-lock            - Regenerate mise.lock after editing tool pins"
	@echo "  make security             - Scan the pinned tools for known vulnerabilities"
	@echo ""
	@echo "TOOLS & APPLICATIONS:"
	@echo "  make setup-<tool>         - Install/configure specific tool"
	@echo "  make install-<app>        - Install specific application"
	@echo ""
	@echo "SETTINGS & CONFIGURATION:"
	@echo "  make setup-macos-settings - Apply macOS system preferences"
	@echo "  make setup-linux-settings - Apply Linux desktop settings"
	@echo "  make setup-gui-apps       - Install GUI applications"
	@echo ""
	@echo "NAS MOUNTING:"
	@echo "  make nas-mount            - Set up NAS auto-mounting"
	@echo "  make nas-status           - Show mount status"
	@echo "  make nas-test             - Test mount connection"
	@echo "  make nas-logs             - View recent mount logs (macOS)"
	@echo "  make nas-fix              - Fix common issues"
	@echo "  make nas-remove           - Remove NAS mount config"
	@echo ""
	@echo "TESTING:"
	@echo "  make test                 - Run complete test suite"
	@echo "  make test-syntax          - Shell script syntax validation"
	@echo "  make test-config          - Configuration loading tests"
	@echo "  make test-stow            - Stow operation validation"
	@echo ""
	@echo "UTILITIES:"
	@echo "  make list-targets         - List all available make targets"
	@echo "  make print-<VAR>          - Print any Makefile variable value"
	@echo ""
	@echo "DOCUMENTATION:"
	@echo "  See docs/BOOTSTRAP-MACOS.md for detailed setup guide"
	@echo "  See docs/NAS-MOUNT-SETUP.md for NAS mounting guide"
	@echo "  See docs/GUI-APPS-AND-SETTINGS.md for desktop configuration guide"
	@echo ""
	@echo "For a complete list of targets, run: make list-targets"

.PHONY: install
install: check-prereqs base-dirs stow tools setup-neovim setup-tmux

.PHONY: install-desktop
install-desktop: mise-env-desktop desktop-dirs fonts setup-ghostty setup-gui-apps setup-macos-settings setup-linux-settings

.PHONY: install-apps
install-apps: install-app-deps setup-ghostty

# Full desktop: CLI install plus desktop tools, GUI apps, fonts and settings.
.PHONY: desktop
desktop: mise-env-desktop
	$(MAKE) install install-desktop install-apps

.PHONY: install-app-deps
install-app-deps: install-homebrew

################################################################################

.PHONY: update
update: $(UPDATE)

.PHONY: clean
clean: $(CLEAN)

.PHONY: clean-all
clean-all: clean $(CLEAN_ALL)
