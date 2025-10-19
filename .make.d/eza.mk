# eza: modern ls replacement
# macOS: Install via Homebrew (no GitHub releases for Darwin)
# Linux: Automatically installed via zinit from GitHub releases (see configs/.zshrc.d/10_plugins.zsh)

setup-eza:
ifeq ($(OS),darwin)
	@echo
	# Installing eza via Homebrew on macOS
	eval "$$(${HOME}/.local/opt/homebrew/bin/brew shellenv)" && brew install eza
else
	@echo "eza is automatically installed via zinit on Linux (see configs/.zshrc.d/10_plugins.zsh)"
	@echo "If you prefer Homebrew installation, run: brew install eza"
endif