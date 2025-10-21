DIRENV_VERSION := 2.37.1

# SHA256 checksums - direnv doesn't publish checksums file
# Verify manually: download binary and run: shasum -a 256 <file>
# TODO: Add checksums after manual verification
DIRENV_CHECKSUM_DARWIN_ARM64 :=
DIRENV_CHECKSUM_DARWIN_X86_64 :=
DIRENV_CHECKSUM_LINUX_ARM64 :=
DIRENV_CHECKSUM_LINUX_X86_64 :=

ifeq ($(UNAME), Darwin)
DIRENV_PLATFORM := darwin
DIRENV_ARCH := $(ARCH)
ifeq ($(ARCH), arm64)
DIRENV_CHECKSUM := $(DIRENV_CHECKSUM_DARWIN_ARM64)
else
DIRENV_CHECKSUM := $(DIRENV_CHECKSUM_DARWIN_X86_64)
endif
endif
ifeq ($(UNAME), Linux)
DIRENV_PLATFORM := linux
DIRENV_ARCH := $(ARCH)
ifeq ($(ARCH), arm64)
DIRENV_CHECKSUM := $(DIRENV_CHECKSUM_LINUX_ARM64)
else
DIRENV_CHECKSUM := $(DIRENV_CHECKSUM_LINUX_X86_64)
endif
endif

.PHONY: setup-direnv
setup-direnv: install-direnv
	chmod +x configs/.zshrc.d/30_direnv.zsh

.PHONY: install-direnv
install-direnv:
	@echo
	# Installing direnv
	curl -Ls -o direnv https://github.com/direnv/direnv/releases/download/v$(DIRENV_VERSION)/direnv.$(DIRENV_PLATFORM)-$(DIRENV_ARCH)
ifneq ($(DIRENV_CHECKSUM),)
	$(call verify_checksum,direnv,$(DIRENV_CHECKSUM))
else
	@echo "WARNING: No checksum available for direnv.$(DIRENV_PLATFORM)-$(DIRENV_ARCH)"
	@echo "Skipping checksum verification (not recommended)"
endif
	mv direnv $(USER_BIN_DIR)/direnv
	chmod 0755 $(USER_BIN_DIR)/direnv
ifeq ($(UNAME), Darwin)
	xattr -dr com.apple.quarantine $(USER_BIN_DIR)/direnv
endif
	@echo
	# direnv installation complete