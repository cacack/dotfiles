CLEAN += clean-stow clean-bashrc
UPDATE += zinit-update

.PHONY: base-dirs
base-dirs:
	@echo
	# Creating basic directories
	mkdir -p ${HOME}/devel
	mkdir -p ${HOME}/.config
	mkdir -p ${HOME}/.local/{bin,etc,opt,share}

.PHONY: stow
stow:
	stow -v configs

zinit-update:
	source "${HOME}/.local/share/zinit/zinit.git/zinit.zsh"; \
	zinit self-update; \
	zinit update --parallel

.PHONY: clean-stow
clean-stow:
	stow --delete configs 2>/dev/null

clean-old-configs:
	rm -f ~/.abcde.conf
	rm -f ~/.config/alacritty/alacritty.yml
	rm -f ~/.config/git.d
	rm -f ~/.config/nvim/lua/custom
	rm -f ~/.config/ohmyposh
	rm -f ~/.gitconfig
	rm -f ~/.p10k.zsh
	rm -f ~/.tmux.conf
	rm -f ~/.zshenv
	rm -f ~/.zshrc
	rm -f ~/.zshrc.d

.PHONY: clean-bashrc
clean-bashrc:
	rm -f ${HOME}/{.bashrc,.bash_history,.bash_logout,.bash_profile}

desktop-dirs: base-dirs
	@echo
ifeq ($(OS),linux)
	# Creating desktop directories for Linux
	mkdir -p ${HOME}/{desktop,documents,downloads,music,pictures,video}
	mkdir -p ${HOME}/.local/share/fonts
	stow packages/xdg
	(( $+commands[xdg-user-dirs-updates] )) && xdg-user-dirs-update
	rm -rf ${HOME}/{Desktop,Documents,Downloads,Music,Pictures,Public,Templates,Video}
endif

setup-terminfo:
ifeq ($(OS),darwin)
	# This doesn't work within kitty as it's terminfo doesn't contain tmux...
	# https://gpanders.com/blog/the-definitive-guide-to-using-tmux-256color-on-macos/
	#${HOMEBREW_PREFIX}/opt/ncurses/bin/infocmp -x tmux-256color > ~/tmux-256color.src
	# So pull down ncurses terminfo file directly
	curl -o - -LO https://invisible-island.net/datafiles/current/terminfo.src.gz | gunzip > terminfo.src
	/usr/bin/tic -x -o ${HOME}/.local/share/terminfo -e xterm-256color terminfo.src
	/usr/bin/tic -x -o ${HOME}/.local/share/terminfo -e tmux-256color terminfo.src
	/usr/bin/tic -x -o ${HOME}/.local/share/terminfo -e xterm-kitty terminfo.src
	/usr/bin/tic -x -o ${HOME}/.local/share/terminfo -e alacritty terminfo.src
	rm terminfo.src
endif

setup-sssd:
	sudo sss_override user-add ${USER} --shell /bin/zsh
	sudo systemctl restart sssd

switch-repo-url:
	cd ${HOME}/.dotfiles && git remote set-url origin git@gitlab.com:cacack/dotfiles.git
