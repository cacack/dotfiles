# ~/.bashrc: executed by bash(1) for non-login shells.
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently non-interactive shells such as scp and rcp
# that can't tolerate any output. So make sure this doesn't display
# anything or bad things will happen !

# Test for an interactive shell. There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
[[ $- != *i* ]] && return

# Source system's global definitions
[ -f "/etc/bashrc" ] && source "/etc/bashrc"
[ -f "/etc/bash.bashrc" ] && source "/etc/bash.bashrc"


################################################################################
# Bash Options

#set -o vi                   # Vi mode
shopt -s autocd             # change to named directory
shopt -s cdable_vars        # if cd arg is not valid, assumes its a var defining a dir
shopt -s cdspell            # autocorrects cd misspellings
shopt -s checkjobs          # don't exit if there are backgroud jobs unless another exit is given
shopt -s checkwinsize       # update the value of LINES and COLUMNS after each command if altered
shopt -s cmdhist            # save multi-line commands in history as single line
shopt -s dotglob            # include dotfiles in pathname expansion
shopt -s expand_aliases     # expand aliases
shopt -s extglob            # enable extended pattern-matching features
shopt -s hostcomplete       # attempt hostname expansion when @ is at the beginning of a word
shopt -s nocaseglob         # pathname expansion will be treated as case-insensitive

# Fix term's to display more color.
[ $TERM == 'xterm' ] && export TERM=xterm-256color

# Source environment variables
if [ -z "$BASHRC_ENV_LOADED" ]; then
  export BASHRC_ENV_LOADED=true
  [ -f "$HOME/.bash_env" ] && source "$HOME/.bash_env"
  [ -f "$HOME/.bash_envlocal" ] && source "$HOME/.bash_envlocal"
fi


################################################################################
# LOOKS

AB='\['
AE='\]'
RESET=${AB}$(tput sgr0)${AE}
BOLD=${AB}$(tput bold)${AE}
DIM=${AB}$(tput dim)${AE}
BLACK=${AB}$(tput setaf 0)${AE}
RED=${AB}$(tput setaf 1)${AE}
GREEN=${AB}$(tput setaf 2)${AE}
YELLOW=${AB}$(tput setaf 3)${AE}
BLUE=${AB}$(tput setaf 4)${AE}
PURPLE=${AB}$(tput setaf 5)${AE}
CYAN=${AB}$(tput setaf 6)${AE}
WHITE=${AB}$(tput setaf 7)${AE}

# Set the PS1 prompt (with colors).
export PS1="${BOLD}${GREEN}\u${RESET}${GREEN}@${BOLD}\h${RESET}:${BOLD}${BLUE}\W${RESET}$ "

[ -f ~/.dir_colors ] &&  eval $(dircolors -b ~/.dir_colors)
 

################################################################################
# HISTORY

# Don't overwrite history
shopt -s histappend

# Remove previous dups from history.
export HISTCONTROL=erasedups

# Append commands to the history every time a prompt is shown,
# instead of after closing the session.
PROMPT_COMMAND='history -a'

# Give history timestamps.
export HISTTIMEFORMAT="[%F %T] "

# Enable lots of history.
export HISTSIZE=10000
export HISTFILESIZE=10000


################################################################################
# EDITOR / PAGER

# Pick the first available editor found.
export EDITOR=$(type vim vi nano pico 2>/dev/null | sed 's/ .*$//;q')
export VISUAL="$EDITOR"

# Perfer less with specific options.
if [[ $(which less) ]]; then
  PAGER="less -FwX"
  MANPAGER="$PAGER"
else
  PAGER="more"
  MANPAGER="$PAGER"
fi
export PAGER MANPAGER

################################################################################
# EXTERNALS

# Add bash aliases.
[ -f "$HOME/.bash_aliases" ] && source "$HOME/.bash_aliases"

# Enable programmable completion features.
if [ -f "/etc/bash_completion" ] && [ ! `shopt -oq posix` ]; then
    source "/etc/bash_completion"
fi

# Execute local differences
[ -f "$HOME/.bashrc_local" ] && source "$HOME/.bashrc_local"


################################################################################
# TMUX

# The last thing is to execute tmux
if [ -z $TMUX ] && [ $TERM != "screen*" ] && [ -z $SSH_TTY ] && [ ! -r "$HOME/.notmux" ]; then
  # Only automatically connect to the default tmux session once.
  if [[ ! `tmux list-clients -t default` ]]; then
    # I cannot get 'exec tmux ...' to work so fudge it by launching it regularly
    # then exiting afterwards.
    tmux -2 attach-session -t default || tmux -2 new-session -s default
    exit 0
  fi
fi
