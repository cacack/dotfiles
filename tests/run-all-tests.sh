#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_banner() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                    DOTFILES TEST SUITE                      ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
}

run_test_suite() {
    local test_script="$1"
    local test_name="$2"

    echo -e "${BLUE}Running $test_name...${NC}"
    echo

    if "$SCRIPT_DIR/$test_script"; then
        echo -e "${GREEN}✓ $test_name passed${NC}"
        return 0
    else
        echo -e "${RED}✗ $test_name failed${NC}"
        return 1
    fi
}

main() {
    print_banner

    local total_tests=0
    local failed_tests=0
    local test_results=()

    # Define test suites
    local test_suites=(
        "test-shell-syntax.sh:Shell Script Syntax Validation"
        "test-config-loading.sh:ZSH Configuration Loading"
        "test-stow-operations.sh:Stow Operation Validation"
    )

    # Run each test suite
    for test_suite in "${test_suites[@]}"; do
        IFS=':' read -r script_name test_name <<< "$test_suite"

        total_tests=$((total_tests + 1))

        if run_test_suite "$script_name" "$test_name"; then
            test_results+=("✓ $test_name")
        else
            test_results+=("✗ $test_name")
            failed_tests=$((failed_tests + 1))
        fi

        echo
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo
    done

    # Print summary
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                        TEST SUMMARY                         ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo

    for result in "${test_results[@]}"; do
        if [[ "$result" == ✓* ]]; then
            echo -e "${GREEN}$result${NC}"
        else
            echo -e "${RED}$result${NC}"
        fi
    done

    echo
    echo -e "Total tests: $total_tests"
    echo -e "Passed: $((total_tests - failed_tests))"
    echo -e "Failed: $failed_tests"
    echo

    if [[ $failed_tests -eq 0 ]]; then
        echo -e "${GREEN}🎉 All tests passed! Your dotfiles configuration is healthy.${NC}"
        return 0
    else
        echo -e "${RED}❌ $failed_tests test suite(s) failed. Please review the output above.${NC}"
        return 1
    fi
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [--help|-h]"
        echo
        echo "Runs the complete dotfiles test suite including:"
        echo "  - Shell script syntax validation"
        echo "  - ZSH configuration loading tests"
        echo "  - Stow operation validation"
        echo
        echo "Options:"
        echo "  --help, -h    Show this help message"
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac