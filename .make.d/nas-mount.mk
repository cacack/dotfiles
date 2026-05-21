################################################################################
# NAS mount configuration
#
# Mounts a Samba share at ~/shared using platform-native tooling:
#
#   macOS:  launchd (com.user.nas-mount) runs scripts/mount-nas.sh every
#           5 minutes (plus on network-state changes via WatchPaths).
#           The script reads ~/.autofs_config, looks up the password in
#           Keychain, and uses `osascript "mount volume"` (the NetFS path
#           Finder uses). Logs to ~/.local/share/logs/nas-mount.log.
#
#   Linux:  autofs with an on-demand map at /etc/auto.smb, triggered by
#           accessing ~/shared. Credentials in ~/.smbcredentials (chmod 600).
#
# Shared configuration: ~/.autofs_config (host/share/username, not in repo).
# Replaces the previous all-autofs setup; autofs on macOS had a Sequoia
# root-ownership bug and assorted lease-cache fragility.
#
# See docs/NAS-MOUNT-SETUP.md for the user-facing guide.
################################################################################

# Shared paths
NAS_CONFIG_FILE := $(HOME)/.autofs_config
NAS_SYMLINK     := $(HOME)/shared

ifeq ($(UNAME), Darwin)
NAS_PLIST          := $(HOME)/Library/LaunchAgents/com.user.nas-mount.plist
NAS_PLIST_TEMPLATE := $(HOME)/.dotfiles/templates/com.user.nas-mount.plist.template
NAS_LABEL          := com.user.nas-mount
NAS_SCRIPT         := $(DOTFILES_SCRIPT_DIR)/mount-nas.sh
NAS_LOG            := $(HOME)/.local/share/logs/nas-mount.log
endif

ifeq ($(UNAME), Linux)
AUTOFS_MASTER  := /etc/auto.master
AUTOFS_MAP     := /etc/auto.smb
SMB_CREDS_FILE := $(HOME)/.smbcredentials
endif

################################################################################
# User-facing targets
################################################################################

.PHONY: nas-mount
nas-mount: ## Set up NAS auto-mounting (idempotent — prompts only for missing pieces)
	@echo
	@echo "==> NAS Mount Setup ($(OS))"
	@$(MAKE) --no-print-directory _nas-ensure-config
ifeq ($(UNAME), Darwin)
	@$(MAKE) --no-print-directory _nas-darwin-ensure-keychain
	@$(MAKE) --no-print-directory _nas-darwin-ensure-launchd
endif
ifeq ($(UNAME), Linux)
	@$(MAKE) --no-print-directory _nas-linux-ensure-autofs
endif
	@echo
	@echo "Setup complete. Run: make nas-status"

.PHONY: nas-status
nas-status: ## Show NAS mount status
	@echo
	@echo "==> NAS Mount Status ($(OS))"
	@echo
	@echo "Configuration:"
	@if [ -f $(NAS_CONFIG_FILE) ]; then \
		echo "  [OK] $(NAS_CONFIG_FILE)"; \
		sed 's/^/       /' $(NAS_CONFIG_FILE); \
	else \
		echo "  [MISSING] $(NAS_CONFIG_FILE)"; \
	fi
	@echo
	@echo "Components:"
ifeq ($(UNAME), Darwin)
	@if [ -x $(NAS_SCRIPT) ]; then echo "  [OK] script $(NAS_SCRIPT)"; else echo "  [MISSING] script $(NAS_SCRIPT)"; fi
	@if [ -f $(NAS_PLIST) ]; then echo "  [OK] plist $(NAS_PLIST)"; else echo "  [MISSING] plist $(NAS_PLIST)"; fi
	@if launchctl list 2>/dev/null | grep -q $(NAS_LABEL); then \
		echo "  [OK] launchd loaded ($(NAS_LABEL))"; \
	else \
		echo "  [MISSING] launchd not loaded ($(NAS_LABEL))"; \
	fi
	@HOST=$$(grep '^nas_host=' $(NAS_CONFIG_FILE) 2>/dev/null | cut -d'=' -f2); \
	NAS_USER=$$(grep '^nas_username=' $(NAS_CONFIG_FILE) 2>/dev/null | cut -d'=' -f2); \
	if [ -n "$$HOST" ] && [ -n "$$NAS_USER" ]; then \
		if security find-generic-password -s "$$HOST" -a "$$NAS_USER" -w >/dev/null 2>&1; then \
			echo "  [OK] keychain entry ($$NAS_USER@$$HOST)"; \
		else \
			echo "  [MISSING] keychain entry for $$NAS_USER@$$HOST"; \
		fi; \
	fi
endif
ifeq ($(UNAME), Linux)
	@if grep -q auto_smb $(AUTOFS_MASTER) 2>/dev/null; then echo "  [OK] $(AUTOFS_MASTER) has auto_smb"; else echo "  [MISSING] no auto_smb in $(AUTOFS_MASTER)"; fi
	@if [ -f $(AUTOFS_MAP) ]; then echo "  [OK] $(AUTOFS_MAP)"; else echo "  [MISSING] $(AUTOFS_MAP)"; fi
	@if [ -f $(SMB_CREDS_FILE) ]; then echo "  [OK] $(SMB_CREDS_FILE)"; else echo "  [MISSING] $(SMB_CREDS_FILE)"; fi
endif
	@echo
	@echo "Mount state:"
	@if [ -L $(NAS_SYMLINK) ]; then \
		echo "  symlink: $(NAS_SYMLINK) -> $$(readlink $(NAS_SYMLINK))"; \
	elif [ -d $(NAS_SYMLINK) ]; then \
		echo "  directory: $(NAS_SYMLINK)"; \
	else \
		echo "  [MISSING] $(NAS_SYMLINK)"; \
	fi
	@if mount | grep -qE "on $(NAS_SYMLINK)|on /Volumes/shared\b"; then \
		echo "  [MOUNTED]"; \
	else \
		echo "  [NOT MOUNTED]"; \
	fi

.PHONY: nas-test
nas-test: ## Test the NAS mount
	@echo
	@echo "==> Testing $(NAS_SYMLINK)"
	@if ls $(NAS_SYMLINK)/ >/dev/null 2>&1; then \
		ls $(NAS_SYMLINK)/ | head -10; \
		echo; \
		echo "[OK] Mount accessible"; \
	else \
		echo "[ERROR] Cannot list $(NAS_SYMLINK). Try: make nas-fix"; \
		exit 1; \
	fi

.PHONY: nas-logs
nas-logs: ## View recent mount logs (macOS only)
ifeq ($(UNAME), Darwin)
	@echo
	@echo "==> $(NAS_LOG) (last 30 lines)"
	@echo
	@tail -30 $(NAS_LOG) 2>/dev/null || echo "(log file does not exist yet)"
else
	@echo "Linux uses autofs; try: journalctl -u autofs -n 50 --no-pager"
endif

.PHONY: nas-fix
nas-fix: ## Interactive fix menu
	@echo
	@echo "==> NAS Mount Fix Menu"
	@echo
ifeq ($(UNAME), Darwin)
	@echo "  1) Refresh Keychain password (e.g. after server-side rotation)"
	@echo "  2) Restart launchd agent"
	@echo "  3) Force remount now"
	@echo "  q) Quit"
	@echo
	@printf "Choice: "; \
	read CHOICE; \
	case "$$CHOICE" in \
		1) $(MAKE) --no-print-directory _nas-darwin-refresh-keychain ;; \
		2) $(MAKE) --no-print-directory _nas-darwin-restart-agent ;; \
		3) $(MAKE) --no-print-directory _nas-darwin-force-remount ;; \
		q|Q) echo "Cancelled." ;; \
		*) echo "Invalid choice." ;; \
	esac
endif
ifeq ($(UNAME), Linux)
	@echo "Reloading autofs..."
	@sudo automount -u
	@sudo automount -cv
endif

.PHONY: nas-remove
nas-remove: ## Remove NAS mount configuration
	@echo
	@echo "==> Remove NAS Mount"
	@echo
ifeq ($(UNAME), Darwin)
	@echo "This will:"
	@echo "  - Unload LaunchAgent $(NAS_LABEL)"
	@echo "  - Force-unmount /Volumes/shared (if mounted)"
	@echo "  - Remove symlink $(NAS_SYMLINK)"
	@echo "  Keychain entry kept; remove manually with:"
	@echo "    security delete-generic-password -s <host> -a <user>"
endif
ifeq ($(UNAME), Linux)
	@echo "This will:"
	@echo "  - Remove auto_smb entry from $(AUTOFS_MASTER)"
	@echo "  - Delete $(AUTOFS_MAP)"
	@echo "  - Reload autofs"
endif
	@echo
	@printf "Continue? [y/N] "; \
	read REPLY; \
	case "$$REPLY" in \
		[Yy]*) $(MAKE) --no-print-directory _nas-remove-confirmed ;; \
		*) echo "Cancelled." ;; \
	esac

################################################################################
# Internal targets
################################################################################

.PHONY: _nas-ensure-config
_nas-ensure-config:
	@if [ ! -f $(NAS_CONFIG_FILE) ]; then \
		echo; \
		echo "Creating $(NAS_CONFIG_FILE)..."; \
		printf "  NAS hostname: "; read HOST; \
		printf "  NAS share name: "; read SHARE; \
		printf "  Username: "; read NAS_USER; \
		{ \
			echo "nas_host=$$HOST"; \
			echo "nas_share=$$SHARE"; \
			echo "nas_username=$$NAS_USER"; \
		} > $(NAS_CONFIG_FILE); \
		chmod 600 $(NAS_CONFIG_FILE); \
		echo "Wrote $(NAS_CONFIG_FILE)"; \
	else \
		echo "[OK] config $(NAS_CONFIG_FILE)"; \
	fi

ifeq ($(UNAME), Darwin)

.PHONY: _nas-darwin-ensure-keychain
_nas-darwin-ensure-keychain:
	@HOST=$$(grep '^nas_host=' $(NAS_CONFIG_FILE) | cut -d'=' -f2); \
	NAS_USER=$$(grep '^nas_username=' $(NAS_CONFIG_FILE) | cut -d'=' -f2); \
	if security find-generic-password -s "$$HOST" -a "$$NAS_USER" -w >/dev/null 2>&1; then \
		echo "[OK] keychain entry for $$NAS_USER@$$HOST"; \
	else \
		echo; \
		printf "SMB password for $$NAS_USER@$$HOST: "; \
		stty -echo; read PW; stty echo; echo; \
		security add-generic-password -U \
			-s "$$HOST" -a "$$NAS_USER" -w "$$PW" \
			-T /sbin/mount_smbfs \
			-T /System/Library/CoreServices/NetAuthAgent.app \
			-T /usr/bin/security; \
		echo "Keychain entry created"; \
	fi

.PHONY: _nas-darwin-ensure-launchd
_nas-darwin-ensure-launchd: _nas-darwin-render-plist
	@if launchctl list 2>/dev/null | grep -q $(NAS_LABEL); then \
		echo "[OK] launchd $(NAS_LABEL) already loaded"; \
	else \
		launchctl bootstrap gui/$$(id -u) $(NAS_PLIST); \
		echo "Loaded launchd $(NAS_LABEL)"; \
	fi

# Render the plist from template into ~/Library/LaunchAgents/. If the
# rendered output differs from what's installed, reload the agent so the
# new settings take effect.
.PHONY: _nas-darwin-render-plist
_nas-darwin-render-plist:
	@if [ ! -f $(NAS_PLIST_TEMPLATE) ]; then \
		echo "ERROR: template $(NAS_PLIST_TEMPLATE) not found"; \
		exit 1; \
	fi
	@mkdir -p $(dir $(NAS_PLIST))
	@RENDERED=$$(mktemp); \
	sed 's|{{MOUNT_SCRIPT}}|$(NAS_SCRIPT)|g' $(NAS_PLIST_TEMPLATE) > $$RENDERED; \
	if [ -f $(NAS_PLIST) ] && cmp -s $$RENDERED $(NAS_PLIST); then \
		echo "[OK] plist $(NAS_PLIST) up to date"; \
		rm -f $$RENDERED; \
	else \
		mv $$RENDERED $(NAS_PLIST); \
		echo "Wrote $(NAS_PLIST) from template"; \
		if launchctl list 2>/dev/null | grep -q $(NAS_LABEL); then \
			echo "Reloading $(NAS_LABEL) to pick up new plist..."; \
			launchctl bootout gui/$$(id -u)/$(NAS_LABEL) 2>/dev/null || true; \
			launchctl bootstrap gui/$$(id -u) $(NAS_PLIST); \
		fi; \
	fi

.PHONY: _nas-darwin-refresh-keychain
_nas-darwin-refresh-keychain:
	@HOST=$$(grep '^nas_host=' $(NAS_CONFIG_FILE) | cut -d'=' -f2); \
	NAS_USER=$$(grep '^nas_username=' $(NAS_CONFIG_FILE) | cut -d'=' -f2); \
	printf "New SMB password for $$NAS_USER@$$HOST: "; \
	stty -echo; read PW; stty echo; echo; \
	security add-generic-password -U \
		-s "$$HOST" -a "$$NAS_USER" -w "$$PW" \
		-T /sbin/mount_smbfs \
		-T /System/Library/CoreServices/NetAuthAgent.app \
		-T /usr/bin/security; \
	echo "Keychain updated. Forcing remount..."; \
	$(MAKE) --no-print-directory _nas-darwin-force-remount

.PHONY: _nas-darwin-restart-agent
_nas-darwin-restart-agent:
	@launchctl bootout gui/$$(id -u)/$(NAS_LABEL) 2>/dev/null || true
	@launchctl bootstrap gui/$$(id -u) $(NAS_PLIST)
	@echo "LaunchAgent restarted"

.PHONY: _nas-darwin-force-remount
_nas-darwin-force-remount:
	@diskutil unmount force /Volumes/shared 2>/dev/null || true
	@$(NAS_SCRIPT)
	@echo "Mount cycle triggered. Tail logs: make nas-logs"

endif

ifeq ($(UNAME), Linux)

.PHONY: _nas-linux-ensure-autofs
_nas-linux-ensure-autofs:
	@HOST=$$(grep '^nas_host=' $(NAS_CONFIG_FILE) | cut -d'=' -f2); \
	SHARE=$$(grep '^nas_share=' $(NAS_CONFIG_FILE) | cut -d'=' -f2); \
	NAS_USER=$$(grep '^nas_username=' $(NAS_CONFIG_FILE) | cut -d'=' -f2); \
	if [ ! -f $(SMB_CREDS_FILE) ]; then \
		printf "SMB password for $$NAS_USER@$$HOST: "; \
		stty -echo; read PW; stty echo; echo; \
		{ echo "username=$$NAS_USER"; echo "password=$$PW"; } > $(SMB_CREDS_FILE); \
		chmod 600 $(SMB_CREDS_FILE); \
		echo "Wrote $(SMB_CREDS_FILE)"; \
	fi; \
	if ! grep -q auto_smb $(AUTOFS_MASTER); then \
		echo "/- auto_smb --timeout=300" | sudo tee -a $(AUTOFS_MASTER) > /dev/null; \
	fi; \
	if [ ! -f $(AUTOFS_MAP) ]; then \
		echo "$(NAS_SYMLINK) -fstype=cifs,credentials=$(SMB_CREDS_FILE),uid=$$(id -u),gid=$$(id -g) ://$$HOST/$$SHARE" | sudo tee $(AUTOFS_MAP) > /dev/null; \
	fi; \
	sudo systemctl restart autofs 2>/dev/null || sudo automount -vc || true

endif

.PHONY: _nas-remove-confirmed
_nas-remove-confirmed:
ifeq ($(UNAME), Darwin)
	@launchctl bootout gui/$$(id -u)/$(NAS_LABEL) 2>/dev/null || true
	@diskutil unmount force /Volumes/shared 2>/dev/null || true
	@rm -f $(NAS_SYMLINK)
	@echo "Removed."
endif
ifeq ($(UNAME), Linux)
	@sudo sed -i.bak '/auto_smb/d' $(AUTOFS_MASTER)
	@sudo rm -f $(AUTOFS_MAP)
	@sudo systemctl restart autofs 2>/dev/null || sudo automount -vc || true
	@echo "Removed."
endif
