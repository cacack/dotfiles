#!/usr/bin/env bash

GIT_DIR=$(git rev-parse --show-toplevel)
RELATIVE_GIT_DIR=$(realpath --relative-to="${PWD}" "${GIT_DIR}")

output=$(LC_ALL=C find "${RELATIVE_GIT_DIR}" -name '*[![:print:]]*' | cat )
if [[ "${output}" != "" ]]; then
  echo "${output}"
  exit 1
fi

exit 0
