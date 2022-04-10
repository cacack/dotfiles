################################################################################
# Variables

PYTHON_VERSION := 3.10.2
SHELLCHECK_VERSION := 0.8.0
KITTY_VERSION := 0.24.4
STARSHIP_VERSION := 1.5.4
LSD_VERSION := 0.21.0
NVM_VERSION := 0.39.1
FZF_VERSION := 0.29.0
NERD_FONT_VERSION := 2.1.0
CLOUD_NUKE_VERSION := 0.10.0

UNAME := $(shell uname)

ANSIBLE_PATH := .ansible

BASE_DIR ?= ${HOME}
RELATIVE_BIN_DIR := $(BASE_DIR)/bin

DOTFILES_CONFIG_DIR := ${HOME}/.dotfiles/configs
USER_BIN_DIR := ${HOME}/.local/bin

# OS-based directories
ifeq ($(UNAME), Linux)
USER_FONT_DIR := ${HOME}/.local/share/fonts
endif
ifeq ($(UNAME), Darwin)
USER_FONT_DIR := ${HOME}/Library/Fonts
endif

# Source the modular make files
#include .make.d/*.mk

SHELLCHECK_URL := https://github.com/koalaman/shellcheck/releases/download/v$(SHELLCHECK_VERSION)/shellcheck-v$(SHELLCHECK_VERSION).linux.x86_64.tar.xz

################################################################################
## Development targets

.PHONY: setup-shellcheck
setup-shellcheck:
	@echo
	curl -fLo shellcheck.tar.xz $(SHELLCHECK_URL)
	tar -xvf shellcheck.tar.xz --directory=$(RELATIVE_BIN_DIR) --mode=0755 --strip-components=1 shellcheck-v${SHELLCHECK_VERSION}/shellcheck
	rm shellcheck.tar.xz

.PHONY: lint-whitespace
lint-whitespace:
	@echo
	git diff --check HEAD --

.PHONY: lint-shellcheck
lint-shellcheck:
	@echo
	git grep -I --name-only --null -e '' \
    | xargs --null --max-lines=1 file --mime-type \
    | sed --quiet 's,: *text/x-shellscript$$,,p' \
    | xargs --no-run-if-empty shellcheck -x

.PHONY: lint-yaml
lint-yaml:
	@echo
	poetry run yamllint .

.PHONY: lint-ansible
lint-ansible:
	@echo
	poetry run ansible-lint $(ANSIBLE_PATH)

print-version: $(PRINT_VERSION)

# Setup development dependencies
#setup: setup-dirs $(SETUP)

setup-desktop: setup-dirs setup-configs setup-progs setup-fonts

setup-dirs:
	mkdir -p ${HOME}/{desktop,devel,documents,downloads,music,pictures,public,templates,video}
	mkdir -p ${HOME}/.local/{bin,shared/fonts}
	ln -sf ${DOTFILES_CONFIG_DIR}/user-dirs.dirs ${HOME}/.config/user-dirs.dirs
	rm -rf ${HOME}/{Desktop,Documents,Downloads,Music,Pictures,Public,Templates,Video}
	xdg-user-dirs-update

setup-configs: setup-tmux-config setup-zsh-config

setup-git-config:
	@echo
	ln -sf $(DOTFILES_CONFIG_DIR)/dot.config/git ${HOME}/.config/git.d

# macos: https://gist.github.com/bbqtd/a4ac060d6f6b9ea6fe3aabe735aa9d95
setup-tmux-config:
	@echo
	ln -sf ${DOTFILES_CONFIG_DIR}/dot.tmux.conf ${HOME}/.tmux.conf

setup-alacritty-config:
	@echo
	ln -sf ${DOTFILES_CONFIG_DIR}/dot.config/alacritty ${HOME}/.config/alacritty

setup-zsh-config:
	@echo
	ln -sf ${DOTFILES_CONFIG_DIR}/dot.zshenv ${HOME}/.zshenv
	ln -sf ${DOTFILES_CONFIG_DIR}/dot.zshrc ${HOME}/.zshrc
	ln -sf ${DOTFILES_CONFIG_DIR}/dot.zshrc.d ${HOME}/.zshrc.d
	[[ -d "${HOME}/.oh-my-zsh" ]] || git clone https://github.com/ohmyzsh/ohmyzsh.git ${HOME}/.oh-my-zsh
	#sudo sss_override user-add cac21 --shell /bin/zsh
	#sudo systemctl restart sssd
	rm -f ${HOME}/{.bashrc,.bash_history,.bash_logout,.bash_profile}

setup-progs: setup-fzf setup-kitty setup-starship setup-lsd setup-nvim setup-nvim-plug

.PHONY: setup-fzf
setup-fzf:
	@echo
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	${HOME}/.fzf/install
	#curl -s -J -L -o fzf.tar.gz https://github.com/junegunn/fzf/releases/download/$(FZF_VERSION)/fzf-$(FZF_VERSION)-linux_amd64.tar.gz
	#sudo tar -xzf fzf.tar.gz -C /usr/local/bin
	#rm fzf.tar.gz
	#sudo curl -s -J -L -o /usr/local/lib/fzf-completion.bash https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.bash
	#sudo curl -s -J -L -o /usr/local/lib/fzf-key-bindings.bash https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.bash
	#sudo chmod 644 /usr/local/lib/fzf-*
	#sudo chown root:root /usr/local/lib/fzf-*

.PHONY: setup-kitty
setup-kitty:
	@echo
	wget -O kitty.txz https://github.com/kovidgoyal/kitty/releases/download/v$(KITTY_VERSION)/kitty-$(KITTY_VERSION)-x86_64.txz
	sudo tar -xv -C /usr/local/bin/ --strip-components 1 -f kitty.txz bin/kitty
	sudo chmod 755 /usr/local/bin/kitty
	rm kitty.txz

.PHONY: setup-kitty-config
setup-kitty-config:
	ln -sf $(DOTFILES_CONFIG_DIR)/kitty.conf ${HOME}/.config/kitty/kitty.conf

.PHONY: setup-alacritty
setup-alacritty:
	@echo
	sudo dnf install alacritty

.PHONY: setup-starship
setup-starship:
	@echo
	wget -O starship.tar.gz https://github.com/starship/starship/releases/download/v$(STARSHIP_VERSION)/starship-x86_64-unknown-linux-gnu.tar.gz
	sudo tar -x -C /usr/local/bin --overwrite -f starship.tar.gz
	sudo chmod 775 /usr/local/bin/starship
	rm starship.tar.gz
	ln -sf $(DOTFILES_CONFIG_DIR)/starship.toml ${HOME}/.config/starship.toml

.PHONY: setup-starship-config
setup-starship-config:
	@echo
	ln -sf $(DOTFILES_CONFIG_DIR)/starship.toml ${HOME}/.config/starship.toml

.PHONY: setup-lsd
setup-lsd:
	@echo
	wget -O lsd.tar.gz https://github.com/Peltoche/lsd/releases/download/$(LSD_VERSION)/lsd-$(LSD_VERSION)-x86_64-unknown-linux-gnu.tar.gz
	sudo tar -x -C /usr/local/bin --overwrite --strip-components=1 -f lsd.tar.gz lsd-$(LSD_VERSION)-x86_64-unknown-linux-gnu/lsd
	sudo chmod 775 /usr/local/bin/lsd
	rm lsd.tar.gz

.PHONY: setup-neovim
setup-neovim:
	@echo
	curl -fLo ${USER_BIN_DIR}/nvim.appimage --create-dirs https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
	chmod 755 ${USER_BIN_DIR}/nvim.appimage

.PHONY: setup-nvim-config
setup-nvim-config:
	@echo
	ln -sf $(DOTFILES_CONFIG_DIR)/dot.config/nvim ${HOME}/.config/nvim
	ln -sf $(DOTFILES_CONFIG_DIR)/dot.config/coc ${HOME}/.config/coc
	cd ${HOME}/.config/coc/extensions; yarn install

.PHONY: setup-nvim-plug
setup-nvim-plug:
	@echo
	curl -fLo ${HOME}/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

.PHONY: setup-nvm
setup-nvm:
	@echo
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v$(NVM_VERSION)/install.sh | bash

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

.PHONY: setup-fonts
setup-fonts: setup-font-3270 setup-font-hack setup-font-meslo setup-font-mplus

.PHONY: setup-font-3270
setup-font-3270:
	@echo
	curl -fLo "$(USER_FONT_DIR)/3270 Medium Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/3270/Medium/complete/3270-Medium%20Nerd%20Font%20Complete.otf

.PHONY: setup-font-firacode
setup-font-firacode:
	@echo
	curl -fLo "$(USER_FONT_DIR)/Fira Code Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/complete/Fira%20Code%20Regular%20Nerd%20Font%20Complete.ttf
	curl -fLo "$(USER_FONT_DIR)/Fira Code Regular Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/complete/Fira%20Code%20Regular%20Nerd%20Font%20Complete%20Mono.ttf

.PHONY: setup-font-hack
setup-font-hack:
	@echo
	curl -fLo "$(USER_FONT_DIR)/Hack Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf

.PHONY: setup-font-jetbrains
setup-font-jetbrains:
	@echo
	curl -fLo "$(USER_FONT_DIR)/JetBrains Mono Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Regular/complete/JetBrains%20Mono%20Regular%20Nerd%20Font%20Complete.ttf

.PHONY: setup-font-meslo
setup-font-meslo:
	@echo
	curl -fLo "$(USER_FONT_DIR)/Meslo LG M DZ Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/M-DZ/Regular/complete/Meslo%20LG%20M%20DZ%20Regular%20Nerd%20Font%20Complete.ttf

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

.PHONY: setup-font-proggy
setup-font-proggy:
	@echo
	curl -fLo "$(USER_FONT_DIR)/ProggyClean Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/ProggyClean/Regular/complete/ProggyCleanTT%20Nerd%20Font%20Complete.ttf


################################################################################
## Lint targets


################################################################################
## Run targets

.PHONY: setup-poetry
setup-poetry:
	@echo
	if ! hash poetry 1>/dev/null 2>&1; then \
		curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | python - ;\
	fi

.PHONY: setup-python-build-dependencies
setup-python-build-dependencies:
	sudo dnf install make gcc zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel

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
	pyenv install --skip-existing $(shell cat .python-version) ;\
	pyenv rehash
	git clone https://github.com/pyenv/pyenv-virtualenv.git ${HOME}/.pyenv/plugins/pyenv-virtualenv

.PHONY: bootstrap
bootstrap: setup-poetry setup-pyenv
	@echo
	export PATH="${HOME}/.pyenv/bin:${HOME}/.local/bin:${PATH}" ;\
	eval "$(pyenv init --path)" ;\
	eval "$(pyenv init -)" ;\
	pyenv rehash ;\
	poetry install ;\
	cd $(ANSIBLE_PATH); poetry run ansible-playbook \
		--connection="local" \
		--inventory="localhost," \
		--extra-vars="host=localhost" \
		--ask-become-pass \
		bootstrap.yml

.PHONY: update-python-version
update-python-version:
	@echo
	echo $(PYTHON_VERSION) > .python-version
