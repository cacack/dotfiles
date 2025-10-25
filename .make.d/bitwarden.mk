################################################################################
# BitWarden CLI Installation
#
# Installs the BitWarden command-line interface tool
# Note: GUI app is installed via gui-apps.mk
################################################################################

ifeq ($(OS),darwin)
BW_PLATFORM := macos
endif
ifeq ($(OS),linux)
BW_PLATFORM := linux
endif

SETUP += setup-bitwarden
UPDATE += update-bitwarden

.PHONY: setup-bitwarden
setup-bitwarden: install-bitwarden-cli

.PHONY: install-bitwarden-cli
install-bitwarden-cli:
	@echo
	# Installing BitWarden CLI
	@mkdir -p $(BIN_DIR)
	@curl -Ls -o /tmp/bitwarden-cli.zip "https://vault.bitwarden.com/download/?app=cli&platform=$(BW_PLATFORM)"
	@unzip -o -d $(BIN_DIR) /tmp/bitwarden-cli.zip bw
	@chmod 0755 $(BIN_DIR)/bw
	@rm -f /tmp/bitwarden-cli.zip
ifeq ($(OS),darwin)
	@xattr -dr com.apple.quarantine $(BIN_DIR)/bw 2>/dev/null || true
endif
	@echo "BitWarden CLI installed to $(BIN_DIR)/bw"

.PHONY: update-bitwarden
update-bitwarden:
	@echo
	# Updating BitWarden CLI
	$(MAKE) install-bitwarden-cli

.PHONY: uninstall-bitwarden-cli
uninstall-bitwarden-cli:
	@echo
	# Uninstalling BitWarden CLI
	@rm -f $(BIN_DIR)/bw
	@echo "BitWarden CLI uninstalled"

.PHONY: setup-bitwarden-server
setup-bitwarden-server:
	@echo
	# Configuring BitWarden server URL
	@if ! bw status >/dev/null 2>&1; then \
		echo "Error: BitWarden CLI not installed. Run 'make install-bitwarden-cli' first."; \
		exit 1; \
	fi
	@echo "Current server configuration:"
	@bw config server || echo "  Not configured (will use bitwarden.com)"
	@echo ""
	@echo "To configure a self-hosted server, run:"
	@echo "  bw config server https://your-bitwarden-server.com"
	@echo ""
	@echo "To reset to bitwarden.com, run:"
	@echo "  bw config server bitwarden.com"

.PHONY: setup-bitwarden-login
setup-bitwarden-login:
	@echo
	# Setting up BitWarden login
	@if ! bw status >/dev/null 2>&1; then \
		echo "Error: BitWarden CLI not installed. Run 'make install-bitwarden-cli' first."; \
		exit 1; \
	fi
	@bw_status=$$(bw status 2>/dev/null | grep -o '"status":"[^"]*"' | cut -d'"' -f4); \
	if [ "$$bw_status" = "unauthenticated" ]; then \
		echo "For self-hosted servers, configure the URL first:"; \
		echo "  bw config server https://your-bitwarden-server.com"; \
		echo ""; \
		echo "Then log in:"; \
		echo "  bw login"; \
		echo ""; \
		echo "After logging in, Bitwarden will prompt for your password once per session."; \
		echo "The session persists across terminal windows until it expires."; \
	else \
		echo "Already logged in to BitWarden."; \
	fi

.PHONY: bitwarden-lock
bitwarden-lock:
	@echo
	# Locking BitWarden session
	@bw lock
	@rm -f ~/.ssh/bw.env
	@echo "BitWarden locked. You will be prompted on next shell."

.PHONY: bitwarden-status
bitwarden-status:
	@echo
	# BitWarden Status
	@if ! bw status >/dev/null 2>&1; then \
		echo "BitWarden CLI: Not installed"; \
		exit 0; \
	fi
	@echo "Server URL:"
	@server_url=$$(bw status 2>/dev/null | grep -o '"serverUrl":"[^"]*"' | cut -d'"' -f4); \
	if [ -z "$$server_url" ] || [ "$$server_url" = "null" ]; then \
		echo "  https://bitwarden.com (default)"; \
	else \
		echo "  $$server_url"; \
	fi
	@echo ""
	@echo "Login Status:"
	@bw status | grep -o '"status":"[^"]*"' | cut -d'"' -f4 | \
		awk '{printf "  %s\n", $$0}'
	@echo ""
	@echo "Session:"
	@if [ -f ~/.ssh/bw.env ]; then \
		echo "  Session file exists (~/.ssh/bw.env)"; \
	else \
		echo "  No session file"; \
	fi
