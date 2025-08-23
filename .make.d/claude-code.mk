.PHONY: install-claude-code
install-claude-code:
	@echo
	# Installing Claude Code
	curl -fsSL https://claude.ai/install.sh | bash
	@echo
	# Claude Code installation complete
	@echo "Run 'claude doctor' to verify installation"
	@echo "Run 'claude auth' to authenticate with your Anthropic account"

.PHONY: install-claude-code-latest
install-claude-code-latest:
	@echo
	# Installing Claude Code (latest version)
	curl -fsSL https://claude.ai/install.sh | bash -s latest
	@echo
	# Claude Code installation complete
	@echo "Run 'claude doctor' to verify installation"
	@echo "Run 'claude auth' to authenticate with your Anthropic account"