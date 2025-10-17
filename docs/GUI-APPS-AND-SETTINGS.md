# GUI Applications and Desktop Settings

This guide covers managing GUI applications and desktop environment settings as code in your dotfiles repository.

## Overview

Three new Makefile modules have been added to manage desktop environments:

1. **`.make.d/gui-apps.mk`** - GUI application installation (cross-platform)
2. **`.make.d/macos-settings.mk`** - macOS system preferences and dock configuration
3. **`.make.d/linux-settings.mk`** - GNOME/XFCE desktop settings

## Quick Start

### Install Everything

```bash
# Install all desktop components (apps + settings)
make install-desktop
```

This will:
- Create desktop directories
- Install fonts
- Set up Kitty terminal
- Install GUI applications
- Apply desktop settings

### macOS Only

```bash
# Just install GUI apps
make setup-gui-apps

# Just apply macOS settings (dock + preferences)
make setup-macos-settings

# Individual targets
make apply-macos-dock
make apply-macos-preferences
```

### Linux Only

```bash
# Just install GUI apps
make setup-gui-apps

# Just apply Linux settings (auto-detects GNOME/XFCE)
make setup-linux-settings

# Individual targets
make apply-gnome-settings
make apply-xfce-settings
```

## Discovering Your Current Setup

Before customizing, discover what you already have installed:

### macOS

```bash
# List currently installed GUI apps
make discover-macos-apps
# Output: /tmp/current-casks.txt

# Capture current system settings
make capture-macos-settings
# Output: /tmp/macos-settings-capture/

# Show just dock settings
make show-dock-settings

# Generate Brewfile from current apps
make generate-brewfile
# Creates/updates Brewfile.gui
```

### Linux

```bash
# List currently installed GUI apps
make discover-linux-apps
# Output: /tmp/current-apt-gui.txt and /tmp/current-flatpak-apps.txt

# Capture current GNOME settings
make capture-gnome-settings
# Output: /tmp/gnome-settings-capture/

# Capture current XFCE settings
make capture-xfce-settings
# Output: /tmp/xfce-settings-capture/
```

## Configuration Workflow

### Adding GUI Applications

**Option 1: Makefile Variables (Recommended)**

Edit `.make.d/gui-apps.mk`:

```makefile
# macOS apps via Homebrew Cask
MACOS_GUI_APPS := \
	bitwarden \
	firefox \
	nextcloud

# Linux apps via apt
LINUX_GUI_APPS := \
	firefox-esr \
	nextcloud-desktop

# Linux apps via Flatpak
FLATPAK_APPS := \
	com.bitwarden.desktop \
	org.mozilla.firefox
```

**Option 2: Brewfile (macOS only)**

Edit `Brewfile.gui`:

```ruby
cask "bitwarden"
cask "firefox"
cask "nextcloud"
```

Then run:
```bash
make install-from-brewfile
```

### Customizing Desktop Settings

#### macOS

Edit `.make.d/macos-settings.mk` and uncomment/modify settings:

```makefile
# Dock on left, auto-hide, smaller size
defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 36
```

**Finding New Settings:**

1. Run `make capture-macos-settings` to capture current state
2. Change a setting in System Settings
3. Run `make capture-macos-settings` again
4. Diff the files in `/tmp/macos-settings-capture/` to see what changed
5. Add the changed setting to `.make.d/macos-settings.mk`

#### Linux (GNOME)

Edit `.make.d/linux-settings.mk` and uncomment/modify settings:

```makefile
# Dark theme
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Show battery percentage
gsettings set org.gnome.desktop.interface show-battery-percentage true
```

**Finding New Settings:**

1. Run `make capture-gnome-settings` to capture current state
2. Change a setting in GNOME Settings
3. Run `make capture-gnome-settings` again
4. Diff the files in `/tmp/gnome-settings-capture/` to see what changed
5. Add the changed setting to `.make.d/linux-settings.mk`

#### Linux (XFCE)

Edit `.make.d/linux-settings.mk` and uncomment/modify settings:

```makefile
# Panel size
xfconf-query -c xfce4-panel -p /panels/panel-1/size -s 32

# Workspace count
xfconf-query -c xfwm4 -p /general/workspace_count -s 4
```

**Finding New Settings:**

1. Run `make capture-xfce-settings` to capture current state
2. Change a setting in XFCE Settings
3. Run `make capture-xfce-settings` again
4. Diff the files in `/tmp/xfce-settings-capture/` to see what changed
5. Add the changed setting to `.make.d/linux-settings.mk`

## Managing Dock Items (macOS)

The system installs `dockutil` for managing dock items. Edit `.make.d/macos-settings.mk`:

```makefile
.PHONY: configure-dock-items
configure-dock-items:
	# Remove all existing items (optional)
	dockutil --remove all --no-restart

	# Add applications (order matters!)
	dockutil --add /Applications/Kitty.app --no-restart
	dockutil --add /Applications/Firefox.app --no-restart
	dockutil --add /Applications/Bitwarden.app --no-restart

	# Add folders
	dockutil --add ~/Downloads --view grid --display folder --no-restart
```

Then run:
```bash
make apply-macos-dock
```

## Updating Applications

```bash
# Update all managed components (including GUI apps)
make update

# Update just GUI apps
make update-gui-apps
```

## Useful Commands

### General

```bash
make list-installed-gui-apps    # Show currently installed GUI apps
make help-macos-settings        # Show macOS settings help
make help-linux-settings        # Show Linux settings help
```

### macOS

```bash
make backup-macos-settings      # Backup all settings to backups/
make reset-dock                 # Reset dock to system defaults
```

### Linux

```bash
make backup-linux-settings      # Backup all settings to backups/
make list-gnome-settings        # Show how to explore GNOME settings
```

### Brewfile (macOS)

```bash
make install-from-brewfile      # Install apps from Brewfile.gui
make generate-brewfile          # Generate Brewfile.gui from current installs
make cleanup-brewfile           # Remove apps not in Brewfile.gui
```

## File Locations

- **Makefile modules:** `.make.d/gui-apps.mk`, `.make.d/macos-settings.mk`, `.make.d/linux-settings.mk`
- **Brewfile (optional):** `Brewfile.gui`
- **Backups:** `~/.dotfiles/backups/`
- **Discovery output:** `/tmp/` (various files)

## Tips

1. **Start small:** Begin by capturing your current setup, then gradually add settings
2. **Test incrementally:** Apply one category of settings at a time
3. **Backup first:** Run backup commands before making major changes
4. **Version control:** Commit your changes to track what works
5. **Platform-specific:** Settings are automatically skipped on non-applicable platforms
6. **Commented by default:** Most settings are commented out - enable as needed

## Example Workflow for New Mac

```bash
# 1. Discover what you want
make discover-macos-apps
make capture-macos-settings

# 2. Edit configuration files
# Edit .make.d/gui-apps.mk - add apps to MACOS_GUI_APPS
# Edit .make.d/macos-settings.mk - uncomment desired settings

# 3. Apply configuration
make install-desktop

# 4. Commit your changes
git add .make.d/gui-apps.mk .make.d/macos-settings.mk
git commit -m "feat: Add GUI app and desktop settings configuration"
```

## Troubleshooting

**Settings not applying:**
- Many macOS/GNOME settings require logging out or restarting
- Some apps need to be restarted to pick up changes
- Run `killall Dock` (macOS) or `killall Finder` (macOS) to restart

**Apps not installing:**
- macOS: Ensure Homebrew is installed (`make install-homebrew`)
- Linux: Ensure apt/flatpak is available
- Check for typos in app names

**Can't find a setting:**
- Use the capture/diff workflow described above
- Search online for "defaults write" (macOS) or "gsettings" (Linux) + setting name
- Check `/tmp/` output files for examples

## Further Customization

All settings in the modules are examples and starting points. Feel free to:
- Add more apps to the lists
- Uncomment and modify existing settings
- Add new settings discovered via the capture workflow
- Create additional platform-specific customizations

The system is designed to be incrementally adopted - start with what matters most to you!
