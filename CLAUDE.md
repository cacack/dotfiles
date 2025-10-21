# CLAUDE.md

## Purpose

This file guides Claude Code (claude.ai/code) when working with this repository. It provides architectural context, development patterns, and guidelines to ensure consistent, quality contributions. This is NOT user documentation - users should refer to README.md and docs/.

**When modifying this file:** Focus on information that helps Claude Code make better decisions. Remove content that duplicates what Claude can discover through exploration (like full command lists discoverable via `make help`).

## Repository Overview

Personal dotfiles repository managing terminal and application configurations across Linux and macOS. Uses GNU Stow for symlink management and a modular Makefile system for installation and configuration.

**Key characteristics:**
- Cross-platform (macOS and Linux)
- Infrastructure-as-Code approach for system configuration
- Modular, testable, and version-controlled
- Bootstrap script: `https://gitlab.com/cacack/dotfiles/-/raw/main/install.sh`
- Primary remote: `git@gitlab.com:cacack/dotfiles.git` (GitLab)

## Architecture & File Organization

### Directory Structure

- **configs/**: Dotfiles symlinked to `$HOME` via GNU Stow (`.zshrc`, `.gitconfig`, etc.)
- **packages/**: Application-specific configurations stowed to specific locations
  - `alacritty/`, `beets/`, `ghostty/`, `kitty/`, `neovim/`, `xdg/`
- **.make.d/**: ~30 modular Makefile components (automatically included)
- **docs/**: User documentation (bootstrap guides, feature docs)

### ZSH Configuration Architecture

The `.zshrc` sources modular scripts from multiple directories:
- `~/.zshrc.d/`: Main configuration (in repo) - numbered files loaded in order
- `~/.zshrc_work.d/`: Work-specific configs (user-provided, optional, not in repo)
- `~/.zshrc_secrets.d/`: Secret configs (user-provided, optional, not in repo)

**Naming convention for `.zshrc.d/`:**
- `00_*.zsh`: Initialization
- `10_*.zsh`: Core setup (PATH, plugins, prompt)
- `20_*.zsh`: Shell behavior (aliases, completion, history, ssh)
- `30_*.zsh`: Tool integrations (bitwarden, direnv, tmux, etc.)

### Tools Managed

- **CLI Tools**: eza, fd, fzf, lsd, ripgrep, zoxide (via zinit on Linux, mixed on macOS)
- **Cloud**: AWS CLI, OpenStack CLI, gh, glab, s5cmd
- **Development**: Go, Node.js (nvm), Python (pyenv), Ruby, uv
- **Editor**: neovim (custom config in packages/neovim/)
- **Other**: autofs, beets, bitwarden-cli, direnv, vagrant
- **Security**: Bitwarden CLI, SSH agent
- **Shell**: zsh with zinit plugin manager, starship prompt
- **Storage**: autofs for automatic NAS mounting
- **Terminal**: alacritty, ghostty, kitty, tmux

## Development Guidelines

### When Adding New Tools

1. **Choose installation method** (see criteria below)
2. **Create `.mk` file** in `.make.d/` following existing patterns if using Makefile
3. **Add configuration** in `configs/` (dotfiles) or `packages/` (app configs)
4. **Test thoroughly** with `make test` and `make clean-stow && make stow`
5. **Update documentation** in README.md if user-facing

### Installation Method Selection

**Use Zinit for:**
- Shell-focused utilities and enhancements
- Simple CLI tools used primarily in shell contexts
- Tools available as GitHub releases
- Tools where automatic updates are preferred
- Utilities that benefit from lazy loading

**Use Makefiles for:**
- Applications needed before shell initialization
- Complex installations requiring system-wide availability
- Language runtimes and development environments
- System services and applications (kitty, neovim, tmux)
- Tools requiring platform-specific installation logic
- Tools requiring specific version pinning

**Current Zinit-managed tools:**
- CLI: `eza` (Linux only), `fd`, `fzf`, `lsd`, `ripgrep`, `starship`, `zoxide`
- Plugins: syntax highlighting, autosuggestions, completions, vi-mode, fzf-tab, git, aws

**Note:** `eza` on macOS uses Homebrew via `make setup-eza` (not zinit)

### Making Configuration Changes

- **Dotfiles**: Edit files in `configs/` directory
- **App configs**: Edit files in `packages/<app>/` directory
- **Shell customization**: Add executable `.zsh` scripts to `configs/.zshrc.d/`
- **Refresh symlinks**: Run `make clean-stow && make stow` after changes
- **Test**: Use `make test` to validate changes

### Makefile Module System

Modules in `.make.d/` are automatically included. Each can contribute to:
- `UPDATE`: Targets added to `make update`
- `CLEAN`: Targets added to `make clean`
- `CLEAN_ALL`: Targets added to `make clean-all`
- `SETUP`: Targets added to setup operations

**Key modules:**
- `00_make.mk`: Core variable definitions and OS detection
- `10_base.mk`: Directory setup, stow operations
- `autofs.mk`: NAS mounting (cross-platform)
- `gui-apps.mk`: GUI apps (cross-platform)
- `linux-settings.mk`: GNOME/XFCE settings
- `macos-settings.mk`: System preferences, dock config
- `testing.mk`: Test suite
- Tool-specific: `golang.mk`, `kitty.mk`, `neovim.mk`, `python.mk`, etc.

### Essential Commands

**Discovery:**
- `make help` - Show all available targets (use this to discover commands)
- `make print-<VAR>` - Print any Makefile variable (e.g., `make print-OS`)

**Core workflows:**
- `make install` - Basic installation (directories, neovim, stow)
- `make install-desktop` - Desktop installation (fonts, kitty, GUI apps, settings)
- `make stow` - Symlink dotfiles to $HOME
- `make clean-stow` - Remove symlinked dotfiles
- `make test` - Run complete test suite
- `make update` - Update all configured tools

**Note:** Claude can discover specific commands via `make help` - don't list them all here.

## Platform Support

### Platform Detection Variables

Set automatically by `.make.d/00_make.mk`:
- `OS`: `linux` or `darwin`
- `ARCH`: `x86_64` or `arm64`
- `ARCH_ALT`: `amd64` or `arm64` (alternative naming convention)
- `BASE_DIR`: `~/.local` (base for bin, share, etc.)
- `BIN_DIR`: `~/.local/bin`
- `DISTRO`: Distribution name on Linux, `none` on macOS
- `SHARE_DIR`: `~/.local/share`
- `SHELL`: Platform-specific shell path
- `USER_FONT_DIR`: Platform-specific font directory

### Platform Differences

- **Linux**: apt for packages, source/release installs, zinit for CLI tools
- **macOS**: Homebrew for packages, Homebrew for many CLI tools (not all via zinit)

### Security: SHA256 Checksum Verification

**Two-layer verification system:**
1. **Upstream binaries**: Checksums stored in individual .mk files as variables
2. **Makefile modules**: Checksums in `.make.d/makefile-checksums.txt` to verify .mk files themselves

**Location:** `.make.d/00_make.mk` (verification functions)
**Helper:** `scripts/update-checksums.sh`

#### Verifying Downloaded Files

**Store checksums in the .mk file:**
```makefile
TOOL_VERSION := 1.2.3

# SHA256 checksums from https://example.com/releases/v1.2.3/checksums.txt
TOOL_CHECKSUM_LINUX_AMD64 := abc123...
TOOL_CHECKSUM_MACOS_ARM64 := def456...
TOOL_CHECKSUM_MACOS_AMD64 := 789ghi...

# Set platform-specific checksum
ifeq ($(UNAME), Darwin)
ifeq ($(ARCH_ALT), arm64)
TOOL_CHECKSUM := $(TOOL_CHECKSUM_MACOS_ARM64)
else
TOOL_CHECKSUM := $(TOOL_CHECKSUM_MACOS_AMD64)
endif
else
TOOL_CHECKSUM := $(TOOL_CHECKSUM_LINUX_AMD64)
endif
```

**Use in download target:**
```makefile
install-tool:
	curl -Ls -o tool.tar.gz https://example.com/tool.tar.gz
	$(call verify_checksum,tool.tar.gz,$(TOOL_CHECKSUM))
	tar -xzf tool.tar.gz
```

**Parameters:**
- First: local filename (what you downloaded)
- Second: expected checksum (use Makefile variable)

**Optional checksums (warns but continues):**
```makefile
ifneq ($(TOOL_CHECKSUM),)
	$(call verify_checksum,tool.tar.gz,$(TOOL_CHECKSUM))
else
	@echo "WARNING: No checksum available, skipping verification"
endif
```

#### Verifying Makefile Modules

**Verify all .mk files haven't been tampered with:**
```bash
make verify-makefiles
```

**After modifying .mk files, regenerate checksums:**
```bash
cd .make.d
shasum -a 256 *.mk | sort -k2 > makefile-checksums.txt.new
# Review changes
diff makefile-checksums.txt makefile-checksums.txt.new
# Apply
mv makefile-checksums.txt.new makefile-checksums.txt
```

**Important:**
- Checksum verification aborts on failure (removes downloaded file)
- Always verify checksums from official sources (release pages, checksum files)
- Update checksums when upgrading tool versions
- Verify makefiles before major installations for security

## Feature-Specific Guidance

### Autofs NAS Mounting

**Location:** `.make.d/autofs.mk`
**Docs:** `docs/AUTOFS-NAS-SETUP.md`

- Cross-platform (macOS and Linux)
- Auto-unmount after inactivity
- Config stored in `~/.autofs_config` (not committed to repo)
- Credential management: Keychain (macOS), credential file (Linux)
- Interactive setup: prompts for NAS hostname/credentials (never hardcode)
- Mounts to `~/shared/` on access

### GUI Applications & Desktop Settings

**Location:** `.make.d/gui-apps.mk`, `.make.d/macos-settings.mk`, `.make.d/linux-settings.mk`
**Docs:** `docs/GUI-APPS-AND-SETTINGS.md`

- Discovery tools: `make discover-macos-apps`, `make capture-macos-settings`
- Infrastructure-as-Code for desktop environments
- macOS: Dock config, system preferences
- Linux: GNOME/XFCE settings
- macOS: Homebrew Cask
- Linux: apt/Flatpak

## Commit Guidelines

**IMPORTANT: Always commit changes in logical, atomic chunks.**

Each commit should:
- Have a clear, descriptive message following conventional commit format
- Include all related changes for that specific change (code + tests + docs)
- Be independently understandable and reviewable
- Represent a single logical change (one feature, one fix, one refactor)

**Conventional commit format:**
```
<type>: <description>

[optional body]

[optional footer]
```

**Types:** `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `style`

**Examples of atomic commits:**
- ✅ `feat: Add nextcloud to GUI apps list`
- ✅ `fix: Use correct autofs mount point on macOS`
- ✅ `docs: Update CLAUDE.md with commit guidelines`
- ❌ `feat: Add nextcloud, fix autofs, update docs` (too broad - should be 3 commits)

**When making multiple unrelated changes:**
1. Commit each change separately with `git add <specific-files>` or `git add -p`
2. Identify distinct logical changes in your modifications
3. Push all commits together when ready
4. Write clear commit messages for each

This practice maintains clean git history and makes code review, debugging, and reverting changes easier.

## Repository Maintenance Rules

- Font management: use dedicated make targets
- README.md: keep updated with user-facing changes
- Remote switching: use `make switch-repo-url` for HTTPS/SSH
- Sort _ALL_ lists alphabetically unless it breaks functionality