################################################################################
# Variables

PYTHON_VERSION := 3.9.7
SHELLCHECK_VERSION := 0.8.0
KITTY_VERSION := 0.23.1
STARSHIP_VERSION := 1.0.0
LSD_VERSION := 0.20.1
NVM_VERSION := 0.39.0
ANSIBLE_PATH := .ansible

FZF_VERSION := 0.28.0
NERD_FONT_VERSION := 2.1.0


# Source the modular make files
include .make.d/*.mk

################################################################################
## Development targets

print-version: $(PRINT_VERSION)

# Setup development dependencies
setup: setup-dirs $(SETUP)

setup-dirs:
	mkdir -p ${HOME}/bin

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
	tar -xv -C ~/bin/ --strip-components 1 -f kitty.txz bin/kitty
	chmod 755 ~/bin/kitty
	rm kitty.txz

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
	tar -x -C /usr/local/bin --overwrite --strip-components=1 -f lsd.tar.gz lsd-$(LSD_VERSION)-x86_64-unknown-linux-gnu/lsd
	chmod 775 /usr/local/bin/lsd
	rm lsd.tar.gz

.PHONY: setup-nvm
setup-nvm:
	@echo
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v$(NVM_VERSION)/install.sh | bash

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

# Update development dependencies
update: $(UPDATE)

# Apply code fix-ups
fixup: $(FIXUP)

# Clean up things from the development process
clean: $(CLEAN)


################################################################################
## Lint targets
lint: $(LINT)

# dockerized execution
lint-dockerized: $(LINT_DOCKERIZED)

unit-test: $(UNIT_TEST)

acceptance-test: $(ACCEPTANCE_TEST)

run: $(RUN)

.PHONY: bootstrap
bootstrap: setup-poetry
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
	pyenv rehash ;\
	poetry install ;\
	cd $(ANSIBLE_PATH); poetry run ansible-playbook \
		--connection="local" \
		--inventory="localhost," \
		--extra-vars="host=localhost" \
		--ask-become-pass \
		bootstrap.yml
