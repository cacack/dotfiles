.PHONY: test test-syntax test-config test-stow test-help

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

# Test help
test-help:
	@echo
	@echo "Available testing targets:"
	@echo "  test        - Run all tests"
	@echo "  test-syntax - Run shell script syntax validation"
	@echo "  test-config - Run configuration loading tests"
	@echo "  test-stow   - Run stow operation validation"
	@echo "  test-help   - Show this help message"
	@echo