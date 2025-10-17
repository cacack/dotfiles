################################################################################
# macOS System Settings
#
# Manages macOS system preferences and dock configuration using:
# - defaults: Built-in macOS tool for user preferences
# - dockutil: Homebrew tool for managing dock items
#
# IMPORTANT: Many settings require logging out or restarting to take full effect.
#
# To discover current settings:
# 1. Run: make capture-macos-settings
# 2. Make changes in System Settings
# 3. Run: make capture-macos-settings again and diff the output
#
# To customize:
# 1. Uncomment and modify the settings below
# 2. Add new settings following the same pattern
# 3. Run: make apply-macos-settings
################################################################################

################################################################################
# TODO: Review and customize these settings for your preferences
################################################################################

SETUP += setup-macos-settings

.PHONY: setup-macos-settings
setup-macos-settings:
ifeq ($(OS),darwin)
	@echo
	# Applying macOS system settings
	$(MAKE) install-dockutil
	$(MAKE) apply-macos-dock
	$(MAKE) apply-macos-preferences
	@echo ""
	@echo "⚠️  Note: Some settings require logging out or restarting to take effect."
endif

################################################################################
# Dock Configuration
################################################################################

.PHONY: install-dockutil
install-dockutil:
ifeq ($(OS),darwin)
	@if ! command -v dockutil >/dev/null 2>&1; then \
		echo "Installing dockutil..."; \
		brew install dockutil; \
	fi
endif

.PHONY: apply-macos-dock
apply-macos-dock:
ifeq ($(OS),darwin)
	@echo
	# Configuring macOS Dock

	# TODO: Customize dock position (left, bottom, right)
	defaults write com.apple.dock orientation -string "left"

	# TODO: Customize dock auto-hide behavior
	defaults write com.apple.dock autohide -bool true

	# TODO: Customize dock icon size (16-128, suggested: 32-48 for small)
	defaults write com.apple.dock tilesize -int 36

	# TODO: Minimize windows into application icon
	defaults write com.apple.dock minimize-to-application -bool true

	# TODO: Show indicator lights for open applications
	defaults write com.apple.dock show-process-indicators -bool true

	# TODO: Don't show recent applications
	defaults write com.apple.dock show-recents -bool false

	# TODO: Faster dock animation
	# defaults write com.apple.dock autohide-delay -float 0
	# defaults write com.apple.dock autohide-time-modifier -float 0.5

	# Apply dock item configuration
	$(MAKE) configure-dock-items

	# Restart Dock to apply changes
	killall Dock
endif

.PHONY: configure-dock-items
configure-dock-items:
ifeq ($(OS),darwin)
	@echo
	# Configuring Dock items

	# TODO: Review and customize dock items below
	# Uncomment and modify as needed

	# Remove all existing items (careful!)
	# dockutil --remove all --no-restart

	# Add applications (order matters!)
	# dockutil --add /Applications/Kitty.app --no-restart
	# dockutil --add /Applications/Firefox.app --no-restart
	# dockutil --add /Applications/Bitwarden.app --no-restart
	# dockutil --add /System/Applications/System\ Settings.app --no-restart

	# Add folders
	# dockutil --add ~/Downloads --view grid --display folder --no-restart

	@echo "Dock items configuration is commented out by default."
	@echo "Edit .make.d/macos-settings.mk to customize your dock items."
endif

################################################################################
# System Preferences
################################################################################

.PHONY: apply-macos-preferences
apply-macos-preferences:
ifeq ($(OS),darwin)
	@echo
	# Configuring macOS System Preferences

	# TODO: Review and customize preferences below

	# === Finder ===
	# Show hidden files
	# defaults write com.apple.finder AppleShowAllFiles -bool true

	# Show file extensions
	defaults write NSGlobalDomain AppleShowAllExtensions -bool true

	# Show path bar
	defaults write com.apple.finder ShowPathbar -bool true

	# Show status bar
	defaults write com.apple.finder ShowStatusBar -bool true

	# Default to list view
	# defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

	# Search current folder by default
	# defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

	# Disable warning when changing file extension
	# defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

	# === Keyboard ===
	# Fast key repeat rate (requires logout)
	# defaults write NSGlobalDomain KeyRepeat -int 2
	# defaults write NSGlobalDomain InitialKeyRepeat -int 15

	# === Trackpad ===
	# Enable tap to click
	# defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
	# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
	# defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

	# === Menu Bar ===
	# Show battery percentage
	# defaults write com.apple.menuextra.battery ShowPercent -string "YES"

	# === Screenshots ===
	# Save screenshots to Downloads
	# defaults write com.apple.screencapture location -string "${HOME}/Downloads"

	# Save screenshots in PNG format
	# defaults write com.apple.screencapture type -string "png"

	# Disable screenshot shadow
	# defaults write com.apple.screencapture disable-shadow -bool true

	# === Mission Control ===
	# Don't automatically rearrange Spaces
	# defaults write com.apple.dock mru-spaces -bool false

	# === Other ===
	# Disable the "Are you sure you want to open this application?" dialog
	# defaults write com.apple.LaunchServices LSQuarantine -bool false

	# Expand save panel by default
	# defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
	# defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

	# Expand print panel by default
	# defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
	# defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

	@echo ""
	@echo "Most preferences are commented out by default."
	@echo "Edit .make.d/macos-settings.mk to enable and customize."

	# Restart affected applications
	# killall Finder
endif

################################################################################
# Discovery and Debugging Tools
################################################################################

.PHONY: capture-macos-settings
capture-macos-settings:
ifeq ($(OS),darwin)
	@echo "Capturing current macOS settings..."
	@mkdir -p /tmp/macos-settings-capture
	@echo "=== Dock Settings ===" > /tmp/macos-settings-capture/dock.txt
	@defaults read com.apple.dock >> /tmp/macos-settings-capture/dock.txt 2>&1
	@echo "" >> /tmp/macos-settings-capture/dock.txt
	@echo "=== Finder Settings ===" > /tmp/macos-settings-capture/finder.txt
	@defaults read com.apple.finder >> /tmp/macos-settings-capture/finder.txt 2>&1
	@echo "" >> /tmp/macos-settings-capture/finder.txt
	@echo "=== Global Settings ===" > /tmp/macos-settings-capture/global.txt
	@defaults read NSGlobalDomain >> /tmp/macos-settings-capture/global.txt 2>&1
	@echo ""
	@echo "Settings captured to /tmp/macos-settings-capture/"
	@echo "  - dock.txt"
	@echo "  - finder.txt"
	@echo "  - global.txt"
	@echo ""
	@echo "To find specific settings:"
	@echo "  1. Run this command"
	@echo "  2. Change a setting in System Settings"
	@echo "  3. Run this command again"
	@echo "  4. Diff the before/after files to see what changed"
endif

.PHONY: show-dock-settings
show-dock-settings:
ifeq ($(OS),darwin)
	@echo "Current Dock settings:"
	@defaults read com.apple.dock
endif

.PHONY: reset-dock
reset-dock:
ifeq ($(OS),darwin)
	@echo "Resetting Dock to defaults..."
	defaults delete com.apple.dock
	killall Dock
	@echo "Dock has been reset to system defaults."
endif

.PHONY: backup-macos-settings
backup-macos-settings:
ifeq ($(OS),darwin)
	@echo "Backing up macOS settings..."
	@mkdir -p $(HOME)/.dotfiles/backups
	@defaults read > $(HOME)/.dotfiles/backups/macos-defaults-$(shell date +%Y%m%d-%H%M%S).txt
	@echo "Backup saved to $(HOME)/.dotfiles/backups/"
endif

################################################################################
# Help
################################################################################

.PHONY: help-macos-settings
help-macos-settings:
	@echo "macOS Settings Management:"
	@echo ""
	@echo "  make setup-macos-settings    - Apply all macOS settings"
	@echo "  make apply-macos-dock        - Apply dock configuration only"
	@echo "  make apply-macos-preferences - Apply system preferences only"
	@echo ""
	@echo "Discovery tools:"
	@echo "  make capture-macos-settings  - Capture current settings to /tmp"
	@echo "  make show-dock-settings      - Show current dock settings"
	@echo "  make backup-macos-settings   - Backup all settings to dotfiles/backups"
	@echo ""
	@echo "Reset:"
	@echo "  make reset-dock              - Reset dock to system defaults"
	@echo ""
	@echo "To customize: Edit .make.d/macos-settings.mk"
