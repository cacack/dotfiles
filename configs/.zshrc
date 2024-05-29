# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

eval "$(/usr/local/Homebrew/bin/brew shellenv)"

# Define zinit home directory
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source zinit
source "${ZINIT_HOME}/zinit.zsh"

# Load completions
autoload -Uz compinit && compinit


zinit ice depth=1; zinit light romkatv/powerlevel10k

# Setup ZSH plugins
zinit light Aloxaf/fzf-tab
zinit snippet OMZP::git
zinit snippet OMZP::aws

zinit ice depth=1; zinit light jeffreytse/zsh-vi-mode

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions


zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

bindkey '^p' history-search-backwards
bindkey '^n' histor-search-forward

HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

alias ls='lsd'

# Add some easy shortcuts for formatted directory listings and add a touch of color.
#alias ls='ls -F --color=auto'
alias ll='ls -l --git'
alias la='ls -a'
alias lla='la -l'
alias lx='ls -X'
alias llx='lx -l'
alias l='ls -1'

if (( $+commands[nvim.appimage] )); then
  alias vi='nvim.appimage'
  alias vim='nvim.appimage'
  alias nvim='nvim.appimage'
elif (( $+commands[nvim] )); then
  alias vi='nvim'
  alias vim='nvim'
else
  alias vi='vim'
fi

eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# Source in external configs.
for script in "${HOME}"/.zshrc.d/*; do
  # skip non-executable snippets
  [[ -x "${script}" ]] || continue
  # execute $script in the context of the current shell
  source "${script}"
done

# Source in external work configs if they exist
if [[ -d ${HOME}/.zshrc_work.d ]]; then
  for script in "${HOME}"/.zshrc_work.d/*; do
    # skip non-executable snippets
    [ -x "${script}" ] || continue
    # execute $script in the context of the current shell
    . "${script}"
  done
fi

# Source in external secrets configs if they exist
if [[ -d ${HOME}/.zshrc_secrets.d ]]; then
  for script in "${HOME}"/.zshrc_secrets.d/*; do
    # skip non-executable snippets
    [ -x "${script}" ] || continue
    # execute $script in the context of the current shell
    . "${script}"
  done
fi
