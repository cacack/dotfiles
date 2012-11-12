# Originally from http://people.redhat.com/rkeech/colorprompt.sh
#------------------------------------------------------------------------
# ISO 6429 character sequences for colors etc
# lc = leading character sequence, common for all colors.
lc='\[\e[1;'
# tc = trailing character sequence
tc='\]'
# foregrounds----backgrounds--------------------------------------------------
BLACK=${lc}30m${tc};  B_BLACK=${lc}40m${tc}
RED=${lc}31m${tc};    B_RED=${lc}41m${tc}
GREEN=${lc}32m${tc};  B_GREEN=${lc}42m${tc}
YELLOW=${lc}33m${tc}; B_YELLOW=${lc}43m${tc}
BLUE=${lc}34m${tc};   B_BLUE=${lc}44m${tc}
PURPLE=${lc}35m${tc}; B_PURPLE=${lc}45m${tc}
CYAN=${lc}36m${tc};   B_CYAN=${lc}46m${tc}
WHITE=${lc}37m${tc};  B_WHITE=${lc}47m${tc}
#------------------------------------------------------------------
BRIGHT=${lc}1m${tc}
UNDER=${lc}4m${tc}
FLASH=${lc}5m${tc}
RC=${lc}0m${tc}  # reset character
SEP="\\\$"  # separator
#------------------------------------------------------------------------
if [ "x${LOGNAME}" = "x" ]
then
  LOGNAME=$(whoami)
fi

# set pc, the prompt color
if [ "$USER" = "root" ]
then
  pc=$RED; dir=$BLUE
else
  pc=$GREEN; dir=$BLUE
fi
#------------------------------------------------------------------------

# set the prompt
if [ $TERM  = "dumb" ]
then
  # no color if a dumb terminal
  pc=""; dir=""; RC=""
fi

PS1="${pc}\u@\h${RC}:${dir}\W${RC}\\$ ${RC}"
#PS1="${pc}\]\u@\h \W\\$ ${RC}\]"
#PS1="${pc}\][\u@\h \w]$SEP${RC} "
#------------------------------------------------------------------------

