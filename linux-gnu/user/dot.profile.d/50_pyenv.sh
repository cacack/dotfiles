#!/usr/bin/env bash

if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then
  if [ -r ~/devel/others/pyenv ]; then
    export PYENV_ROOT="${HOME}/devel/others/pyenv"
    export PATH="${HOME}/devel/others/pyenv/bin:$PATH"
    if command -v pyenv 1>/dev/null 2>&1; then
      eval "$(pyenv init -)"
    fi
  fi
fi