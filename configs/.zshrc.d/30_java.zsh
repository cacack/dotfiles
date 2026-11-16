# Use Android Studio's bundled JDK (JBR) when no other JDK is configured.
_jbr="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
if [[ -z "$JAVA_HOME" && -d "$_jbr" ]]; then
  export JAVA_HOME="$_jbr"
fi
unset _jbr
