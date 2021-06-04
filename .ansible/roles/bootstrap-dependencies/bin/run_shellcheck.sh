#!/usr/bin/env bash

WORKING_DIR=$(dirname "${BASH_SOURCE[0]}")

# Use git to generate a list of files (ignoring nested gits)
git grep -I --name-only -z -e '' \
  | "${WORKING_DIR}/helpers/pipe_to_shellcheck.sh"
