################################################################################
# Basic make configuration
#
# Mostly defines some variables that other make targets can leverage.
################################################################################

################################################################################
# Variables
UNAME := $(shell uname)
ARCH := $(shell uname -m)

BASE_DIR ?= ${HOME}/.local
BIN_DIR := $(BASE_DIR)/bin
SHARE_DIR := $(BASE_DIR)/share

DOTFILES_CONFIG_DIR := ${HOME}/.dotfiles/configs
DOTFILES_SCRIPT_DIR := ${HOME}/.dotfiles/scripts
USER_BIN_DIR := ${HOME}/.local/bin

REPO_DIR := $(shell git rev-parse --show-toplevel)
REPO_URL := $(shell git remote get-url --push origin)
REPO_NAME := $(shell git remote get-url --push origin | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')


# Architecture-based variables
ifeq ($(ARCH), x86_64)
ARCH_ALT := amd64
endif
ifeq ($(ARCH), arm64)
ARCH_ALT := arm64
endif

# OS-based directories
ifeq ($(UNAME), Linux)
OS := linux
DISTRO := $(shell lsb_release -si)
SHELL := $(shell which bash)
USER_FONT_DIR := ${HOME}/.local/share/fonts
endif
ifeq ($(UNAME), Darwin)
OS := darwin
DISTRO := none
SHELL := /bin/zsh
USER_FONT_DIR := ${HOME}/Library/Fonts
endif

################################################################################
# Checksum verification
################################################################################
CHECKSUMS_FILE := $(REPO_DIR)/.make.d/checksums.txt
MAKEFILE_CHECKSUMS_FILE := $(REPO_DIR)/.make.d/makefile-checksums.txt

# Determine which shasum command is available
ifeq ($(UNAME), Darwin)
SHASUM := shasum -a 256
SHASUM_CHECK := shasum -a 256 -c
else
SHASUM := sha256sum
SHASUM_CHECK := sha256sum -c
endif

# Usage: $(call verify_checksum,file,expected_checksum)
# Example: $(call verify_checksum,downloaded.tar.gz,$(GH_CHECKSUM_MACOS_ARM64))
define verify_checksum
	@echo "Verifying checksum for $(1)..."
	@EXPECTED="$(2)"; \
	if [ -z "$$EXPECTED" ]; then \
		echo "ERROR: No checksum provided for $(1)"; \
		echo "Please provide a checksum as the second parameter."; \
		exit 1; \
	fi; \
	ACTUAL=$$($(SHASUM) $(1) | awk '{print $$1}'); \
	if [ "$$EXPECTED" != "$$ACTUAL" ]; then \
		echo "ERROR: Checksum verification failed for $(1)"; \
		echo "Expected: $$EXPECTED"; \
		echo "Actual:   $$ACTUAL"; \
		echo "File may be corrupted or tampered with."; \
		rm -f $(1); \
		exit 1; \
	fi; \
	echo "✓ Checksum verified for $(1)"
endef


# useful for debugging, just run make print-<VAR>
print-%  : ; @echo $* = $($*)

# list all available make targets in alphabetical order
.PHONY: list-targets
list-targets:
	@$(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | \
		awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | \
		sort -u | \
		grep -E -v '^(Makefile|[^[:alnum:]])' | \
		grep -v '^$$'


################################################################################
SETUP += setup-bin-dir

.PHONY: setup-bin-dir
setup-bin-dir:
	@echo
	# Ensure bin dir exists and is referenced in $PATH
	mkdir -p $(BIN_DIR)
	@if [[ ":${PATH}:" != *":$(BIN_DIR):"* ]]; then echo "Your \$PATH is missing bin dir ${BIN_DIR}.  Please correct."; fi


################################################################################
#UPDATE +=


.PHONY: print-repo-directory
print-repo-directory:
	@echo
	echo $(REPO_DIR)

.PHONY: print-repo-name
print-repo-name:
	@echo $(REPO_NAME)

################################################################################
# Makefile integrity verification
################################################################################

.PHONY: verify-makefiles
verify-makefiles:
	@echo
	@echo "Verifying integrity of Makefile modules..."
	@cd $(REPO_DIR)/.make.d && \
	if $(SHASUM_CHECK) --quiet makefile-checksums.txt 2>/dev/null; then \
		echo "✓ All Makefile modules verified successfully"; \
	else \
		echo "ERROR: Makefile verification failed!"; \
		echo "One or more .mk files have been modified or corrupted."; \
		echo ""; \
		echo "To see which files changed:"; \
		echo "  cd .make.d && $(SHASUM_CHECK) makefile-checksums.txt"; \
		echo ""; \
		echo "If changes are intentional, regenerate checksums:"; \
		echo "  cd .make.d && shasum -a 256 *.mk | sort -k2 > makefile-checksums.txt.new"; \
		echo "  # Review changes, then:"; \
		echo "  mv makefile-checksums.txt.new makefile-checksums.txt"; \
		exit 1; \
	fi
	@echo
