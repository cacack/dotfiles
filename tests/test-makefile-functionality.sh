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
    echo -e "${YELLOW}=== Makefile Functionality Tests ===${NC}"
}

test_platform_detection() {
    echo "Testing platform detection:"

    local failures=0

    # Test OS detection (extract value after '=')
    local os=$(make -C "$DOTFILES_DIR" print-OS 2>/dev/null | grep "^OS =" | cut -d= -f2 | tr -d ' ')
    if [[ "$os" == "darwin" ]] || [[ "$os" == "linux" ]]; then
        echo -e "  ${GREEN}✓${NC} OS detected: $os"
    else
        echo -e "  ${RED}✗${NC} Invalid OS detection: '$os'"
        failures=$((failures + 1))
    fi

    # Test ARCH detection (extract value after '=')
    local arch=$(make -C "$DOTFILES_DIR" print-ARCH 2>/dev/null | grep "^ARCH =" | cut -d= -f2 | tr -d ' ')
    if [[ "$arch" == "x86_64" ]] || [[ "$arch" == "arm64" ]]; then
        echo -e "  ${GREEN}✓${NC} ARCH detected: $arch"
    else
        echo -e "  ${RED}✗${NC} Invalid ARCH detection: '$arch'"
        failures=$((failures + 1))
    fi

    # Test ARCH_ALT detection (extract value after '=')
    local arch_alt=$(make -C "$DOTFILES_DIR" print-ARCH_ALT 2>/dev/null | grep "^ARCH_ALT =" | cut -d= -f2 | tr -d ' ')
    if [[ "$arch_alt" == "amd64" ]] || [[ "$arch_alt" == "arm64" ]]; then
        echo -e "  ${GREEN}✓${NC} ARCH_ALT detected: $arch_alt"
    else
        echo -e "  ${RED}✗${NC} Invalid ARCH_ALT detection: '$arch_alt'"
        failures=$((failures + 1))
    fi

    return $failures
}

test_variable_definitions() {
    echo "Testing critical variable definitions:"

    local failures=0

    # Test BASE_DIR (extract value after '=')
    local base_dir=$(make -C "$DOTFILES_DIR" print-BASE_DIR 2>/dev/null | grep "^BASE_DIR =" | cut -d= -f2- | sed 's/^ *//')
    if [[ -n "$base_dir" ]] && [[ "$base_dir" =~ \.local$ ]]; then
        echo -e "  ${GREEN}✓${NC} BASE_DIR defined: $base_dir"
    else
        echo -e "  ${RED}✗${NC} BASE_DIR not properly defined: '$base_dir'"
        failures=$((failures + 1))
    fi

    # Test BIN_DIR (extract value after '=')
    local bin_dir=$(make -C "$DOTFILES_DIR" print-BIN_DIR 2>/dev/null | grep "^BIN_DIR =" | cut -d= -f2- | sed 's/^ *//')
    if [[ -n "$bin_dir" ]] && [[ "$bin_dir" =~ bin$ ]]; then
        echo -e "  ${GREEN}✓${NC} BIN_DIR defined: $bin_dir"
    else
        echo -e "  ${RED}✗${NC} BIN_DIR not properly defined: '$bin_dir'"
        failures=$((failures + 1))
    fi

    # Test SHARE_DIR (extract value after '=')
    local share_dir=$(make -C "$DOTFILES_DIR" print-SHARE_DIR 2>/dev/null | grep "^SHARE_DIR =" | cut -d= -f2- | sed 's/^ *//')
    if [[ -n "$share_dir" ]] && [[ "$share_dir" =~ share$ ]]; then
        echo -e "  ${GREEN}✓${NC} SHARE_DIR defined: $share_dir"
    else
        echo -e "  ${RED}✗${NC} SHARE_DIR not properly defined: '$share_dir'"
        failures=$((failures + 1))
    fi

    # Test USER_FONT_DIR (extract value after '=')
    local font_dir=$(make -C "$DOTFILES_DIR" print-USER_FONT_DIR 2>/dev/null | grep "^USER_FONT_DIR =" | cut -d= -f2- | sed 's/^ *//')
    if [[ -n "$font_dir" ]]; then
        echo -e "  ${GREEN}✓${NC} USER_FONT_DIR defined: $font_dir"
    else
        echo -e "  ${RED}✗${NC} USER_FONT_DIR not defined"
        failures=$((failures + 1))
    fi

    # Test SHELL variable (extract value after '=')
    local shell_var=$(make -C "$DOTFILES_DIR" print-SHELL 2>/dev/null | grep "^SHELL =" | cut -d= -f2- | sed 's/^ *//')
    if [[ -n "$shell_var" ]] && [[ "$shell_var" =~ (bash|zsh|sh)$ ]]; then
        echo -e "  ${GREEN}✓${NC} SHELL defined: $shell_var"
    else
        echo -e "  ${RED}✗${NC} SHELL not properly defined: '$shell_var'"
        failures=$((failures + 1))
    fi

    return $failures
}

test_help_target() {
    echo "Testing help target:"

    local failures=0

    # Test that help target runs without error
    if make -C "$DOTFILES_DIR" help >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Help target runs successfully"
    else
        echo -e "  ${RED}✗${NC} Help target failed"
        failures=$((failures + 1))
        return $failures
    fi

    # Test that help output contains expected content
    local help_output=$(make -C "$DOTFILES_DIR" help 2>/dev/null)

    if echo "$help_output" | grep -qi "Dotfiles\|COMMANDS"; then
        echo -e "  ${GREEN}✓${NC} Help output contains expected headers"
    else
        echo -e "  ${RED}✗${NC} Help output missing expected headers"
        failures=$((failures + 1))
    fi

    if echo "$help_output" | grep -q "make install"; then
        echo -e "  ${GREEN}✓${NC} Help output shows 'make install'"
    else
        echo -e "  ${RED}✗${NC} Help output missing 'make install'"
        failures=$((failures + 1))
    fi

    return $failures
}

test_print_variable_functionality() {
    echo "Testing print-* variable functionality:"

    local failures=0

    # Test that print-* pattern works
    if make -C "$DOTFILES_DIR" print-OS >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} print-OS target works"
    else
        echo -e "  ${RED}✗${NC} print-OS target failed"
        failures=$((failures + 1))
    fi

    if make -C "$DOTFILES_DIR" print-ARCH >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} print-ARCH target works"
    else
        echo -e "  ${RED}✗${NC} print-ARCH target failed"
        failures=$((failures + 1))
    fi

    # Test with a non-existent variable (should still work, just be empty)
    if make -C "$DOTFILES_DIR" print-NONEXISTENT_VAR >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} print-* works for undefined variables"
    else
        echo -e "  ${RED}✗${NC} print-* failed for undefined variable"
        failures=$((failures + 1))
    fi

    return $failures
}

test_essential_targets_exist() {
    echo "Testing essential targets exist:"

    local failures=0
    local targets=("install" "stow" "clean-stow" "update" "clean" "test" "help")

    for target in "${targets[@]}"; do
        # Use make -n (dry-run) to check if target exists
        if make -C "$DOTFILES_DIR" -n "$target" >/dev/null 2>&1; then
            echo -e "  ${GREEN}✓${NC} Target '$target' exists"
        else
            echo -e "  ${RED}✗${NC} Target '$target' not found"
            failures=$((failures + 1))
        fi
    done

    return $failures
}

test_makefile_syntax() {
    echo "Testing Makefile syntax:"

    local failures=0

    # Test main Makefile syntax
    if make -C "$DOTFILES_DIR" -n >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Main Makefile has valid syntax"
    else
        echo -e "  ${RED}✗${NC} Main Makefile has syntax errors"
        make -C "$DOTFILES_DIR" -n 2>&1 | head -5 | sed 's/^/    /'
        failures=$((failures + 1))
    fi

    # Count .mk files
    local mk_count=$(find "$DOTFILES_DIR/.make.d" -name "*.mk" | wc -l)
    echo -e "  ${GREEN}✓${NC} Found $mk_count module files in .make.d/"

    return $failures
}

test_module_inclusion() {
    echo "Testing module inclusion:"

    local failures=0

    # Test that .make.d modules are being included
    local modules=("00_make.mk" "10_base.mk" "testing.mk")

    for module in "${modules[@]}"; do
        if [[ -f "$DOTFILES_DIR/.make.d/$module" ]]; then
            echo -e "  ${GREEN}✓${NC} Module $module exists"
        else
            echo -e "  ${RED}✗${NC} Module $module not found"
            failures=$((failures + 1))
        fi
    done

    return $failures
}

test_phony_targets() {
    echo "Testing .PHONY declarations:"

    local failures=0

    # Check that common targets are marked as .PHONY
    if grep -q ".PHONY.*install" "$DOTFILES_DIR/.make.d/10_base.mk" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} install is marked as .PHONY"
    else
        echo -e "  ${YELLOW}⚠${NC} install may not be marked as .PHONY"
    fi

    if grep -q ".PHONY.*test" "$DOTFILES_DIR/.make.d/testing.mk" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} test is marked as .PHONY"
    else
        echo -e "  ${RED}✗${NC} test is not marked as .PHONY"
        failures=$((failures + 1))
    fi

    return $failures
}

test_platform_specific_logic() {
    echo "Testing platform-specific logic:"

    local failures=0
    local os=$(make -C "$DOTFILES_DIR" print-OS 2>/dev/null | grep "^OS =" | cut -d= -f2 | tr -d ' ')

    if [[ "$os" == "darwin" ]]; then
        # Test macOS-specific targets exist
        if [[ -f "$DOTFILES_DIR/.make.d/macos-settings.mk" ]]; then
            echo -e "  ${GREEN}✓${NC} macOS-specific modules present"
        else
            echo -e "  ${RED}✗${NC} macOS modules missing on macOS system"
            failures=$((failures + 1))
        fi

        # Test that macOS font directory is correct
        local font_dir=$(make -C "$DOTFILES_DIR" print-USER_FONT_DIR 2>/dev/null | grep "^USER_FONT_DIR =" | cut -d= -f2- | sed 's/^ *//')
        if [[ "$font_dir" =~ Library/Fonts ]]; then
            echo -e "  ${GREEN}✓${NC} macOS font directory correct: $font_dir"
        else
            echo -e "  ${RED}✗${NC} macOS font directory incorrect: '$font_dir'"
            failures=$((failures + 1))
        fi
    elif [[ "$os" == "linux" ]]; then
        # Test Linux-specific targets exist
        if [[ -f "$DOTFILES_DIR/.make.d/linux-settings.mk" ]]; then
            echo -e "  ${GREEN}✓${NC} Linux-specific modules present"
        else
            echo -e "  ${RED}✗${NC} Linux modules missing on Linux system"
            failures=$((failures + 1))
        fi

        # Test that Linux font directory is correct
        local font_dir=$(make -C "$DOTFILES_DIR" print-USER_FONT_DIR 2>/dev/null | grep "^USER_FONT_DIR =" | cut -d= -f2- | sed 's/^ *//')
        if [[ "$font_dir" =~ .local/share/fonts ]]; then
            echo -e "  ${GREEN}✓${NC} Linux font directory correct: $font_dir"
        else
            echo -e "  ${RED}✗${NC} Linux font directory incorrect: '$font_dir'"
            failures=$((failures + 1))
        fi
    fi

    return $failures
}

main() {
    print_header

    local total=0
    local failures=0

    # Run all test functions
    total=$((total + 1))
    test_platform_detection || failures=$((failures + 1))
    echo

    total=$((total + 1))
    test_variable_definitions || failures=$((failures + 1))
    echo

    total=$((total + 1))
    test_help_target || failures=$((failures + 1))
    echo

    total=$((total + 1))
    test_print_variable_functionality || failures=$((failures + 1))
    echo

    total=$((total + 1))
    test_essential_targets_exist || failures=$((failures + 1))
    echo

    total=$((total + 1))
    test_makefile_syntax || failures=$((failures + 1))
    echo

    total=$((total + 1))
    test_module_inclusion || failures=$((failures + 1))
    echo

    total=$((total + 1))
    test_phony_targets || failures=$((failures + 1))
    echo

    total=$((total + 1))
    test_platform_specific_logic || failures=$((failures + 1))
    echo

    if [[ $failures -eq 0 ]]; then
        echo -e "${GREEN}All $total Makefile functionality tests passed!${NC}"
        return 0
    else
        echo -e "${RED}$failures out of $total Makefile functionality tests failed${NC}"
        return 1
    fi
}

main "$@"
