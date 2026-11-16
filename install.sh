#!/usr/bin/env bash

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Install target: `make install` (CLI) by default, `make desktop` with --desktop
make_target="install"
for arg in "$@"; do
    case "${arg}" in
        --desktop) make_target="desktop" ;;
        *) echo "Usage: install.sh [--desktop]" >&2; exit 1 ;;
    esac
done

# Repository configuration
repo_url="https://github.com/cacack/dotfiles.git"
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

# Install prerequisites for Linux. The package manager is only used when
# something is missing; without root or sudo, report what an admin must add.
install_linux_prereqs() {
    info "Checking Linux prerequisites..."

    local missing=()
    local pkg
    # Keep in step with PREREQS in .make.d/10_base.mk.
    for pkg in zsh make stow git curl tar unzip; do
        command_exists "${pkg}" || missing+=("${pkg}")
    done
    # Node (desktop tool set) links against libatomic on Linux.
    local need_atomic=false
    if [ "${make_target}" = "desktop" ] && ! ls /lib/*/libatomic.so.1 /usr/lib/*/libatomic.so.1 /usr/lib64/libatomic.so.1 2>/dev/null | grep -q .; then
        need_atomic=true
    fi

    if [ ${#missing[@]} -eq 0 ] && [ "${need_atomic}" = false ]; then
        success "All prerequisites present"
        return 0
    fi

    local sudo=""
    if [ "$(id -u)" -ne 0 ]; then
        if command_exists sudo; then
            sudo="sudo"
        else
            ${need_atomic} && missing+=("libatomic")
            error "Missing prerequisites: ${missing[*]}"
            error "No root or sudo available: ask an admin to install them, then re-run."
            exit 1
        fi
    fi

    local update install atomic_pkg
    if command_exists apt-get; then
        update="${sudo} apt-get update"; install="${sudo} apt-get install -y"; atomic_pkg="libatomic1"
    elif command_exists dnf; then
        update="${sudo} dnf check-update || true"; install="${sudo} dnf install -y"; atomic_pkg="libatomic"
    elif command_exists pacman; then
        update="${sudo} pacman -Sy"; install="${sudo} pacman -S --noconfirm"; atomic_pkg="gcc-libs"
    elif command_exists zypper; then
        update="${sudo} zypper refresh"; install="${sudo} zypper install -y"; atomic_pkg="libatomic1"
    else
        error "No supported package manager found (apt, dnf, pacman, zypper)"
        error "Please install manually: ${missing[*]}"
        exit 1
    fi
    ${need_atomic} && missing+=("${atomic_pkg}")

    info "Installing: ${missing[*]}"
    eval "${update}"
    eval "${install} ${missing[*]}"
    success "Prerequisites installed"
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
        make "${make_target}"
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
    info "  1. Make zsh your shell: chsh -s \"\$(command -v zsh)\""
    info "     Without chsh rights, add to ~/.bash_profile: [ -x \"\$(command -v zsh)\" ] && exec zsh -l"
    info "  2. Restart your terminal"
    info "  3. See 'make help' for more options"
    echo ""
}

# Run main function
main "$@"
