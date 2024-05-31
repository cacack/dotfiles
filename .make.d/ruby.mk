.PHONY: setup-ruby
setup-ruby: setup-frum

.PHONY: setup-frum
setup-frum:
	@echo
ifeq ($(OS),linux)
	#export NVM_DIR=${HOME}/.nvm; [ -s ${NVM_DIR}/nvm.sh ] && source ${NVM_DIR}/nvm.sh; nvm install --lts; corepack enable; corepack prepare yarn@stable --activate
endif
ifeq ($(OS),darwin)
	brew install libyaml frum
endif
