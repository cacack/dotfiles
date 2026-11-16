# brew/mise/fzf/zoxide regenerate their init script by spawning their binary on
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

# Shell code pins: zinit, every plugin and the Oh My Zsh snippets run at these
# exact commits (a commit hash names its exact content). New installs check them
# out here and via ver"" in 10_plugins.zsh; `make update` moves existing ones to
# them (`zinit update` would follow the branch head instead). Renovate bumps
# them (renovate.json); each line's comment names the branch it tracks. Keep
# the "  owner/repo <sha>" line shape: .make.d/10_base.mk and renovate.json parse
# it, and `make test` checks every plugin load in 10_plugins.zsh names a pin.
typeset -A _zinit_pins=(
  # renovate: branch=main
  zdharma-continuum/zinit d7b10fcab51ea034aa7df5d241604b3e6bf46449
  # renovate: branch=master
  Aloxaf/fzf-tab 24105b15714bfec37989ed5c5b6e60f572253019
  # renovate: branch=master
  jeffreytse/zsh-vi-mode 91cafe4a09b6670cb8e761aa413e5f7b9e00816f
  # renovate: branch=master
  ohmyzsh/ohmyzsh c0140703a53eb0d22be44f7bac318d0baacc927c
  # renovate: branch=master
  zsh-users/zsh-autosuggestions 85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5
  # renovate: branch=master
  zsh-users/zsh-completions 989b23277ab33e8d5e82df6aed936e846db9d8b8
  # renovate: branch=master
  zsh-users/zsh-syntax-highlighting e6683f20e5c38d3e5447f45845d04ddda75d0f23
)

# Define zinit home directory
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
# Download Zinit at its pinned commit, if it's not there yet. Clone and check
# out in a scratch dir and only then move it into place, so an interrupted or
# failed checkout never leaves an unpinned zinit for later shells to source.
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   _zinit_tmp="$(mktemp -d)/zinit.git"
   if git clone -q https://github.com/zdharma-continuum/zinit.git "$_zinit_tmp" &&
      git -C "$_zinit_tmp" -c advice.detachedHead=false checkout -q "${_zinit_pins[zdharma-continuum/zinit]}"; then
      mv "$_zinit_tmp" "$ZINIT_HOME"
   else
      print -u2 "zinit: could not install the pinned commit; plugins will not load"
   fi
   unset _zinit_tmp
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
