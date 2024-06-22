.PHONY: setup-neovim
setup-neovim: install-neovim install-nvchad setup-nvchad-custom-config

.PHONY: install-neovim
install-neovim:
	@echo
	# Installing NeoVim
ifeq ($(OS),linux)
	curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
	sudo rm -rf ${HOME}/.local/opt/nvim-linux64
	sudo tar -C ${HOME}/.local/opt -xzf nvim-linux64.tar.gz
	rm nvim-linux64.tar.gz
endif
ifeq ($(OS),darwin)
	brew install neovim
endif

.PHONY: install-nvchad
install-nvchad:
	[[ -d ${HOME}/.config/nvim ]] || git clone https://github.com/NvChad/NvChad ${HOME}/.config/nvim --depth 1

.PHONY: setup-nvchad-custom-config
setup-nvchad-custom-config:
	cd packages && stow --target=${HOME} neovim
