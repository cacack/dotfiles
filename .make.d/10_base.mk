CLEAN += clean-stow clean-bashrc
UPDATE += zinit-update zinit-prune-completions

# What `make install` needs but cannot provide itself. None of it needs root
# once present. unzip unpacks tools shipped as .zip (terraform-ls, tflint,
# aws-cli, bw); on Linux desktops, Node (desktop tool set) also needs libatomic.
PREREQS := curl git make stow tar unzip zsh

.PHONY: check-prereqs
check-prereqs:
	@missing=""; \
	for cmd in $(PREREQS); do command -v $$cmd >/dev/null 2>&1 || missing="$$missing $$cmd"; done; \
	if [ "$(MISE_ENV)" = "desktop" ] && [ "$(OS)" = "linux" ] && \
		! ls /lib/*/libatomic.so.1 /usr/lib/*/libatomic.so.1 /usr/lib64/libatomic.so.1 2>/dev/null | grep -q .; then \
		missing="$$missing libatomic"; \
	fi; \
	if [ -n "$$missing" ]; then \
		echo "ERROR: missing prerequisites:$$missing"; \
		echo "Install them (or ask an admin to), then re-run."; \
		exit 1; \
	fi

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

# Move zinit and each installed plugin to its pinned commit (_zinit_pins in
# 00_init.zsh). Not `zinit self-update`/`zinit update`: those follow the branch
# head and ignore the pins. Oh My Zsh snippets are pinned by URL and need nothing.
# The sed reads the pin block's exact shape ("  owner/repo <40-hex sha>"), as
# does renovate.json; an empty result means the block was reformatted.
ZINIT_DATA := $(or $(XDG_DATA_HOME),${HOME}/.local/share)/zinit
ZINIT_PINS = $(shell sed -nE 's/^ +([A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+) ([0-9a-f]{40})$$/\1=\2/p' $(REPO_DIR)/configs/.zshrc.d/00_init.zsh)
.PHONY: zinit-update
zinit-update:
	@echo
	# Syncing zinit and plugins to their pinned commits
	@[ -n "$(ZINIT_PINS)" ] || { echo "ERROR: no pins parsed from _zinit_pins in 00_init.zsh"; exit 1; }
	@for pin in $(ZINIT_PINS); do \
		repo=$${pin%%=*}; sha=$${pin#*=}; \
		case "$$repo" in \
			ohmyzsh/ohmyzsh) continue ;; \
			zdharma-continuum/zinit) dir="$(ZINIT_DATA)/zinit.git" ;; \
			*) dir="$(ZINIT_DATA)/plugins/$${repo%%/*}---$${repo#*/}" ;; \
		esac; \
		[ -d "$$dir/.git" ] || continue; \
		[ "$$(git -C "$$dir" rev-parse HEAD)" = "$$sha" ] && continue; \
		echo "$$repo -> $$sha"; \
		git -C "$$dir" fetch -q origin "$$sha" && \
		git -C "$$dir" -c advice.detachedHead=false checkout -q "$$sha" || exit 1; \
	done

# Plugin updates can drop or relocate completion files, leaving dangling
# symlinks in zinit's aggregated completions dir that break compinit on next
# shell start. Prune the broken links and clear the compdump cache so it
# rebuilds clean. Runs after zinit-update in `make update`.
.PHONY: zinit-prune-completions
zinit-prune-completions:
	@echo
	# Pruning broken zinit completion symlinks
	@comp_dir="${HOME}/.local/share/zinit/completions"; \
	if [ -d "$$comp_dir" ]; then \
		pruned=$$(find "$$comp_dir" -maxdepth 1 -type l ! -exec test -e {} \; -print 2>/dev/null | wc -l | tr -d ' '); \
		find "$$comp_dir" -maxdepth 1 -type l ! -exec test -e {} \; -delete 2>/dev/null; \
		echo "Removed $$pruned dangling completion symlink(s)"; \
		if [ "$$pruned" -gt 0 ]; then \
			find "${HOME}" -maxdepth 1 -name '.zcompdump*' -delete 2>/dev/null; \
			echo "Cleared compdump cache (rebuilds on next shell start)"; \
		fi; \
	fi

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
	cd ${HOME}/.dotfiles && git remote set-url origin git@github.com:cacack/dotfiles.git
