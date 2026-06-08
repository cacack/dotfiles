.PHONY: setup-claude install-claude-code

# Pinned Claude Code version. Autoupdate is disabled via DISABLE_AUTOUPDATER=1
# in ~/.claude/settings.json; bump this and re-run to move to a newer release.
CLAUDE_CODE_VERSION := 2.1.162

setup-claude: install-claude-code

install-claude-code:
	@echo
	# Installing Claude Code (pinned to $(CLAUDE_CODE_VERSION))
	curl -fsSL https://claude.ai/install.sh | bash -s $(CLAUDE_CODE_VERSION)
	@echo
	# Claude Code installation complete
	@echo "Autoupdate must be disabled in ~/.claude/settings.json: \"env\": { \"DISABLE_AUTOUPDATER\": \"1\" }"
	@echo "Run 'claude doctor' to verify installation"
	@echo "Run 'claude auth' to authenticate with your Anthropic account"
