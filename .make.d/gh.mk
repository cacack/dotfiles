# GitHub CLI (gh) installation
# https://github.com/cli/cli

GH_VERSION := 2.83.2

# SHA256 checksums from https://github.com/cli/cli/releases
GH_CHECKSUM_LINUX_AMD64 := ca6e7641214fbd0e21429cec4b64a7ba626fd946d8f9d6d191467545b092015e
GH_CHECKSUM_MACOS_AMD64 := 6f1712519ccc768946791dc97da407bf188582345b73fef3d604d050ebf6f614
GH_CHECKSUM_MACOS_ARM64 := ba3e0396ebbc8da17256144ddda503e4e79c8b502166335569f8390d6b75fa8d

ifeq ($(UNAME), Darwin)
GH_PLATFORM := macOS
GH_ARCH := $(ARCH_ALT)
ifeq ($(ARCH_ALT), arm64)
GH_CHECKSUM := $(GH_CHECKSUM_MACOS_ARM64)
else
GH_CHECKSUM := $(GH_CHECKSUM_MACOS_AMD64)
endif
endif
ifeq ($(UNAME), Linux)
GH_PLATFORM := linux
GH_ARCH := $(ARCH_ALT)
GH_CHECKSUM := $(GH_CHECKSUM_LINUX_AMD64)
endif

.PHONY: setup-gh
setup-gh: install-gh

.PHONY: install-gh
install-gh:
	@echo
	# Installing GitHub CLI (gh)
ifeq ($(UNAME), Darwin)
	curl -Ls -o gh.zip https://github.com/cli/cli/releases/download/v$(GH_VERSION)/gh_$(GH_VERSION)_$(GH_PLATFORM)_$(GH_ARCH).zip
	$(call verify_checksum,gh.zip,$(GH_CHECKSUM))
	unzip -q gh.zip
	mv gh_$(GH_VERSION)_$(GH_PLATFORM)_$(GH_ARCH)/bin/gh $(USER_BIN_DIR)/gh
	chmod 0755 $(USER_BIN_DIR)/gh
	rm -rf gh.zip gh_$(GH_VERSION)_$(GH_PLATFORM)_$(GH_ARCH)/
	xattr -dr com.apple.quarantine $(USER_BIN_DIR)/gh
else
	curl -Ls -o gh.tar.gz https://github.com/cli/cli/releases/download/v$(GH_VERSION)/gh_$(GH_VERSION)_$(GH_PLATFORM)_$(GH_ARCH).tar.gz
	$(call verify_checksum,gh.tar.gz,$(GH_CHECKSUM))
	tar -xzf gh.tar.gz
	mv gh_$(GH_VERSION)_$(GH_PLATFORM)_$(GH_ARCH)/bin/gh $(USER_BIN_DIR)/gh
	chmod 0755 $(USER_BIN_DIR)/gh
	rm -rf gh.tar.gz gh_$(GH_VERSION)_$(GH_PLATFORM)_$(GH_ARCH)/
endif
	@echo
	# GitHub CLI installation complete
	@echo "Run 'gh auth login' to authenticate with your GitHub account"
