# Bootstrap Guide for macOS

This guide walks through setting up this dotfiles repository on a fresh Mac from scratch.

## Quick Start (One Command - No Prerequisites)

The installation script now automatically installs all prerequisites. Just run:

```bash
curl -sSL https://raw.githubusercontent.com/cacack/dotfiles/main/install.sh | bash
```

The script will:
1. Detect your platform (macOS) and architecture
2. Install Command Line Tools (if needed) - provides `git`, `make`, `curl`, and other essential tools
3. Install Homebrew (if needed) - macOS package manager
4. Install GNU Stow (if needed) - symlink farm manager for managing dotfiles
5. Clone the repository to `~/.dotfiles`
6. Run the basic installation (`make install`)

**Note:** On macOS, you may need to interact with the Command Line Tools installer dialog if it's not already installed.

## Step-by-Step Installation (Manual Method)

**Note:** These steps are now **optional** since the one-command installation script handles all prerequisites automatically. This section is kept for reference and for users who prefer manual installation or troubleshooting.

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

`install.sh` does this for you (see [Homebrew Without Admin Rights](#homebrew-without-admin-rights)). Manually, as an admin, run the official installer:

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
curl -sSL https://raw.githubusercontent.com/cacack/dotfiles/main/install.sh | bash
```

**Option B: Manual installation**
```bash
# Clone the repository
git clone https://github.com/cacack/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Run basic installation
make install

# Optional: Install desktop components
make install-desktop

# Optional, personal machines only: personal apps on top of the desktop
make personal
```

### 5. Switch to Zsh (if needed)

Modern macOS already uses Zsh as the default shell, but if needed:

```bash
chsh -s "$(command -v zsh)"
```

### 6. Restart Your Terminal

Close and reopen your terminal (or open a new tab) to load the new configuration.

Zinit will automatically install plugins on first launch.

## What Gets Installed

### Basic Installation (`make install`)
- Checks prerequisites (zsh, make, stow, git, curl, tar, unzip)
- Creates directory structure (`~/devel`, `~/.config`, `~/.local/*`)
- Symlinks dotfiles from `configs/` to `$HOME`
- Installs mise and the light tool set (`make tools`)
- Links the Neovim config and builds the tmux-256color terminfo

### Full Desktop (`make desktop`, or `install.sh --desktop`)
- Records the machine as a desktop (`MISE_ENV=desktop`) and adds the desktop tool set
- Runs basic and desktop installation below

### Desktop Installation (`make install-desktop`)
- Records the machine as a desktop (`MISE_ENV=desktop`); run `make tools` to add the desktop tool set
- Installs Nerd Fonts
- Installs the desktop GUI apps (`Brewfile.gui`) and links the Ghostty config
- Installs the OpenStack CLI
- Applies macOS settings (if configured)

### Personal Machines (`make personal`)
- Runs the full desktop install, then adds the personal-only apps
  (`Brewfile.personal`). Work machines skip this.

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

### Homebrew Without Admin Rights

`install.sh` installs Homebrew to `/opt/homebrew` when you are an admin, and
otherwise untars it into `~/.local/opt/homebrew` (no sudo needed). The shell
config finds either. Casks go to `~/Applications` in both cases.

## Starting Fresh on a New Mac

When setting up a new Mac with this repo already configured:

```bash
# Install dotfiles (prerequisites are automatically installed)
curl -sSL https://raw.githubusercontent.com/cacack/dotfiles/main/install.sh | bash

# Install desktop components (fonts, GUI apps, settings)
cd ~/.dotfiles
make install-desktop

# Restart terminal
```

That's it! Your terminal environment will be set up and ready to go.

The installation script now handles all prerequisites automatically, so you don't need to manually install Command Line Tools, Homebrew, or Stow beforehand.
