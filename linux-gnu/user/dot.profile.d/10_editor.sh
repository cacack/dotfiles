#!/usr/bin/env bash

# Set the default editor to vim.
if [ -x "$(command -v vim)" ]; then
  export EDITOR=vim
elif [ -x "$(command -v vi)" ]; then
  export EDITOR=vi
fi
export VISUAL=$EDITOR
