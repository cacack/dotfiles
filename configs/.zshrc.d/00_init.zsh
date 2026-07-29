if [ Darwin = `uname` ]; then
  if [ -d /usr/local/Homebrew ]; then
    eval "$(/usr/local/Homebrew/bin/brew shellenv)"
  elif [ -d ${HOME}/.local/opt/homebrew ]; then
    eval "$(${HOME}/.local/opt/homebrew/bin/brew shellenv)"
    # Custom prefix (~/.local) forces source builds for non-relocatable
    # formulae (python, gcc). Those apply patches that only resolve against a
    # real tap repo, not the JSON API, so use the locally-tapped homebrew/core.
    export HOMEBREW_NO_INSTALL_FROM_API=1
  fi
fi

# Define zinit home directory
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source zinit
source "${ZINIT_HOME}/zinit.zsh"

# Load completions. The full compinit security scan (stat'ing every file on
# fpath) is slow enough to notice on every shell start, so only pay for it
# once a day; otherwise trust the existing dump via `-C`.
autoload -Uz compinit
_zcompdump="${HOME}/.zcompdump"
if [[ -n ${_zcompdump}(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
unset _zcompdump

zinit cdreplay -q
