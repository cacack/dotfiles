#!/usr/bin/env bash

CONF_FILE="${1}"
if [[ -f "${CONF_FILE}" ]]; then
  grep -EzZ '.*\.ya?ml$' \
    | xargs -r0 ansible-lint -c "${CONF_FILE}"
else
  grep -EzZ '.*\.ya?ml$' \
    | xargs -r0 ansible-lint
fi
