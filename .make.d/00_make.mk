# Enforce use of bash for make to avoid issues in Debian-based distro's that use dash.
SHELL := /usr/bin/bash

UNAME := $(shell uname)
ARCH := $(shell uname -m)

BASE_DIR ?= ${HOME}/.local
BIN_DIR := $(BASE_DIR)/bin

DOTFILES_CONFIG_DIR := ${HOME}/.dotfiles/configs
USER_BIN_DIR := ${HOME}/.local/bin

# Architecture-based variables
ifeq ($(ARCH), x86_64)
ARCH_ALT := amd64
endif
ifeq ($(ARCH), arm64)
ARCH_ALT := arm64
endif

# OS-based directories
ifeq ($(UNAME), Linux)
USER_FONT_DIR := ${HOME}/.local/share/fonts
OS := linux
DISTO := $(shell lsb_release -si)
endif
ifeq ($(UNAME), Darwin)
USER_FONT_DIR := ${HOME}/Library/Fonts
OS := darwin
DISTRO := none
endif
