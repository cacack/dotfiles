setup-python: install-python

install-python:
	@echo
	# Installing yarn
ifeq ($(DISTRO),Fedora)
	sudo dnf install python
endif
ifeq ($(DISTRO),Ubuntu)
	sudo apt install --yes --no-install-recommends python3-venv
endif
ifeq ($(OS),darwin)
	brew install python
endif
