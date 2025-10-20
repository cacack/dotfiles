CLEAN_ALL += clean-ccstatusline-config

# ccstatusline is used via npx (npx ccstatusline@latest)
# No installation needed - npx downloads and runs the latest version on-demand

.PHONY: setup-ccstatusline
setup-ccstatusline: setup-ccstatusline-config setup-claude-code-settings

.PHONY: setup-ccstatusline-config
setup-ccstatusline-config:
	@echo
	@echo "Setting up ccstatusline configuration..."
	cd packages && stow --target=${HOME} ccstatusline

.PHONY: setup-claude-code-settings
setup-claude-code-settings:
	@echo
	@echo "Setting up Claude Code settings..."
	@mkdir -p ~/.claude
	@echo '{\n  "statusLine": {\n    "command": "npx ccstatusline"\n  }\n}' > ~/.claude/settings.json
	@echo "Claude Code settings created at ~/.claude/settings.json"

.PHONY: clean-ccstatusline-config
clean-ccstatusline-config:
	cd packages && stow --target=${HOME} --delete ccstatusline 2>/dev/null || true
	rm -rf ~/.config/ccstatusline
	rm -f ~/.claude/settings.json
