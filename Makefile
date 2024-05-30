.PHONY: install
install: stow

.PHONY: stow
stow:
	stow configs

.PHONY: clean
clean:
	rm -f ~/.config/alacritty/alacritty.yml
	rm -f ~/.config/git.d
	rm -f ~/.config/lsd
	rm -f ~/.config/nvim/lua/custom
	rm -f ~/.config/starship.toml
	rm -f ~/.gitconfig
	rm -f ~/.tmux.conf
	rm -f ~/.zshenv
