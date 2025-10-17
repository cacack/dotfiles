# dotfiles

> This is my terminal. There are many like it, but this one is mine.
> My terminal is my best friend. It is my life. I must master it as I must master my life.
> Without me, my terminal is useless. Without my terminal, I am useless.

My various configuration files to make ${HOME} home.

## Installation

### One-Command Install (No Prerequisites Needed!)

The installation script automatically detects your platform and installs all prerequisites. Just run:

```sh
curl -sSL https://gitlab.com/cacack/dotfiles/-/raw/main/install.sh | bash
```

The script will automatically install:
- **macOS**: Command Line Tools, Homebrew, GNU Stow
- **Linux**: zsh, make, stow, git (via your package manager)

Supported platforms: macOS (Intel/Apple Silicon), Ubuntu/Debian, Fedora/RHEL/CentOS, Arch, openSUSE

**Then change shells to zsh:**

```sh
chsh --shell $(which zsh)
```

Log out and back in to activate the new setup (zinit will install plugins automatically).

**📖 For detailed setup instructions and troubleshooting, see [`docs/BOOTSTRAP-MACOS.md`](docs/BOOTSTRAP-MACOS.md)**

### Manual Install (Optional)

If you prefer to install prerequisites manually or need more control over the process:

```bash
# Clone the repository
git clone https://gitlab.com/cacack/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Basic installation (creates directories, installs neovim, symlinks configs)
make install

# Desktop installation (adds fonts, kitty, GUI apps, system settings)
make install-desktop

# Full application installation (all CLI and GUI tools)
make install-apps
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
- [eza](https://github.com/eza-community/eza)
- [fzf](https://github.com/junegunn/fzf)
- [neovim](https://neovim.io)

## License

Copyright (c) 2024, Chris Clonch. Distributed under an [MIT License].

[mit license]: http://www.opensource.org/licenses/MIT
