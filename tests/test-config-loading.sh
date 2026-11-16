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
    echo -e "${YELLOW}=== ZSH Configuration Loading Tests ===${NC}"
}

test_individual_config() {
    local file="$1"
    local filename=$(basename "$file")

    # Create a minimal test environment
    local temp_dir=$(mktemp -d)
    local test_script="$temp_dir/test.zsh"

    cat > "$test_script" << EOF
#!/usr/bin/env zsh
# Minimal environment setup
export HOME="$temp_dir"
export DOTFILES_CONFIG_DIR="$DOTFILES_DIR/configs"
export USER_BIN_DIR="$temp_dir/.local/bin"
export USER_FONT_DIR="$temp_dir/.local/share/fonts"

# Create basic directories
mkdir -p "\$HOME/.local/bin"
mkdir -p "\$HOME/.config"
mkdir -p "\$HOME/.ssh"

# Mock common commands that might not be available
command_exists() { command -v "\$1" >/dev/null 2>&1; }

# Mock bitwarden commands
bw() {
    case "\$1" in
        unlock)
            if [[ "\$2" == "--check" ]]; then
                return 1  # Not unlocked in test
            elif [[ "\$2" == "--raw" ]]; then
                echo "test-session-key"
            fi
            ;;
        sync)
            return 0
            ;;
        *)
            return 0
            ;;
    esac
}

# Mock kiro command
kiro() {
    if [[ "\$1" == "--locate-shell-integration-path" ]]; then
        # Create a temporary empty shell integration file
        local integration_file="\$HOME/.kiro_integration.zsh"
        touch "\$integration_file"
        echo "\$integration_file"
    fi
}

# Mock zinit to prevent actual plugin loading
zinit() {
    case "\$1" in
        ice|light|snippet|load)
            return 0
            ;;
        *)
            return 0
            ;;
    esac
}

# Mock the init-script cache helper and plugin pins defined in 00_init.zsh
_cached_init() { return 0; }
typeset -A _zinit_pins

# Create mock files that bitwarden script expects
touch "\$HOME/.ssh/bw.env" 2>/dev/null || true

# Source the configuration file
source "$file"
EOF

    if zsh "$test_script" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $filename"
        rm -rf "$temp_dir"
        return 0
    else
        echo -e "  ${RED}✗${NC} $filename - loading error"
        zsh "$test_script" 2>&1 | sed 's/^/    /' || true
        rm -rf "$temp_dir"
        return 1
    fi
}

test_full_zshrc_loading() {
    echo "Testing full .zshrc loading (safe mode):"

    local temp_dir=$(mktemp -d)
    local test_script="$temp_dir/test_zshrc.zsh"

    cat > "$test_script" << EOF
#!/usr/bin/env zsh
# Set up safe test environment
export HOME="$temp_dir"
export DOTFILES_CONFIG_DIR="$DOTFILES_DIR/configs"
export USER_BIN_DIR="$temp_dir/.local/bin"
export USER_FONT_DIR="$temp_dir/.local/share/fonts"
export ZDOTDIR="$temp_dir"

# Create required directories
mkdir -p "\$HOME/.local/bin"
mkdir -p "\$HOME/.config"
mkdir -p "\$HOME/.zshrc.d"
mkdir -p "\$HOME/.local/share/zinit"
mkdir -p "\$HOME/.ssh"

# Copy zshrc.d files to test location
cp -r "$DOTFILES_DIR/configs/.zshrc.d"/* "\$HOME/.zshrc.d/"

# Mock bitwarden commands
bw() {
    case "\$1" in
        unlock)
            if [[ "\$2" == "--check" ]]; then
                return 1  # Not unlocked in test
            elif [[ "\$2" == "--raw" ]]; then
                echo "test-session-key"
            fi
            ;;
        sync)
            return 0
            ;;
        *)
            return 0
            ;;
    esac
}

# Mock kiro command
kiro() {
    if [[ "\$1" == "--locate-shell-integration-path" ]]; then
        local integration_file="\$HOME/.kiro_integration.zsh"
        touch "\$integration_file"
        echo "\$integration_file"
    fi
}

# Mock zinit for testing (prevent actual plugin loading)
zinit() {
    case "\$1" in
        ice|light|snippet|load)
            return 0
            ;;
        *)
            return 0
            ;;
    esac
}

# Mock other commands that might cause issues
fzf() { return 0; }
source() {
    # Only source files that exist and aren't external commands
    local file="\$1"
    if [[ "\$file" =~ "fzf --zsh" ]] || [[ "\$file" =~ "zoxide init" ]]; then
        return 0
    fi
    builtin source "\$@"
}

# Create mock files
touch "\$HOME/.ssh/bw.env" 2>/dev/null || true

# Source individual config files safely
for config_file in "\$HOME/.zshrc.d"/*.zsh; do
    if [[ -f "\$config_file" ]]; then
        builtin source "\$config_file" || exit 1
    fi
done
EOF

    if zsh "$test_script" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Full .zshrc configuration loading"
        rm -rf "$temp_dir"
        return 0
    else
        echo -e "  ${RED}✗${NC} Full .zshrc configuration loading failed"
        zsh "$test_script" 2>&1 | sed 's/^/    /' || true
        rm -rf "$temp_dir"
        return 1
    fi
}

test_aliases_availability() {
    echo "Testing alias definitions:"

    local temp_dir=$(mktemp -d)
    local test_script="$temp_dir/test_aliases.zsh"

    cat > "$test_script" << EOF
#!/usr/bin/env zsh
export HOME="$temp_dir"

# Mock the commands that aliases depend on. Stub executables, not functions:
# the aliases test \$+commands[...], which only sees PATH.
mkdir -p "\$HOME/bin"
for cmd in lsd nvim; do printf '#!/bin/sh\n' > "\$HOME/bin/\$cmd"; chmod +x "\$HOME/bin/\$cmd"; done
export PATH="\$HOME/bin:\$PATH"

# Source aliases
source "$DOTFILES_DIR/configs/.zshrc.d/20_aliases.zsh"

# Test that aliases are defined
alias ls >/dev/null 2>&1 || exit 1
alias ll >/dev/null 2>&1 || exit 1
alias la >/dev/null 2>&1 || exit 1
EOF

    if zsh "$test_script" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Aliases are properly defined"
        rm -rf "$temp_dir"
        return 0
    else
        echo -e "  ${RED}✗${NC} Alias definition failed"
        zsh "$test_script" 2>&1 | sed 's/^/    /' || true
        rm -rf "$temp_dir"
        return 1
    fi
}

# Every zinit plugin must load at its pinned commit: a missing or mistyped pin
# expands to ver"" and silently loads the branch head instead.
test_zinit_pins() {
    echo "Testing zinit plugin pins:"
    local zdir="$DOTFILES_DIR/configs/.zshrc.d" problems="" line repo key
    local pins
    pins="$(sed -nE 's/^ +([A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+) ([0-9a-f]{40})$/\1/p' "$zdir/00_init.zsh")"
    [[ -n "$pins" ]] || problems+=$'\n    no pins parsed from _zinit_pins in 00_init.zsh'
    # Plugin loads: `zinit light|load owner/repo`, or an owner/repo item in a `for` list.
    while IFS= read -r line; do
        repo="$(grep -oE '[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+( \\)?$' <<<"$line" | sed 's/ \\$//')"
        [[ -z "$repo" || "$repo" == */*.zsh ]] && continue
        [[ "$line" == *"_zinit_pins[$repo]"* ]] || problems+=$'\n    unpinned plugin load: '"$repo"
    done < <(grep -hvE '^\s*#' "$zdir"/*.zsh | awk '
        /zinit (light|load) / { print; next }
        infor { print; if ($0 !~ /\\$/) infor = 0; next }
        /zinit .* for \\$/ { infor = 1 }' | grep -v 'https://\|\${_omz}')
    # Every pin referenced must exist.
    while IFS= read -r key; do
        grep -qxF "$key" <<<"$pins" || problems+=$'\n    no pin named: '"$key"
    done < <(grep -hoE '_zinit_pins\[[^]]+\]' "$zdir"/*.zsh | sed -E 's/_zinit_pins\[(.*)\]/\1/' | sort -u)
    # Oh My Zsh shorthands always fetch master.
    grep -hvE '^\s*#' "$zdir"/*.zsh | grep -qE 'OMZ[PL]?::' && problems+=$'\n    OMZ:: shorthand loads Oh My Zsh master; use the pinned ${_omz} URL'

    if [[ -z "$problems" ]]; then
        echo -e "  ${GREEN}✓${NC} Every zinit plugin loads at a pinned commit"
        return 0
    fi
    echo -e "  ${RED}✗${NC} zinit pin problems:$problems"
    return 1
}

main() {
    print_header

    local failures=0
    local total=0

    # Test individual configuration files
    echo "Testing individual configuration files:"
    for file in "$DOTFILES_DIR"/configs/.zshrc.d/*.zsh; do
        if [[ -f "$file" ]]; then
            total=$((total + 1))
            if ! test_individual_config "$file"; then
                failures=$((failures + 1))
            fi
        fi
    done

    # Skip full zshrc loading test for now (requires better plugin mocking)
    # total=$((total + 1))
    # if ! test_full_zshrc_loading; then
    #     failures=$((failures + 1))
    # fi

    # Test aliases
    total=$((total + 1))
    if ! test_aliases_availability; then
        failures=$((failures + 1))
    fi

    total=$((total + 1))
    if ! test_zinit_pins; then
        failures=$((failures + 1))
    fi

    echo
    if [[ $failures -eq 0 ]]; then
        echo -e "${GREEN}All $total configuration loading tests passed!${NC}"
        return 0
    else
        echo -e "${RED}$failures out of $total configuration loading tests failed${NC}"
        return 1
    fi
}

main "$@"