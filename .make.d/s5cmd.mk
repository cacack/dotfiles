S5CMD_VERSION := 2.3.0

# SHA256 checksums from https://github.com/peak/s5cmd/releases/download/v2.3.0/s5cmd_checksums.txt
S5CMD_CHECKSUM_LINUX_64BIT := de0fdbfa3aceae55e069ba81a0fc17b2026567637603734a387b2fca06c299b4
S5CMD_CHECKSUM_MACOS_ARM64 := ae007bc96276f498ae3c1fb017e57630cf93ef260cfe7e97b365522e240c973f
S5CMD_CHECKSUM_MACOS_X86_64 := df6f76f6d317c4d051ad083219ed36eb8d8e5ebc55ceeeb91f5e66cdc3ac71fb

ifeq ($(UNAME), Darwin)
S5CMD_PLATFORM := macOS
ifeq ($(ARCH), arm64)
S5CMD_ARCH := arm64
S5CMD_CHECKSUM := $(S5CMD_CHECKSUM_MACOS_ARM64)
else
S5CMD_ARCH := x86_64
S5CMD_CHECKSUM := $(S5CMD_CHECKSUM_MACOS_X86_64)
endif
endif
ifeq ($(UNAME), Linux)
S5CMD_PLATFORM := Linux
S5CMD_ARCH := 64bit
S5CMD_CHECKSUM := $(S5CMD_CHECKSUM_LINUX_64BIT)
endif

.PHONY: setup-s5cmd
setup-s5cmd: install-s5cmd

.PHONY: install-s5cmd
install-s5cmd:
	@echo
	curl -Ls -o s5cmd.tar.gz https://github.com/peak/s5cmd/releases/download/v$(S5CMD_VERSION)/s5cmd_$(S5CMD_VERSION)_$(S5CMD_PLATFORM)-$(S5CMD_ARCH).tar.gz
	$(call verify_checksum,s5cmd.tar.gz,$(S5CMD_CHECKSUM))
	tar -xz -C $(USER_BIN_DIR) -f s5cmd.tar.gz s5cmd
	rm s5cmd.tar.gz
