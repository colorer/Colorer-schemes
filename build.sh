
# rem path to java libs
export CLR_JL=./javalib

export CLASSPATH=$CLR_JL/commons-net-ftp-2.0.jar:$CLR_JL/commons-net-2.0.jar:$CLR_JL/resolver.jar:$CLR_JL/saxon9.jar:$CLASSPATH

echo $CLASSPATH
ant $*
