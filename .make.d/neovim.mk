CLEAN_ALL += clean-neovim-config

.PHONY: setup-neovim
setup-neovim: setup-neovim-config

.PHONY: setup-neovim-config
setup-neovim-config:
	cd packages && stow --target=${HOME} neovim

.PHONY: clean-neovim-config
clean-neovim-config:
	cd packages && stow --target=${HOME} --delete neovim 2>/dev/null
	rm -rf ~/.config/nvim
	rm -rf ~/.local/state/nvim
	rm -rf ~/.local/share/nvim
