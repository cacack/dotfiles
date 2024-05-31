install-homebrew:
ifeq ($(OS),darwin)
	@echo
	# Installing Homebrew
	mkdir -p ${HOME}/.local/opt/homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ${HOME}/.local/opt/homebrew
	eval "$(${HOME}/.local/opt/homebrew/bin/brew shellenv)" && brew update --force --quiet
	chmod -R go-w "$(brew --prefix)/share/zsh"
endif
