# brew/fzf/zoxide/pyenv regenerate their init script by spawning their binary on
# every shell start. Cache the generated script instead and only regenerate
# when missing or the binary itself has been updated.
_zsh_init_cache_dir="${XDG_CACHE_HOME:-${HOME}/.cache}/zsh-init"
mkdir -p "$_zsh_init_cache_dir"
_cached_init() {
  local name="$1" cmd="$2" bin="$3"
  local cache_file="${_zsh_init_cache_dir}/${name}.zsh"
  local bin_path="$(command -v "$bin")"
  if [[ ! -s "$cache_file" || ( -n "$bin_path" && "$cache_file" -ot "$bin_path" ) ]]; then
    eval "$cmd" >| "$cache_file"
  fi
  source "$cache_file"
}

if [[ $OSTYPE == darwin* ]]; then
  if [ -d /opt/homebrew ]; then
    _cached_init brew '/opt/homebrew/bin/brew shellenv' /opt/homebrew/bin/brew
  elif [ -d /usr/local/Homebrew ]; then
    _cached_init brew '/usr/local/Homebrew/bin/brew shellenv' /usr/local/Homebrew/bin/brew
  elif [ -d ${HOME}/.local/opt/homebrew ]; then
    _cached_init brew '${HOME}/.local/opt/homebrew/bin/brew shellenv' ${HOME}/.local/opt/homebrew/bin/brew
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
# once a day; otherwise trust the existing dump via `-C`. compinit leaves an
# unchanged dump untouched, so touch it to restart the 24h window.
autoload -Uz compinit
_zcompdump="${HOME}/.zcompdump"
_zcompdump_stale=( ${_zcompdump}(N.mh+24) )  # glob: [[ ]] never expands one
if (( ${#_zcompdump_stale} )); then
  compinit && touch "$_zcompdump"
else
  compinit -C
fi
unset _zcompdump _zcompdump_stale

zinit cdreplay -q
