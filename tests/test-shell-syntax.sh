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
    echo -e "${YELLOW}=== Shell Script Syntax Validation ===${NC}"
}

test_zsh_syntax() {
    local file="$1"
    local filename=$(basename "$file")

    if zsh -n "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $filename"
        return 0
    else
        echo -e "  ${RED}✗${NC} $filename - syntax error"
        zsh -n "$file" 2>&1 | sed 's/^/    /'
        return 1
    fi
}

test_bash_syntax() {
    local file="$1"
    local filename=$(basename "$file")

    if bash -n "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $filename"
        return 0
    else
        echo -e "  ${RED}✗${NC} $filename - syntax error"
        bash -n "$file" 2>&1 | sed 's/^/    /'
        return 1
    fi
}

main() {
    print_header

    local failures=0
    local total=0

    # Test zsh configuration files
    echo "Testing ZSH configuration files:"
    for file in "$DOTFILES_DIR"/configs/.zshrc.d/*.zsh; do
        if [[ -f "$file" ]]; then
            total=$((total + 1))
            if ! test_zsh_syntax "$file"; then
                failures=$((failures + 1))
            fi
        fi
    done

    # Test main zshrc
    if [[ -f "$DOTFILES_DIR/configs/.zshrc" ]]; then
        total=$((total + 1))
        echo "Testing main ZSH configuration:"
        if ! test_zsh_syntax "$DOTFILES_DIR/configs/.zshrc"; then
            failures=$((failures + 1))
        fi
    fi

    # Test bash/shell scripts in .make.d/
    echo "Testing Make scripts:"
    for file in "$DOTFILES_DIR"/.make.d/*.mk; do
        if [[ -f "$file" ]]; then
            # Skip make files, they're not shell scripts
            continue
        fi
    done

    # Test any shell scripts in the root
    for file in "$DOTFILES_DIR"/*.sh; do
        if [[ -f "$file" ]]; then
            total=$((total + 1))
            if ! test_bash_syntax "$file"; then
                failures=$((failures + 1))
            fi
        fi
    done

    echo
    if [[ $failures -eq 0 ]]; then
        echo -e "${GREEN}All $total shell scripts passed syntax validation!${NC}"
        return 0
    else
        echo -e "${RED}$failures out of $total shell scripts failed syntax validation${NC}"
        return 1
    fi
}

main "$@"