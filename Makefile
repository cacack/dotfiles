################################################################################
# Variables

PYTHON_VERSION := 3.8.10
SHELLCHECK_VERSION := 0.7.2
KITTY_VERSION := 0.20.3
STARSHIP_VERSION := 0.54.0
LSD_VERSION := 0.20.1
NVM_VERSION := 0.37.2
ANSIBLE_PATH := .ansible

FZF_VERSION := 0.27.2


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

do-bootstrap:
	cd $(ANSIBLE_PATH); pipenv run ansible-playbook \
		--connection="local" \
		--inventory="localhost," \
		--extra-vars="host=localhost" \
		--ask-become-pass \
		bootstrap.yml

.PHONY: setup-kitty
setup-kitty:
	@echo
	wget -O kitty.txz https://github.com/kovidgoyal/kitty/releases/download/v$(KITTY_VERSION)/kitty-$(KITTY_VERSION)-x86_64.txz
	tar -x -C ~/bin/ -f kitty.txz bin/kitty
	chmod 755 ~/bin/kitty
	rm kitty.txz

.PHONY: setup-starship
setup-starship:
	@echo
	wget -O starship.tar.gz https://github.com/starship/starship/releases/download/v$(STARSHIP_VERSION)/starship-x86_64-unknown-linux-gnu.tar.gz
	tar -x -C /usr/local/bin --overwrite -f starship.tar.gz
	chmod 775 /usr/local/bin/starship
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
