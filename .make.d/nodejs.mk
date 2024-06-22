NVM_VERSION := 0.39.3

setup-node: setup-nodejs
setup-nodejs: install-yarn install-nvm

install-yarn:
	@echo
	# Installing yarn
ifeq ($(DISTRO),Fedora)
	sudo dnf install yarnpkg
endif
ifeq ($(DISTRO),Ubuntu)
	sudo apt install --yes --no-install-recommends yarnpkg npm
endif
ifeq ($(OS),darwin)
	brew install yarn
endif


.PHONY: install-nvm
install-nvm:
	@echo
	# Installing nvm
ifeq ($(OS),linux)
	curl -Ls -o- https://raw.githubusercontent.com/nvm-sh/nvm/v$(NVM_VERSION)/install.sh | bash
endif
ifeq ($(OS),darwin)
	brew install nvm
endif

install-nodejs:
	@echo
	# Installing NodeJS
ifeq ($(OS),linux)
	export NVM_DIR=${HOME}/.nvm; [ -s ${NVM_DIR}/nvm.sh ] && source ${NVM_DIR}/nvm.sh; nvm install --lts; corepack enable; corepack prepare yarn@stable --activate
endif
ifeq ($(OS),darwin)
	brew install node@16 yarn npm
endif
