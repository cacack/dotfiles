################################################################################
# Autofs configuration for NAS mounting
#
# This module sets up autofs to automatically mount Samba shares to ~/shared/
# on both Linux and macOS.
#
# The NAS hostname and credentials are stored in ~/.autofs_config which is
# NOT committed to the repository for security.
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

.PHONY: setup-autofs
setup-autofs:
	@echo
	@echo "==> Setting up autofs for NAS mounting"
	@echo
	@# Check if configuration exists
	@if [ ! -f $(AUTOFS_CONFIG) ]; then \
		echo "ERROR: NAS configuration not found at $(AUTOFS_CONFIG)"; \
		echo; \
		echo "Please run 'make setup-autofs-credentials' first to configure your NAS settings."; \
		echo; \
		exit 1; \
	fi
	@echo "This will configure autofs to mount $(NAS_SHARE) to $(MOUNT_POINT)"
	@echo
	@echo "Required steps:"
	@echo "1. Install autofs package (if not already installed)"
	@echo "2. Create mount point directory"
	@echo "3. Configure autofs maps (requires sudo)"
	@echo "4. Restart autofs service (requires sudo)"
	@echo
	@echo "Prerequisites:"
	@echo "  - You need sudo access"
	@echo "  - NAS credentials configured at $(AUTOFS_CONFIG)"
	@echo
	@printf "Continue with setup? [y/N] "; \
	read REPLY; \
	case "$$REPLY" in \
		[Yy]*) echo "Proceeding with setup...";; \
		*) echo "Setup cancelled."; exit 1;; \
	esac
	@$(MAKE) install-autofs-package
	@$(MAKE) create-autofs-mountpoint
	@$(MAKE) configure-autofs-maps
	@$(MAKE) restart-autofs-service
	@echo
	@echo "==> Autofs setup complete!"
	@echo
	@echo "Your NAS share should now be available at: $(MOUNT_POINT)"
	@echo "The share will mount automatically when you access the directory."
	@echo
	@echo "Test with: ls $(MOUNT_POINT)"

.PHONY: install-autofs-package
install-autofs-package:
	@echo
	@echo "--> Installing autofs package"
ifeq ($(UNAME), Darwin)
	@# autofs is built into macOS, no installation needed
	@echo "autofs is built into macOS, skipping installation"
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
	@echo "Unsupported Linux distribution: $(DISTRO)"
	@echo "Please install autofs and cifs-utils manually"
	@exit 1
endif
endif

.PHONY: create-autofs-mountpoint
create-autofs-mountpoint:
	@echo
	@echo "--> Creating mount point directory"
ifeq ($(UNAME), Darwin)
	@# On macOS, create the actual mount point and symlink from ~/shared
	@sudo mkdir -p $(ACTUAL_MOUNT_POINT)
	@if [ ! -L $(MOUNT_POINT) ]; then \
		ln -s $(ACTUAL_MOUNT_POINT) $(MOUNT_POINT); \
		echo "Created symlink: $(MOUNT_POINT) -> $(ACTUAL_MOUNT_POINT)"; \
	else \
		echo "Symlink already exists: $(MOUNT_POINT)"; \
	fi
endif
ifeq ($(UNAME), Linux)
	@mkdir -p $(MOUNT_POINT)
endif

.PHONY: configure-autofs-maps
configure-autofs-maps:
	@echo
	@echo "--> Configuring autofs maps"
ifeq ($(UNAME), Darwin)
	@# macOS autofs configuration - uses direct mounts and keychain for credentials
	@echo "Creating macOS autofs map at $(AUTOFS_MAP)"
	@# Get password from keychain for the NAS host
	@NAS_PASSWORD=$$(security find-generic-password -s "$(NAS_HOST)" -a "$(NAS_USERNAME)" -w 2>/dev/null); \
	if [ -z "$$NAS_PASSWORD" ]; then \
		echo "ERROR: No password found in Keychain for host $(NAS_HOST), account $(NAS_USERNAME)"; \
		echo "Please run 'make setup-autofs-credentials' first to store credentials in Keychain."; \
		exit 1; \
	fi; \
	echo "$(ACTUAL_MOUNT_POINT) -fstype=smbfs,soft,noowners,nosuid,rw ://$(NAS_USERNAME):$$NAS_PASSWORD@$(NAS_HOST)/$(NAS_SHARE_NAME)" | sudo tee $(AUTOFS_MAP) > /dev/null
	@# Ensure only direct mount entry exists in auto_master (remove any old indirect mounts)
	@sudo sed -i.bak '/\/Users\/.*\/shared.*auto_nas/d' $(AUTOFS_CONF) 2>/dev/null || true
	@if ! grep -q "^/-[[:space:]].*auto_nas" $(AUTOFS_CONF); then \
		echo "/-	auto_nas	-nosuid" | sudo tee -a $(AUTOFS_CONF) > /dev/null; \
		echo "Added direct mount entry to $(AUTOFS_CONF)"; \
	else \
		echo "Direct mount entry already exists in $(AUTOFS_CONF)"; \
	fi
endif
ifeq ($(UNAME), Linux)
	@# Linux autofs configuration
	@echo "Creating Linux autofs map at $(AUTOFS_MAP)"
	@echo "shared -fstype=cifs,credentials=$(HOME)/.smbcredentials,uid=$$(id -u),gid=$$(id -g),file_mode=0644,dir_mode=0755 :$(NAS_SHARE)" | sudo tee $(AUTOFS_MAP) > /dev/null
	@if ! grep -q "$(MOUNT_POINT)" $(AUTOFS_CONF); then \
		echo "$(MOUNT_POINT) $(AUTOFS_MAP) --timeout=60" | sudo tee -a $(AUTOFS_CONF) > /dev/null; \
		echo "Added entry to $(AUTOFS_CONF)"; \
	else \
		echo "Entry already exists in $(AUTOFS_CONF)"; \
	fi
endif

.PHONY: restart-autofs-service
restart-autofs-service:
	@echo
	@echo "--> Restarting autofs service"
ifeq ($(UNAME), Darwin)
	sudo automount -vc
endif
ifeq ($(UNAME), Linux)
	sudo systemctl restart $(AUTOFS_SERVICE)
	sudo systemctl enable $(AUTOFS_SERVICE)
endif

.PHONY: setup-autofs-credentials
setup-autofs-credentials:
	@echo
	@echo "==> Setting up NAS configuration and credentials"
	@echo
	@set -e; \
	if [ -f $(AUTOFS_CONFIG) ]; then \
		echo "Configuration already exists at $(AUTOFS_CONFIG)"; \
		echo; \
		echo "Current configuration:"; \
		cat $(AUTOFS_CONFIG); \
		echo; \
		printf "Do you want to reconfigure? [y/N] "; \
		read REPLY; \
		case "$$REPLY" in \
			[Yy]*) echo "Reconfiguring...";; \
			*) echo "Setup cancelled."; exit 0;; \
		esac; \
	fi; \
	echo; \
	echo "This will configure your NAS connection details."; \
	echo "The configuration will be stored in $(AUTOFS_CONFIG)"; \
	echo "This file is NOT committed to the repository for security."; \
	echo; \
	printf "Enter your NAS hostname (e.g., nas.example.com): "; \
	read nas_host; \
	if [ -z "$$nas_host" ]; then \
		echo "ERROR: NAS hostname cannot be empty"; \
		exit 1; \
	fi; \
	printf "Enter the share name [shared]: "; \
	read nas_share; \
	nas_share=$${nas_share:-shared}; \
	printf "Enter your NAS username [$(USER)]: "; \
	read nas_username; \
	nas_username=$${nas_username:-$(USER)}; \
	echo "# Autofs NAS Configuration" > $(AUTOFS_CONFIG); \
	echo "# This file is NOT committed to the repository" >> $(AUTOFS_CONFIG); \
	echo "# Generated on $$(date)" >> $(AUTOFS_CONFIG); \
	echo "nas_host=$$nas_host" >> $(AUTOFS_CONFIG); \
	echo "nas_share=$$nas_share" >> $(AUTOFS_CONFIG); \
	echo "nas_username=$$nas_username" >> $(AUTOFS_CONFIG); \
	chmod 600 $(AUTOFS_CONFIG); \
	echo; \
	echo "Configuration saved to $(AUTOFS_CONFIG)"; \
	echo
	@# Platform-specific credential setup
ifeq ($(UNAME), Darwin)
	@echo "macOS Credential Setup:"
	@echo "----------------------"
	@echo "macOS uses Keychain for Samba credentials."
	@echo
	@NAS_HOST_VAL=$$(grep '^nas_host=' $(AUTOFS_CONFIG) | cut -d'=' -f2); \
	NAS_USER_VAL=$$(grep '^nas_username=' $(AUTOFS_CONFIG) | cut -d'=' -f2); \
	echo "Storing credentials for $$NAS_HOST_VAL (account: $$NAS_USER_VAL) in Keychain..."; \
	echo; \
	printf "Enter password for $$NAS_USER_VAL@$$NAS_HOST_VAL: "; \
	stty -echo; \
	read NAS_PASSWORD; \
	stty echo; \
	echo; \
	if [ -n "$$NAS_PASSWORD" ]; then \
		security delete-generic-password -s "$$NAS_HOST_VAL" -a "$$NAS_USER_VAL" 2>/dev/null || true; \
		security add-generic-password -s "$$NAS_HOST_VAL" -a "$$NAS_USER_VAL" -w "$$NAS_PASSWORD" -T /usr/sbin/automount -T /usr/bin/security; \
		echo "Credentials stored in Keychain for $$NAS_HOST_VAL (account: $$NAS_USER_VAL)"; \
	else \
		echo "ERROR: Password cannot be empty"; \
		exit 1; \
	fi
endif
ifeq ($(UNAME), Linux)
	@echo "Linux Credential Setup:"
	@echo "----------------------"
	@if [ -f $(HOME)/.smbcredentials ]; then \
		echo "Credentials file already exists at $(HOME)/.smbcredentials"; \
		echo; \
		printf "Do you want to update it? [y/N] "; \
		read REPLY; \
		case "$$REPLY" in \
			[Yy]*) echo "Updating credentials...";; \
			*) echo "Keeping existing credentials file."; exit 0;; \
		esac; \
	fi; \
	echo; \
	printf "Enter your Samba username: "; \
	read smb_user; \
	printf "Enter your Samba password: "; \
	stty -echo; \
	read smb_pass; \
	stty echo; \
	echo; \
	printf "Enter your Samba domain [WORKGROUP]: "; \
	read smb_domain; \
	smb_domain=$${smb_domain:-WORKGROUP}; \
	echo "username=$$smb_user" > $(HOME)/.smbcredentials; \
	echo "password=$$smb_pass" >> $(HOME)/.smbcredentials; \
	echo "domain=$$smb_domain" >> $(HOME)/.smbcredentials; \
	chmod 600 $(HOME)/.smbcredentials; \
	echo; \
	echo "Credentials saved to $(HOME)/.smbcredentials (mode 600)"
endif
	@echo
	@echo "==> Configuration complete!"
	@echo
	@echo "Next steps:"
	@echo "  1. Run 'make setup-autofs' to install and configure autofs"
	@echo "  2. Run 'make test-autofs' to test the mount"

.PHONY: test-autofs
test-autofs:
	@echo
	@echo "==> Testing autofs NAS mount"
	@echo
	@echo "Attempting to access $(MOUNT_POINT)"
	@ls -la $(MOUNT_POINT) || echo "Mount failed - check autofs configuration and credentials"

.PHONY: remove-autofs
remove-autofs:
	@echo
	@echo "==> Removing autofs NAS configuration"
	@echo
	@echo "This will:"
	@echo "1. Remove autofs map entries"
	@echo "2. Remove mount point directory"
	@echo "3. Restart autofs service"
	@echo
	@printf "Continue with removal? [y/N] "; \
	read REPLY; \
	case "$$REPLY" in \
		[Yy]*) echo "Proceeding with removal...";; \
		*) echo "Removal cancelled."; exit 1;; \
	esac
	@echo
	@echo "--> Removing autofs configuration"
	@sudo sed -i.bak '/$(subst /,\/,$(MOUNT_POINT))/d' $(AUTOFS_CONF)
	@if [ -f $(AUTOFS_MAP) ]; then sudo rm -f $(AUTOFS_MAP); fi
	@echo
	@echo "--> Removing mount point"
	@rm -rf $(MOUNT_POINT)
	@$(MAKE) restart-autofs-service
	@echo
	@echo "Autofs NAS configuration removed."

.PHONY: status-autofs
status-autofs:
	@echo
	@echo "==> Autofs NAS Status"
	@echo
	@echo "NAS Host: $(NAS_HOST)"
	@echo "NAS Share: $(NAS_SHARE)"
	@echo "NAS Username: $(NAS_USERNAME)"
	@echo "User Mount Point: $(MOUNT_POINT)"
ifeq ($(UNAME), Darwin)
	@echo "Actual Mount Point: $(ACTUAL_MOUNT_POINT)"
endif
	@echo
	@echo "Autofs Configuration:"
	@if [ -f $(AUTOFS_CONF) ]; then \
		echo "Master config: $(AUTOFS_CONF)"; \
		grep -E "auto_nas" $(AUTOFS_CONF) 2>/dev/null || echo "  No entries found"; \
	else \
		echo "Master config not found: $(AUTOFS_CONF)"; \
	fi
	@echo
	@if [ -f $(AUTOFS_MAP) ]; then \
		echo "Map config: $(AUTOFS_MAP)"; \
		sudo cat $(AUTOFS_MAP) | sed 's/:[^:]*@/:****@/g'; \
	else \
		echo "Map config not found: $(AUTOFS_MAP)"; \
	fi
	@echo
	@echo "Mount Point Status:"
ifeq ($(UNAME), Darwin)
	@if [ -L $(MOUNT_POINT) ]; then \
		echo "  Symlink exists: $(MOUNT_POINT) -> $$(readlink $(MOUNT_POINT))"; \
	else \
		echo "  Symlink does not exist: $(MOUNT_POINT)"; \
	fi
	@if [ -d $(ACTUAL_MOUNT_POINT) ]; then \
		echo "  Actual mount point exists: $(ACTUAL_MOUNT_POINT)"; \
		mount | grep "$(ACTUAL_MOUNT_POINT)" || echo "  Not currently mounted"; \
	else \
		echo "  Actual mount point does not exist: $(ACTUAL_MOUNT_POINT)"; \
	fi
endif
ifeq ($(UNAME), Linux)
	@if [ -d $(MOUNT_POINT) ]; then \
		echo "  Directory exists: $(MOUNT_POINT)"; \
		mount | grep "$(MOUNT_POINT)" || echo "  Not currently mounted"; \
	else \
		echo "  Directory does not exist: $(MOUNT_POINT)"; \
	fi
endif
	@echo
ifeq ($(UNAME), Darwin)
	@echo "Autofs Service Status:"
	@ps aux | grep -E "[a]utomountd|[a]utofsd" || echo "  Autofs service not running"
endif
ifeq ($(UNAME), Linux)
	@echo "Autofs Service Status:"
	@systemctl is-active $(AUTOFS_SERVICE) || echo "  Service not running"
	@systemctl is-enabled $(AUTOFS_SERVICE) || echo "  Service not enabled"
endif

.PHONY: help-autofs
help-autofs:
	@echo
	@echo "==> Autofs NAS Mounting Help"
	@echo
	@echo "Available targets:"
	@echo "  make setup-autofs              - Complete autofs setup for NAS mounting"
	@echo "  make setup-autofs-credentials  - Configure Samba credentials"
	@echo "  make test-autofs               - Test the NAS mount"
	@echo "  make status-autofs             - Show autofs configuration status"
	@echo "  make restart-autofs-service    - Restart autofs service"
	@echo "  make remove-autofs             - Remove autofs NAS configuration"
	@echo "  make help-autofs               - Show this help message"
	@echo
	@echo "Quick start:"
	@echo "  1. make setup-autofs-credentials  # Set up Samba credentials"
	@echo "  2. make setup-autofs              # Configure autofs"
	@echo "  3. make test-autofs               # Test the mount"
	@echo
	@echo "Configuration:"
	@echo "  NAS Host:         $(NAS_HOST)"
	@echo "  NAS Username:     $(NAS_USERNAME)"
	@echo "  User Mount Point: $(MOUNT_POINT)"
ifeq ($(UNAME), Darwin)
	@echo "  Actual Mount:     $(ACTUAL_MOUNT_POINT)"
endif
	@echo "  Share:            $(NAS_SHARE)"
	@echo
