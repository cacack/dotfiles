setup-eza:
ifeq ($(OS),darwin)
	@echo
	# Installing eza via Homebrew on macOS
	eval "$$(${HOME}/.local/opt/homebrew/bin/brew shellenv)" && brew install eza
else
	@echo
	# Installing eza via Homebrew on Linux
	@which brew > /dev/null 2>&1 && brew install eza || echo "Homebrew not found, install manually or use package manager"
endif