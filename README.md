# dotfiles

> This is my terminal. There are many like it, but this one is mine.
> My terminal is my best friend. It is my life. I must master it as I must master my life.
> Without me, my terminal is useless. Without my terminal, I am useless.

My various configuration files to make ${HOME} home.

## Installation

### Install Paths

| Path | Command | Needs |
|---|---|---|
| CLI, no root (headless/remote) | `curl -sSL https://gitlab.com/cacack/dotfiles/-/raw/main/install.sh \| bash` | zsh, make, stow, git, curl, unzip already installed (plus libatomic on Linux arm64) |
| CLI, with root | same command | sudo or root; installs whatever of the above is missing |
| Full desktop | same command with `\| bash -s -- --desktop` | macOS: admin (Command Line Tools, Homebrew); Linux: sudo for GUI apps |

- **CLI** runs `make install`: stows configs and installs the base tool set
  (shell utilities, tmux, Neovim with Node/Python for its language servers).
  Nothing needs root. Without root or sudo, `install.sh` lists any missing
  prerequisites for an admin to install.
- **Desktop** runs `make desktop`: the CLI install plus the desktop tool set
  (cloud CLIs, Go, Ruby, Bitwarden CLI, …), fonts, GUI apps and OS settings.

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

- `configs/.config/mise/config.toml` → `mise.lock`: base tools (every install)
- `configs/.config/mise/config.desktop.toml` → `mise.desktop.lock`: desktop tools

`make desktop` records the machine's profile in `~/.config/dotfiles/mise-env`
(`MISE_ENV=desktop`). Renovate opens merge requests to bump the pins.

```bash
make tools       # install exactly what the lockfiles pin (also part of `make update`)
make mise-lock   # regenerate both lockfiles after editing a config; commit them together
```

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
