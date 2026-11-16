# Setup ZSH plugins
zinit light Aloxaf/fzf-tab
zinit snippet OMZP::aws

# Google Cloud SDK: point the gcloud snippet at mise's install (bin/gcloud -> SDK root)
(( $+commands[gcloud] )) && export CLOUDSDK_HOME="${commands[gcloud]:A:h:h}"
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

# CLI tools themselves are installed by mise (10_mise.zsh); init their shell hooks.
_cached_init fzf 'fzf --zsh' fzf
_cached_init zoxide 'zoxide init --cmd cd zsh' zoxide

# _cached_init is defined in 00_init.zsh; this file is its last user.
unset -f _cached_init
unset _zsh_init_cache_dir
