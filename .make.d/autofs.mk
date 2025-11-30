################################################################################
# Autofs configuration for NAS mounting
#
# This module sets up autofs to automatically mount Samba shares.
# Based on: https://gist.github.com/rudelm/7bcc905ab748ab9879ea
#
# Credentials are retrieved from Bitwarden using the `bw` CLI.
# The password is embedded in the autofs map file (required for autofs).
#
# macOS Sequoia note: After reboot, mounts may be owned by root.
# Run `make autofs-fix` or the mount will auto-fix on first access attempt.
#
# User-facing targets:
#   setup-autofs  - Complete setup (retrieves creds from Bitwarden)
#   autofs-status - Show current configuration and mount status
#   autofs-test   - Test the NAS mount
#   autofs-fix    - Fix ownership after reboot (macOS Sequoia bug)
#   autofs-remove - Remove autofs NAS configuration
################################################################################

# Bitwarden item ID for NAS credentials (Samba entry with username 'chris')
BW_NAS_ITEM_ID := 822d23b2-a60e-43b4-bf4b-108990046c57

# NAS configuration
NAS_HOST := borg.theclonchs.com
NAS_SHARE := shared
NAS_USERNAME := chris

# Platform-specific paths
ifeq ($(UNAME), Darwin)
AUTOFS_MASTER := /etc/auto_master
AUTOFS_MAP := /etc/auto_smb
# Sequoia requires /System/Volumes/Data prefix for mount points
ACTUAL_MOUNT_POINT := /System/Volumes/Data/mnt/nas
MOUNT_SYMLINK := $(HOME)/shared
endif

ifeq ($(UNAME), Linux)
AUTOFS_MASTER := /etc/auto.master
AUTOFS_MAP := /etc/auto.smb
ACTUAL_MOUNT_POINT := $(HOME)/shared
endif

################################################################################
# User-facing targets
################################################################################

.PHONY: setup-autofs
setup-autofs: ## Set up autofs NAS mounting (retrieves password from Bitwarden)
	@echo
	@echo "==> Autofs NAS Setup"
	@echo
	@echo "This will configure autofs to mount //$(NAS_HOST)/$(NAS_SHARE)"
ifeq ($(UNAME), Darwin)
	@echo "Mount point: $(MOUNT_SYMLINK) -> $(ACTUAL_MOUNT_POINT)"
else
	@echo "Mount point: $(ACTUAL_MOUNT_POINT)"
endif
	@echo
	@echo "Retrieving password from Bitwarden..."
	@if ! command -v bw >/dev/null 2>&1; then \
		echo "ERROR: Bitwarden CLI (bw) not found. Install with: make setup-bitwarden"; \
		exit 1; \
	fi
	@BW_STATUS=$$(bw status 2>/dev/null | grep -o '"status":"[^"]*"' | cut -d'"' -f4); \
	if [ "$$BW_STATUS" != "unlocked" ]; then \
		echo "ERROR: Bitwarden is not unlocked. Run: eval \$$(bw unlock)"; \
		exit 1; \
	fi
	@NAS_PASSWORD=$$(bw get item "$(BW_NAS_ITEM_ID)" 2>/dev/null | jq -r '.login.password'); \
	if [ -z "$$NAS_PASSWORD" ] || [ "$$NAS_PASSWORD" = "null" ]; then \
		echo "ERROR: Could not retrieve password from Bitwarden"; \
		exit 1; \
	fi; \
	echo "Password retrieved successfully."; \
	echo; \
	$(MAKE) _autofs-install NAS_PASSWORD="$$NAS_PASSWORD"
	@echo
	@echo "==> Setup complete!"
	@echo
	@echo "Test with: make autofs-test"
	@echo "Status:    make autofs-status"
ifeq ($(UNAME), Darwin)
	@echo
	@echo "NOTE: After reboot, run 'make autofs-fix' if mount is owned by root."
endif

.PHONY: autofs-status
autofs-status: ## Show autofs NAS configuration and mount status
	@echo
	@echo "==> Autofs NAS Status"
	@echo
	@echo "Configuration:"
	@echo "  NAS Host:     $(NAS_HOST)"
	@echo "  NAS Share:    $(NAS_SHARE)"
	@echo "  NAS Username: $(NAS_USERNAME)"
ifeq ($(UNAME), Darwin)
	@echo "  Mount Point:  $(MOUNT_SYMLINK) -> $(ACTUAL_MOUNT_POINT)"
else
	@echo "  Mount Point:  $(ACTUAL_MOUNT_POINT)"
endif
	@echo
	@echo "System Files:"
	@if grep -q "auto_smb" $(AUTOFS_MASTER) 2>/dev/null; then \
		echo "  [OK] $(AUTOFS_MASTER) has auto_smb entry"; \
	else \
		echo "  [MISSING] No auto_smb in $(AUTOFS_MASTER)"; \
	fi
	@if [ -f $(AUTOFS_MAP) ]; then \
		echo "  [OK] $(AUTOFS_MAP) exists"; \
	else \
		echo "  [MISSING] $(AUTOFS_MAP) not found"; \
	fi
	@echo
	@echo "Mount Status:"
ifeq ($(UNAME), Darwin)
	@if [ -L $(MOUNT_SYMLINK) ]; then \
		echo "  [OK] Symlink exists: $(MOUNT_SYMLINK)"; \
	else \
		echo "  [MISSING] Symlink not found"; \
	fi
	@if mount | grep -q "$(ACTUAL_MOUNT_POINT)"; then \
		echo "  [MOUNTED] Currently mounted"; \
	else \
		echo "  [NOT MOUNTED] Will mount on access"; \
	fi
	@if [ -d $(ACTUAL_MOUNT_POINT) ]; then \
		OWNER=$$(stat -f "%Su" $(ACTUAL_MOUNT_POINT) 2>/dev/null); \
		if [ "$$OWNER" = "root" ]; then \
			echo "  [WARNING] Owned by root - run 'make autofs-fix'"; \
		else \
			echo "  [OK] Owned by $$OWNER"; \
		fi; \
	fi
endif
ifeq ($(UNAME), Linux)
	@if mount | grep -q "$(ACTUAL_MOUNT_POINT)"; then \
		echo "  [MOUNTED] Currently mounted"; \
	else \
		echo "  [NOT MOUNTED] Will mount on access"; \
	fi
endif

.PHONY: autofs-test
autofs-test: ## Test the autofs NAS mount
	@echo
	@echo "==> Testing autofs mount"
	@echo
ifeq ($(UNAME), Darwin)
	@echo "Accessing $(MOUNT_SYMLINK)..."
	@if ls $(MOUNT_SYMLINK)/ >/dev/null 2>&1; then \
		ls -la $(MOUNT_SYMLINK)/ | head -10; \
		echo; \
		echo "[OK] Mount successful!"; \
	else \
		echo "[ERROR] Mount failed"; \
		echo "Try: make autofs-fix"; \
		exit 1; \
	fi
else
	@echo "Accessing $(ACTUAL_MOUNT_POINT)..."
	@if ls $(ACTUAL_MOUNT_POINT)/ >/dev/null 2>&1; then \
		ls -la $(ACTUAL_MOUNT_POINT)/ | head -10; \
		echo; \
		echo "[OK] Mount successful!"; \
	else \
		echo "[ERROR] Mount failed"; \
		exit 1; \
	fi
endif

.PHONY: autofs-fix
autofs-fix: ## Fix autofs mount ownership (macOS Sequoia workaround)
	@echo
	@echo "==> Fixing autofs mount (Sequoia workaround)"
	@echo
	@echo "Running: sudo automount -u && sudo automount -cv"
	@sudo automount -u
	@sudo automount -cv
	@echo
	@echo "Done. Test with: make autofs-test"

.PHONY: autofs-remove
autofs-remove: ## Remove autofs NAS configuration
	@echo
	@echo "==> Remove autofs NAS configuration"
	@echo
	@echo "This will remove:"
	@echo "  - auto_smb entry from $(AUTOFS_MASTER)"
	@echo "  - $(AUTOFS_MAP) map file"
ifeq ($(UNAME), Darwin)
	@echo "  - Symlink at $(MOUNT_SYMLINK)"
endif
	@echo
	@printf "Continue? [y/N] "
	@read REPLY; \
	case "$$REPLY" in \
		[Yy]*) \
			echo; \
			sudo sed -i.bak '/auto_smb/d' $(AUTOFS_MASTER); \
			sudo rm -f $(AUTOFS_MAP); \
			rm -f $(MOUNT_SYMLINK) 2>/dev/null || true; \
			sudo automount -vc; \
			echo "Autofs configuration removed."; \
			;; \
		*) echo "Cancelled.";; \
	esac

################################################################################
# Internal targets
################################################################################

.PHONY: _autofs-install
_autofs-install:
ifndef NAS_PASSWORD
	$(error NAS_PASSWORD not set)
endif
	@echo "Creating mount point directory..."
ifeq ($(UNAME), Darwin)
	@sudo mkdir -p $(ACTUAL_MOUNT_POINT)
	@sudo chown $(USER) $(ACTUAL_MOUNT_POINT)
endif
ifeq ($(UNAME), Linux)
	@sudo mkdir -p $(ACTUAL_MOUNT_POINT)
	@sudo chown $(USER):$(USER) $(ACTUAL_MOUNT_POINT)
endif
	@echo
	@echo "Creating autofs map file..."
ifeq ($(UNAME), Darwin)
	@# URL-encode special characters in password for SMB URL
	@ENCODED_PASS=$$(python3 -c "import urllib.parse; print(urllib.parse.quote('$(NAS_PASSWORD)', safe=''))"); \
	echo "$(ACTUAL_MOUNT_POINT) -fstype=smbfs,soft,noowners,nosuid,rw ://$(NAS_USERNAME):$$ENCODED_PASS@$(NAS_HOST)/$(NAS_SHARE)" | sudo tee $(AUTOFS_MAP) > /dev/null
	@sudo chmod 600 $(AUTOFS_MAP)
endif
ifeq ($(UNAME), Linux)
	@# Linux uses credentials file instead of embedded password
	@echo "username=$(NAS_USERNAME)" > $(HOME)/.smbcredentials
	@echo "password=$(NAS_PASSWORD)" >> $(HOME)/.smbcredentials
	@chmod 600 $(HOME)/.smbcredentials
	@echo "$(NAS_SHARE) -fstype=cifs,credentials=$(HOME)/.smbcredentials,uid=$$(id -u),gid=$$(id -g) ://$(NAS_HOST)/$(NAS_SHARE)" | sudo tee $(AUTOFS_MAP) > /dev/null
endif
	@echo
	@echo "Updating $(AUTOFS_MASTER)..."
	@sudo sed -i.bak '/auto_smb/d' $(AUTOFS_MASTER) 2>/dev/null || true
ifeq ($(UNAME), Darwin)
	@echo "/-	auto_smb	-nosuid,noowners" | sudo tee -a $(AUTOFS_MASTER) > /dev/null
endif
ifeq ($(UNAME), Linux)
	@echo "/- auto_smb --timeout=300" | sudo tee -a $(AUTOFS_MASTER) > /dev/null
endif
	@echo
	@echo "Creating symlink..."
ifeq ($(UNAME), Darwin)
	@rm -f $(MOUNT_SYMLINK) 2>/dev/null || true
	@ln -s $(ACTUAL_MOUNT_POINT) $(MOUNT_SYMLINK)
	@echo "Created: $(MOUNT_SYMLINK) -> $(ACTUAL_MOUNT_POINT)"
endif
	@echo
	@echo "Reloading autofs..."
	@sudo automount -vc
