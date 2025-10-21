GH_VERSION := 2.82.0

# SHA256 checksums from https://github.com/cli/cli/releases/download/v2.82.0/gh_2.82.0_checksums.txt
GH_CHECKSUM_LINUX_AMD64 := aba32dd552112101464941c7b5ee5f097896e1e234eb99581ff1652f44c4009a
GH_CHECKSUM_MACOS_AMD64 := c5dd3ebea62a7363226026acf0493eda93a66273f8fbf24014a73fb33330ab14
GH_CHECKSUM_MACOS_ARM64 := c52d24f92858743e7142c0ddbea7ba3679e116062a48f364be8fe6aa6b24e42c

ifeq ($(UNAME), Darwin)
GH_PLATFORM := macOS
GH_ARCH := $(ARCH_ALT)
GH_ARCHIVE := zip
ifeq ($(ARCH_ALT), arm64)
GH_CHECKSUM := $(GH_CHECKSUM_MACOS_ARM64)
else
GH_CHECKSUM := $(GH_CHECKSUM_MACOS_AMD64)
endif
else ifeq ($(UNAME), Linux)
GH_PLATFORM := linux
GH_ARCH := $(ARCH_ALT)
GH_ARCHIVE := tar.gz
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
