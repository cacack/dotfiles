################################################################################
# Variables

FZF_VERSION := 0.35.1
KITTY_VERSION := 0.26.5
LSD_VERSION := 0.23.1
NERD_FONT_VERSION := 2.1.0
NVM_VERSION := 0.39.3
PYTHON_VERSION := 3.11.1
SHELLCHECK_VERSION := 0.8.0
STARSHIP_VERSION := 1.12.0

# Source the modular make files
include .make.d/*.mk


################################################################################
# Development targets

check: $(CHECK)

print-version: $(PRINT_VERSION)

lint: $(LINT)


################################################################################
# Dotfile targets

setup-desktop: setup-dirs setup-configs setup-progs setup-fonts

setup-dirs:
	@echo
	mkdir -p ${HOME}/devel
ifeq ($(OS),linux)
	mkdir -p ${HOME}/{desktop,documents,downloads,music,pictures,video}
	mkdir -p ${HOME}/.local/{bin,shared/fonts}
	cp -f ${DOTFILES_CONFIG_DIR}/user-dirs.dirs ${HOME}/.config/user-dirs.dirs
	rm -rf ${HOME}/{Desktop,Documents,Downloads,Music,Pictures,Public,Templates,Video}
	#xdg-user-dirs-update
endif
ifeq ($(OS),darwin)
	mkdir -p ${HOME}/.config
endif


################################################################################
# Generic configs

setup-configs: setup-git-config setup-zsh-config

setup-git-config:
	@echo
	ln -sf $(DOTFILES_CONFIG_DIR)/dot.config/git ${HOME}/.config/git.d

setup-zsh-config:
	@echo
	ln -sf ${DOTFILES_CONFIG_DIR}/dot.zshenv ${HOME}/.zshenv
	ln -sf ${DOTFILES_CONFIG_DIR}/dot.zshrc ${HOME}/.zshrc
	ln -sf ${DOTFILES_CONFIG_DIR}/dot.zshrc.d ${HOME}/.zshrc.d
	[[ -d "${HOME}/.oh-my-zsh" ]] || git clone https://github.com/ohmyzsh/ohmyzsh.git ${HOME}/.oh-my-zsh
	rm -f ${HOME}/{.bashrc,.bash_history,.bash_logout,.bash_profile}

setup-sssd:
	sudo sss_override user-add ${USER} --shell /bin/zsh
	sudo systemctl restart sssd

################################################################################
# Programs

setup-progs: setup-tmux setup-fzf setup-kitty setup-starship setup-lsd setup-nvim setup-nvim-plug

# Homebrew is a bit special since it is a dep for other things...
setup-homebrew:
	curl -fsSL -o install.sh https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
	chmod 755 ./install.sh
	./install.sh
	rm ./install.sh

# macos: https://gist.github.com/bbqtd/a4ac060d6f6b9ea6fe3aabe735aa9d95
setup-tmux: install-tmux setup-tmux-config

install-tmux:
	@echo
ifeq ($(OS),darwin)
	curl -LO https://invisible-island.net/datafiles/current/terminfo.src.gz && gunzip terminfo.src.gz
	sudo /usr/bin/tic -xe tmux-256color terminfo.src
	brew install tmux
endif

setup-tmux-config:
	@echo
	ln -sf ${DOTFILES_CONFIG_DIR}/dot.tmux.conf ${HOME}/.tmux.conf

.PHONY: setup-fzf
setup-fzf:
	@echo
ifeq ($(OS),linux)
	#https://github.com/junegunn/fzf/releases/download/0.30.0/fzf-0.30.0-linux_amd64.tar.gz
	wget -O fzf.tar.gz https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tar.gz
	tar -xvzf fzf.tar.gz
	cp fzf ${USER_BIN_DIR}/fzf
	chmod 755 ${USER_BIN_DIR}/fzf
	rm -f fzf fzf.tar.gz
endif
ifeq ($(OS),darwin)
	brew install fzf
endif

.PHONY: setup-kitty
setup-kitty: install-kitty setup-kitty-config

.PHONY: install-kitty
install-kitty:
ifeq ($(OS),linux)
	@echo
	wget -O kitty.txz https://github.com/kovidgoyal/kitty/releases/download/v$(KITTY_VERSION)/kitty-$(KITTY_VERSION)-x86_64.txz
	sudo tar -xv -C /usr/local/bin/ --strip-components 1 -f kitty.txz bin/kitty
	sudo chmod 755 /usr/local/bin/kitty
	rm kitty.txz
endif
ifeq ($(OS),darwin)
	@echo
	brew install kitty
endif

.PHONY: setup-kitty-config
setup-kitty-config:
	mkdir -p ${HOME}/.config/kitty
	ln -sf $(DOTFILES_CONFIG_DIR)/kitty.conf ${HOME}/.config/kitty/kitty.conf

.PHONY: setup-starship
setup-starship: install-starship setup-starship-config

.PHONY: install-starship
install-starship:
	@echo
ifeq ($(OS),linux)
	wget -O starship.tar.gz https://github.com/starship/starship/releases/download/v$(STARSHIP_VERSION)/starship-x86_64-unknown-linux-gnu.tar.gz
	sudo tar -x -C /usr/local/bin --overwrite -f starship.tar.gz
	sudo chmod 775 /usr/local/bin/starship
	rm starship.tar.gz
endif
ifeq ($(OS),darwin)
	brew install starship
endif

.PHONY: setup-starship-config
setup-starship-config:
	@echo
	ln -sf $(DOTFILES_CONFIG_DIR)/starship.toml ${HOME}/.config/starship.toml

.PHONY: setup-lsd
setup-lsd:
	@echo
ifeq ($(OS),linux)
	wget -O lsd.tar.gz https://github.com/Peltoche/lsd/releases/download/$(LSD_VERSION)/lsd-$(LSD_VERSION)-x86_64-unknown-linux-gnu.tar.gz
	sudo tar -x -C /usr/local/bin --overwrite --strip-components=1 -f lsd.tar.gz lsd-$(LSD_VERSION)-x86_64-unknown-linux-gnu/lsd
	sudo chmod 775 /usr/local/bin/lsd
	rm lsd.tar.gz
endif
ifeq ($(OS),darwin)
	brew install lsd
endif

setup-nodejs:
	@echo
ifeq ($(OS),darwin)
	brew install node@16 yarn
endif

.PHONY: setup-neovim
setup-neovim: install-neovim setup-neovim-config

.PHONY: install-neovim
install-neovim:
	@echo
ifeq ($(OS),linux)
	curl -fLo ${USER_BIN_DIR}/nvim.appimage --create-dirs https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
	chmod 755 ${USER_BIN_DIR}/nvim.appimage
endif
ifeq ($(OS),darwin)
	brew install neovim
endif

.PHONY: setup-neovim-config
setup-neovim-config: setup-nodejs
	@echo
	ln -sf $(DOTFILES_CONFIG_DIR)/dot.config/nvim ${HOME}/.config/nvim
	ln -sf $(DOTFILES_CONFIG_DIR)/dot.config/coc ${HOME}/.config/coc
	cd ${HOME}/.config/coc/extensions; yarn install

.PHONY: setup-neovim-plug
setup-neovim-plug:
	@echo
	curl -fLo ${HOME}/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

.PHONY: setup-nvm
setup-nvm:
	@echo
ifeq ($(OS),linux)
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v$(NVM_VERSION)/install.sh | bash
endif
ifeq ($(OS),darwin)
	brew install nvm
endif

.PHONY: setup-aws-cli
setup-aws-cli:
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip awscliv2.zip
	./aws/install --install-dir ~/.aws-cli --bin-dir ${USER_BIN_DIR}
	rm -rf awscliv2.zip aws

.PHONY: setup-cloud-nuke
setup-cloud-nuke:
	curl -fLo ${USER_BIN_DIR}/cloud-nuke "https://github.com/gruntwork-io/cloud-nuke/releases/download/v0.10.0/cloud-nuke_linux_amd64"
	chmod 755 ${USER_BIN_DIR}/cloud-nuke


################################################################################
# Fonts
# kitty +list-fonts

.PHONY: setup-fonts
setup-fonts: setup-font-3270 setup-font-firacode setup-font-hack setup-font-jetbrains setup-font-meslo setup-font-mononoki setup-font-proggy

.PHONY: setup-font-3270
setup-font-3270:
	@echo
	curl -fLo "$(USER_FONT_DIR)/3270 Medium Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/3270/Medium/complete/3270-Medium%20Nerd%20Font%20Complete.otf
	curl -fLo "$(USER_FONT_DIR)/3270 Medium Nerd Font Complete Mono.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/3270/Medium/complete/3270-Medium%20Nerd%20Font%20Complete%20Mono.otf

.PHONY: setup-font-firacode
setup-font-firacode:
	@echo
	curl -fLo "$(USER_FONT_DIR)/Fira Code Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/complete/Fira%20Code%20Regular%20Nerd%20Font%20Complete.ttf
	curl -fLo "$(USER_FONT_DIR)/Fira Code Regular Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/complete/Fira%20Code%20Regular%20Nerd%20Font%20Complete%20Mono.ttf

.PHONY: setup-font-hack
setup-font-hack:
	@echo
	curl -fLo "$(USER_FONT_DIR)/Hack Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf
	curl -fLo "$(USER_FONT_DIR)/Hack Regular Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete%20Mono.ttf
	curl -fLo "$(USER_FONT_DIR)/Hack Bold Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Bold/complete/Hack%20Bold%20Nerd%20Font%20Complete%20Mono.ttf
	curl -fLo "$(USER_FONT_DIR)/Hack Italic Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Italic/complete/Hack%20Italic%20Nerd%20Font%20Complete%20Mono.ttf

.PHONY: setup-font-jetbrains
setup-font-jetbrains:
	@echo
	curl -fLo "$(USER_FONT_DIR)/JetBrains Mono Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Regular/complete/JetBrains%20Mono%20Regular%20Nerd%20Font%20Complete.ttf
	curl -fLo "$(USER_FONT_DIR)/JetBrains Mono Regular Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Regular/complete/JetBrains%20Mono%20Regular%20Nerd%20Font%20Complete%20Mono.ttf
	curl -fLo "$(USER_FONT_DIR)/JetBrains Mono Bold Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Bold/complete/JetBrains%20Mono%20Bold%20Nerd%20Font%20Complete%20Mono.ttf
	curl -fLo "$(USER_FONT_DIR)/JetBrains Mono Italic Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Italic/complete/JetBrains%20Mono%20Italic%20Nerd%20Font%20Complete%20Mono.ttf

.PHONY: setup-font-meslo
setup-font-meslo:
	@echo
	curl -fLo "$(USER_FONT_DIR)/Meslo LG M DZ Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/M-DZ/Regular/complete/Meslo%20LG%20M%20DZ%20Regular%20Nerd%20Font%20Complete.ttf
	curl -fLo "$(USER_FONT_DIR)/Meslo LG M DZ Regular Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/M-DZ/Regular/complete/Meslo%20LG%20M%20DZ%20Regular%20Nerd%20Font%20Complete%20Mono.ttf
	curl -fLo "$(USER_FONT_DIR)/Meslo LG M DZ Bold Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/M-DZ/Bold/complete/Meslo%20LG%20M%20DZ%20Bold%20Nerd%20Font%20Complete%20Mono.ttf
	curl -fLo "$(USER_FONT_DIR)/Meslo LG M DZ Bold Italic Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/M-DZ/Bold-Italic/complete/Meslo%20LG%20M%20DZ%20Bold%20Italic%20Nerd%20Font%20Complete%20Mono.ttf
	curl -fLo "$(USER_FONT_DIR)/Meslo LG M DZ Italic Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/M-DZ/Italic/complete/Meslo%20LG%20M%20DZ%20Italic%20Nerd%20Font%20Complete%20Mono.ttf

.PHONY: setup-font-mplus
setup-font-mplus:
	@echo
	curl -fLo font.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v$(NERD_FONT_VERSION)/MPlus.zip
	unzip -o -d ${USER_FONT_DIR} font.zip
	rm font.zip

.PHONY: setup-font-mononoki
setup-font-mononoki:
	@echo
	curl -fLo "$(USER_FONT_DIR)/mononoki Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Mononoki/Regular/complete/mononoki-Regular%20Nerd%20Font%20Complete.ttf
	curl -fLo "$(USER_FONT_DIR)/mononoki Regular Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Mononoki/Regular/complete/mononoki-Regular%20Nerd%20Font%20Complete%20Mono.ttf
	curl -fLo "$(USER_FONT_DIR)/mononoki Bold Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Mononoki/Bold/complete/mononoki%20Bold%20Nerd%20Font%20Complete%20Mono.ttf
	curl -fLo "$(USER_FONT_DIR)/mononoki Bold Italic Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Mononoki/Bold-Italic/complete/mononoki%20Bold%20Italic%20Nerd%20Font%20Complete%20Mono.ttf
	curl -fLo "$(USER_FONT_DIR)/mononoki Italic Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Mononoki/Italic/complete/mononoki%20Italic%20Nerd%20Font%20Complete%20Mono.ttf

.PHONY: setup-font-proggy
setup-font-proggy:
	@echo
	curl -fLo "$(USER_FONT_DIR)/ProggyClean Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/ProggyClean/Regular/complete/ProggyCleanTT%21Nerd%20Font%20Complete.ttf
	curl -fLo "$(USER_FONT_DIR)/ProggyClean Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/ProggyClean/Regular/complete/ProggyCleanTT%20Nerd%20Font%20Complete%20Mono.ttf

.PHONY: setup-font-glyphs
setup-font-glyphs:
	@echo
	curl -fLo font.zip https://github.com/ryanoasis/nerd-fonts/releases/download/2.2.0-RC/NerdFontsSymbolsOnly.zip
	unzip font.zip *.ttf
	mv *.ttf $(USER_FONT_DIR)/
	rm font.zip


.PHONY: setup-poetry
setup-poetry:
	@echo
	if ! hash poetry 1>/dev/null 2>&1; then \
		curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | python - ;\
	fi

.PHONY: setup-python-build-dependencies
setup-python-build-dependencies:
ifeq ($(DISTRO),Fedora)
	sudo dnf install make gcc zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel
endif
ifeq ($(DISTRO),Ubuntu)
	sudo apt install --no-install-recommends make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
endif

.PHONY: setup-pyenv
setup-pyenv: setup-python-build-dependencies
	@echo
	if ! hash pyenv 1>/dev/null 2>&1; then \
		if [[ ! -d "${HOME}.pyenv" ]]; then \
			git clone https://github.com/pyenv/pyenv.git ${HOME}/.pyenv ;\
		else \
			cd "${HOME}/.pyenv" && git pull ;\
		fi ;\
		export PYENV_ROOT="$${HOME}/.pyenv" ;\
		export PATH="$${PYENV_ROOT}/bin:$${PATH}" ;\
		eval "$$(pyenv init --path)" ;\
	fi ;\
	cd "${HOME}/.pyenv" && git pull ;\
	cd - ;\
	pyenv install --skip-existing $(PYTHON_VERSION) ;\
	pyenv rehash
	git clone https://github.com/pyenv/pyenv-virtualenv.git ${HOME}/.pyenv/plugins/pyenv-virtualenv
