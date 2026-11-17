# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**When modifying this file:** Focus on information that helps Claude Code make better decisions. Remove content that duplicates what Claude can discover through exploration (like full command lists discoverable via `make help`). This is NOT user documentation - users should refer to README.md and docs/.

## Repository Overview

Personal dotfiles repository managing terminal and application configurations across Linux and macOS. Uses GNU Stow for symlink management and a modular Makefile system for installation and configuration.

**Key characteristics:**
- Cross-platform (macOS and Linux)
- Infrastructure-as-Code approach for system configuration
- Modular, testable, and version-controlled
- Bootstrap script: `https://raw.githubusercontent.com/cacack/dotfiles/main/install.sh`
- Primary remote: `git@github.com:cacack/dotfiles.git` (GitHub; CI in `.github/workflows/`)

## Architecture & File Organization

### Directory Structure

- **configs/**: Dotfiles symlinked to `$HOME` via GNU Stow (`.zshrc`, `.gitconfig`, etc.)
- **packages/**: Application-specific configurations stowed to specific locations
  - `beets/`, `ghostty/`, `neovim/`, `xdg/`
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

- **CLI Tools**: fd, fzf, lsd, ripgrep, zoxide
- **Cloud/DevOps**: AWS CLI, Azure CLI, gcloud, gh, glab, OpenStack CLI
- **Development**: Go, Node.js, Python, Ruby, uv (all via mise)
- **Editor**: neovim (custom config in packages/neovim/)
- **Shell**: zsh with zinit plugin manager, starship prompt
- **Storage**: Bitwarden CLI, NAS auto-mount (launchd on macOS, autofs on Linux)
- **Terminal**: ghostty, tmux
- **Utilities**: beets, direnv, vagrant

## Development Guidelines

### When Adding New Tools

1. **Choose installation method** (see criteria below)
2. **mise tools**: add an exact version to `config.toml` (light) or `config.desktop.toml` (heavy) in `configs/.config/mise/`, run `make mise-lock`, commit config and lockfiles; otherwise create a `.mk` file in `.make.d/`
3. **Add configuration** in `configs/` (dotfiles) or `packages/` (app configs)
4. **Test thoroughly** with `make test` and `make clean-stow && make stow`
5. **Update documentation** in README.md if user-facing

### Installation Method Selection

**Use mise** for every CLI tool and language runtime: `config.toml` is the light
set (every install, no root, no language runtimes), `config.desktop.toml` the heavy
set: runtimes and what needs them (`MISE_ENV=desktop`, recorded in
`~/.config/dotfiles/mise-env` by `make desktop`). Neovim's `lua/configs/tools.lua`
enables Neovim's language servers (installed by mise, not Mason) on the same flag; keep the two in step.
Install paths: `make install` (CLI, never needs root) and `make desktop`. Rules:
- Exact versions only, locked in `mise.lock`/`mise.desktop.lock` (`locked = true` rejects anything unlocked). Renovate bumps pins; `make tools` (in `make update`) syncs the machine.
- Pick a backend that publishes prebuilt binaries for all `lockfile_platforms` (restrict with `os = [...]` when upstream lacks one) (prefer `aqua:`/`core:`; check `mise registry <tool>`). Avoid `vfox:`/`asdf:` plugin-repo backends: Renovate can't track them, and no source builds.
- `pypi:` tools lock their dependencies only without `uvx_args`; tools needing injected plugins (OpenStack CLI) stay in make via `uv tool install`.
- Python tooling uses uv/uvx only: never pip, pipx or Poetry. The `pypi:poetry` pin is a temporary holdover while projects migrate to uv; don't build on it.
- Not in Renovate's mise manager (e.g. `http:` backend, mise itself): add a custom manager in `renovate.json`.
- Renovate updates `mise.lock`/`mise.desktop.lock` with bumps from its mise manager, but not with custom-manager bumps (gcloud), and an edit to a tool's `uv.lock` sidecar leaves the lock's digest stale; for those, CI (`.github/workflows/supply-chain.yml`, `make mise-lock-check`) fails until `make mise-lock` is committed on the branch.

**Use Makefiles for** machine setup mise can't do: GUI apps (Homebrew casks, apt/Flatpak), fonts, OS settings, NAS mounts, stow.

**Zinit** loads shell plugins only (syntax highlighting, autosuggestions, completions, vi-mode, fzf-tab, OMZ snippets); it installs no binaries. Every plugin, OMZ and zinit itself is pinned to a commit in `_zinit_pins` (`00_init.zsh`, with a `# renovate: branch=` line each); load plugins with `ver"${_zinit_pins[...]}"` and OMZ files by pinned raw URL, never `OMZP::`. `make update` syncs them (`zinit-update`); never call `zinit update`/`self-update`, which ignore pins.

**macOS prerequisite:** Homebrew (installed by `install.sh`) provides stow and casks; mise is installed by `make install-mise`, pinned in `.make.d/mise.mk`.

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
- `00_make.mk`: Core variables, OS detection, checksum verification
- `10_base.mk`: Directory setup, stow operations
- `gui-apps.mk`: GUI apps (cross-platform)
- `linux-settings.mk`: GNOME/XFCE settings
- `macos-settings.mk`: System preferences, dock config
- `mise.mk`: mise install (pinned), profiles, `tools`, `mise-lock`, `mise-lock-check`
- `nas-mount.mk`: NAS mounting (launchd on macOS, autofs on Linux)
- `security.mk`: `security` (osv-scanner + Trivy over the pinned tools)
- `testing.mk`: Test suite
- Tool-specific: `ghostty.mk` (config only), `neovim.mk` (config only), `openstack-cli.mk`, `tmux.mk`, etc.

**Local overrides:** `.make.d/99_local.mk` is gitignored and auto-included
last. Use it for personal-infrastructure targets (private repos, host-
specific paths) that should not be committed to a public dotfiles repo.

### Essential Commands

**Discovery:**
- `make help` - Show all available targets (use this to discover commands)
- `make print-<VAR>` - Print any Makefile variable (e.g., `make print-OS`)

**Core workflows:**
- `make install` - Basic installation (directories, neovim, stow)
- `make install-desktop` - Desktop installation (fonts, GUI apps, settings)
- `make personal` - `make desktop` plus personal-only apps (skipped on work machines)
- `make stow` - Symlink dotfiles to $HOME
- `make clean-stow` - Remove symlinked dotfiles
- `make test` - Run complete test suite
- `make test-<type>` - Run specific test (syntax, config, stow, makefile, shellcheck, security, permissions)
- `make test-install` - Light install end to end in a Docker container (not in `make test`); run after changing install.sh, prerequisites, mise configs or Neovim's tools.lua
- `make update` - Update all configured tools

**Note:** Use `make help` or `make list-targets` to discover all available commands.

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

- **Both**: mise for CLI tools and runtimes
- **Linux**: apt/Flatpak for system packages and GUI apps
- **macOS**: Homebrew for stow, system packages and casks

### Security: SHA256 Checksum Verification

**Two-layer verification system:**
1. **Upstream binaries**: mise tools are checksummed per platform in `mise.lock`; the rest store checksums in their .mk files as variables (mise itself checks its release's `SHASUMS256.txt`)
2. **Makefile modules**: Checksums in `.make.d/makefile-checksums.txt` to verify .mk files themselves

**Vulnerability scans** (`security.mk`, README "Supply-Chain Defenses"): `make security` runs osv-scanner on the uv and npm (aube) locks and Trivy on installed tools. A new finding is fixed by a bump if one exists; otherwise add it to `.osv-scanner.toml` / `.trivyignore.yaml` with a reason and an expiry, never without, and scope Trivy entries with `paths` to the tool you reviewed (an ID-only entry hides that CVE in every tool). Prefer dropping an unmaintained tool over ignoring its findings (s5cmd was dropped this way).

**Implementation:** See `.make.d/00_make.mk` for `verify_checksum` function.

**Usage pattern in .mk files:**
```makefile
# Store platform-specific checksums as variables
TOOL_CHECKSUM_LINUX_AMD64 := abc123...
TOOL_CHECKSUM_MACOS_ARM64 := def456...

# In download target:
curl -Ls -o tool.tar.gz https://example.com/tool.tar.gz
$(call verify_checksum,tool.tar.gz,$(TOOL_CHECKSUM))
```

**Makefile integrity:**
- `make verify-makefiles` - Verify .mk files haven't been tampered with
- After modifying .mk files: `cd .make.d && ls *.mk | grep -vx 99_local.mk | xargs shasum -a 256 | sort -k2 > makefile-checksums.txt`

**Important:** Checksum verification aborts on failure and removes the downloaded file. Always source checksums from official release pages.

## Feature-Specific Guidance

### NAS Mounting

**Location:** `.make.d/nas-mount.mk` (cross-platform).
**Docs:** `docs/NAS-MOUNT-SETUP.md`.

- macOS: launchd + `scripts/mount-nas.sh` (NetFS path, Keychain-stored password). The pure-autofs path on macOS was retired due to a Sequoia root-ownership bug and lease-cache fragility.
- Linux: autofs + cifs with `~/.smbcredentials` (chmod 600).
- Shared config: `~/.autofs_config` (chmod 600, gitignored) — host/share/username only, never passwords.
- Mount point: `~/shared` on both platforms (symlink on macOS, direct mount on Linux).
- Entry points: `make nas-mount` (setup) and friends; see `make help`.

### Bitwarden CLI Authentication

**Location:** `.make.d/bitwarden.mk`, `configs/.zshrc.d/30_bitwarden.zsh`

- Session-based authentication (like ssh-agent)
- Prompt once per session, reuse across all terminal windows
- Session token stored in `~/.ssh/bw.env` with TTL
- Auto-syncs vault on unlock
- Works cross-platform (no OS-specific dependencies)
- Commands: `make bitwarden-status`, `make bitwarden-lock`
- Self-hosted support: `bw config server https://your-server.com`

### GUI Applications & Desktop Settings

**Location:** `.make.d/gui-apps.mk`, `.make.d/macos-settings.mk`, `.make.d/linux-settings.mk`
**Docs:** `docs/GUI-APPS-AND-SETTINGS.md`

- Discovery tools: `make discover-macos-apps`, `make capture-macos-settings`
- Infrastructure-as-Code for desktop environments
- macOS: Dock config, system preferences
- Linux: GNOME/XFCE settings
- macOS: `Brewfile.gui` (desktop, incl. work) / `Brewfile.personal` (`make personal`); casks go to `~/Applications` (no admin needed)
- Linux: apt/Flatpak (`FLATPAK_APPS` / `FLATPAK_APPS_PERSONAL`)

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
- Public repo: never commit employer or work details (hosts, policies, names). The private-terms hooks and CI job enforce this (README "Private Terms"); never add the term list itself to this repo