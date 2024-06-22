# macos: https://gist.github.com/bbqtd/a4ac060d6f6b9ea6fe3aabe735aa9d95
setup-tmux: install-tmux

install-tmux:
	@echo
ifeq ($(OS),darwin)
	# This doesn't work within kitty as it's terminfo doesn't contain tmux...
	# https://gpanders.com/blog/the-definitive-guide-to-using-tmux-256color-on-macos/
	#${HOMEBREW_PREFIX}/opt/ncurses/bin/infocmp -x tmux-256color > ~/tmux-256color.src
	# So pull down ncurses terminfo file directly
	curl -o - -LO https://invisible-island.net/datafiles/current/terminfo.src.gz | gunzip > terminfo.src
	/usr/bin/tic -x -o ${HOME}/.local/share/terminfo -e tmux-256color terminfo.src
	rm terminfo.src
	brew install tmux
endif
