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
install-desktop: desktop-dirs fonts setup-kitty

.PHONY: install-apps
install-apps: install-app-deps setup-kitty setup-tmux setup-neovim install-aws-cli

.PHONY: install-app-deps
install-app-deps: install-homebrew install-yarn

################################################################################

.PHONY: update
update: $(UPDATE)

.PHONY: clean
clean: $(CLEAN)

.PHONY: clean-all
clean-all: $(CLEAN_ALL) clean
