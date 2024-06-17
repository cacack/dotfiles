.PHONY: setup-alacritty
setup-alacritty: setup-alacritty-config

.PHONY: setup-alacritty-config
setup-alacritty-config:
	mkdir -p ${HOME}/.config/alacritty
	cd packages && stow --target=${HOME} alacritty
