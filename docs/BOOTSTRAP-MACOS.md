# Bootstrap Guide for macOS

This guide walks through setting up this dotfiles repository on a fresh Mac from scratch.

## Prerequisites

Before installing the dotfiles, you need these tools:

1. **Command Line Tools** - Provides `git`, `make`, `curl`, and other essential tools
2. **Homebrew** - macOS package manager
3. **GNU Stow** - Symlink farm manager for managing dotfiles

## Quick Start (One Command)

If you already have the prerequisites installed, run:

```bash
curl -sSL https://gitlab.com/cacack/dotfiles/-/raw/main/install.sh | bash
```

## Step-by-Step Installation (Fresh Mac)

### 1. Install Command Line Tools

Open Terminal and run:

```bash
xcode-select --install
```

Click "Install" in the dialog that appears. This provides `git`, `make`, and other essential development tools.

**Verify installation:**
```bash
git --version
make --version
```

### 2. Install Homebrew

Run the official Homebrew installer:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**After installation, add Homebrew to your PATH:**

For Apple Silicon Macs:
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

For Intel Macs:
```bash
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/usr/local/bin/brew shellenv)"
```

**Verify installation:**
```bash
brew --version
```

### 3. Install GNU Stow

```bash
brew install stow
```

**Verify installation:**
```bash
stow --version
```

### 4. Clone and Install Dotfiles

Now that prerequisites are met, install the dotfiles:

**Option A: Using the install script**
```bash
curl -sSL https://gitlab.com/cacack/dotfiles/-/raw/main/install.sh | bash
```

**Option B: Manual installation**
```bash
# Clone the repository
git clone https://gitlab.com/cacack/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Run basic installation
make install

# Optional: Install desktop components
make install-desktop

# Optional: Install additional applications
make install-apps
```

### 5. Switch to Zsh (if needed)

Modern macOS already uses Zsh as the default shell, but if needed:

```bash
chsh -s $(which zsh)
```

### 6. Restart Your Terminal

Close and reopen your terminal (or open a new tab) to load the new configuration.

Zinit will automatically install plugins on first launch.

## What Gets Installed

### Basic Installation (`make install`)
- Creates directory structure (`~/devel`, `~/.config`, `~/.local/*`)
- Installs Neovim
- Symlinks dotfiles from `configs/` to `$HOME`

### Desktop Installation (`make install-desktop`)
- All of basic installation
- Installs Nerd Fonts
- Installs Kitty terminal
- Installs GUI applications (if configured)
- Applies macOS settings (if configured)

### App Installation (`make install-apps`)
- Installs Homebrew (if not present)
- Installs Yarn
- Installs Kitty terminal
- Installs Tmux
- Installs Neovim
- Installs AWS CLI
- Installs GitLab CLI (glab)
- Sets up direnv

## Customization

After installation, you can customize:

1. **ZSH Configuration**: `~/.zshrc.d/` - modular zsh configuration
2. **Work-specific configs**: `~/.zshrc_work.d/` (optional, user-provided)
3. **Secrets**: `~/.zshrc_secrets.d/` (optional, user-provided, gitignored)
4. **GUI Apps**: `.make.d/gui-apps.mk`
5. **macOS Settings**: `.make.d/macos-settings.mk`

See [`docs/GUI-APPS-AND-SETTINGS.md`](GUI-APPS-AND-SETTINGS.md) for managing GUI applications and system settings.

## Troubleshooting

### Command not found: stow
Stow is not installed. Run: `brew install stow`

### Command not found: brew
Homebrew is not installed. See step 2 above.

### Command not found: make
Command Line Tools are not installed. Run: `xcode-select --install`

### Permission denied errors
Some operations may require administrator privileges. The Makefile will use `sudo` where needed.

### Stow conflicts
If you have existing dotfiles, stow may report conflicts:
```bash
# Back up existing configs
mv ~/.zshrc ~/.zshrc.backup
mv ~/.gitconfig ~/.gitconfig.backup

# Then retry
make stow
```

### Homebrew path issues
If commands installed via Homebrew aren't found, ensure Homebrew is in your PATH:
```bash
# Check if Homebrew is in PATH
which brew

# If not found, add to PATH (adjust path based on your installation)
eval "$(/opt/homebrew/bin/brew shellenv)"  # Apple Silicon
# OR
eval "$(/usr/local/bin/brew shellenv)"      # Intel Mac
```

## Next Steps

1. **Explore available commands**: `make help` (or see [`CLAUDE.md`](../CLAUDE.md))
2. **Configure GUI apps**: See [`docs/GUI-APPS-AND-SETTINGS.md`](GUI-APPS-AND-SETTINGS.md)
3. **Customize settings**: Edit files in `.make.d/` and `configs/.zshrc.d/`
4. **Set up work configs**: Create `~/.zshrc_work.d/` for work-specific settings
5. **Update tools**: Run `make update` periodically

## Advanced Options

### Alternative Homebrew Installation

If you prefer a local Homebrew installation in `~/.local/opt/homebrew` instead of the system-wide installation, you can use the dotfiles' Makefile target **after cloning the repository**:

```bash
# Clone the repository first
git clone https://gitlab.com/cacack/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Install Homebrew locally
make install-homebrew

# Add to PATH
eval "$(${HOME}/.local/opt/homebrew/bin/brew shellenv)"

# Install Stow and continue with setup
brew install stow
make install
```

**Note:** This approach installs Homebrew in your home directory rather than `/opt/homebrew` or `/usr/local`. It's useful for systems where you don't have admin access or prefer to keep everything self-contained. However, you cannot use the one-line quick install script with this method since you need to clone the repo first.

## Starting Fresh on a New Mac

When setting up a new Mac with this repo already configured:

```bash
# Install prerequisites
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install stow

# Install dotfiles
curl -sSL https://gitlab.com/cacack/dotfiles/-/raw/main/install.sh | bash

# Install desktop components (fonts, GUI apps, settings)
cd ~/.dotfiles
make install-desktop

# Restart terminal
```

That's it! Your terminal environment will be set up and ready to go.
