.PHONY: test test-syntax test-config test-stow test-makefile test-shellcheck test-security test-permissions test-help

# Main test target - runs all tests
test:
	@echo
	@echo "Running dotfiles test suite..."
	@./tests/run-all-tests.sh

# Individual test targets
test-syntax:
	@echo
	@echo "Running shell syntax validation tests..."
	@./tests/test-shell-syntax.sh

test-config:
	@echo
	@echo "Running configuration loading tests..."
	@./tests/test-config-loading.sh

test-stow:
	@echo
	@echo "Running stow operation validation tests..."
	@./tests/test-stow-operations.sh

test-makefile:
	@echo
	@echo "Running Makefile functionality tests..."
	@./tests/test-makefile-functionality.sh

test-shellcheck:
	@echo
	@echo "Running ShellCheck linting..."
	@./tests/test-shellcheck.sh

test-security:
	@echo
	@echo "Running security scanning..."
	@./tests/test-security-scan.sh

test-permissions:
	@echo
	@echo "Running file permissions validation..."
	@./tests/test-file-permissions.sh

# Test help
test-help:
	@echo
	@echo "Available testing targets:"
	@echo "  test             - Run all tests"
	@echo "  test-syntax      - Run shell script syntax validation"
	@echo "  test-config      - Run configuration loading tests"
	@echo "  test-stow        - Run stow operation validation"
	@echo "  test-makefile    - Run Makefile functionality tests"
	@echo "  test-shellcheck  - Run ShellCheck linting"
	@echo "  test-security    - Run security scanning"
	@echo "  test-permissions - Run file permissions validation"
	@echo "  test-help        - Show this help message"
	@echo