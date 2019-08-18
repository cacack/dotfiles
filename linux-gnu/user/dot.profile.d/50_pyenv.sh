#!/usr/bin/env bash

if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then
  if [ -r ~/.pyenv ]; then
    export PYENV_ROOT="${HOME}/.pyenv"
    export PATH="${HOME}/.pyenv/bin:$PATH"
    if command -v pyenv 1>/dev/null 2>&1; then
      eval "$(pyenv init -)"
    fi
  fi
fi
