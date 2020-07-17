################################################################################
# Variables

PYTHON_VERSION := 3.8.3
SHELLCHECK_VERSION := 0.7.1


# Source the modular make files
include .make.d/*.mk

################################################################################
## Development targets

print-version: $(PRINT_VERSION)

# Setup development dependencies
setup: $(SETUP)

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
