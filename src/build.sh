
# rem path to java libs
CLR_JL="$( dirname "$( readlink -f "$0" )" )/javalib"
export CLR_JL

CLASSPATH="$CLR_JL/commons-net-ftp-2.0.jar:$CLR_JL/commons-net-2.0.jar:$CLR_JL/resolver.jar:$CLR_JL/saxon9.jar${CLASSPATH+:}$CLASSPATH"
export CLASSPATH

echo "$CLASSPATH"
ant "$@"
