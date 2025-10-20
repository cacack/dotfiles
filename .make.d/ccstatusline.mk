CLEAN_ALL += clean-ccstatusline-config

# ccstatusline is used via npx (npx ccstatusline@latest)
# No installation needed - npx downloads and runs the latest version on-demand

.PHONY: setup-ccstatusline
setup-ccstatusline: setup-ccstatusline-config

.PHONY: setup-ccstatusline-config
setup-ccstatusline-config:
	@echo
	@echo "Setting up ccstatusline configuration..."
	cd packages && stow --target=${HOME} ccstatusline

.PHONY: clean-ccstatusline-config
clean-ccstatusline-config:
	cd packages && stow --target=${HOME} --delete ccstatusline 2>/dev/null || true
	rm -rf ~/.config/ccstatusline
