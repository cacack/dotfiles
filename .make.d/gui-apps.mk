################################################################################
# GUI Applications
#
# Manages installation of GUI applications across platforms:
# - macOS: Uses Homebrew Cask
# - Linux: Uses apt/flatpak/snap (depending on preference)
#
# To add new apps:
# 1. Add the app name to the appropriate TODO section below
# 2. For macOS: Add to MACOS_GUI_APPS or use Brewfile
# 3. For Linux: Add to LINUX_GUI_APPS or FLATPAK_APPS
################################################################################

################################################################################
# TODO: Add your GUI applications here
#
# Examples of common GUI apps to consider:
# - Bitwarden (password manager)
# - Nextcloud (file sync)
# - Firefox / Brave / Chrome (browsers)
# - Slack / Discord (communication)
# - VSCode / Sublime Text (editors if using GUI)
# - Spotify (music)
# - VLC (media player)
# - GIMP / Inkscape (graphics)
# - Obsidian / Notion (notes)
# - Docker Desktop (if needed)
################################################################################

# macOS apps via Homebrew Cask
MACOS_GUI_APPS := \
	bitwarden \
	discord \
	firefox \
	gimp \
	google-chrome \
	libreoffice \
	nextcloud \
	slack \
	spotify \
	vlc

# TODO: Add more macOS cask apps above (space-separated, use \ for line continuation)

# Linux apps via apt (for Debian/Ubuntu-based distros)
LINUX_GUI_APPS := \
	# firefox-esr

# TODO: Add more Linux apt packages above

# Linux apps via Flatpak (cross-distro, sandboxed)
FLATPAK_APPS := \
	com.bitwarden.desktop \
	com.discordapp.Discord \
	com.google.Chrome \
	com.nextcloud.desktopclient.nextcloud \
	com.slack.Slack \
	com.spotify.Client \
	org.gimp.GIMP \
	org.libreoffice.LibreOffice \
	org.mozilla.firefox \
	org.videolan.VLC

# TODO: Add more Flatpak apps above (use flatpak app IDs)

################################################################################

SETUP += setup-gui-apps
UPDATE += update-gui-apps

.PHONY: setup-gui-apps
setup-gui-apps:
	@echo
	# Setting up GUI applications
ifeq ($(OS),darwin)
	$(MAKE) install-macos-gui-apps
endif
ifeq ($(OS),linux)
	$(MAKE) install-linux-gui-apps
endif

.PHONY: install-macos-gui-apps
install-macos-gui-apps:
ifeq ($(OS),darwin)
	@echo
	# Installing macOS GUI applications via Homebrew Cask
	@for app in $(MACOS_GUI_APPS); do \
		echo "Installing $$app..."; \
		brew install --cask $$app || true; \
	done
endif

.PHONY: install-linux-gui-apps
install-linux-gui-apps:
ifeq ($(OS),linux)
	@echo
	# Installing Linux GUI applications
	@if [ -n "$(LINUX_GUI_APPS)" ]; then \
		echo "Installing via apt..."; \
		sudo apt-get update && sudo apt-get install -y $(LINUX_GUI_APPS); \
	fi
	@if command -v flatpak >/dev/null 2>&1 && [ -n "$(FLATPAK_APPS)" ]; then \
		echo "Installing via Flatpak..."; \
		for app in $(FLATPAK_APPS); do \
			flatpak install -y flathub $$app || true; \
		done; \
	fi
endif

.PHONY: update-gui-apps
update-gui-apps:
	@echo
	# Updating GUI applications
ifeq ($(OS),darwin)
	brew upgrade --cask --greedy
endif
ifeq ($(OS),linux)
	@if command -v flatpak >/dev/null 2>&1; then \
		flatpak update -y; \
	fi
endif

.PHONY: list-installed-gui-apps
list-installed-gui-apps:
	@echo
	# Listing installed GUI applications
ifeq ($(OS),darwin)
	brew list --cask
endif
ifeq ($(OS),linux)
	@echo "=== APT packages (GUI) ==="
	@apt list --installed 2>/dev/null | grep -v "lib" | head -20
	@if command -v flatpak >/dev/null 2>&1; then \
		echo "=== Flatpak applications ==="; \
		flatpak list --app; \
	fi
endif

################################################################################
# Helper targets to discover what's currently installed
################################################################################

.PHONY: discover-macos-apps
discover-macos-apps:
ifeq ($(OS),darwin)
	@echo "Currently installed Homebrew Cask applications:"
	@brew list --cask > /tmp/current-casks.txt
	@cat /tmp/current-casks.txt
	@echo ""
	@echo "Output saved to /tmp/current-casks.txt"
	@echo "Review and add desired apps to MACOS_GUI_APPS in .make.d/gui-apps.mk"
endif

.PHONY: discover-linux-apps
discover-linux-apps:
ifeq ($(OS),linux)
	@echo "Currently installed GUI applications (non-lib packages):"
	@apt list --installed 2>/dev/null | grep -v "^lib" | grep -v "Listing..." > /tmp/current-apt-gui.txt
	@head -30 /tmp/current-apt-gui.txt
	@echo ""
	@if command -v flatpak >/dev/null 2>&1; then \
		echo "Currently installed Flatpak applications:"; \
		flatpak list --app > /tmp/current-flatpak-apps.txt; \
		cat /tmp/current-flatpak-apps.txt; \
		echo ""; \
	fi
	@echo "Output saved to /tmp/current-apt-gui.txt and /tmp/current-flatpak-apps.txt"
	@echo "Review and add desired apps to .make.d/gui-apps.mk"
endif

################################################################################
# Alternative: Brewfile Management (macOS)
################################################################################

.PHONY: install-from-brewfile
install-from-brewfile:
ifeq ($(OS),darwin)
	@echo
	# Installing GUI apps from Brewfile.gui
	@if [ -f Brewfile.gui ]; then \
		brew bundle install --file=Brewfile.gui; \
	else \
		echo "Brewfile.gui not found. Create one or use MACOS_GUI_APPS instead."; \
	fi
endif

.PHONY: generate-brewfile
generate-brewfile:
ifeq ($(OS),darwin)
	@echo
	# Generating Brewfile.gui from currently installed casks
	@brew bundle dump --file=Brewfile.gui --force --casks
	@echo "Brewfile.gui has been generated/updated with your current GUI apps"
	@echo "Review and commit this file to track your GUI applications"
endif

.PHONY: cleanup-brewfile
cleanup-brewfile:
ifeq ($(OS),darwin)
	@echo
	# Removing apps not listed in Brewfile.gui
	@if [ -f Brewfile.gui ]; then \
		brew bundle cleanup --file=Brewfile.gui; \
	else \
		echo "Brewfile.gui not found."; \
	fi
endif
