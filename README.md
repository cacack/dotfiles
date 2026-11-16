# dotfiles

> This is my terminal. There are many like it, but this one is mine.
> My terminal is my best friend. It is my life. I must master it as I must master my life.
> Without me, my terminal is useless. Without my terminal, I am useless.

My various configuration files to make ${HOME} home.

## Installation

### Install Paths

| Path | Command | Needs |
|---|---|---|
| CLI, no root (headless/remote) | `curl -sSL https://gitlab.com/cacack/dotfiles/-/raw/main/install.sh \| bash` | zsh, make, stow, git, curl, tar, unzip already installed |
| CLI, with root | same command | sudo or root; installs whatever of the above is missing |
| Full desktop | same command with `\| bash -s -- --desktop` | macOS: admin (Command Line Tools, Homebrew); Linux: sudo for GUI apps, plus libatomic |

- **CLI** runs `make install`: stows configs and installs the light tool set
  (shell utilities, prompt, tmux, Neovim with binary-only language servers;
  no language runtimes, nothing compiled). Nothing needs root. Without root or sudo, `install.sh` lists any missing
  prerequisites for an admin to install.
- **Desktop** runs `make desktop`: the CLI install plus the heavy tool set
  (Go, Node, Python, Ruby, Rust, cloud CLIs, Bitwarden CLI, …, plus Neovim's
  full language servers), fonts, GUI apps and OS settings.

Supported platforms: macOS (Apple Silicon), Ubuntu/Debian, Fedora/RHEL, Arch, openSUSE (x86_64 and arm64)

**Then change shells to zsh:**

```sh
chsh -s "$(command -v zsh)"
```

Without `chsh` rights (e.g. directory-managed accounts), add this to `~/.bash_profile` instead:

```sh
[ -x "$(command -v zsh)" ] && exec zsh -l
```

Log out and back in to activate the new setup (zinit will install plugins automatically).

**📖 For detailed setup instructions and troubleshooting, see [`docs/BOOTSTRAP-MACOS.md`](docs/BOOTSTRAP-MACOS.md)**

### Manual Install (Optional)

```bash
git clone https://gitlab.com/cacack/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install    # CLI
make desktop    # or: full desktop
```

### CLI Tools and Runtimes (mise)

CLI tools and language runtimes are installed by [mise](https://mise.jdx.dev).
Every version is pinned exactly and locked, with per-platform checksums:

- `configs/.config/mise/config.toml` → `mise.lock`: light tools (every install)
- `configs/.config/mise/config.desktop.toml` → `mise.desktop.lock`: heavy tools
  (language runtimes and what needs them)

`make desktop` (and `make install-desktop`) records the machine's profile in
`~/.config/dotfiles/mise-env` (`MISE_ENV=desktop`); Neovim reads the same flag
to pick its language servers (`lua/configs/tools.lua`). Without it a machine is
light: **desktops set up before mise must run `make desktop` once**, or they lose
their runtimes, cloud CLIs and GUI app updates on the next `make update`.

Renovate opens merge requests to bump the pins. A bump only changes the config,
so the `mise-lock` CI job fails until `make mise-lock` is run on the branch and
the lockfiles committed.

```bash
make tools       # install exactly what the lockfiles pin (also part of `make update`)
make mise-lock   # regenerate both lockfiles after editing a config; commit them together
make security    # scan the pinned tools for known vulnerabilities
```

### Supply-Chain Defenses

Each layer catches what the others miss:

| Layer | Guards against | Where |
|---|---|---|
| Exact pins + per-platform checksums | a tampered or swapped download | `mise.lock`, `locked = true` |
| Shell plugins, Oh My Zsh and zinit pinned to commits | a malicious push to a plugin repo reaching every shell | `_zinit_pins` in `configs/.zshrc.d/00_init.zsh` |
| Signed provenance re-verified on install (GitHub attestations, SLSA, cosign) where upstream publishes it | a release not built by the project's CI | `locked_verify_provenance` in `config.toml` |
| 7-day minimum release age (vulnerability fixes exempt) | a compromised release, usually yanked within days | `renovate.json` |
| Lockfile check on every merge request | a bump that skips the lock | `mise-lock` CI job |
| osv-scanner on the Python and npm tools' locked dependencies | known-vulnerable transitive packages | `make security-deps`, CI on merge requests + weekly |
| Trivy on everything installed (HIGH/CRITICAL with a fix) | vulnerable Go modules, bundled npm/gems/Python packages | `make security-tools`, CI weekly |

Accepted findings live in `.osv-scanner.toml` and `.trivyignore.yaml`, each with a
reason and an expiry date, so they come back for review. The weekly scans need a
pipeline schedule in GitLab (Build > Pipeline schedules).

### Optional Customization

- GUI applications and system settings: See [`docs/GUI-APPS-AND-SETTINGS.md`](docs/GUI-APPS-AND-SETTINGS.md)
- Work-specific configs: Create `~/.zshrc_work.d/` directory
- Secrets: Create `~/.zshrc_secrets.d/` directory

## Tools I currently use

- [kitty](https://github.com/kovidgoyal/kitty)
- [tmux](https://github.com/tmux/tmux)
- [zsh](https://www.zsh.org/)
- [starship](https://github.com/starship/starship)
- [lsd](https://github.com/lsd-rs/lsd)
- [mise](https://github.com/jdx/mise)
- [fzf](https://github.com/junegunn/fzf)
- [neovim](https://neovim.io)

## License

Copyright (c) 2024, Chris Clonch. Distributed under an [MIT License].

[mit license]: http://www.opensource.org/licenses/MIT
