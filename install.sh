#!/usr/bin/env bash

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Repository configuration
repo_url="https://gitlab.com/cacack/dotfiles.git"
dotfiles_dir="${HOME}/.dotfiles"

# Logging functions
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect platform and architecture
detect_platform() {
    OS="$(uname -s)"
    ARCH="$(uname -m)"

    case "${OS}" in
        Linux*)
            PLATFORM="linux"
            # Detect Linux distribution
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                DISTRO="${ID}"
                DISTRO_VERSION="${VERSION_ID}"
            else
                DISTRO="unknown"
            fi
            ;;
        Darwin*)
            PLATFORM="macos"
            DISTRO="none"
            ;;
        *)
            error "Unsupported operating system: ${OS}"
            exit 1
            ;;
    esac

    info "Detected platform: ${PLATFORM} (${DISTRO}) on ${ARCH}"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install prerequisites for macOS
install_macos_prereqs() {
    info "Installing macOS prerequisites..."

    # Check for Command Line Tools
    if ! xcode-select -p >/dev/null 2>&1; then
        info "Installing Command Line Tools..."
        xcode-select --install

        # Wait for installation to complete
        warning "Please complete the Command Line Tools installation in the dialog."
        warning "Press Enter when installation is complete..."
        read -r

        if ! xcode-select -p >/dev/null 2>&1; then
            error "Command Line Tools installation failed or was cancelled"
            exit 1
        fi
    else
        success "Command Line Tools already installed"
    fi

    # Check for Homebrew
    if ! command_exists brew; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for this session
        if [[ "${ARCH}" == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        if ! command_exists brew; then
            error "Homebrew installation failed"
            exit 1
        fi
        success "Homebrew installed successfully"
    else
        success "Homebrew already installed"
    fi

    # Check for GNU Stow
    if ! command_exists stow; then
        info "Installing GNU Stow..."
        brew install stow
        success "GNU Stow installed successfully"
    else
        success "GNU Stow already installed"
    fi
}

# Install prerequisites for Linux
install_linux_prereqs() {
    info "Installing Linux prerequisites..."

    # Detect package manager
    if command_exists apt-get; then
        PKG_MANAGER="apt-get"
        PKG_UPDATE="sudo apt-get update"
        PKG_INSTALL="sudo apt-get install -y"
    elif command_exists dnf; then
        PKG_MANAGER="dnf"
        PKG_UPDATE="sudo dnf check-update || true"
        PKG_INSTALL="sudo dnf install -y"
    elif command_exists yum; then
        PKG_MANAGER="yum"
        PKG_UPDATE="sudo yum check-update || true"
        PKG_INSTALL="sudo yum install -y"
    elif command_exists pacman; then
        PKG_MANAGER="pacman"
        PKG_UPDATE="sudo pacman -Sy"
        PKG_INSTALL="sudo pacman -S --noconfirm"
    elif command_exists zypper; then
        PKG_MANAGER="zypper"
        PKG_UPDATE="sudo zypper refresh"
        PKG_INSTALL="sudo zypper install -y"
    else
        error "No supported package manager found (apt, dnf, yum, pacman, zypper)"
        error "Please install zsh, make, stow, and git manually"
        exit 1
    fi

    info "Using package manager: ${PKG_MANAGER}"

    # Update package database
    info "Updating package database..."
    eval "${PKG_UPDATE}"

    # Required packages
    PACKAGES=("zsh" "make" "stow" "git")

    # Check and install each package
    for pkg in "${PACKAGES[@]}"; do
        if ! command_exists "${pkg}"; then
            info "Installing ${pkg}..."
            eval "${PKG_INSTALL} ${pkg}"

            if ! command_exists "${pkg}"; then
                error "Failed to install ${pkg}"
                exit 1
            fi
            success "${pkg} installed successfully"
        else
            success "${pkg} already installed"
        fi
    done
}

# Install prerequisites based on platform
install_prerequisites() {
    info "Checking and installing prerequisites..."

    case "${PLATFORM}" in
        macos)
            install_macos_prereqs
            ;;
        linux)
            install_linux_prereqs
            ;;
        *)
            error "Unsupported platform: ${PLATFORM}"
            exit 1
            ;;
    esac

    success "All prerequisites installed!"
}

# Clone dotfiles repository
clone_dotfiles() {
    if [ -d "${dotfiles_dir}" ]; then
        warning "Dotfiles directory already exists at ${dotfiles_dir}"
        warning "Skipping clone. If you want to reinstall, remove this directory first."
        return 0
    fi

    info "Cloning dotfiles repository..."
    git clone "${repo_url}" "${dotfiles_dir}"
    success "Dotfiles repository cloned to ${dotfiles_dir}"
}

# Run installation
run_installation() {
    info "Running dotfiles installation..."
    (
        cd "${dotfiles_dir}" || exit 1
        make install
    )
    success "Dotfiles installation complete!"
}

# Main installation flow
main() {
    echo ""
    info "=== Dotfiles Installation Script ==="
    echo ""

    # Detect platform
    detect_platform

    # Install prerequisites
    install_prerequisites

    # Clone repository
    clone_dotfiles

    # Run installation
    run_installation

    echo ""
    success "=== Installation Complete! ==="
    info "Next steps:"
    info "  1. Restart your terminal or run: exec \$SHELL"
    info "  2. Optional: Run 'make install-desktop' for GUI apps and fonts"
    info "  3. Optional: Run 'make install-apps' for additional CLI tools"
    info "  4. See 'make help' for more options"
    echo ""
}

# Run main function
main "$@"
