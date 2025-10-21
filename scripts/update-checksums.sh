#!/usr/bin/env bash
################################################################################
# update-checksums.sh
#
# Helper script to fetch and update SHA256 checksums from release pages.
# This script helps maintain the checksums.txt file by automatically fetching
# official checksums from GitHub/GitLab releases.
#
# Usage:
#   ./scripts/update-checksums.sh <tool-name>
#   ./scripts/update-checksums.sh all
#
# Examples:
#   ./scripts/update-checksums.sh direnv
#   ./scripts/update-checksums.sh gh
#   ./scripts/update-checksums.sh all
################################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CHECKSUMS_FILE="$DOTFILES_ROOT/.make.d/checksums.txt"
MAKE_DIR="$DOTFILES_ROOT/.make.d"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

# Extract version from a makefile module
get_version_from_mk() {
    local tool=$1
    local mk_file="$MAKE_DIR/${tool}.mk"

    if [[ ! -f "$mk_file" ]]; then
        log_error "Makefile not found: $mk_file"
        return 1
    fi

    # Try different version variable naming conventions
    local version_var="$(echo "${tool}" | tr '[:lower:]' '[:upper:]')_VERSION"
    version=$(grep -E "^${version_var}\s*:?=" "$mk_file" | head -1 | sed -E 's/.*:?=\s*//' | tr -d ' ')

    if [[ -z "$version" ]]; then
        log_error "Could not find version for $tool in $mk_file"
        return 1
    fi

    echo "$version"
}

# Fetch checksums for direnv
update_direnv_checksums() {
    log_info "Fetching checksums for direnv..."

    local version
    version=$(get_version_from_mk "direnv") || return 1

    local checksums_url="https://github.com/direnv/direnv/releases/download/v${version}/checksums.txt"

    log_info "Downloading from: $checksums_url"
    local checksums
    checksums=$(curl -sSL "$checksums_url")

    if [[ -z "$checksums" ]]; then
        log_error "Failed to download checksums"
        return 1
    fi

    # Extract relevant checksums
    echo "$checksums" | grep -E "direnv\.(darwin|linux)-(arm64|x86_64)$" || true
    log_success "Direnv checksums fetched"
}

# Fetch checksums for gh (GitHub CLI)
update_gh_checksums() {
    log_info "Fetching checksums for gh..."

    local version
    version=$(get_version_from_mk "gh") || return 1

    local checksums_url="https://github.com/cli/cli/releases/download/v${version}/gh_${version}_checksums.txt"

    log_info "Downloading from: $checksums_url"
    local checksums
    checksums=$(curl -sSL "$checksums_url")

    if [[ -z "$checksums" ]]; then
        log_error "Failed to download checksums"
        return 1
    fi

    # Extract relevant checksums (macOS and Linux, amd64 and arm64)
    echo "$checksums" | grep -E "gh_${version}_(linux_amd64\.tar\.gz|macOS_(amd64|arm64)\.zip)" || true
    log_success "GitHub CLI checksums fetched"
}

# Fetch checksums for s5cmd
update_s5cmd_checksums() {
    log_info "Fetching checksums for s5cmd..."

    local version
    version=$(get_version_from_mk "s5cmd") || return 1

    local checksums_url="https://github.com/peak/s5cmd/releases/download/v${version}/s5cmd_checksums.txt"

    log_info "Downloading from: $checksums_url"
    local checksums
    checksums=$(curl -sSL "$checksums_url")

    if [[ -z "$checksums" ]]; then
        log_error "Failed to download checksums"
        return 1
    fi

    # Extract relevant checksums
    echo "$checksums" | grep -E "s5cmd_${version}_(Linux-64bit|macOS-(arm64|64bit))\.tar\.gz" || true
    log_success "s5cmd checksums fetched"
}

# Fetch checksums for glab
update_glab_checksums() {
    log_info "Fetching checksums for glab..."

    local version
    version=$(get_version_from_mk "glab") || return 1

    local checksums_url="https://gitlab.com/gitlab-org/cli/-/releases/v${version}/downloads/checksums.txt"

    log_info "Downloading from: $checksums_url"
    local checksums
    checksums=$(curl -sSL "$checksums_url" 2>/dev/null) || {
        log_warn "Could not fetch checksums from GitLab (may require authentication or different URL format)"
        log_info "Please manually verify checksums from: https://gitlab.com/gitlab-org/cli/-/releases/v${version}"
        return 0
    }

    echo "$checksums" | grep -E "glab_${version}_(Linux|macOS)_(x86_64|arm64)\.tar\.gz" || true
    log_success "glab checksums fetched (verify manually)"
}

# Fetch checksums for uv
update_uv_checksums() {
    log_info "Fetching checksums for uv..."

    local version
    version=$(get_version_from_mk "uv") || return 1

    # uv uses a different version format (includes leading v)
    local checksums_url="https://github.com/astral-sh/uv/releases/download/${version}/uv-${version}.sha256"

    log_info "Trying: $checksums_url"
    local checksums
    checksums=$(curl -sSL "$checksums_url" 2>/dev/null) || {
        log_warn "Could not fetch checksums from $checksums_url"
        log_info "Check the release page: https://github.com/astral-sh/uv/releases/tag/${version}"
        return 0
    }

    echo "$checksums"
    log_success "uv checksums fetched"
}

# Main function
main() {
    local tool="${1:-}"

    if [[ -z "$tool" ]]; then
        log_error "Usage: $0 <tool-name|all>"
        log_info "Available tools: direnv, gh, s5cmd, glab, uv"
        exit 1
    fi

    echo "================================"
    log_info "SHA256 Checksum Updater"
    echo "================================"
    echo

    case "$tool" in
        direnv)
            update_direnv_checksums
            ;;
        gh)
            update_gh_checksums
            ;;
        s5cmd)
            update_s5cmd_checksums
            ;;
        glab)
            update_glab_checksums
            ;;
        uv)
            update_uv_checksums
            ;;
        all)
            log_info "Fetching all available checksums..."
            echo
            update_direnv_checksums
            echo
            update_gh_checksums
            echo
            update_s5cmd_checksums
            echo
            update_glab_checksums
            echo
            update_uv_checksums
            ;;
        *)
            log_error "Unknown tool: $tool"
            log_info "Available tools: direnv, gh, s5cmd, glab, uv, all"
            exit 1
            ;;
    esac

    echo
    echo "================================"
    log_info "Copy the checksums above and update $CHECKSUMS_FILE"
    log_warn "Always verify checksums from official sources before adding!"
    echo "================================"
}

main "$@"
