.PHONY: setup-vagrant
setup-vagrant:
	@echo
ifeq ($(OS),darwin)
	brew install vagrant
endif
