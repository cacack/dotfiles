CLAUDE_POWERLINE_VERSION := 1.2.0

ifeq ($(UNAME), Darwin)
CLAUDE_POWERLINE_PLATFORM := macos
ifeq ($(ARCH), x86_64)
CLAUDE_POWERLINE_ARCH := x64
else
CLAUDE_POWERLINE_ARCH := arm64
endif
endif
ifeq ($(UNAME), Linux)
CLAUDE_POWERLINE_PLATFORM := linux
CLAUDE_POWERLINE_ARCH := x64
endif

.PHONY: setup-claude-powerline-rust
setup-claude-powerline-rust: install-claude-powerline-rust

.PHONY: install-claude-powerline-rust
install-claude-powerline-rust:
	@echo
	# Installing claude-powerline-rust
	curl -Ls -o claude-powerline.tar.gz https://github.com/david-strejc/claude-powerline-rust/releases/download/v$(CLAUDE_POWERLINE_VERSION)/claude-powerline-$(CLAUDE_POWERLINE_PLATFORM)-$(CLAUDE_POWERLINE_ARCH).tar.gz
	tar -xzf claude-powerline.tar.gz
	mv claude-powerline $(USER_BIN_DIR)/claude-powerline
	chmod 0755 $(USER_BIN_DIR)/claude-powerline
	rm -rf claude-powerline.tar.gz
ifeq ($(UNAME), Darwin)
	xattr -dr com.apple.quarantine $(USER_BIN_DIR)/claude-powerline
endif
	@echo
	# claude-powerline-rust installation complete
	@echo "claude-powerline is now available in your PATH"