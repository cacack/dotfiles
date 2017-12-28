#!/usr/bin/env bash

WORKING_DIR=$(dirname "${BASH_SOURCE[0]}")

git grep -I --name-only -z -e '' \
  | "${WORKING_DIR}/helpers/pipe_to_rubocop.sh"
