################################################################################
# Main make configuration file
#
# It is intended to be copied into the local repository once and local overrides
# or customizations go into `.make.d/99_local.mk`.
################################################################################


# Source the modular make files
include .make.d/*.mk


################################################################################

.PHONY: install
install: base-dirs setup-neovim stow

.PHONY: install-desktop
install-desktop: desktop-dirs fonts setup-ghostty setup-gui-apps setup-macos-settings setup-linux-settings

.PHONY: install-apps
install-apps: install-app-deps setup-eza setup-ghostty setup-tmux setup-neovim install-aws-cli install-glab setup-direnv setup-bitwarden

.PHONY: install-app-deps
install-app-deps: install-homebrew install-yarn

################################################################################

.PHONY: update
update: $(UPDATE)

.PHONY: clean
clean: $(CLEAN)

.PHONY: clean-all
clean-all: clean $(CLEAN_ALL)
