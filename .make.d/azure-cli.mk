.PHONY: install-azure-cli
install-azure-cli:
	@echo
	# Installing Azure CLI
ifeq ($(UNAME), Linux)
	pipx install azure-cli
endif
ifeq ($(UNAME), Darwin)
	brew install azure-cli
endif
