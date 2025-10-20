################################################################################
# Development Environment Setup
#
# Install and configure development dependencies for working on this repository
################################################################################

.PHONY: setup-dev check-dev-tools install-shellcheck install-yamllint

# Main development setup target
setup-dev: install-shellcheck install-yamllint
	@echo
	@echo "Development environment setup complete!"
	@echo
	@echo "Installed tools:"
	@command -v shellcheck >/dev/null && echo "  ✓ shellcheck: $$(shellcheck --version | head -2 | tail -1 | awk '{print $$2}')" || echo "  ✗ shellcheck: not found"
	@command -v yamllint >/dev/null && echo "  ✓ yamllint: $$(yamllint --version)" || echo "  ✗ yamllint: not found"
	@echo
	@echo "Run 'make test' to verify everything works"
	@echo

# Check which development tools are installed
check-dev-tools:
	@echo "Checking development tools..."
	@echo
	@echo "Required for testing:"
	@command -v shellcheck >/dev/null && echo "  ✓ shellcheck" || echo "  ✗ shellcheck (install with: make install-shellcheck)"
	@command -v yamllint >/dev/null && echo "  ✓ yamllint" || echo "  ✗ yamllint (install with: make install-yamllint)"
	@echo
	@echo "General tools:"
	@command -v git >/dev/null && echo "  ✓ git" || echo "  ✗ git"
	@command -v make >/dev/null && echo "  ✓ make" || echo "  ✗ make"
	@command -v stow >/dev/null && echo "  ✓ stow" || echo "  ✗ stow"
	@command -v zsh >/dev/null && echo "  ✓ zsh" || echo "  ✗ zsh"
	@echo

# Install shellcheck
install-shellcheck:
	@echo "Installing shellcheck..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		echo "  shellcheck already installed"; \
	elif [ "$(OS)" = "darwin" ]; then \
		if command -v brew >/dev/null 2>&1; then \
			brew install shellcheck; \
		else \
			echo "ERROR: Homebrew not found. Install from https://brew.sh"; \
			exit 1; \
		fi; \
	elif [ "$(OS)" = "linux" ]; then \
		if command -v apt-get >/dev/null 2>&1; then \
			echo "Installing shellcheck via apt..."; \
			sudo apt-get update && sudo apt-get install -y shellcheck; \
		else \
			echo "ERROR: apt-get not found. Install shellcheck manually."; \
			exit 1; \
		fi; \
	fi

# Install yamllint
install-yamllint:
	@echo "Installing yamllint..."
	@if command -v yamllint >/dev/null 2>&1; then \
		echo "  yamllint already installed"; \
	elif [ "$(OS)" = "darwin" ]; then \
		if command -v brew >/dev/null 2>&1; then \
			brew install yamllint; \
		else \
			echo "ERROR: Homebrew not found. Install from https://brew.sh"; \
			exit 1; \
		fi; \
	elif [ "$(OS)" = "linux" ]; then \
		if command -v apt-get >/dev/null 2>&1; then \
			echo "Installing yamllint via apt..."; \
			sudo apt-get update && sudo apt-get install -y yamllint; \
		else \
			echo "ERROR: apt-get not found. Install yamllint manually."; \
			exit 1; \
		fi; \
	fi
