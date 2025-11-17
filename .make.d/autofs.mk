################################################################################
# Autofs configuration for NAS mounting
#
# This module sets up autofs to automatically mount Samba shares to ~/shared/
# on both Linux and macOS.
#
# The NAS hostname and credentials are stored in ~/.autofs_config which is
# NOT committed to the repository for security.
#
# User-facing targets (5 total):
#   autofs        - Complete setup (credentials + configuration)
#   autofs-status - Show current configuration and mount status
#   autofs-test   - Test the NAS mount
#   autofs-fix    - Fix common issues (ownership, refresh creds, restart)
#   autofs-remove - Remove autofs NAS configuration
################################################################################

AUTOFS_CONFIG := $(HOME)/.autofs_config
MOUNT_POINT := $(HOME)/shared

# Read NAS configuration from config file if it exists
ifneq (,$(wildcard $(AUTOFS_CONFIG)))
NAS_HOST := $(shell grep '^nas_host=' $(AUTOFS_CONFIG) 2>/dev/null | cut -d'=' -f2)
NAS_SHARE_NAME := $(shell grep '^nas_share=' $(AUTOFS_CONFIG) 2>/dev/null | cut -d'=' -f2)
NAS_USERNAME := $(shell grep '^nas_username=' $(AUTOFS_CONFIG) 2>/dev/null | cut -d'=' -f2)
endif

# Default values if not configured
NAS_HOST ?= not-configured
NAS_SHARE_NAME ?= shared
NAS_USERNAME ?= $(USER)
NAS_SHARE := //$(NAS_HOST)/$(NAS_SHARE_NAME)

# Platform-specific autofs setup
ifeq ($(UNAME), Darwin)
AUTOFS_CONF := /etc/auto_master
AUTOFS_MAP := /etc/auto_nas
AUTOFS_SERVICE := com.apple.autofsd
# macOS uses /System/Volumes/Data for user data (more stable after sleep/wake)
ACTUAL_MOUNT_POINT := /System/Volumes/Data/shared-$(NAS_USERNAME)
endif

ifeq ($(UNAME), Linux)
AUTOFS_CONF := /etc/auto.master
AUTOFS_MAP := /etc/auto.nas
AUTOFS_SERVICE := autofs
# Linux can mount directly to home directory
ACTUAL_MOUNT_POINT := $(MOUNT_POINT)
endif

################################################################################
# User-facing targets
################################################################################

.PHONY: autofs
autofs:
	@echo
	@echo "==> Autofs NAS Setup"
	@echo
	@echo "This will set up automatic mounting of your NAS share at $(MOUNT_POINT)"
	@echo
	@if [ ! -f $(AUTOFS_CONFIG) ]; then \
		echo "Step 1: Configure NAS credentials"; \
		$(MAKE) _autofs-credentials; \
	else \
		echo "NAS configuration found at $(AUTOFS_CONFIG)"; \
		echo "Current config:"; \
		grep -v '^#' $(AUTOFS_CONFIG) | sed 's/^/  /'; \
		echo; \
		printf "Reconfigure credentials? [y/N] "; \
		read REPLY; \
		case "$$REPLY" in \
			[Yy]*) $(MAKE) _autofs-credentials;; \
			*) echo "Using existing configuration.";; \
		esac; \
	fi
	@echo
	@echo "Step 2: Configure autofs system files"
	@$(MAKE) _autofs-configure
	@echo
	@echo "==> Setup complete!"
	@echo
	@echo "Test with: make autofs-test"
	@echo "Check status: make autofs-status"
ifeq ($(UNAME), Darwin)
	@echo
	@echo "Note: If you experience permission issues after sleep/wake, run:"
	@echo "  make autofs-fix"
endif

.PHONY: autofs-status
autofs-status:
	@echo
	@echo "==> Autofs NAS Status"
	@echo
	@echo "Configuration:"
	@echo "  NAS Host:     $(NAS_HOST)"
	@echo "  NAS Share:    $(NAS_SHARE)"
	@echo "  NAS Username: $(NAS_USERNAME)"
	@echo "  Mount Point:  $(MOUNT_POINT)"
ifeq ($(UNAME), Darwin)
	@echo "  Actual Mount: $(ACTUAL_MOUNT_POINT)"
endif
	@echo
	@echo "System Configuration:"
	@if [ -f $(AUTOFS_CONF) ]; then \
		if grep -q "auto_nas" $(AUTOFS_CONF) 2>/dev/null; then \
			echo "  [OK] Entry exists in $(AUTOFS_CONF)"; \
		else \
			echo "  [MISSING] No entry in $(AUTOFS_CONF) - run 'make autofs'"; \
		fi; \
	else \
		echo "  [ERROR] $(AUTOFS_CONF) not found"; \
	fi
	@if [ -f $(AUTOFS_MAP) ]; then \
		echo "  [OK] Map file exists: $(AUTOFS_MAP)"; \
	else \
		echo "  [MISSING] Map file not found - run 'make autofs'"; \
	fi
	@echo
	@echo "Mount Point:"
ifeq ($(UNAME), Darwin)
	@if [ -L $(MOUNT_POINT) ]; then \
		echo "  [OK] Symlink: $(MOUNT_POINT) -> $$(readlink $(MOUNT_POINT))"; \
	else \
		echo "  [MISSING] Symlink does not exist"; \
	fi
	@if [ -d $(ACTUAL_MOUNT_POINT) ]; then \
		if mount | grep -q "$(ACTUAL_MOUNT_POINT)"; then \
			echo "  [MOUNTED] Currently mounted"; \
		else \
			echo "  [NOT MOUNTED] Will mount on access"; \
		fi; \
		OWNER=$$(stat -f "%Su" $(ACTUAL_MOUNT_POINT) 2>/dev/null); \
		if [ "$$OWNER" = "root" ]; then \
			echo "  [WARNING] Owned by root - may need 'make autofs-fix'"; \
		else \
			echo "  [OK] Owned by $$OWNER"; \
		fi; \
	else \
		echo "  [MISSING] Mount point does not exist"; \
	fi
endif
ifeq ($(UNAME), Linux)
	@if [ -d $(MOUNT_POINT) ]; then \
		if mount | grep -q "$(MOUNT_POINT)"; then \
			echo "  [MOUNTED] Currently mounted"; \
		else \
			echo "  [NOT MOUNTED] Will mount on access"; \
		fi; \
	else \
		echo "  [MISSING] Mount point does not exist"; \
	fi
endif
	@echo
	@echo "Service:"
ifeq ($(UNAME), Darwin)
	@if ps aux | grep -q "[a]utomountd"; then \
		echo "  [OK] autofs service running"; \
	else \
		echo "  [ERROR] autofs service not running"; \
	fi
endif
ifeq ($(UNAME), Linux)
	@if systemctl is-active $(AUTOFS_SERVICE) >/dev/null 2>&1; then \
		echo "  [OK] autofs service running"; \
	else \
		echo "  [ERROR] autofs service not running"; \
	fi
endif

.PHONY: autofs-test
autofs-test:
	@echo
	@echo "==> Testing autofs NAS mount"
	@echo
	@echo "Accessing $(MOUNT_POINT)..."
	@if ls $(MOUNT_POINT) >/dev/null 2>&1; then \
		echo; \
		ls -la $(MOUNT_POINT) | head -20; \
		echo; \
		echo "[OK] Mount successful!"; \
	else \
		echo; \
		echo "[ERROR] Mount failed - check 'make autofs-status' for details"; \
		exit 1; \
	fi

.PHONY: autofs-fix
autofs-fix:
	@echo
	@echo "==> Autofs Fix Menu"
	@echo
	@echo "What would you like to fix?"
	@echo "  1) Refresh credentials (after password change)"
	@echo "  2) Restart autofs service"
ifeq ($(UNAME), Darwin)
	@echo "  3) Fix ownership bug (macOS)"
	@echo "  4) Install auto-fix agent (macOS)"
	@echo "  5) Uninstall auto-fix agent (macOS)"
endif
	@echo "  q) Quit"
	@echo
	@printf "Choice: "; \
	read CHOICE; \
	case "$$CHOICE" in \
		1) $(MAKE) _autofs-refresh-creds;; \
		2) $(MAKE) _autofs-restart;; \
ifeq ($(UNAME), Darwin)
		3) $(MAKE) _autofs-fix-ownership;; \
		4) $(MAKE) _autofs-install-agent;; \
		5) $(MAKE) _autofs-uninstall-agent;; \
endif
		q|Q) echo "Cancelled.";; \
		*) echo "Invalid choice.";; \
	esac

.PHONY: autofs-remove
autofs-remove:
	@echo
	@echo "==> Remove autofs NAS configuration"
	@echo
	@echo "This will:"
	@echo "  - Remove autofs map entries from system files"
	@echo "  - Remove mount point directory/symlink"
	@echo "  - Restart autofs service"
	@echo
	@echo "NOTE: This does NOT remove:"
	@echo "  - $(AUTOFS_CONFIG) (your NAS config)"
	@echo "  - Keychain credentials (macOS) or ~/.smbcredentials (Linux)"
	@echo
	@printf "Continue? [y/N] "; \
	read REPLY; \
	case "$$REPLY" in \
		[Yy]*) \
			echo; \
			echo "Removing autofs configuration..."; \
			sudo sed -i.bak '/auto_nas/d' $(AUTOFS_CONF) 2>/dev/null || true; \
			if [ -f $(AUTOFS_MAP) ]; then sudo rm -f $(AUTOFS_MAP); fi; \
			if [ -L $(MOUNT_POINT) ]; then rm -f $(MOUNT_POINT); fi; \
			if [ -d $(MOUNT_POINT) ]; then rmdir $(MOUNT_POINT) 2>/dev/null || true; fi; \
			$(MAKE) _autofs-restart; \
			echo; \
			echo "Autofs configuration removed."; \
			;; \
		*) echo "Cancelled.";; \
	esac

################################################################################
# Internal targets (prefixed with _ to hide from make help)
################################################################################

.PHONY: _autofs-credentials
_autofs-credentials:
	@echo
	@echo "Configuring NAS connection details..."
	@echo "Configuration will be stored in $(AUTOFS_CONFIG)"
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
	echo "# Autofs NAS Configuration" > $(AUTOFS_CONFIG); \
	echo "# Generated on $$(date)" >> $(AUTOFS_CONFIG); \
	echo "nas_host=$$nas_host" >> $(AUTOFS_CONFIG); \
	echo "nas_share=$$nas_share" >> $(AUTOFS_CONFIG); \
	echo "nas_username=$$nas_username" >> $(AUTOFS_CONFIG); \
	chmod 600 $(AUTOFS_CONFIG); \
	echo; \
	echo "Configuration saved."; \
	echo
ifeq ($(UNAME), Darwin)
	@NAS_HOST_VAL=$$(grep '^nas_host=' $(AUTOFS_CONFIG) | cut -d'=' -f2); \
	NAS_USER_VAL=$$(grep '^nas_username=' $(AUTOFS_CONFIG) | cut -d'=' -f2); \
	echo "Storing password in Keychain for $$NAS_USER_VAL@$$NAS_HOST_VAL"; \
	printf "Password: "; \
	stty -echo; \
	read NAS_PASSWORD; \
	stty echo; \
	echo; \
	if [ -n "$$NAS_PASSWORD" ]; then \
		security delete-generic-password -s "$$NAS_HOST_VAL" -a "$$NAS_USER_VAL" 2>/dev/null || true; \
		security add-generic-password -s "$$NAS_HOST_VAL" -a "$$NAS_USER_VAL" -w "$$NAS_PASSWORD" -T /usr/sbin/automount -T /usr/bin/security; \
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
	NAS_USER_VAL=$$(grep '^nas_username=' $(AUTOFS_CONFIG) | cut -d'=' -f2); \
	echo "username=$$NAS_USER_VAL" > $(HOME)/.smbcredentials; \
	echo "password=$$smb_pass" >> $(HOME)/.smbcredentials; \
	echo "domain=$$smb_domain" >> $(HOME)/.smbcredentials; \
	chmod 600 $(HOME)/.smbcredentials; \
	echo "Credentials saved to $(HOME)/.smbcredentials"
endif

.PHONY: _autofs-configure
_autofs-configure:
	@echo "Installing autofs package..."
ifeq ($(UNAME), Darwin)
	@echo "autofs is built into macOS, skipping."
endif
ifeq ($(UNAME), Linux)
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
endif
	@echo
	@echo "Creating mount point..."
ifeq ($(UNAME), Darwin)
	@sudo mkdir -p $(ACTUAL_MOUNT_POINT)
	@if [ ! -L $(MOUNT_POINT) ]; then \
		ln -s $(ACTUAL_MOUNT_POINT) $(MOUNT_POINT); \
		echo "Created symlink: $(MOUNT_POINT) -> $(ACTUAL_MOUNT_POINT)"; \
	else \
		echo "Symlink already exists."; \
	fi
endif
ifeq ($(UNAME), Linux)
	@mkdir -p $(MOUNT_POINT)
endif
	@echo
	@echo "Configuring autofs maps (requires sudo)..."
ifeq ($(UNAME), Darwin)
	@NAS_PASSWORD=$$(security find-generic-password -s "$(NAS_HOST)" -a "$(NAS_USERNAME)" -w 2>/dev/null); \
	if [ -z "$$NAS_PASSWORD" ]; then \
		echo "ERROR: No password in Keychain for $(NAS_HOST)/$(NAS_USERNAME)"; \
		exit 1; \
	fi; \
	echo "$(ACTUAL_MOUNT_POINT) -fstype=smbfs,soft,noowners,nosuid,rw ://$(NAS_USERNAME):$$NAS_PASSWORD@$(NAS_HOST)/$(NAS_SHARE_NAME)" | sudo tee $(AUTOFS_MAP) > /dev/null
	@sudo sed -i.bak '/auto_nas/d' $(AUTOFS_CONF) 2>/dev/null || true
	@echo "/-	auto_nas	-nosuid" | sudo tee -a $(AUTOFS_CONF) > /dev/null
	@echo "Added entry to $(AUTOFS_CONF)"
endif
ifeq ($(UNAME), Linux)
	@echo "shared -fstype=cifs,credentials=$(HOME)/.smbcredentials,uid=$$(id -u),gid=$$(id -g),file_mode=0644,dir_mode=0755 :$(NAS_SHARE)" | sudo tee $(AUTOFS_MAP) > /dev/null
	@if ! grep -q "$(MOUNT_POINT)" $(AUTOFS_CONF); then \
		echo "$(MOUNT_POINT) $(AUTOFS_MAP) --timeout=60" | sudo tee -a $(AUTOFS_CONF) > /dev/null; \
		echo "Added entry to $(AUTOFS_CONF)"; \
	fi
endif
	@$(MAKE) _autofs-restart

.PHONY: _autofs-restart
_autofs-restart:
	@echo "Restarting autofs service..."
ifeq ($(UNAME), Darwin)
	@sudo automount -vc
endif
ifeq ($(UNAME), Linux)
	@sudo systemctl restart $(AUTOFS_SERVICE)
	@sudo systemctl enable $(AUTOFS_SERVICE)
endif

.PHONY: _autofs-refresh-creds
_autofs-refresh-creds:
	@echo
	@echo "Refreshing autofs credentials..."
ifeq ($(UNAME), Darwin)
	@NAS_PASSWORD=$$(security find-generic-password -s "$(NAS_HOST)" -a "$(NAS_USERNAME)" -w 2>/dev/null); \
	if [ -z "$$NAS_PASSWORD" ]; then \
		echo "ERROR: No password in Keychain"; \
		exit 1; \
	fi; \
	echo "$(ACTUAL_MOUNT_POINT) -fstype=smbfs,soft,noowners,nosuid,rw ://$(NAS_USERNAME):$$NAS_PASSWORD@$(NAS_HOST)/$(NAS_SHARE_NAME)" | sudo tee $(AUTOFS_MAP) > /dev/null
endif
	@$(MAKE) _autofs-restart
	@echo "Credentials refreshed!"

ifeq ($(UNAME), Darwin)
.PHONY: _autofs-fix-ownership
_autofs-fix-ownership:
	@echo
	@echo "Fixing autofs mount ownership (macOS bug workaround)..."
	@if [ -f $(BASE_DIR)/../.dotfiles/scripts/fix-autofs-ownership.sh ]; then \
		$(BASE_DIR)/../.dotfiles/scripts/fix-autofs-ownership.sh; \
	else \
		sudo umount -f $(ACTUAL_MOUNT_POINT) 2>/dev/null || true; \
		sudo automount -vc; \
		echo "Mount refreshed."; \
	fi

.PHONY: _autofs-install-agent
_autofs-install-agent:
	@echo
	@echo "Installing LaunchAgent for automatic ownership fixes..."
	@if [ -f ~/Library/LaunchAgents/com.dotfiles.autofs-fix.plist ]; then \
		launchctl unload ~/Library/LaunchAgents/com.dotfiles.autofs-fix.plist 2>/dev/null || true; \
	fi
	@mkdir -p ~/Library/LaunchAgents
	@cp packages/launchd/Library/LaunchAgents/com.dotfiles.autofs-fix.plist ~/Library/LaunchAgents/
	@launchctl load ~/Library/LaunchAgents/com.dotfiles.autofs-fix.plist
	@echo "LaunchAgent installed. View logs: tail -f /tmp/autofs-fix.log"

.PHONY: _autofs-uninstall-agent
_autofs-uninstall-agent:
	@echo
	@echo "Uninstalling autofs fix LaunchAgent..."
	@if [ -f ~/Library/LaunchAgents/com.dotfiles.autofs-fix.plist ]; then \
		launchctl unload ~/Library/LaunchAgents/com.dotfiles.autofs-fix.plist 2>/dev/null || true; \
		rm ~/Library/LaunchAgents/com.dotfiles.autofs-fix.plist; \
		echo "LaunchAgent uninstalled."; \
	else \
		echo "LaunchAgent not found."; \
	fi
endif
