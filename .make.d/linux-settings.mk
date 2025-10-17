################################################################################
# Linux Desktop Settings
#
# Manages Linux desktop environment settings for:
# - GNOME: Using gsettings/dconf
# - XFCE: Using xfconf-query
#
# To discover current settings:
# 1. GNOME: Run `make capture-gnome-settings`
# 2. XFCE: Run `make capture-xfce-settings`
# 3. Make changes in your desktop settings
# 4. Run capture again and diff to see what changed
#
# To customize:
# 1. Uncomment and modify settings below
# 2. Run: make apply-linux-settings
################################################################################

################################################################################
# TODO: Review and customize these settings for your preferences
################################################################################

SETUP += setup-linux-settings

.PHONY: setup-linux-settings
setup-linux-settings:
ifeq ($(OS),linux)
	@echo
	# Applying Linux desktop settings
	@if command -v gnome-shell >/dev/null 2>&1 || [ "$$XDG_CURRENT_DESKTOP" = "GNOME" ]; then \
		$(MAKE) apply-gnome-settings; \
	elif command -v xfce4-session >/dev/null 2>&1 || [ "$$XDG_CURRENT_DESKTOP" = "XFCE" ]; then \
		$(MAKE) apply-xfce-settings; \
	else \
		echo "Desktop environment not detected or not supported yet."; \
		echo "Current: $$XDG_CURRENT_DESKTOP"; \
	fi
endif

################################################################################
# GNOME Settings (gsettings / dconf)
################################################################################

.PHONY: apply-gnome-settings
apply-gnome-settings:
ifeq ($(OS),linux)
	@echo
	# Configuring GNOME desktop settings

	# TODO: Review and customize GNOME settings below

	# === Window Manager ===
	# Focus mode (click vs sloppy/mouse)
	# gsettings set org.gnome.desktop.wm.preferences focus-mode 'click'

	# Show minimize/maximize buttons
	# gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

	# === Interface ===
	# Enable dark theme
	# gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
	# gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

	# Show weekday in clock
	# gsettings set org.gnome.desktop.interface clock-show-weekday true

	# Show battery percentage
	# gsettings set org.gnome.desktop.interface show-battery-percentage true

	# === Keyboard ===
	# Fast key repeat
	# gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 30
	# gsettings set org.gnome.desktop.peripherals.keyboard delay 250

	# === Mouse & Touchpad ===
	# Enable tap to click
	# gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true

	# Natural scrolling
	# gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true

	# Mouse speed
	# gsettings set org.gnome.desktop.peripherals.mouse speed 0.0

	# === Files (Nautilus) ===
	# Show hidden files
	# gsettings set org.gtk.Settings.FileChooser show-hidden false

	# Default list view
	# gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'

	# === Power ===
	# Disable automatic suspend
	# gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

	# === Privacy ===
	# Disable recent files tracking
	# gsettings set org.gnome.desktop.privacy remember-recent-files false

	# === Shell ===
	# Static workspaces (don't auto-create/remove)
	# gsettings set org.gnome.mutter dynamic-workspaces false
	# gsettings set org.gnome.desktop.wm.preferences num-workspaces 4

	# Workspaces on all displays
	# gsettings set org.gnome.mutter workspaces-only-on-primary false

	@echo ""
	@echo "Most GNOME settings are commented out by default."
	@echo "Edit .make.d/linux-settings.mk to enable and customize."
endif

################################################################################
# XFCE Settings (xfconf-query)
################################################################################

.PHONY: apply-xfce-settings
apply-xfce-settings:
ifeq ($(OS),linux)
	@echo
	# Configuring XFCE desktop settings

	# TODO: Review and customize XFCE settings below

	# === Panel ===
	# Auto-hide panel
	# xfconf-query -c xfce4-panel -p /panels/panel-1/autohide-behavior -s 1

	# Panel size
	# xfconf-query -c xfce4-panel -p /panels/panel-1/size -s 32

	# === Window Manager ===
	# Enable compositor for effects
	# xfconf-query -c xfwm4 -p /general/use_compositing -s true

	# Workspace count
	# xfconf-query -c xfwm4 -p /general/workspace_count -s 4

	# Show window contents while resizing
	# xfconf-query -c xfwm4 -p /general/box_resize -s false

	# === Keyboard ===
	# Key repeat rate
	# xfconf-query -c keyboards -p /Default/KeyRepeat/Rate -s 30
	# xfconf-query -c keyboards -p /Default/KeyRepeat/Delay -s 250

	# === Mouse & Touchpad ===
	# Enable tap to click (may vary by system)
	# xfconf-query -c pointers -p /SynPS2_Synaptics_TouchPad/Properties/libinput_Tapping_Enabled -s 1

	# === Desktop ===
	# Icon size
	# xfconf-query -c xfce4-desktop -p /desktop-icons/icon-size -s 48

	# Show hidden files in Thunar
	# xfconf-query -c thunar -p /last-show-hidden -s true

	# === Appearance ===
	# GTK theme
	# xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita-dark"

	# Icon theme
	# xfconf-query -c xsettings -p /Net/IconThemeName -s "Adwaita"

	# Font
	# xfconf-query -c xsettings -p /Gtk/FontName -s "Sans 10"

	@echo ""
	@echo "Most XFCE settings are commented out by default."
	@echo "Edit .make.d/linux-settings.mk to enable and customize."
endif

################################################################################
# Discovery and Debugging Tools
################################################################################

.PHONY: capture-gnome-settings
capture-gnome-settings:
ifeq ($(OS),linux)
	@echo "Capturing current GNOME settings..."
	@mkdir -p /tmp/gnome-settings-capture
	@dconf dump / > /tmp/gnome-settings-capture/dconf-full-$(shell date +%Y%m%d-%H%M%S).ini
	@dconf dump /org/gnome/desktop/ > /tmp/gnome-settings-capture/desktop.ini
	@dconf dump /org/gnome/shell/ > /tmp/gnome-settings-capture/shell.ini
	@dconf dump /org/gnome/nautilus/ > /tmp/gnome-settings-capture/nautilus.ini
	@echo ""
	@echo "GNOME settings captured to /tmp/gnome-settings-capture/"
	@echo ""
	@echo "To find specific settings:"
	@echo "  1. Run this command"
	@echo "  2. Change a setting in GNOME Settings"
	@echo "  3. Run this command again"
	@echo "  4. Diff the before/after files"
endif

.PHONY: capture-xfce-settings
capture-xfce-settings:
ifeq ($(OS),linux)
	@echo "Capturing current XFCE settings..."
	@mkdir -p /tmp/xfce-settings-capture
	@xfconf-query -c xfce4-panel -l -v > /tmp/xfce-settings-capture/panel.txt 2>&1
	@xfconf-query -c xfwm4 -l -v > /tmp/xfce-settings-capture/wm.txt 2>&1
	@xfconf-query -c xfce4-desktop -l -v > /tmp/xfce-settings-capture/desktop.txt 2>&1
	@xfconf-query -c xsettings -l -v > /tmp/xfce-settings-capture/xsettings.txt 2>&1
	@xfconf-query -c thunar -l -v > /tmp/xfce-settings-capture/thunar.txt 2>&1
	@echo ""
	@echo "XFCE settings captured to /tmp/xfce-settings-capture/"
	@echo ""
	@echo "To find specific settings:"
	@echo "  1. Run this command"
	@echo "  2. Change a setting in XFCE Settings"
	@echo "  3. Run this command again"
	@echo "  4. Diff the before/after files"
endif

.PHONY: list-gnome-settings
list-gnome-settings:
ifeq ($(OS),linux)
	@echo "Common GNOME settings categories:"
	@echo ""
	@echo "To explore:"
	@echo "  gsettings list-schemas | grep desktop"
	@echo "  gsettings list-keys org.gnome.desktop.interface"
	@echo "  gsettings get org.gnome.desktop.interface gtk-theme"
endif

.PHONY: backup-linux-settings
backup-linux-settings:
ifeq ($(OS),linux)
	@echo "Backing up Linux desktop settings..."
	@mkdir -p $(HOME)/.dotfiles/backups
	@if command -v dconf >/dev/null 2>&1; then \
		dconf dump / > $(HOME)/.dotfiles/backups/dconf-$(shell date +%Y%m%d-%H%M%S).ini; \
		echo "GNOME settings backed up"; \
	fi
	@if command -v xfconf-query >/dev/null 2>&1; then \
		xfconf-query -c xfce4-panel -l -v > $(HOME)/.dotfiles/backups/xfce-panel-$(shell date +%Y%m%d-%H%M%S).txt 2>&1; \
		xfconf-query -c xfwm4 -l -v > $(HOME)/.dotfiles/backups/xfce-wm-$(shell date +%Y%m%d-%H%M%S).txt 2>&1; \
		echo "XFCE settings backed up"; \
	fi
	@echo "Backups saved to $(HOME)/.dotfiles/backups/"
endif

################################################################################
# Help
################################################################################

.PHONY: help-linux-settings
help-linux-settings:
	@echo "Linux Desktop Settings Management:"
	@echo ""
	@echo "  make setup-linux-settings     - Apply all Linux desktop settings"
	@echo "  make apply-gnome-settings     - Apply GNOME settings only"
	@echo "  make apply-xfce-settings      - Apply XFCE settings only"
	@echo ""
	@echo "Discovery tools:"
	@echo "  make capture-gnome-settings   - Capture current GNOME settings to /tmp"
	@echo "  make capture-xfce-settings    - Capture current XFCE settings to /tmp"
	@echo "  make list-gnome-settings      - Show how to explore GNOME settings"
	@echo "  make backup-linux-settings    - Backup all settings to dotfiles/backups"
	@echo ""
	@echo "To customize: Edit .make.d/linux-settings.mk"
