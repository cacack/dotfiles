S5CMD_VERSION := 2.3.0


ifeq ($(UNAME), Darwin)
S5CMD_PLATFORM := macOS
S5CMD_ARCH := $(ARCH)
endif
ifeq ($(UNAME), Linux)
S5CMD_PLATFORM := Linux
S5CMD_ARCH := 64bit
endif

.PHONY: setup-s5cmd
setup-s5cmd: install-s5cmd

.PHONY: install-s5cmd
install-s5cmd:
	@echo
	curl -Ls -o s5cmd.tar.gz https://github.com/peak/s5cmd/releases/download/v$(S5CMD_VERSION)/s5cmd_$(S5CMD_VERSION)_$(S5CMD_PLATFORM)-$(S5CMD_ARCH).tar.gz
	tar -xz -C $(USER_BIN_DIR) -f s5cmd.tar.gz s5cmd
	rm s5cmd.tar.gz
