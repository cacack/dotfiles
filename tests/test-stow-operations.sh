#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

print_header() {
    echo -e "${YELLOW}=== Stow Operation Validation Tests ===${NC}"
}

test_stow_dry_run() {
    echo "Testing stow dry-run operations:"

    local temp_dir=$(mktemp -d)
    local temp_home="$temp_dir/home"
    local temp_configs="$temp_dir/configs"

    # Set up test environment
    mkdir -p "$temp_home"
    cp -r "$DOTFILES_DIR/configs" "$temp_configs"

    # Test stow dry-run from temp configs to temp home
    cd "$temp_dir"

    if stow --simulate --target="$temp_home" configs 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Stow simulation completed without errors"
        rm -rf "$temp_dir"
        return 0
    else
        echo -e "  ${RED}✗${NC} Stow simulation failed"
        stow --simulate --target="$temp_home" configs 2>&1 | sed 's/^/    /' || true
        rm -rf "$temp_dir"
        return 1
    fi
}

test_stow_conflict_detection() {
    echo "Testing stow conflict detection:"

    local temp_dir=$(mktemp -d)
    local temp_home="$temp_dir/home"
    local temp_configs="$temp_dir/configs"

    # Set up test environment
    mkdir -p "$temp_home"
    cp -r "$DOTFILES_DIR/configs" "$temp_configs"

    # Create a conflicting file
    mkdir -p "$temp_home/.config"
    echo "existing content" > "$temp_home/.zshrc"

    cd "$temp_dir"

    # This should detect the conflict
    if ! stow --simulate --target="$temp_home" configs 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Conflict detection working correctly"
        rm -rf "$temp_dir"
        return 0
    else
        echo -e "  ${RED}✗${NC} Failed to detect existing file conflict"
        rm -rf "$temp_dir"
        return 1
    fi
}

test_stow_unstow_operations() {
    echo "Testing stow/unstow operations:"

    local temp_dir=$(mktemp -d)
    local temp_home="$temp_dir/home"
    local temp_configs="$temp_dir/configs"

    # Set up test environment
    mkdir -p "$temp_home"
    cp -r "$DOTFILES_DIR/configs" "$temp_configs"

    cd "$temp_dir"

    # Test stow operation
    if stow --target="$temp_home" configs 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Stow operation successful"
    else
        echo -e "  ${RED}✗${NC} Stow operation failed"
        rm -rf "$temp_dir"
        return 1
    fi

    # Verify symlinks were created
    if [[ -L "$temp_home/.zshrc" ]]; then
        echo -e "  ${GREEN}✓${NC} Symlinks created correctly"
    else
        echo -e "  ${RED}✗${NC} Expected symlinks not found"
        rm -rf "$temp_dir"
        return 1
    fi

    # Test unstow operation
    if stow --delete --target="$temp_home" configs 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Unstow operation successful"
    else
        echo -e "  ${RED}✗${NC} Unstow operation failed"
        rm -rf "$temp_dir"
        return 1
    fi

    # Verify symlinks were removed
    if [[ ! -L "$temp_home/.zshrc" ]] && [[ ! -e "$temp_home/.zshrc" ]]; then
        echo -e "  ${GREEN}✓${NC} Symlinks removed correctly"
    else
        echo -e "  ${RED}✗${NC} Symlinks not properly removed"
        rm -rf "$temp_dir"
        return 1
    fi

    rm -rf "$temp_dir"
    return 0
}

test_stow_packages_directory() {
    echo "Testing packages directory stow operations:"

    if [[ ! -d "$DOTFILES_DIR/packages" ]]; then
        echo -e "  ${YELLOW}⚠${NC} Packages directory not found, skipping test"
        return 0
    fi

    local temp_dir=$(mktemp -d)
    local temp_home="$temp_dir/home"

    # Set up test environment
    mkdir -p "$temp_home"

    cd "$DOTFILES_DIR/packages"

    # Test each package directory
    local packages_tested=0
    local packages_failed=0

    for package_dir in */; do
        if [[ -d "$package_dir" ]]; then
            package_name=$(basename "$package_dir")
            packages_tested=$((packages_tested + 1))

            if stow --simulate --target="$temp_home" "$package_name" 2>/dev/null; then
                echo -e "  ${GREEN}✓${NC} Package '$package_name' stow simulation successful"
            else
                echo -e "  ${RED}✗${NC} Package '$package_name' stow simulation failed"
                packages_failed=$((packages_failed + 1))
            fi
        fi
    done

    rm -rf "$temp_dir"

    if [[ $packages_failed -eq 0 ]]; then
        echo -e "  ${GREEN}✓${NC} All $packages_tested packages passed stow validation"
        return 0
    else
        echo -e "  ${RED}✗${NC} $packages_failed out of $packages_tested packages failed stow validation"
        return 1
    fi
}

test_stow_command_availability() {
    echo "Testing stow command availability:"

    if command -v stow >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Stow command is available"
        echo -e "  ${GREEN}✓${NC} Stow version: $(stow --version 2>/dev/null | head -n1 || echo 'Unknown')"
        return 0
    else
        echo -e "  ${RED}✗${NC} Stow command not found"
        echo -e "      Install with: sudo apt install stow (Ubuntu) or brew install stow (macOS)"
        return 1
    fi
}

main() {
    print_header

    local failures=0
    local total=0

    # Test stow command availability
    total=$((total + 1))
    if ! test_stow_command_availability; then
        failures=$((failures + 1))
    fi

    # Only run other tests if stow is available
    if command -v stow >/dev/null 2>&1; then
        # Test stow dry-run
        total=$((total + 1))
        if ! test_stow_dry_run; then
            failures=$((failures + 1))
        fi

        # Test conflict detection
        total=$((total + 1))
        if ! test_stow_conflict_detection; then
            failures=$((failures + 1))
        fi

        # Test actual stow/unstow operations
        total=$((total + 1))
        if ! test_stow_unstow_operations; then
            failures=$((failures + 1))
        fi

        # Test packages directory
        total=$((total + 1))
        if ! test_stow_packages_directory; then
            failures=$((failures + 1))
        fi
    else
        echo -e "${YELLOW}Skipping stow operation tests - stow command not available${NC}"
    fi

    echo
    if [[ $failures -eq 0 ]]; then
        echo -e "${GREEN}All $total stow operation tests passed!${NC}"
        return 0
    else
        echo -e "${RED}$failures out of $total stow operation tests failed${NC}"
        return 1
    fi
}

main "$@"