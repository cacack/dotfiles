################################################################################
# NAS mounting configuration
#
# This module sets up automatic mounting of Samba shares to ~/shared/
# on both Linux (using autofs) and macOS (using launchd + periodic script).
#
# The NAS hostname and credentials are stored in ~/.autofs_config which is
# NOT committed to the repository for security.
#
# User-facing targets (6 total):
#   nas-mount  - Complete setup (credentials + configuration)
#   nas-status - Show current configuration and mount status
#   nas-test   - Test the NAS mount
#   nas-logs   - View recent mount logs (macOS only)
#   nas-fix    - Fix common issues (ownership, refresh creds, restart)
#   nas-remove - Remove NAS configuration
################################################################################

NAS_CONFIG := $(HOME)/.autofs_config
MOUNT_POINT := $(HOME)/shared
LOG_DIR := $(SHARE_DIR)/logs
NAS_LOG_FILE := $(LOG_DIR)/nas-mount.log

# Read NAS configuration from config file if it exists
ifneq (,$(wildcard $(NAS_CONFIG)))
NAS_HOST := $(shell grep '^nas_host=' $(NAS_CONFIG) 2>/dev/null | cut -d'=' -f2)
NAS_SHARE_NAME := $(shell grep '^nas_share=' $(NAS_CONFIG) 2>/dev/null | cut -d'=' -f2)
NAS_USERNAME := $(shell grep '^nas_username=' $(NAS_CONFIG) 2>/dev/null | cut -d'=' -f2)
endif

# Default values if not configured
NAS_HOST ?= not-configured
NAS_SHARE_NAME ?= shared
NAS_USERNAME ?= $(USER)
NAS_SHARE := //$(NAS_HOST)/$(NAS_SHARE_NAME)

# Platform-specific setup
ifeq ($(UNAME), Darwin)
# macOS uses launchd + periodic mount script
LAUNCHD_PLIST := com.user.nas-mount.plist
LAUNCHD_DEST := $(HOME)/Library/LaunchAgents/$(LAUNCHD_PLIST)
MOUNT_SCRIPT := $(BASE_DIR)/../.dotfiles/scripts/mount-nas.sh
# macOS mounts to /Volumes/nas-share and symlinks to ~/shared
ACTUAL_MOUNT_POINT := /Volumes/nas-$(NAS_USERNAME)
endif

ifeq ($(UNAME), Linux)
# Linux uses autofs (original implementation)
AUTOFS_CONF := /etc/auto.master
AUTOFS_MAP := /etc/auto.nas
AUTOFS_SERVICE := autofs
# Linux can mount directly to home directory
ACTUAL_MOUNT_POINT := $(MOUNT_POINT)
endif

################################################################################
# User-facing targets
################################################################################

.PHONY: nas-mount
nas-mount:
	@echo
	@echo "==> NAS Mount Setup"
	@echo
ifeq ($(UNAME), Darwin)
	@echo "This will set up automatic mounting of your NAS share at $(MOUNT_POINT)"
	@echo "using launchd + periodic mount script (runs every 5 minutes)."
else
	@echo "This will set up automatic mounting of your NAS share at $(MOUNT_POINT)"
	@echo "using autofs."
endif
	@echo
	@if [ ! -f $(NAS_CONFIG) ]; then \
		echo "Step 1: Configure NAS credentials"; \
		$(MAKE) _nas-credentials; \
	else \
		echo "NAS configuration found at $(NAS_CONFIG)"; \
		echo "Current config:"; \
		grep -v '^#' $(NAS_CONFIG) | sed 's/^/  /'; \
		echo; \
		printf "Reconfigure credentials? [y/N] "; \
		read REPLY; \
		case "$$REPLY" in \
			[Yy]*) $(MAKE) _nas-credentials;; \
			*) echo "Using existing configuration.";; \
		esac; \
	fi
	@echo
	@echo "Step 2: Configure mounting system"
	@$(MAKE) _nas-configure
	@echo
	@echo "==> Setup complete!"
	@echo
	@echo "Test with: make nas-test"
	@echo "Check status: make nas-status"
ifeq ($(UNAME), Darwin)
	@echo "View logs: make nas-logs"
endif

.PHONY: nas-status
nas-status:
	@echo
	@echo "==> NAS Mount Status"
	@echo
	@echo "Configuration:"
	@echo "  NAS Host:     $(NAS_HOST)"
	@echo "  NAS Share:    $(NAS_SHARE)"
	@echo "  NAS Username: $(NAS_USERNAME)"
	@echo "  Mount Point:  $(MOUNT_POINT)"
ifeq ($(UNAME), Darwin)
	@echo "  Actual Mount: $(ACTUAL_MOUNT_POINT)"
	@echo "  Log File:     $(NAS_LOG_FILE)"
endif
	@echo
ifeq ($(UNAME), Darwin)
	@echo "System Configuration:"
	@if [ -f $(MOUNT_SCRIPT) ]; then \
		echo "  [OK] Mount script exists: $(MOUNT_SCRIPT)"; \
	else \
		echo "  [MISSING] Mount script not found - run 'make nas-mount'"; \
	fi
	@if [ -f $(LAUNCHD_DEST) ]; then \
		echo "  [OK] LaunchAgent exists: $(LAUNCHD_DEST)"; \
	else \
		echo "  [MISSING] LaunchAgent not found - run 'make nas-mount'"; \
	fi
	@echo
	@echo "Mount Point:"
	@if [ -L $(MOUNT_POINT) ]; then \
		echo "  [OK] Symlink: $(MOUNT_POINT) -> $$(readlink $(MOUNT_POINT))"; \
	else \
		echo "  [MISSING] Symlink does not exist"; \
	fi
	@if mount | grep -q "$(ACTUAL_MOUNT_POINT)"; then \
		echo "  [MOUNTED] Currently mounted"; \
		OWNER=$$(stat -f "%Su" $(ACTUAL_MOUNT_POINT) 2>/dev/null || echo "unknown"); \
		echo "  [OK] Owned by $$OWNER"; \
	else \
		echo "  [NOT MOUNTED] Not currently mounted"; \
	fi
	@echo
	@echo "LaunchAgent Service:"
	@if launchctl list | grep -q "com.user.nas-mount"; then \
		echo "  [OK] LaunchAgent loaded and running"; \
	else \
		echo "  [ERROR] LaunchAgent not loaded - run 'make nas-mount'"; \
	fi
endif
ifeq ($(UNAME), Linux)
	@echo "System Configuration:"
	@if [ -f $(AUTOFS_CONF) ]; then \
		if grep -q "auto_nas" $(AUTOFS_CONF) 2>/dev/null; then \
			echo "  [OK] Entry exists in $(AUTOFS_CONF)"; \
		else \
			echo "  [MISSING] No entry in $(AUTOFS_CONF) - run 'make nas-mount'"; \
		fi; \
	else \
		echo "  [ERROR] $(AUTOFS_CONF) not found"; \
	fi
	@if [ -f $(AUTOFS_MAP) ]; then \
		echo "  [OK] Map file exists: $(AUTOFS_MAP)"; \
	else \
		echo "  [MISSING] Map file not found - run 'make nas-mount'"; \
	fi
	@echo
	@echo "Mount Point:"
	@if [ -d $(MOUNT_POINT) ]; then \
		if mount | grep -q "$(MOUNT_POINT)"; then \
			echo "  [MOUNTED] Currently mounted"; \
		else \
			echo "  [NOT MOUNTED] Will mount on access"; \
		fi; \
	else \
		echo "  [MISSING] Mount point does not exist"; \
	fi
	@echo
	@echo "Service:"
	@if systemctl is-active $(AUTOFS_SERVICE) >/dev/null 2>&1; then \
		echo "  [OK] autofs service running"; \
	else \
		echo "  [ERROR] autofs service not running"; \
	fi
endif

.PHONY: nas-test
nas-test:
	@echo
	@echo "==> Testing NAS mount"
	@echo
	@echo "Accessing $(MOUNT_POINT)..."
	@if ls $(MOUNT_POINT) >/dev/null 2>&1; then \
		echo; \
		ls -la $(MOUNT_POINT) | head -20; \
		echo; \
		echo "[OK] Mount successful!"; \
	else \
		echo; \
		echo "[ERROR] Mount failed - check 'make nas-status' for details"; \
ifeq ($(UNAME), Darwin)
		echo "        or check logs with 'make nas-logs'"; \
endif
		exit 1; \
	fi

ifeq ($(UNAME), Darwin)
.PHONY: nas-logs
nas-logs:
	@echo
	@echo "==> Recent NAS mount logs"
	@echo
	@if [ -f $(NAS_LOG_FILE) ]; then \
		tail -50 $(NAS_LOG_FILE); \
	else \
		echo "No logs found at $(NAS_LOG_FILE)"; \
	fi
endif

.PHONY: nas-fix
nas-fix:
	@echo
	@echo "==> NAS Mount Fix Menu"
	@echo
	@echo "What would you like to fix?"
	@echo "  1) Refresh credentials (after password change)"
ifeq ($(UNAME), Darwin)
	@echo "  2) Restart launchd service"
	@echo "  3) Force remount now"
else
	@echo "  2) Restart autofs service"
endif
	@echo "  q) Quit"
	@echo
	@printf "Choice: "; \
	read CHOICE; \
	case "$$CHOICE" in \
		1) $(MAKE) _nas-refresh-creds;; \
		2) $(MAKE) _nas-restart;; \
ifeq ($(UNAME), Darwin)
		3) $(MAKE) _nas-force-mount;; \
endif
		q|Q) echo "Cancelled.";; \
		*) echo "Invalid choice.";; \
	esac

.PHONY: nas-remove
nas-remove:
	@echo
	@echo "==> Remove NAS mount configuration"
	@echo
ifeq ($(UNAME), Darwin)
	@echo "This will:"
	@echo "  - Unload and remove LaunchAgent"
	@echo "  - Remove mount script"
	@echo "  - Unmount NAS share"
	@echo "  - Remove mount point symlink"
else
	@echo "This will:"
	@echo "  - Remove autofs map entries from system files"
	@echo "  - Remove mount point directory/symlink"
	@echo "  - Restart autofs service"
endif
	@echo
	@echo "NOTE: This does NOT remove:"
	@echo "  - $(NAS_CONFIG) (your NAS config)"
	@echo "  - Keychain credentials (macOS) or ~/.smbcredentials (Linux)"
	@echo
	@printf "Continue? [y/N] "; \
	read REPLY; \
	case "$$REPLY" in \
		[Yy]*) \
			echo; \
			echo "Removing NAS mount configuration..."; \
ifeq ($(UNAME), Darwin)
			$(MAKE) _nas-uninstall-macos; \
else
			$(MAKE) _nas-uninstall-linux; \
endif
			echo; \
			echo "NAS mount configuration removed."; \
			;; \
		*) echo "Cancelled.";; \
	esac

################################################################################
# Internal targets (prefixed with _ to hide from make help)
################################################################################

.PHONY: _nas-credentials
_nas-credentials:
	@echo
	@echo "Configuring NAS connection details..."
	@echo "Configuration will be stored in $(NAS_CONFIG)"
	@echo
	@printf "NAS hostname (e.g., nas.example.com): "; \
	read nas_host; \
	if [ -z "$$nas_host" ]; then \
		echo "ERROR: Hostname cannot be empty"; \
		exit 1; \
	fi; \
	printf "Share name [shared]: "; \
	read nas_share; \
	nas_share=$${nas_share:-shared}; \
	printf "Username [$(USER)]: "; \
	read nas_username; \
	nas_username=$${nas_username:-$(USER)}; \
	echo "# NAS Configuration" > $(NAS_CONFIG); \
	echo "# Generated on $$(date)" >> $(NAS_CONFIG); \
	echo "nas_host=$$nas_host" >> $(NAS_CONFIG); \
	echo "nas_share=$$nas_share" >> $(NAS_CONFIG); \
	echo "nas_username=$$nas_username" >> $(NAS_CONFIG); \
	chmod 600 $(NAS_CONFIG); \
	echo; \
	echo "Configuration saved."; \
	echo
ifeq ($(UNAME), Darwin)
	@NAS_HOST_VAL=$$(grep '^nas_host=' $(NAS_CONFIG) | cut -d'=' -f2); \
	NAS_USER_VAL=$$(grep '^nas_username=' $(NAS_CONFIG) | cut -d'=' -f2); \
	echo "Storing password in Keychain for $$NAS_USER_VAL@$$NAS_HOST_VAL"; \
	printf "Password: "; \
	stty -echo; \
	read NAS_PASSWORD; \
	stty echo; \
	echo; \
	if [ -n "$$NAS_PASSWORD" ]; then \
		security delete-generic-password -s "$$NAS_HOST_VAL" -a "$$NAS_USER_VAL" 2>/dev/null || true; \
		security add-generic-password -s "$$NAS_HOST_VAL" -a "$$NAS_USER_VAL" -w "$$NAS_PASSWORD"; \
		echo "Credentials stored in Keychain."; \
	else \
		echo "ERROR: Password cannot be empty"; \
		exit 1; \
	fi
endif
ifeq ($(UNAME), Linux)
	@printf "Samba password: "; \
	stty -echo; \
	read smb_pass; \
	stty echo; \
	echo; \
	printf "Samba domain [WORKGROUP]: "; \
	read smb_domain; \
	smb_domain=$${smb_domain:-WORKGROUP}; \
	NAS_USER_VAL=$$(grep '^nas_username=' $(NAS_CONFIG) | cut -d'=' -f2); \
	echo "username=$$NAS_USER_VAL" > $(HOME)/.smbcredentials; \
	echo "password=$$smb_pass" >> $(HOME)/.smbcredentials; \
	echo "domain=$$smb_domain" >> $(HOME)/.smbcredentials; \
	chmod 600 $(HOME)/.smbcredentials; \
	echo "Credentials saved to $(HOME)/.smbcredentials"
endif

.PHONY: _nas-configure
_nas-configure:
ifeq ($(UNAME), Darwin)
	@$(MAKE) _nas-install-macos
endif
ifeq ($(UNAME), Linux)
	@$(MAKE) _nas-install-linux
endif

################################################################################
# macOS-specific targets (launchd + mount script)
################################################################################

ifeq ($(UNAME), Darwin)
.PHONY: _nas-install-macos
_nas-install-macos:
	@echo "Installing NAS mount script..."
	@mkdir -p $(LOG_DIR)
	@mkdir -p $(BASE_DIR)/../.dotfiles/scripts
	@if [ -f $(MOUNT_SCRIPT) ]; then \
		echo "Mount script already exists at $(MOUNT_SCRIPT)"; \
	else \
		echo "ERROR: Mount script not found at $(MOUNT_SCRIPT)"; \
		exit 1; \
	fi
	@chmod +x $(MOUNT_SCRIPT)
	@echo
	@echo "Creating mount point..."
	@mkdir -p $(ACTUAL_MOUNT_POINT)
	@if [ ! -L $(MOUNT_POINT) ]; then \
		ln -sf $(ACTUAL_MOUNT_POINT) $(MOUNT_POINT); \
		echo "Created symlink: $(MOUNT_POINT) -> $(ACTUAL_MOUNT_POINT)"; \
	else \
		echo "Symlink already exists."; \
	fi
	@echo
	@echo "Installing LaunchAgent..."
	@$(MAKE) _nas-install-launchd
	@echo
	@echo "Running initial mount..."
	@$(MOUNT_SCRIPT) || echo "Initial mount attempt complete (may fail if network unavailable)"

.PHONY: _nas-install-launchd
_nas-install-launchd:
	@mkdir -p $(HOME)/Library/LaunchAgents
	@sed 's|{{MOUNT_SCRIPT}}|$(MOUNT_SCRIPT)|g' \
		$(BASE_DIR)/../.dotfiles/templates/$(LAUNCHD_PLIST).template > $(LAUNCHD_DEST)
	@if launchctl list | grep -q "com.user.nas-mount" 2>/dev/null; then \
		launchctl unload $(LAUNCHD_DEST) 2>/dev/null || true; \
	fi
	@launchctl load $(LAUNCHD_DEST)
	@echo "LaunchAgent installed and loaded"

.PHONY: _nas-uninstall-macos
_nas-uninstall-macos:
	@if [ -f $(LAUNCHD_DEST) ]; then \
		launchctl unload $(LAUNCHD_DEST) 2>/dev/null || true; \
		rm -f $(LAUNCHD_DEST); \
		echo "LaunchAgent removed"; \
	fi
	@if mount | grep -q "$(ACTUAL_MOUNT_POINT)"; then \
		umount $(ACTUAL_MOUNT_POINT) 2>/dev/null || true; \
		echo "Unmounted NAS share"; \
	fi
	@if [ -L $(MOUNT_POINT) ]; then \
		rm -f $(MOUNT_POINT); \
		echo "Removed symlink"; \
	fi

.PHONY: _nas-restart
_nas-restart:
	@echo "Restarting NAS mount service..."
	@if [ -f $(LAUNCHD_DEST) ]; then \
		launchctl unload $(LAUNCHD_DEST) 2>/dev/null || true; \
		launchctl load $(LAUNCHD_DEST); \
		echo "LaunchAgent restarted"; \
	else \
		echo "ERROR: LaunchAgent not installed"; \
		exit 1; \
	fi

.PHONY: _nas-force-mount
_nas-force-mount:
	@echo
	@echo "Forcing immediate mount attempt..."
	@if [ -f $(MOUNT_SCRIPT) ]; then \
		$(MOUNT_SCRIPT); \
	else \
		echo "ERROR: Mount script not found"; \
		exit 1; \
	fi

.PHONY: _nas-refresh-creds
_nas-refresh-creds:
	@echo
	@echo "Refreshing NAS credentials..."
	@NAS_HOST_VAL=$$(grep '^nas_host=' $(NAS_CONFIG) | cut -d'=' -f2); \
	NAS_USER_VAL=$$(grep '^nas_username=' $(NAS_CONFIG) | cut -d'=' -f2); \
	echo "Updating password in Keychain for $$NAS_USER_VAL@$$NAS_HOST_VAL"; \
	printf "New Password: "; \
	stty -echo; \
	read NAS_PASSWORD; \
	stty echo; \
	echo; \
	if [ -n "$$NAS_PASSWORD" ]; then \
		security delete-generic-password -s "$$NAS_HOST_VAL" -a "$$NAS_USER_VAL" 2>/dev/null || true; \
		security add-generic-password -s "$$NAS_HOST_VAL" -a "$$NAS_USER_VAL" -w "$$NAS_PASSWORD"; \
		echo "Credentials updated in Keychain."; \
		echo "Forcing remount..."; \
		$(MAKE) _nas-force-mount; \
	else \
		echo "ERROR: Password cannot be empty"; \
		exit 1; \
	fi
endif

################################################################################
# Linux-specific targets (autofs - original implementation)
################################################################################

ifeq ($(UNAME), Linux)
.PHONY: _nas-install-linux
_nas-install-linux:
	@echo "Installing autofs package..."
ifeq ($(DISTRO), Ubuntu)
	sudo apt-get update && sudo apt-get install -y autofs cifs-utils
else ifeq ($(DISTRO), Debian)
	sudo apt-get update && sudo apt-get install -y autofs cifs-utils
else ifeq ($(DISTRO), Fedora)
	sudo dnf install -y autofs cifs-utils
else ifeq ($(DISTRO), CentOS)
	sudo yum install -y autofs cifs-utils
else ifeq ($(DISTRO), Arch)
	sudo pacman -S --noconfirm autofs cifs-utils
else
	@echo "Unsupported distro: $(DISTRO). Install autofs and cifs-utils manually."
	@exit 1
endif
	@echo
	@echo "Creating mount point..."
	@mkdir -p $(MOUNT_POINT)
	@echo
	@echo "Configuring autofs maps (requires sudo)..."
	@echo "shared -fstype=cifs,credentials=$(HOME)/.smbcredentials,uid=$$(id -u),gid=$$(id -g),file_mode=0644,dir_mode=0755 :$(NAS_SHARE)" | sudo tee $(AUTOFS_MAP) > /dev/null
	@if ! grep -q "$(MOUNT_POINT)" $(AUTOFS_CONF); then \
		echo "$(MOUNT_POINT) $(AUTOFS_MAP) --timeout=60" | sudo tee -a $(AUTOFS_CONF) > /dev/null; \
		echo "Added entry to $(AUTOFS_CONF)"; \
	fi
	@$(MAKE) _nas-restart

.PHONY: _nas-uninstall-linux
_nas-uninstall-linux:
	@sudo sed -i.bak '/auto_nas/d' $(AUTOFS_CONF) 2>/dev/null || true
	@if [ -f $(AUTOFS_MAP) ]; then sudo rm -f $(AUTOFS_MAP); fi
	@if [ -L $(MOUNT_POINT) ]; then rm -f $(MOUNT_POINT); fi
	@if [ -d $(MOUNT_POINT) ]; then rmdir $(MOUNT_POINT) 2>/dev/null || true; fi
	@$(MAKE) _nas-restart

.PHONY: _nas-restart
_nas-restart:
	@echo "Restarting autofs service..."
	@sudo systemctl restart $(AUTOFS_SERVICE)
	@sudo systemctl enable $(AUTOFS_SERVICE)

.PHONY: _nas-refresh-creds
_nas-refresh-creds:
	@echo
	@echo "Refreshing NAS credentials..."
	@printf "New Samba password: "; \
	stty -echo; \
	read smb_pass; \
	stty echo; \
	echo; \
	printf "Samba domain [WORKGROUP]: "; \
	read smb_domain; \
	smb_domain=$${smb_domain:-WORKGROUP}; \
	NAS_USER_VAL=$$(grep '^nas_username=' $(NAS_CONFIG) | cut -d'=' -f2); \
	echo "username=$$NAS_USER_VAL" > $(HOME)/.smbcredentials; \
	echo "password=$$smb_pass" >> $(HOME)/.smbcredentials; \
	echo "domain=$$smb_domain" >> $(HOME)/.smbcredentials; \
	chmod 600 $(HOME)/.smbcredentials; \
	echo "Credentials updated in $(HOME)/.smbcredentials"; \
	$(MAKE) _nas-restart; \
	echo "Credentials refreshed!"
endif
