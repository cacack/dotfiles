#!/usr/bin/env bash

WORKING_DIR=$(dirname "${BASH_SOURCE[0]}")
GIT_ROOT_DIR=$(git rev-parse --show-toplevel)
CONF_FILE="${GIT_ROOT_DIR}/.yamllint.yml"

# Use git to generate a list of files (ignoring nested gits)
git grep -I --name-only -z -e '' \
  | "${WORKING_DIR}/helpers/pipe_to_yamllint.sh" "${CONF_FILE}"
