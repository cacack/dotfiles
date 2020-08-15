################################################################################
# Variables

PYTHON_VERSION := 3.8.5
SHELLCHECK_VERSION := 0.7.1
ANSIBLE_PATH := .ansible


# Source the modular make files
include .make.d/*.mk

################################################################################
## Development targets

print-version: $(PRINT_VERSION)

# Setup development dependencies
setup: setup-dirs $(SETUP)

setup-dirs:
	mkdir -p ${HOME}/bin

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
