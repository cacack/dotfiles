################################################################################
# Development Environment Setup
#
# Install and configure development dependencies for working on this repository
################################################################################

.PHONY: setup-dev check-dev-tools

# Main development setup target
setup-dev: tools
	@echo
	@echo "Development environment setup complete!"
	@echo
	@echo "Installed tools:"
	@command -v shellcheck >/dev/null && echo "  ✓ shellcheck: $$(shellcheck --version | head -2 | tail -1 | awk '{print $$2}')" || echo "  ✗ shellcheck: not found"
	@command -v yamllint >/dev/null && echo "  ✓ yamllint: $$(yamllint --version)" || echo "  ✗ yamllint: not found (desktop tool set: make desktop)"
	@echo
	@echo "Run 'make test' to verify everything works"
	@echo

# Check which development tools are installed
check-dev-tools:
	@echo "Checking development tools..."
	@echo
	@echo "Required for testing:"
	@command -v shellcheck >/dev/null && echo "  ✓ shellcheck" || echo "  ✗ shellcheck (install with: make tools)"
	@command -v yamllint >/dev/null && echo "  ✓ yamllint" || echo "  ✗ yamllint (desktop tool set: make desktop)"
	@echo
	@echo "General tools:"
	@command -v git >/dev/null && echo "  ✓ git" || echo "  ✗ git"
	@command -v make >/dev/null && echo "  ✓ make" || echo "  ✗ make"
	@command -v stow >/dev/null && echo "  ✓ stow" || echo "  ✗ stow"
	@command -v zsh >/dev/null && echo "  ✓ zsh" || echo "  ✗ zsh"
	@echo
