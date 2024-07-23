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

zinit ice from"gh-r" as"program"
zinit light junegunn/fzf
source <(fzf --zsh)

zinit ice from"gh-r" as"program" mv"lsd-*/lsd -> lsd"
zinit light lsd-rs/lsd

zinit ice from"gh-r" as"program"
zinit light starship/starship

zinit ice from"gh-r" as"program"
zinit light ajeetdsouza/zoxide
source <(zoxide init --cmd cd zsh)

# Pyenv
export PYENV_ROOT="${HOME}/.local/opt/pyenv"
command -v pyenv >/dev/null || export PATH="${PYENV_ROOT}/bin:${PATH}"
source <(pyenv init -)
