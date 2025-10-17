# Prefer eza, fallback to lsd, then default ls
if (( $+commands[eza] )); then
  alias ls='eza'
elif (( $+commands[lsd] )); then
  alias ls='lsd'
fi

# Add some easy shortcuts for formatted directory listings and add a touch of color.
#alias ls='ls -F --color=auto'
alias ll='ls -l --git'
alias la='ls -a'
alias lla='la -l'
alias lx='ls --sort=extension'
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

# Disable built in time command and use OS time binary
disable -r time
alias time='time -p'

# Claude Code wrapper to avoid zoxide cd alias conflicts
# See: https://github.com/anthropics/claude-code/issues/2407
claude() {
  SHELL=/bin/bash command claude "$@"
}

alias n='noted'
alias ne='noted edit'
