UPDATE += update-ccstatusline
CLEAN_ALL += clean-ccstatusline-config

.PHONY: setup-ccstatusline
setup-ccstatusline: install-ccstatusline setup-ccstatusline-config

.PHONY: install-ccstatusline
install-ccstatusline:
	@echo
	@echo "Installing ccstatusline..."
	npm install -g ccstatusline

.PHONY: update-ccstatusline
update-ccstatusline:
	@echo
	@echo "Updating ccstatusline..."
	npm update -g ccstatusline

.PHONY: setup-ccstatusline-config
setup-ccstatusline-config:
	cd packages && stow --target=${HOME} ccstatusline

.PHONY: clean-ccstatusline-config
clean-ccstatusline-config:
	cd packages && stow --target=${HOME} --delete ccstatusline 2>/dev/null || true
	rm -rf ~/.config/ccstatusline
