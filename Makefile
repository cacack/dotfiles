PYTHON_VERSION := 3.8.2


.PHONY: list list-targets
list: list-targets
list-targets:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null \
		| awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' \
		| sort \
		| egrep -v -e '^[^[:alnum:]]' -e '^$@$$'


################################################################################
## Development targets

# Setup development environment
setup: install-deps sync-modules update-ansible-roles

# Install dependencies
install-deps:
	@echo "You'll need to manually install pyenv first to get the ball rolling."

# Update dependencies
update: update-python update-ansible-roles
update-python: update-python-version update-modules sync-modules

update-python-version:
	@echo
	sed -i 's/python:.*/python:$(PYTHON_VERSION)/g' .gitlab-ci.yml
	pyenv local $(PYTHON_VERSION)
	pipenv --python $(PYTHON_VERSION)

update-modules:
	@echo
	pipenv lock --dev

sync-modules:
	@echo
	pipenv sync --dev

update-ansible-roles:
	@echo
	#cd ansible; pipenv run ansible-galaxy install -v -r requirements.yml -f --ignore-errors

# Apply code fix-ups
fixup:

fixup: fixup-python
fixup-changed: fixup-python-changed

fixup-python:
	@echo
	pipenv run isort --recursive
	pipenv run black .

clean:
	@echo This target is not implemented


################################################################################
## Lint targets

lint: lint-whitespace lint-yaml lint-ansible lint-shellcheck lint-python
lint-changed: lint-whitespace lint-yaml-changed lint-ansible-changed lint-shellcheck-changed lint-python-changed

lint-whitespace:
	git diff --check HEAD --

lint-yaml:
	git grep -I --name-only --null -e '' \
		| grep -EzZ '.*\.ya?ml$$' \
		| xargs -r0 pipenv run yamllint -c "$(CURDIR)/.yamllint.yml"

lint-ansible:
	git grep -I --name-only --null -e '' \
		| grep -EzZ '.*\.ya?ml$$' \
		| xargs -r0 pipenv run ansible-lint --exclude=platform-emaas-k8s-monitoring/

lint-shellcheck:
	git grep -I --name-only --null -e '' \
		| xargs --null --max-lines=1 file --mime-type \
		| sed --quiet 's,: *text/x-shellscript$$,,p' \
		| xargs --no-run-if-empty shellcheck -x
