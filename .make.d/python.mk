UPDATE += install-pyenv

setup-python: install-python install-pipx install-poetry install-pyenv

install-python:
	@echo
	# Installing python
ifeq ($(DISTRO),Fedora)
	sudo dnf install python
endif
ifeq ($(DISTRO),Ubuntu)
	sudo apt install --yes --no-install-recommends python3-venv python3-dev
endif
ifeq ($(OS),darwin)
	brew install python
endif

install-pipx:
	@echo
	# Installing pipx
ifeq ($(DISTRO),Fedora)
	sudo dnf install pipx
endif
ifeq ($(DISTRO),Ubuntu)
	sudo apt install --yes --no-install-recommends pipx
endif
ifeq ($(OS),darwin)
	brew install pipx
endif

install-poetry:
	@echo
	pipx install poetry

install-pyenv:
	@echo
	# Install pyenv
	[ -d ${HOME}/.local/opt/pyenv ] && (cd ${HOME}/.local/opt/pyenv && git pull) || git clone https://github.com/pyenv/pyenv.git ${HOME}/.local/opt/pyenv
