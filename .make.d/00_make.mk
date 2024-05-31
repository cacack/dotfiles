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


# useful for debugging, just run make print-<VAR>
print-%  : ; @echo $* = $($*)


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
