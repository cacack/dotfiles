#!/usr/bin/env bash

WORKING_DIR=$(dirname "${BASH_SOURCE[0]}")
GIT_DIR=$(git rev-parse --show-toplevel)
RELATIVE_GIT_DIR=$(realpath --relative-to="${PWD}" "${GIT_DIR}")
CONF_FILE="${GIT_ROOT_DIR}/.ansible-lint"

find "${RELATIVE_GIT_DIR}" -type f -print0 \
  | "${WORKING_DIR}/helpers/pipe_to_ansible_lint.sh" "${CONF_FILE}"
