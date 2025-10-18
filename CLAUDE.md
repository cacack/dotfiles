# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository that manages terminal and application configurations across Linux and macOS systems. The setup uses GNU Stow for symlink management and a modular Makefile system for installation and configuration.

## Prerequisites & Bootstrap

**One-command installation (no manual prerequisites needed):**
```bash
curl -sSL https://gitlab.com/cacack/dotfiles/-/raw/main/install.sh | bash
```

The installation script automatically detects your platform (macOS/Linux) and installs all prerequisites:
- **macOS**: Command Line Tools, Homebrew, GNU Stow
- **Linux**: zsh, make, stow, git (via your distro's package manager)

Supported Linux distributions: Ubuntu/Debian, Fedora/RHEL/CentOS, Arch, openSUSE

**📖 Detailed setup guide:** See [`docs/BOOTSTRAP-MACOS.md`](docs/BOOTSTRAP-MACOS.md) for step-by-step instructions and troubleshooting.

## Architecture

The repository is organized into three main components:

- **configs/**: Contains dotfiles that get symlinked to `$HOME` via GNU Stow
- **packages/**: Contains application-specific configurations (kitty, neovim, alacritty, ghostty, beets, xdg) that get stowed to specific locations
- **.make.d/**: Modular Makefile components for installing and managing different tools and applications (~30 modules)

## Key Commands

### Installation
```bash
make install              # Basic installation: creates directories, installs neovim, runs stow
make install-desktop      # Desktop installation: adds fonts, kitty, GUI apps, and system settings
make install-apps         # Application installation: homebrew, yarn, kitty, tmux, neovim, aws-cli, glab, direnv
```

### Configuration Management
```bash
stow configs             # Symlink dotfiles to $HOME
stow --delete configs    # Remove symlinked dotfiles
make stow                # Same as `stow configs`
make clean-stow          # Same as `stow --delete configs`
```

### Individual Tools
```bash
make setup-autofs        # Setup autofs for NAS mounting
make setup-neovim        # Install neovim and configure
make setup-kitty         # Install kitty terminal and configure
make setup-tmux          # Setup tmux configuration
make install-homebrew    # Install Homebrew (macOS)
make setup-direnv        # Setup direnv configuration
make setup-gui-apps      # Install GUI applications (cross-platform)
make setup-macos-settings # Apply macOS system preferences and dock configuration
make setup-linux-settings # Apply Linux desktop settings (GNOME/XFCE)
```

### Updates and Maintenance
```bash
make update              # Update all configured tools
make clean               # Clean temporary files
make clean-all           # Deep clean including configurations
make zinit-update        # Update zinit and all zinit-managed plugins
```

### Testing
```bash
make test                # Run complete test suite
make test-syntax         # Shell script syntax validation
make test-config         # Configuration loading tests
make test-stow           # Stow operation validation
make test-help           # Show testing help
```

### Debugging
```bash
make print-<VAR>         # Print any Makefile variable value (e.g., make print-OS)
```

## Configuration Structure

### ZSH Configuration
The `.zshrc` loads modular configuration scripts from:
- `~/.zshrc.d/`: Main configuration snippets (included in repo)
- `~/.zshrc_work.d/`: Work-specific configurations (user-provided, optional)
- `~/.zshrc_secrets.d/`: Secret configurations (user-provided, optional)

Configuration scripts in `.zshrc.d/` include:
- `00_init.zsh`: Basic shell initialization
- `10_path.zsh`: PATH management
- `10_plugins.zsh`: Plugin loading with zinit
- `10_prompt.zsh`: Prompt configuration (starship)
- `20_aliases.zsh`: Shell aliases
- `20_completion.zsh`: Command completion setup
- `20_history.zsh`: History configuration
- `20_ssh_agent.zsh`: SSH agent management
- `30_bitwarden.zsh`: Bitwarden CLI integration
- `30_direnv.zsh`: Direnv initialization
- `30_kiro.zsh`: Kiro-specific configuration
- `30_tmux.zsh`: Tmux-specific configuration

### Tools Managed
- **Terminal**: kitty, ghostty, alacritty, tmux
- **Shell**: zsh with zinit plugin manager, starship prompt
- **Editor**: neovim with custom configuration
- **CLI Tools**: eza (default), fzf, lsd (backup), ripgrep, fd, zoxide
- **Development**: Node.js (via nvm), Python (via pyenv), Go, Ruby, uv (Python package manager)
- **Cloud**: AWS CLI, OpenStack CLI, s5cmd, glab
- **Security**: Bitwarden CLI, SSH agent
- **Storage**: autofs for automatic NAS mounting (Samba/SMB shares)
- **Other**: direnv, vagrant, beets

## Platform Support

The Makefile system detects the platform and adjusts installation accordingly:
- **Linux**: Uses apt for package management, installs from source/releases
- **macOS**: Uses Homebrew for package management

Variables are set based on platform detection:
- `OS`: linux or darwin
- `ARCH`: x86_64 or arm64
- `ARCH_ALT`: amd64 or arm64 (alternative naming)
- `DISTRO`: Distribution name on Linux, 'none' on macOS
- `USER_FONT_DIR`: Platform-specific font directory
- `SHELL`: Platform-specific shell path
- `BASE_DIR`: `~/.local` (base for bin, share, etc.)
- `BIN_DIR`: `~/.local/bin`
- `SHARE_DIR`: `~/.local/share`

## Development Patterns

When modifying this repository:

1. **Adding new tools**: Create a new `.mk` file in `.make.d/` following existing patterns
2. **Configuration changes**: Modify files in `configs/` or `packages/` directories
3. **Shell customization**: Add executable scripts to `configs/.zshrc.d/`
4. **Testing changes**: Use `make clean-stow && make stow` to refresh symlinks

### Installation Method Guidelines

**Use Zinit for:**
- Simple CLI tools used primarily in shell contexts
- Shell-focused utilities and enhancements
- Tools available as GitHub releases
- Utilities that benefit from lazy loading
- Tools where automatic updates are preferred

**Use Makefiles for:**
- Complex installations requiring system-wide availability
- System services and applications (tmux, kitty, neovim)
- Language runtimes and development environments
- Tools requiring platform-specific installation logic
- Applications needed before shell initialization
- Tools requiring specific version pinning

**Current Tools Managed via Zinit:**
- `eza` - modern ls replacement (default)
- `fd` - fast find alternative
- `fzf` - fuzzy finder
- `lsd` - modern ls replacement (backup)
- `ripgrep` - fast grep alternative
- `starship` - cross-shell prompt
- `zoxide` - smart cd replacement
- Various zsh plugins (syntax highlighting, autosuggestions, completions, vi-mode, fzf-tab, git, aws)

## Makefile Module System

The `.make.d/` directory contains modular Makefile components that are automatically included. Key modules:
- `00_make.mk`: Core variable definitions and OS detection
- `10_base.mk`: Basic directory setup and stow operations
- `autofs.mk`: Automatic NAS mounting via autofs (cross-platform)
- `gui-apps.mk`: GUI application installation (cross-platform)
- `linux-settings.mk`: Linux desktop settings (GNOME/XFCE)
- `macos-settings.mk`: macOS system preferences and dock configuration
- `testing.mk`: Test suite targets
- Tool-specific modules (e.g., `neovim.mk`, `kitty.mk`, `golang.mk`, `python.mk`)

Each module can contribute to these special variables:
- `UPDATE`: Add targets to the `make update` command
- `CLEAN`: Add targets to the `make clean` command
- `CLEAN_ALL`: Add targets to the `make clean-all` command
- `SETUP`: Add targets to setup operations

## Autofs NAS Mounting

The repository includes autofs configuration for automatic mounting of Samba/SMB NAS shares:

**📖 Complete guide:** See [`docs/AUTOFS-NAS-SETUP.md`](docs/AUTOFS-NAS-SETUP.md) for detailed instructions.

**Key capabilities:**
- Automatic mounting of NAS shares to `~/shared/` on access
- Cross-platform support (macOS and Linux)
- Interactive setup prompts for NAS hostname (not hardcoded in repo)
- Credential management (Keychain for macOS, credential file for Linux)
- Auto-unmount after inactivity to save resources
- Configuration stored locally in `~/.autofs_config` (not committed)

**Quick start:**
```bash
# Interactive setup: prompts for NAS hostname, share name, and credentials
make setup-autofs-credentials

# Install and configure autofs (requires sudo)
make setup-autofs

# Test the mount
make test-autofs
```

**Available commands:**
```bash
make setup-autofs              # Complete autofs setup for NAS mounting
make setup-autofs-credentials  # Configure Samba credentials
make test-autofs               # Test the NAS mount
make status-autofs             # Show autofs configuration status
make help-autofs               # Show autofs help message
```

## GUI Applications & Desktop Settings

The repository now includes Infrastructure-as-Code for GUI applications and desktop environment settings:

**📖 Complete guide:** See [`docs/GUI-APPS-AND-SETTINGS.md`](docs/GUI-APPS-AND-SETTINGS.md) for detailed instructions.

**Key capabilities:**
- Install GUI apps via Homebrew Cask (macOS) or apt/Flatpak (Linux)
- Configure macOS dock position, size, auto-hide, and items
- Apply macOS system preferences (Finder, keyboard, trackpad, screenshots, etc.)
- Configure GNOME/XFCE desktop settings on Linux
- Discovery tools to capture current settings and generate config

**Example workflow:**
```bash
# Discover current setup
make discover-macos-apps
make capture-macos-settings

# Edit .make.d/gui-apps.mk and .make.d/macos-settings.mk
# Uncomment and customize desired apps and settings

# Apply configuration
make setup-gui-apps
make setup-macos-settings
```

## Repository Maintenance

- Uses GitLab as primary remote: `git@gitlab.com:cacack/dotfiles.git`
- Installation script available at: `https://gitlab.com/cacack/dotfiles/-/raw/main/install.sh`
- Font management handled through dedicated make targets
- Supports switching between HTTPS and SSH remotes via `make switch-repo-url`
- Remember to update the README.md as needed.
- Sort _ALL_ lists unless it breaks functionality.
- Commit changes to maintain atomic changes.