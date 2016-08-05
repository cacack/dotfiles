if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then
	source /usr/local/share/chruby/chruby.sh
	source /usr/local/share/chruby/auto.sh

	chruby ruby-2.3
fi
