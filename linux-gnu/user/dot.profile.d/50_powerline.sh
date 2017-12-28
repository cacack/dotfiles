#!/usr/bin/env bash
# shellcheck disable=SC1091

if [ -f "$(which powerline-daemon)" ]; then
  powerline-daemon -q
  export POWERLINE_BASH_CONTINUATION=1
  export POWERLINE_BASH_SELECT=1
  source /usr/share/powerline/bash/powerline.sh
fi
