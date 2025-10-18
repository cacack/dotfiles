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
