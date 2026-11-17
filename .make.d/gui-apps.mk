################################################################################
# GUI Applications
#
# Manages installation of GUI applications across platforms:
# - macOS: Homebrew Cask via Brewfile.gui (into ~/Applications)
# - Linux: apt (LINUX_GUI_APPS) and Flatpak (FLATPAK_APPS)
#
# Two tiers: desktop apps (every desktop, `make desktop`) and personal-only
# apps (`make personal`: Brewfile.personal, FLATPAK_APPS_PERSONAL).
#
# To add new apps:
# 1. For macOS: add a `cask` line to Brewfile.gui or Brewfile.personal
# 2. For Linux: Add to LINUX_GUI_APPS, FLATPAK_APPS or FLATPAK_APPS_PERSONAL
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

# macOS apps live in Brewfile.gui.

# Linux apps via apt (for Debian/Ubuntu-based distros)
# ghostty: Ubuntu 26.04+ (universe); not packaged by Debian.
LINUX_GUI_APPS := \
	ghostty

# TODO: Add more Linux apt packages above

# Linux apps via Flatpak (cross-distro, sandboxed). No Claude Desktop for Linux.
FLATPAK_APPS := \
	com.bitwarden.desktop \
	com.spotify.Client

FLATPAK_APPS_PERSONAL := \
	com.discordapp.Discord \
	com.google.AndroidStudio \
	com.google.Chrome \
	com.nextcloud.desktopclient.nextcloud \
	com.slack.Slack \
	org.gimp.GIMP \
	org.libreoffice.LibreOffice \
	org.mozilla.firefox \
	org.videolan.VLC

################################################################################

SETUP += setup-gui-apps
UPDATE += update-gui-apps

.PHONY: setup-gui-apps
setup-gui-apps:
	@echo
	# Setting up GUI applications
ifeq ($(OS),darwin)
	$(MAKE) install-from-brewfile
endif
ifeq ($(OS),linux)
	$(MAKE) install-linux-gui-apps
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
	$(call flatpak_install,$(FLATPAK_APPS))
endif

# Personal-only apps (`make personal`), on top of the desktop ones.
.PHONY: install-personal-apps
install-personal-apps:
	@echo
	# Installing personal-only GUI applications
ifeq ($(OS),darwin)
	brew bundle install --file=Brewfile.personal
endif
ifeq ($(OS),linux)
	$(call flatpak_install,$(FLATPAK_APPS_PERSONAL))
endif

define flatpak_install
	@if command -v flatpak >/dev/null 2>&1; then \
		echo "Installing via Flatpak..."; \
		for app in $(1); do \
			flatpak install -y flathub $$app || true; \
		done; \
	fi
endef

.PHONY: update-gui-apps
update-gui-apps:
	@echo
	# Updating GUI applications
	@# GUI apps are desktop-only (`make desktop`); MISE_ENV comes from mise.mk.
ifeq ($(OS),darwin)
	@if [ "$(MISE_ENV)" = desktop ]; then brew upgrade --cask --greedy; else echo "Skipping: not a desktop install"; fi
endif
ifeq ($(OS),linux)
	@if [ "$(MISE_ENV)" = desktop ] && command -v flatpak >/dev/null 2>&1; then \
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
	@echo "Review and add desired apps to Brewfile.gui"
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
# Brewfile Management (macOS)
################################################################################

.PHONY: install-from-brewfile
install-from-brewfile:
ifeq ($(OS),darwin)
	@echo
	# Installing GUI apps from Brewfile.gui
	brew bundle install --file=Brewfile.gui
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
