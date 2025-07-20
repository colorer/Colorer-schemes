@echo off

rem path to java libs
set CLR_JL=javalib

set CLASSPATH=%CLR_JL%\commons-net-ftp-2.0.jar;%CLR_JL%\commons-net-2.0.jar;%CLR_JL%\resolver.jar;%CLR_JL%\saxon9.jar;%CLASSPATH%
ant %*
