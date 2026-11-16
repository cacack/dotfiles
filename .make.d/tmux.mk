# tmux itself is installed by mise (configs/.config/mise/config.toml).
# macOS lacks a tmux-256color terminfo entry; build it from ncurses' source.
# https://gpanders.com/blog/the-definitive-guide-to-using-tmux-256color-on-macos/
.PHONY: setup-tmux
setup-tmux:
ifeq ($(OS),darwin)
	@echo
	curl -fsSL https://invisible-island.net/datafiles/current/terminfo.src.gz | gunzip > terminfo.src
	/usr/bin/tic -x -o ${HOME}/.local/share/terminfo -e tmux-256color terminfo.src
	rm terminfo.src
endif
