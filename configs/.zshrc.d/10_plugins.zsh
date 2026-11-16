# Setup ZSH plugins, each at its pinned commit (_zinit_pins in 00_init.zsh).
# Oh My Zsh snippets load from that commit's raw files rather than OMZP::,
# which always fetches master.
_omz="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/${_zinit_pins[ohmyzsh/ohmyzsh]}/plugins"

zinit ice ver"${_zinit_pins[Aloxaf/fzf-tab]}"; zinit light Aloxaf/fzf-tab
zinit snippet "${_omz}/aws/aws.plugin.zsh"

# Google Cloud SDK: point the gcloud snippet at mise's install (bin/gcloud -> SDK root)
(( $+commands[gcloud] )) && export CLOUDSDK_HOME="${commands[gcloud]:A:h:h}"
zinit snippet "${_omz}/gcloud/gcloud.plugin.zsh"

ZVM_INIT_MODE=sourcing
zinit ice ver"${_zinit_pins[jeffreytse/zsh-vi-mode]}"; zinit light jeffreytse/zsh-vi-mode

zinit ice ver"${_zinit_pins[zsh-users/zsh-completions]}"; zinit light zsh-users/zsh-completions

# Turbo mode: load these after the first prompt is drawn (~30ms off startup).
# syntax-highlighting stays last so it wraps every other widget.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#555558"
zinit wait lucid light-mode for \
  "${_omz}/git/git.plugin.zsh" \
  ver"${_zinit_pins[zsh-users/zsh-autosuggestions]}" atload"_zsh_autosuggest_start" zsh-users/zsh-autosuggestions \
  ver"${_zinit_pins[zsh-users/zsh-syntax-highlighting]}" zsh-users/zsh-syntax-highlighting
unset _omz _zinit_pins

# CLI tools themselves are installed by mise (10_mise.zsh); init their shell hooks.
_cached_init fzf 'fzf --zsh' fzf
_cached_init zoxide 'zoxide init --cmd cd zsh' zoxide

# _cached_init is defined in 00_init.zsh; this file is its last user.
unset -f _cached_init
unset _zsh_init_cache_dir
