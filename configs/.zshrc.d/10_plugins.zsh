# fzf/zoxide/pyenv regenerate their init script by spawning their binary on
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

# Setup ZSH plugins
zinit light Aloxaf/fzf-tab
zinit snippet OMZP::aws

# Google Cloud SDK: set CLOUDSDK_HOME for Linux custom install path
if [[ -d "${HOME}/.local/opt/google-cloud-sdk" ]]; then
  export CLOUDSDK_HOME="${HOME}/.local/opt/google-cloud-sdk"
fi
zinit snippet OMZP::gcloud

ZVM_INIT_MODE=sourcing
zinit ice depth=1; zinit light jeffreytse/zsh-vi-mode

zinit light zsh-users/zsh-completions

# Turbo mode: load these after the first prompt is drawn (~30ms off startup).
# syntax-highlighting stays last so it wraps every other widget.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#555558"
zinit wait lucid light-mode for \
  OMZP::git \
  atload"_zsh_autosuggest_start" zsh-users/zsh-autosuggestions \
  zsh-users/zsh-syntax-highlighting

zinit ice from"gh-r" as"program"
zinit light junegunn/fzf
_cached_init fzf 'fzf --zsh' fzf

# eza: modern ls replacement (default)
# Note: On macOS, eza is installed via Homebrew (make setup-eza)
# GitHub releases only provide Linux binaries
if [[ "$(uname -s)" == "Linux" ]]; then
  zinit ice from"gh-r" as"program" bpick"*$(uname -m)*linux*.tar.gz" pick"bin/eza"
  zinit light eza-community/eza
fi

# lsd: backup ls replacement
zinit ice from"gh-r" as"program" mv"lsd-*/lsd -> lsd"
zinit light lsd-rs/lsd

zinit ice from"gh-r" as"program"
zinit light starship/starship

zinit ice from"gh-r" as"program"
zinit light ajeetdsouza/zoxide
_cached_init zoxide 'zoxide init --cmd cd zsh' zoxide

zinit ice from"gh-r" as"program" mv"ripgrep-*/rg -> rg"
zinit light BurntSushi/ripgrep

zinit ice from"gh-r" as"program" mv"fd-*/fd -> fd"
zinit light sharkdp/fd

# Pyenv
if [[ -d ${HOME}/.local/opt/pyenv ]]; then
  export PYENV_ROOT="${HOME}/.local/opt/pyenv"
  command -v pyenv >/dev/null || export PATH="${PYENV_ROOT}/bin:${PATH}"
  _cached_init pyenv 'pyenv init -' pyenv
fi

unset -f _cached_init
unset _zsh_init_cache_dir
