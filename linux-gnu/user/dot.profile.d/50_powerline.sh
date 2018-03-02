#!/usr/bin/env bash
# shellcheck disable=SC1091

if [ -f "$(which powerline-daemon)" ]; then
  powerline-daemon -q
  export POWERLINE_BASH_CONTINUATION=1
  export POWERLINE_BASH_SELECT=1
  [ -f /usr/share/powerline/bash/powerline.sh ] \
    && source /usr/share/powerline/bash/powerline.sh
  [ -f /usr/lib/python3.6/site-packages/powerline/bindings/bash/powerline.sh ] \
    && source /usr/lib/python3.6/site-packages/powerline/bindings/bash/powerline.sh
fi
