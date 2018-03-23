#!/usr/bin/env bash
# Ansible managed

if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then
  if [ -r /usr/local/share/chruby/chruby.sh ]; then
    # shellcheck disable=SC1091
    source /usr/local/share/chruby/chruby.sh
    # shellcheck disable=SC1091
    source /usr/local/share/chruby/auto.sh
  fi
fi
