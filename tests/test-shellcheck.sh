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
    echo -e "${YELLOW}=== ShellCheck Linting ===${NC}"
}

check_shellcheck_available() {
    if ! command -v shellcheck >/dev/null 2>&1; then
        echo -e "${RED}ERROR: shellcheck not found${NC}"
        echo -e "${YELLOW}Install with: make install-shellcheck${NC}"
        return 1
    fi
    return 0
}

lint_shell_script() {
    local file="$1"
    local filename=$(basename "$file")
    local relative_path="${file#$DOTFILES_DIR/}"

    # Run shellcheck with appropriate options
    # -x: Follow source statements
    # -e SC1091: Ignore "not following" errors for external files
    # -S error: Only fail on errors, not warnings
    if shellcheck -x -e SC1091 -S error "$file" 2>/dev/null; then
        # Check if there are warnings
        if shellcheck -x -e SC1091 "$file" 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} $relative_path"
        else
            echo -e "  ${GREEN}✓${NC} $relative_path (with warnings)"
        fi
        return 0
    else
        echo -e "  ${RED}✗${NC} $relative_path"
        echo -e "${YELLOW}Critical issues found:${NC}"
        shellcheck -x -e SC1091 "$file" 2>&1 | grep "error:" | sed 's/^/    /'
        return 1
    fi
}

lint_zsh_script() {
    local file="$1"
    local filename=$(basename "$file")
    local relative_path="${file#$DOTFILES_DIR/}"

    # For ZSH files, use shell=bash as shellcheck doesn't fully support zsh
    # Ignore common ZSH-specific patterns that shellcheck doesn't understand:
    # - SC1091: Not following sourced files
    # - SC1090: Can't follow non-constant source
    # - SC2148: No shebang (sourced files don't need one)
    # - SC2154: Variable referenced but not assigned (ZSH built-ins like $+commands)
    # - SC2296: Parameter expansions (ZSH-specific syntax)
    # - SC2016: Single quotes in zstyle (intentional in ZSH)
    # - SC2034: Appears unused (ZSH shell options)
    # - SC2046: Word splitting (often intentional in ZSH)
    local ignore_codes="SC1091,SC1090,SC2148,SC2154,SC2296,SC2016,SC2034,SC2046"

    if shellcheck -s bash -e "$ignore_codes" "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $relative_path"
        return 0
    else
        # Check if there are only warnings we're ignoring
        local errors=$(shellcheck -s bash -e "$ignore_codes" "$file" 2>&1)
        if [ -z "$errors" ]; then
            echo -e "  ${GREEN}✓${NC} $relative_path"
            return 0
        else
            # Only fail on errors, not warnings
            if echo "$errors" | grep -q "error:"; then
                echo -e "  ${RED}✗${NC} $relative_path"
                echo -e "${YELLOW}Critical issues found:${NC}"
                echo "$errors" | sed 's/^/    /'
                return 1
            else
                # Just warnings, pass with note
                echo -e "  ${GREEN}✓${NC} $relative_path (with minor warnings)"
                return 0
            fi
        fi
    fi
}

main() {
    print_header

    if ! check_shellcheck_available; then
        return 1
    fi

    echo "ShellCheck version: $(shellcheck --version | head -2 | tail -1 | awk '{print $2}')"
    echo

    local total=0
    local failures=0

    # Lint shell scripts (.sh files)
    echo "Linting shell scripts:"
    for file in "$DOTFILES_DIR"/*.sh "$DOTFILES_DIR"/tests/*.sh; do
        if [[ -f "$file" ]]; then
            total=$((total + 1))
            if ! lint_shell_script "$file"; then
                failures=$((failures + 1))
            fi
        fi
    done
    echo

    # Lint ZSH configuration files
    echo "Linting ZSH configuration files:"
    for file in "$DOTFILES_DIR"/configs/.zshrc.d/*.zsh; do
        if [[ -f "$file" ]]; then
            total=$((total + 1))
            if ! lint_zsh_script "$file"; then
                failures=$((failures + 1))
            fi
        fi
    done

    # Lint main .zshrc if it exists
    if [[ -f "$DOTFILES_DIR/configs/.zshrc" ]]; then
        total=$((total + 1))
        if ! lint_zsh_script "$DOTFILES_DIR/configs/.zshrc"; then
            failures=$((failures + 1))
        fi
    fi

    echo
    if [[ $failures -eq 0 ]]; then
        echo -e "${GREEN}All $total files passed shellcheck linting!${NC}"
        return 0
    else
        echo -e "${RED}$failures out of $total files have linting issues${NC}"
        echo -e "${YELLOW}Fix the issues above or add shellcheck directives to suppress false positives${NC}"
        return 1
    fi
}

main "$@"
