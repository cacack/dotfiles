.PHONY: setup-alacritty
setup-alacritty: setup-alacritty-config

.PHONY: setup-alacritty-config
setup-alacritty-config:
	mkdir -p ${HOME}/.config/alacritty
	ln -nsf $(DOTFILES_CONFIG_DIR)/dot.config/alacritty/alacritty.yml ${HOME}/.config/alacritty/alacritty.yml

