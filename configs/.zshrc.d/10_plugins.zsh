zinit ice depth=1; zinit light romkatv/powerlevel10k

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

zinit ice from"gh-r" as"program" mv"lsd-*/lsd -> lsd"
zinit light lsd-rs/lsd

zinit ice from"gh-r" as"program"
zinit light ajeetdsouza/zoxide

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


source <(fzf --zsh)
eval "$(zoxide init --cmd cd zsh)"

