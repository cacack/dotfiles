# Ghostty itself is a GUI app (gui-apps.mk: Brewfile.gui / LINUX_GUI_APPS);
# this module only links its config.
.PHONY: setup-ghostty
setup-ghostty:
	@echo
	# Symlinking ghostty's config
	mkdir -p ${HOME}/.config/ghostty
	cd packages && stow --target=${HOME} ghostty
