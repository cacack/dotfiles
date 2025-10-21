################################################################################
# Main make configuration file
#
# It is intended to be copied into the local repository once and local overrides
# or customizations go into `.make.d/99_local.mk`.
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
	@echo "  make install              - Basic installation (directories, neovim, stow)"
	@echo "  make install-desktop      - Desktop installation (fonts, GUI apps, settings)"
	@echo "  make install-apps         - Application installation (homebrew, dev tools)"
	@echo ""
	@echo "CONFIGURATION MANAGEMENT:"
	@echo "  make stow                 - Symlink dotfiles to \$$HOME"
	@echo "  make clean-stow           - Remove symlinked dotfiles"
	@echo ""
	@echo "UPDATES & MAINTENANCE:"
	@echo "  make update               - Update all configured tools"
	@echo "  make clean                - Clean temporary files"
	@echo "  make clean-all            - Deep clean including configurations"
	@echo "  make zinit-update         - Update zinit and all plugins"
	@echo ""
	@echo "TOOLS & APPLICATIONS:"
	@echo "  make setup-<tool>         - Install/configure specific tool"
	@echo "  make install-<app>        - Install specific application"
	@echo ""
	@echo "SETTINGS & CONFIGURATION:"
	@echo "  make setup-macos-settings - Apply macOS system preferences"
	@echo "  make setup-linux-settings - Apply Linux desktop settings"
	@echo "  make setup-autofs         - Configure NAS mounting"
	@echo "  make setup-gui-apps       - Install GUI applications"
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
	@echo "  See docs/AUTOFS-NAS-SETUP.md for NAS mounting guide"
	@echo "  See docs/GUI-APPS-AND-SETTINGS.md for desktop configuration guide"
	@echo ""
	@echo "For a complete list of targets, run: make list-targets"

.PHONY: install
install: base-dirs setup-neovim stow

.PHONY: install-desktop
install-desktop: desktop-dirs fonts setup-ghostty setup-gui-apps setup-macos-settings setup-linux-settings

.PHONY: install-apps
install-apps: install-app-deps setup-eza setup-ghostty setup-tmux setup-neovim install-aws-cli setup-gh install-glab setup-direnv setup-bitwarden

.PHONY: install-app-deps
install-app-deps: install-homebrew install-yarn

################################################################################

.PHONY: update
update: $(UPDATE)

.PHONY: clean
clean: $(CLEAN)

.PHONY: clean-all
clean-all: clean $(CLEAN_ALL)
