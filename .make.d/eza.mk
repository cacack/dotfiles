setup-eza:
ifeq ($(OS),darwin)
	@echo
	# Installing eza via Homebrew on macOS
	eval "$$(${HOME}/.local/opt/homebrew/bin/brew shellenv)" && brew install eza
else
	@echo
	# Installing eza via zinit on Linux (handled in zsh plugins)
	@echo "eza will be installed via zinit when zsh is loaded"
endif