# zinit ice from"gh-r" as"program" mv"posh-* -> oh-my-posh"
# zinit light JanDeDobbeleer/oh-my-posh

# Setup ZSH plugins
zinit light Aloxaf/fzf-tab
zinit snippet OMZP::git
zinit snippet OMZP::aws

ZVM_INIT_MODE=sourcing
zinit ice depth=1; zinit light jeffreytse/zsh-vi-mode

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#555558"

zinit ice from"gh-r" as"program"
zinit light junegunn/fzf
source <(fzf --zsh)

# eza: installed via Homebrew (see .make.d/eza.mk)

# lsd: zinit on all platforms
zinit ice from"gh-r" as"program" mv"lsd-*/lsd -> lsd"
zinit light lsd-rs/lsd

zinit ice from"gh-r" as"program"
zinit light starship/starship

zinit ice from"gh-r" as"program"
zinit light ajeetdsouza/zoxide
source <(zoxide init --cmd cd zsh)

zinit ice from"gh-r" as"program" mv"ripgrep-*/rg -> rg"
zinit light BurntSushi/ripgrep

zinit ice from"gh-r" as"program" mv"fd-*/fd -> fd"
zinit light sharkdp/fd

# Pyenv
if [[ -d ${HOME}/.local/opt/pyenv ]]; then
  export PYENV_ROOT="${HOME}/.local/opt/pyenv"
  command -v pyenv >/dev/null || export PATH="${PYENV_ROOT}/bin:${PATH}"
  source <(pyenv init -)
fi
