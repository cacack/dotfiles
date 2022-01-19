################################################################################
# Variables

PYTHON_VERSION := 3.10.2
SHELLCHECK_VERSION := 0.8.0
KITTY_VERSION := 0.24.1
STARSHIP_VERSION := 1.2.1
LSD_VERSION := 0.21.0
NVM_VERSION := 0.39.1
FZF_VERSION := 0.29.0
NERD_FONT_VERSION := 2.1.0

ANSIBLE_PATH := .ansible

# Source the modular make files
#include .make.d/*.mk

################################################################################
## Development targets

print-version: $(PRINT_VERSION)

# Setup development dependencies
setup: setup-dirs $(SETUP)

setup-desktop: setup-dirs setup-configs setup-progs setup-fonts

setup-dirs:
	mkdir -p ${HOME}/{.fonts,bin,desktop,devel,documents,downloads,music,pictures,public,templates,video}
	ln -sf ${HOME}/.dotfiles/configs/user-dirs.dirs ${HOME}/.config/user-dirs.dirs
	rm -rf ${HOME}/{Desktop,Documents,Downloads,Music,Pictures,Public,Templates,Video}
	xdg-user-dirs-update

setup-configs: setup-tmux-config setup-zsh-config

setup-tmux-config:
	@echo
	ln -sf ${HOME}/.dotfiles/configs/dot.tmux.conf ${HOME}/.tmux.conf

setup-alacritty-config:
	@echo
	ln -sf ${HOME}/.dotfiles/configs/dot.config/alacritty ${HOME}/.config/alacritty

setup-zsh-config:
	@echo
	ln -sf ${HOME}/.dotfiles/configs/dot.zshenv ${HOME}/.zshenv
	ln -sf ${HOME}/.dotfiles/configs/dot.zshrc ${HOME}/.zshrc
	ln -sf ${HOME}/.dotfiles/configs/dot.zshrc.d ${HOME}/.zshrc.d
	[[ -d "${HOME}/.oh-my-zsh" ]] || git clone https://github.com/ohmyzsh/ohmyzsh.git ${HOME}/.oh-my-zsh
	sudo sss_override user-add cac21 --shell /bin/zsh
	sudo systemctl restart sssd
	rm -f ${HOME}/{.bashrc,.bash_history,.bash_logout,.bash_profile}

setup-progs: setup-fzf setup-kitty setup-starship setup-lsd setup-nvim setup-nvim-plug

.PHONY: setup-fzf
setup-fzf:
	@echo
	curl -s -J -L -o fzf.tar.gz https://github.com/junegunn/fzf/releases/download/$(FZF_VERSION)/fzf-$(FZF_VERSION)-linux_amd64.tar.gz
	sudo tar -xzf fzf.tar.gz -C /usr/local/bin
	rm fzf.tar.gz
	sudo curl -s -J -L -o /usr/local/lib/fzf-completion.bash https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.bash
	sudo curl -s -J -L -o /usr/local/lib/fzf-key-bindings.bash https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.bash
	sudo chmod 644 /usr/local/lib/fzf-*
	sudo chown root:root /usr/local/lib/fzf-*

.PHONY: setup-kitty
setup-kitty:
	@echo
	wget -O kitty.txz https://github.com/kovidgoyal/kitty/releases/download/v$(KITTY_VERSION)/kitty-$(KITTY_VERSION)-x86_64.txz
	sudo tar -xv -C /usr/local/bin/ --strip-components 1 -f kitty.txz bin/kitty
	sudo chmod 755 /usr/local/bin/kitty
	rm kitty.txz

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

.PHONY: setup-lsd
setup-lsd:
	@echo
	wget -O lsd.tar.gz https://github.com/Peltoche/lsd/releases/download/$(LSD_VERSION)/lsd-$(LSD_VERSION)-x86_64-unknown-linux-gnu.tar.gz
	sudo tar -x -C /usr/local/bin --overwrite --strip-components=1 -f lsd.tar.gz lsd-$(LSD_VERSION)-x86_64-unknown-linux-gnu/lsd
	sudo chmod 775 /usr/local/bin/lsd
	rm lsd.tar.gz

.PHONY: setup-nvim
setup-nvim:
	@echo
	curl -fLo ${HOME}/bin/nvim.appimage --create-dirs https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
	chmod 755 ${HOME}/bin/nvim.appimage

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
	./aws/install --install-dir ~/.aws-cli --bin-dir ${HOME}/.local/bin
	rm -rf awscliv2.zip aws


################################################################################
# Fonts

.PHONY: setup-fonts
setup-fonts: setup-font-3270 setup-font-hack setup-font-meslo setup-font-mplus

.PHONY: setup-font-3270
setup-font-3270:
	@echo
	wget -O font.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v$(NERD_FONT_VERSION)/3270.zip
	unzip -o -d ${HOME}/.fonts font.zip
	rm font.zip

.PHONY: setup-font-hack
setup-font-hack:
	@echo
	wget -O font.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v$(NERD_FONT_VERSION)/Hack.zip
	unzip -o -d ${HOME}/.fonts font.zip
	rm font.zip

.PHONY: setup-font-meslo
setup-font-meslo:
	@echo
	wget -O font.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v$(NERD_FONT_VERSION)/Meslo.zip
	unzip -o -d ${HOME}/.fonts font.zip
	rm font.zip

.PHONY: setup-font-mplus
setup-font-mplus:
	@echo
	wget -O font.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v$(NERD_FONT_VERSION)/MPlus.zip
	unzip -o -d ${HOME}/.fonts font.zip
	rm font.zip



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
