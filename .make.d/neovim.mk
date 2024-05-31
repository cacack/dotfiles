.PHONY: setup-neovim
setup-neovim: install-neovim install-nvchad setup-nvchad-custom-config

.PHONY: install-neovim
install-neovim:
	@echo
	# Installing NeoVim
ifeq ($(OS),linux)
	curl -Lsf -o ${USER_BIN_DIR}/nvim.appimage --create-dirs https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
	chmod 755 ${USER_BIN_DIR}/nvim.appimage
endif
ifeq ($(OS),darwin)
	brew install neovim
endif

.PHONY: install-nvchad
install-nvchad:
	[[ -d ${HOME}/.config/nvim ]] || git clone https://github.com/NvChad/NvChad ${HOME}/.config/nvim --depth 1

.PHONY: setup-nvchad-custom-config
setup-nvchad-custom-config:
	stow packages/neovim
