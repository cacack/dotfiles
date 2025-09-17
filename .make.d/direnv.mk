DIRENV_VERSION := 2.37.1

ifeq ($(UNAME), Darwin)
DIRENV_PLATFORM := darwin
DIRENV_ARCH := $(ARCH)
endif
ifeq ($(UNAME), Linux)
DIRENV_PLATFORM := linux
DIRENV_ARCH := $(ARCH)
endif

.PHONY: setup-direnv
setup-direnv: install-direnv

.PHONY: install-direnv
install-direnv:
	@echo
	# Installing direnv
	curl -Ls -o direnv https://github.com/direnv/direnv/releases/download/v$(DIRENV_VERSION)/direnv.$(DIRENV_PLATFORM)-$(DIRENV_ARCH)
	mv direnv $(USER_BIN_DIR)/direnv
	chmod 0755 $(USER_BIN_DIR)/direnv
ifeq ($(UNAME), Darwin)
	xattr -dr com.apple.quarantine $(USER_BIN_DIR)/direnv
endif
	@echo
	# direnv installation complete