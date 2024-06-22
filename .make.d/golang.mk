setup-go: setup-golang
setup-golang: install-golang

install-golang:
	@echo
	# Installing yarn
ifeq ($(DISTRO),Fedora)
	sudo dnf install golang
endif
ifeq ($(DISTRO),Ubuntu)
	sudo apt install --yes --no-install-recommends golang
endif
ifeq ($(OS),darwin)
	brew install golang
endif
