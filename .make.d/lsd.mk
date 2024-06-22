setup-lsd: install-lsd setup-lsd-config

install-lsd:
	@echo
	# Installing lsd
	zinit ice from"gh-r" as"program" mv"lsd-*/lsd -> lsd"; zinit light lsd-rs/lsd

setup-lsd-config:
	@echo
	# Symlinking lsd config
	cd packages; stow lsd
