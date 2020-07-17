################################################################################
SETUP += setup-ansible-roles

.PHONY: setup-ansible-roles
setup-ansible-roles: setup-python-modules
	@echo
	cd ansible; pipenv run ansible-galaxy install -v -r requirements.yml -f --ignore-errors


################################################################################
UPDATE += update-ansible-roles

.PHONY: update-ansible-roles
update-ansible-roles: update-python-modules
	@echo
	cd ansible; pipenv run ansible-galaxy install -v -r requirements.yml -f --ignore-errors


################################################################################
LINT += lint-ansible

.PHONY: lint-ansible
lint-ansible:
	@echo
	git grep -I --name-only --null -e '' \
		| grep -EzZ '.*\.ya?ml$$' \
		| xargs -r0 pipenv run ansible-lint --exclude=platform-emaas-k8s-monitoring/

.PHONY: lint-ansible-changed
lint-ansible-changed:
	@echo
	git diff --name-only --diff-filter=ACM -z origin/master..HEAD \
		| grep -EzZ '.*\.ya?ml$$' \
		| xargs -r0 pipenv run ansible-lint --exclude=platform-emaas-k8s-monitoring/
