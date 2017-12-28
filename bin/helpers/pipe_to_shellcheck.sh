#!/usr/bin/env bash

grep -EzZ '.*\.sh$' \
  | xargs -r0 shellcheck -x
