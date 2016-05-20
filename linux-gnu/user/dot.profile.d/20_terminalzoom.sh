zi() {
	CONFIG=~/.config/xfce4/terminal/terminalrc
	SIZE=`grep 'FontName' $CONFIG | awk '{print $NF}'`
	NEWSIZE=$((SIZE + 2))
	## echo "old size $SIZE, new size $NEWSIZE"
	REGEXPR='s/FontName\(.*\)'$SIZE'$/FontName\1'$NEWSIZE'/g'
	sed -i "$REGEXPR" $CONFIG
}
zo() {
	CONFIG=~/.config/xfce4/terminal/terminalrc
	SIZE=`grep 'FontName' $CONFIG | awk '{print $NF}'`
	NEWSIZE=$((SIZE - 2))
	## echo "old size $SIZE, new size $NEWSIZE"
	REGEXPR='s/FontName\(.*\)'$SIZE'$/FontName\1'$NEWSIZE'/g'
	sed -i "$REGEXPR" $CONFIG
}
zrs() {
	CONFIG=~/.config/xfce4/terminal/terminalrc
	SIZE=$(grep 'FontName' $CONFIG | awk '{print $NF}')
	NEWSIZE=8
	## echo "old size $SIZE, new size $NEWSIZE"
	REGEXPR='s/FontName\(.*\)'$SIZE'$/FontName\1'$NEWSIZE'/g'
	sed -i "$REGEXPR" $CONFIG
}
