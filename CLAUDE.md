# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository that manages terminal and application configurations across Linux and macOS systems. The setup uses GNU Stow for symlink management and a modular Makefile system for installation and configuration.

## Architecture

The repository is organized into three main components:

- **configs/**: Contains dotfiles that get symlinked to `$HOME` via GNU Stow
- **packages/**: Contains application-specific configurations (kitty, neovim, etc.) that get stowed to specific locations
- **.make.d/**: Modular Makefile components for installing and managing different tools and applications

## Key Commands

### Installation
```bash
make install              # Basic installation: creates directories, installs neovim, runs stow
make install-desktop      # Desktop installation: adds fonts and kitty setup
make install-apps         # Application installation: homebrew, yarn, kitty, tmux, neovim, aws-cli
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
make setup-neovim        # Install neovim and configure
make setup-kitty         # Install kitty terminal and configure
make setup-tmux          # Setup tmux configuration
make install-homebrew    # Install Homebrew (macOS)
```

### Updates and Maintenance
```bash
make update              # Update all configured tools
make clean               # Clean temporary files
make clean-all           # Deep clean including configurations
```

### Testing
```bash
make test                # Run complete test suite
make test-syntax         # Shell script syntax validation
make test-config         # Configuration loading tests
make test-stow           # Stow operation validation
make test-help           # Show testing help
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

### Tools Managed
- **Terminal**: kitty, tmux
- **Shell**: zsh with zinit plugin manager, starship prompt
- **Editor**: neovim with custom configuration
- **CLI Tools**: eza, fzf, git configurations
- **Development**: Node.js, Python, Go, Ruby environments
- **Cloud**: AWS CLI, OpenStack CLI
- **Security**: Bitwarden CLI, SSH agent

## Platform Support

The Makefile system detects the platform and adjusts installation accordingly:
- **Linux**: Uses apt for package management, installs from source/releases
- **macOS**: Uses Homebrew for package management

Variables are set based on platform detection:
- `OS`: linux or darwin
- `ARCH`: x86_64 or arm64
- `USER_FONT_DIR`: Platform-specific font directory
- `SHELL`: Platform-specific shell path

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
- `fzf` - fuzzy finder
- `eza` - modern ls replacement
- `starship` - cross-shell prompt
- `zoxide` - smart cd replacement
- Various zsh plugins (syntax highlighting, autosuggestions, completions, vi-mode, fzf-tab)

## Repository Maintenance

- Uses GitLab as primary remote: `git@gitlab.com:cacack/dotfiles.git`
- Installation script available at: `https://gitlab.com/cacack/dotfiles/-/raw/main/install.sh`
- Font management handled through dedicated make targets
- Supports switching between HTTPS and SSH remotes via `make switch-repo-url`