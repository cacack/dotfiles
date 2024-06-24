CLEAN_ALL += clean-neovim-config

.PHONY: setup-neovim
setup-neovim: install-neovim setup-neovim-config

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

.PHONY: setup-neovim-config
setup-neovim-config:
	cd packages && stow --target=${HOME} neovim

.PHONY: clean-neovim-config
clean-neovim-config:
	cd packages && stow --target=${HOME} --delete neovim 2>/dev/null
	rm -rf ~/.config/nvim
	rm -rf ~/.local/state/nvim
	rm -rf ~/.local/share/nvim
