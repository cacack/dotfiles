################################################################################
# Variables

PYTHON_VERSION := 3.8.5
SHELLCHECK_VERSION := 0.7.1
ANSIBLE_PATH := .ansible

FZF_VERSION := 0.25.1


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

do-bootstrap: update-ansible-roles
	cd $(ANSIBLE_PATH); pipenv run ansible-playbook \
		--connection="local" \
		--inventory="localhost," \
		--extra-vars="host=localhost" \
		--ask-become-pass \
		bootstrap.yml
