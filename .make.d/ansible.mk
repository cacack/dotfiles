################################################################################
ANSIBLE_PATH ?= ansible


################################################################################
SETUP += setup-ansible-roles

.PHONY: setup-ansible-roles
setup-ansible-roles: setup-python-modules
	@echo
	cd $(ANSIBLE_PATH); pipenv run ansible-galaxy install -v -r requirements.yml -f


################################################################################
UPDATE += update-ansible-roles

.PHONY: update-ansible-roles
update-ansible-roles:
	@echo
	cd $(ANSIBLE_PATH); pipenv run ansible-galaxy install -v -r requirements.yml -f


################################################################################
LINT += lint-ansible

.PHONY: lint-ansible
lint-ansible:
	@echo
	git grep -I --name-only --null -e '' \
		| grep -EzZ '.*\.ya?ml$$' \
		| xargs -r0 pipenv run ansible-lint

.PHONY: lint-ansible-changed
lint-ansible-changed:
	@echo
	git diff --name-only --diff-filter=ACM -z origin/master..HEAD \
		| grep -EzZ '.*\.ya?ml$$' \
		| xargs -r0 pipenv run ansible-lint
