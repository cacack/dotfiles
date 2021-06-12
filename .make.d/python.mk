################################################################################
# Variables that can be overridden

PYTHON_VERSION ?= 3.8.3


################################################################################
PRINT_VERSION += print-version-python

.PHONY: print-version-python
print-version-python:
	@echo "Python: $(PYTHON_VERSION)"


################################################################################
SETUP += setup-pyenv setup-python setup-pipenv setup-python-modules

.PHONY: setup-pyenv
setup-pyenv:
	@echo
	if ! hash pyenv 1>/dev/null 2>&1; then \
		if [[ ! -d "${HOME}.pyenv" ]]; then git clone https://github.com/pyenv/pyenv.git ${HOME}/.pyenv; fi ;\
		echo 'export PYENV_ROOT="$${HOME}/.pyenv"' >> ${HOME}/.bashrc ;\
		echo 'export PATH="$${PYENV_ROOT}/bin:$${PATH}"' >> ${HOME}/.bashrc ;\
		echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$$(pyenv init --path)"\nfi'>> ${HOME}/.bashrc ;\
	fi


.PHONY: setup-python
setup-python: setup-pyenv
	@echo
	source ${HOME}/.bashrc ;\
	pyenv install --skip-existing $(shell cat .python-version) ;\
	pyenv rehash

.PHONY: setup-poetry
setup-poetry:
	@echo
	if ! hash poetry 1>/dev/null 2>&1; then \
		curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | python - ;\
	fi

.PHONY: setup-pipenv
setup-pipenv: setup-python
	@echo
	pip install -U pipenv

.PHONY: setup-python-modules
setup-python-modules: setup-pipenv
	@echo
	pipenv sync --dev


################################################################################
UPDATE += update-python update-python-modules

.PHONY: update-python
update-python:
	@echo
	sed -i 's/python:.*/python:$(PYTHON_VERSION)/g' .gitlab-ci.yml
	pyenv local $(PYTHON_VERSION)
	pipenv --python $(PYTHON_VERSION)

.PHONY: update-python-modules
update-python-modules: update-python
	@echo
	pipenv lock --dev
	pipenv sync --dev


################################################################################
FIXUP += fixup-python

.PHONY: fixup-python
fixup-python:
	@echo
	pipenv run isort --recursive
	pipenv run black .


################################################################################
LINT += lint-yaml lint-pipenv-check lint-black lint-flake8 lint-isort \
				lint-darglint lint-pydocstyle

.PHONY: lint-yaml
lint-yaml:
	@echo
	git grep -I --name-only --null -e '' \
		| grep -EzZ '.*\.ya?ml$$' \
		| xargs -r0 pipenv run yamllint -c "$(CURDIR)/.yamllint.yml"

.PHONY: lint-yaml-changed
lint-yaml-changed:
	@echo
	git diff --name-only --diff-filter=ACM -z origin/master..HEAD \
		| grep -EzZ '.*\.ya?ml$$' \
		| xargs -r0 pipenv run yamllint -c "$(CURDIR)/.yamllint.yml"

.PHONY: lint-pipenv-check
lint-pipenv-check:
	@echo
	xargs -r0 pipenv check

.PHONY: lint-black
lint-black:
	@echo
	git grep -I --name-only --null -e '' \
		| grep -EzZ '.*\.py$$' \
		| xargs -r0 pipenv run black --check --diff

.PHONY: lint-black-changed
lint-black-changed:
	@echo
	git diff --name-only --diff-filter=ACM -z origin/master..HEAD \
		| grep -EzZ '.*\.py$$' \
		| xargs -r0 pipenv run black --check --diff

.PHONY: lint-flake8
lint-flake8:
	@echo
	git grep -I --name-only --null -e '' \
		| grep -EzZ '.*\.py$$' \
		| xargs -r0 pipenv run flake8 --benchmark

.PHONY: lint-flake8-changed
lint-flake8-changed:
	@echo
	git diff --name-only --diff-filter=ACM -z origin/master..HEAD \
		| grep -EzZ '.*\.py$$' \
		| xargs -r0 pipenv run flake8 --benchmark

.PHONY: lint-isort
lint-isort:
	@echo
	pipenv run isort --diff --recursive --check-only

.PHONY: lint-isort-changed
lint-isort-changed:
	@echo
	git diff --name-only --diff-filter=ACM -z origin/master..HEAD \
		| grep -EzZ '.*\.py$$' \
		| xargs -r0 pipenv run isort --diff --check-only

.PHONY: lint-darglint
lint-darglint:
	@echo
	git grep -I --name-only --null -e '' \
		| grep -EzZ '.*\.py$$' \
		| xargs -r0 pipenv run darglint

.PHONY: lint-darglint-changed
lint-darglint-changed:
	@echo
	git diff --name-only --diff-filter=ACM -z origin/master..HEAD \
		| grep -EzZ '.*\.py$$' \
		| xargs -r0 pipenv run darglint

.PHONY: lint-pydocstyle
lint-pydocstyle:
	@echo
	git grep -I --name-only --null -e '' \
		| grep -EzZ '.*\.py$$' \
		| xargs -r0 pipenv run pydocstyle

.PHONY: lint-pydocstyle-changed
lint-pydocstyle-changed:
	@echo
	git diff --name-only --diff-filter=ACM -z origin/master..HEAD \
		| grep -EzZ '.*\.py$$' \
		| xargs -r0 pipenv run pydocstyle


################################################################################
UNIT_TEST += unit-pytest

.PHONY: unit-pytest
unit-pytest:
	@echo
	git diff --name-only --diff-filter=ACM -z origin/master..HEAD \
		| grep -EzZ '.*\.py$$' \
		| xargs -r0 pipenv run pytest
