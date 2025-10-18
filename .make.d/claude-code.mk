.PHONY: setup-claude install-claude-code

setup-claude: install-claude-code

install-claude-code:
	@echo
	# Installing Claude Code
	curl -fsSL https://claude.ai/install.sh | bash
	@echo
	# Claude Code installation complete
	@echo "Run 'claude doctor' to verify installation"
	@echo "Run 'claude auth' to authenticate with your Anthropic account"
