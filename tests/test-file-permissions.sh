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
    echo -e "${YELLOW}=== File Permissions Validation ===${NC}"
}

test_executable_scripts() {
    echo "Checking that scripts are executable:"

    local failures=0

    # Files that SHOULD be executable
    local should_be_executable=(
        "install.sh"
        "tests/run-all-tests.sh"
        "tests/test-shell-syntax.sh"
        "tests/test-config-loading.sh"
        "tests/test-stow-operations.sh"
        "tests/test-makefile-functionality.sh"
        "tests/test-shellcheck.sh"
        "tests/test-security-scan.sh"
        "tests/test-file-permissions.sh"
    )

    for file_path in "${should_be_executable[@]}"; do
        local full_path="$DOTFILES_DIR/$file_path"
        if [[ -f "$full_path" ]]; then
            if [[ -x "$full_path" ]]; then
                echo -e "  ${GREEN}✓${NC} $file_path is executable"
            else
                echo -e "  ${RED}✗${NC} $file_path is NOT executable (should be)"
                failures=$((failures + 1))
            fi
        fi
    done

    echo
    return $failures
}

test_non_executable_configs() {
    echo "Checking that config files are NOT executable:"

    local failures=0

    # ZSH config files should NOT be executable (they are sourced, not executed)
    for file in "$DOTFILES_DIR"/configs/.zshrc.d/*.zsh; do
        if [[ -f "$file" ]]; then
            local filename=$(basename "$file")
            if [[ -x "$file" ]]; then
                echo -e "  ${RED}✗${NC} $filename is executable (should NOT be)"
                failures=$((failures + 1))
            else
                echo -e "  ${GREEN}✓${NC} $filename is not executable"
            fi
        fi
    done

    # .zshrc should not be executable
    if [[ -f "$DOTFILES_DIR/configs/.zshrc" ]]; then
        if [[ -x "$DOTFILES_DIR/configs/.zshrc" ]]; then
            echo -e "  ${RED}✗${NC} .zshrc is executable (should NOT be)"
            failures=$((failures + 1))
        else
            echo -e "  ${GREEN}✓${NC} .zshrc is not executable"
        fi
    fi

    # Makefile modules should not be executable
    for file in "$DOTFILES_DIR"/.make.d/*.mk; do
        if [[ -f "$file" ]]; then
            local filename=$(basename "$file")
            if [[ -x "$file" ]]; then
                echo -e "  ${RED}✗${NC} $filename is executable (should NOT be)"
                failures=$((failures + 1))
            fi
        fi
    done

    # If any Makefile modules are executable, just report summary
    local mk_executable_count=$(find "$DOTFILES_DIR/.make.d" -name "*.mk" -type f -perm +111 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$mk_executable_count" -gt 0 ]]; then
        echo -e "  ${RED}✗${NC} Found $mk_executable_count executable .mk files (should NOT be)"
        failures=$((failures + mk_executable_count))
    else
        echo -e "  ${GREEN}✓${NC} All Makefile modules (.mk) are not executable"
    fi

    echo
    return $failures
}

test_directory_permissions() {
    echo "Checking directory permissions:"

    local failures=0

    # Important directories that should be readable and traversable
    local important_dirs=(
        "."
        "configs"
        "packages"
        "tests"
        ".make.d"
        "docs"
    )

    for dir_path in "${important_dirs[@]}"; do
        local full_path="$DOTFILES_DIR/$dir_path"
        if [[ -d "$full_path" ]]; then
            if [[ -r "$full_path" ]] && [[ -x "$full_path" ]]; then
                echo -e "  ${GREEN}✓${NC} $dir_path/ is accessible"
            else
                echo -e "  ${RED}✗${NC} $dir_path/ has restricted permissions"
                failures=$((failures + 1))
            fi
        fi
    done

    echo
    return $failures
}

test_no_world_writable() {
    echo "Checking for world-writable files (security risk):"

    local world_writable=$(find "$DOTFILES_DIR" -path "$DOTFILES_DIR/.git" -prune -o -type f -perm -002 -print 2>/dev/null)

    if [[ -z "$world_writable" ]]; then
        echo -e "  ${GREEN}✓${NC} No world-writable files found"
        echo
        return 0
    else
        echo -e "  ${RED}✗${NC} Found world-writable files:"
        echo "$world_writable" | sed 's/^/    /'
        echo
        return 1
    fi
}

fix_permissions() {
    echo -e "${YELLOW}To fix permission issues, run:${NC}"
    echo
    echo "  # Make scripts executable:"
    echo "  chmod +x install.sh tests/*.sh"
    echo
    echo "  # Remove executable bit from configs:"
    echo "  chmod -x configs/.zshrc.d/*.zsh configs/.zshrc .make.d/*.mk"
    echo
}

main() {
    print_header

    local total_failures=0

    # Test 1: Scripts should be executable
    test_executable_scripts || total_failures=$((total_failures + $?))

    # Test 2: Config files should NOT be executable
    test_non_executable_configs || total_failures=$((total_failures + $?))

    # Test 3: Directories should be accessible
    test_directory_permissions || total_failures=$((total_failures + $?))

    # Test 4: No world-writable files
    test_no_world_writable || total_failures=$((total_failures + $?))

    if [[ $total_failures -eq 0 ]]; then
        echo -e "${GREEN}All file permission checks passed!${NC}"
        return 0
    else
        echo -e "${RED}$total_failures file permission issue(s) found${NC}"
        echo
        fix_permissions
        return 1
    fi
}

main "$@"
