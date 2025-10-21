GH_VERSION := 2.82.0

ifeq ($(UNAME), Darwin)
GH_PLATFORM := macOS
GH_ARCH := $(ARCH_ALT)
GH_ARCHIVE := zip
else ifeq ($(UNAME), Linux)
GH_PLATFORM := linux
GH_ARCH := $(ARCH_ALT)
GH_ARCHIVE := tar.gz
endif

.PHONY: setup-gh
setup-gh: install-gh

.PHONY: install-gh
install-gh:
	@echo
	# Installing GitHub CLI (gh)
ifeq ($(UNAME), Darwin)
	curl -Ls -o gh.zip https://github.com/cli/cli/releases/download/v$(GH_VERSION)/gh_$(GH_VERSION)_$(GH_PLATFORM)_$(GH_ARCH).zip
	unzip -q gh.zip
	mv gh_$(GH_VERSION)_$(GH_PLATFORM)_$(GH_ARCH)/bin/gh $(USER_BIN_DIR)/gh
	chmod 0755 $(USER_BIN_DIR)/gh
	rm -rf gh.zip gh_$(GH_VERSION)_$(GH_PLATFORM)_$(GH_ARCH)/
	xattr -dr com.apple.quarantine $(USER_BIN_DIR)/gh
else
	curl -Ls -o gh.tar.gz https://github.com/cli/cli/releases/download/v$(GH_VERSION)/gh_$(GH_VERSION)_$(GH_PLATFORM)_$(GH_ARCH).tar.gz
	tar -xzf gh.tar.gz
	mv gh_$(GH_VERSION)_$(GH_PLATFORM)_$(GH_ARCH)/bin/gh $(USER_BIN_DIR)/gh
	chmod 0755 $(USER_BIN_DIR)/gh
	rm -rf gh.tar.gz gh_$(GH_VERSION)_$(GH_PLATFORM)_$(GH_ARCH)/
endif
	@echo
	# GitHub CLI installation complete
	@echo "Run 'gh auth login' to authenticate with your GitHub account"
