#!/usr/bin/env bash

grep -EzZ '.*\.md$' \
  | xargs -r0 mdl
