#!/usr/bin/env bash

grep -EzZ '.*\.rb$' \
  | xargs -r0 rubocop
