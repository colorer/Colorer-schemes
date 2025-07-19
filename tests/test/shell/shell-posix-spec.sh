#!/bin/sh

# ------------------------------------------------------------------------
# POSIX doc:

# 2.2 Quoting
\| \& \; \> \< \( \) \$ \` \\ \" \' no meaning
test for no meaning for new line \
    I_AM_NOT_VARIABLE=1 command \
    if doesn\'t work also

# 2.2.2 Single-Quotes
'single quote string' 'escape does not \work here'

# 2.2.3 Double-Quotes
double quoted "only these chars should be escaped \$, \`, \", \\, but \nothing \! else"

# 2.4 Reserved Words
! command
# Everything is marked as errors, except 'in'
do elif else
elif
elif VAR=1 some command here >&1
else
in
then
# the following words are in their blocks:
# case/esac if/fi for/done while/done until/done
#
# Special cases
#
# Only the first reserved word must be highlighted
do elif else
#

# 2.5.2 Special Parameters
$@ $* $# $? $- $$ $0
${@} ${*} ${#} ${?} ${-} ${$} ${0}

# 2.5.3 Shell Variables
$ENV $HOME $IFS $LANG $LC_ALL $LC_COLLATE $LC_TYPE $LC_MESSAGES
$LINENO $NLSPATH $PATH $PPID $PS1 $PS2 $PS4 $PWD

$PATH_SEPARATOR # <- this is not a shell variable

${ENV} ${HOME} ${IFS} ${LANG} ${LC_ALL} ${LC_COLLATE} ${LC_TYPE} ${LC_MESSAGES}
${LINENO} ${NLSPATH} ${PATH} ${PPID} ${PS1} ${PS2} ${PS4} ${PWD}

ENV=1 HOME=2 IFS=3 LANG=foo LC_ALL=bar LC_COLLATE=xxx LC_TYPE=1 LC_MESSAGES=2
LINENO=1 NLSPATH=bla PATH=11 PPID=r PS1=x PS2=+ PS4=e PWD=5

# 2.6.2 Parameter Expansion
${ASD-fo br}  ${ASD:-fo" br"} ${ASD='br bz'}       ${ASD:=br \{ bo}
${ASD?$VARH}  ${ASD:?"$QVAR"} ${ASD+$(V=1 cmd re)} ${ASD:+`V=1 a here`}
${1-foo bar}  ${1:-foo" bar"} ${1='bar baz'}       ${1:=bar \{ boo}
${1?$VARHERE} ${1:?"$QVAR"}   ${1+$(V=1 cmd here)} ${1:+`V=1 a here`}

${#ASD} ${#1}

${ASD%fo ba} ${ASD%%fo" br"} ${ASD#'bz bz'}     ${ASD##br \{ bo}
${1%$VARH}   ${1%%"$QVAR"}   ${1#$(V=1 cmd re)} ${1##`V=1 a here`}

$ASD $1

# Word break characters should not be considered as the end of
# the parameter extension.

${A%foo # bar}
${A%foo ; command}
${A%foo > command}
${A%foo ) command}
${A%foo ( command}
${A%foo & command}
${A%foo | command}

A=123 A="sdfasdf" A=$(V=1 command here 2>/dev/null) B=`cd asd`
A=123; cd test
A=1|B=2|topipe command
A=1;nextcmd
A=1>A=1 cmd here # <- 'A=1' is not a variable assignment, it is a file

# 2.6.3 Command Substitution
exec 1 $( { V=123 V2="sdsdf"; }; execute something 2>&1 1>/dev/null && X=1 echo 123 V=1)
exec 2 "$(V=123 V2="sdsdf" execute something 2>&1 1>/dev/null && X=1 echo 123 V=1)"
exec 3 `V=123 V2="sdsdf" execute something 2>&1 1>/dev/null && X=1 echo 123 V=1`
exec 4 "`V=123 V2="sdsdf" execute something 2>&1 1>/dev/null && X=1 echo 123 V=1`"

# nested (not implemented, TODO?)
exec 3 `V=123 V2="sdsdf" \`X=1 echo 123 V=1\` more params`
exec 4 "`V=123 V2="sdsdf" \`X=1 echo 123 V=1\` more params`"

# 2.6.4 Arithmetic Expansion
$(( X + B << 2 * 10 / 30 + $X - $1 % "123" ))
A=$(( X + B << 2 * 10 / 30 ))
A="$(( X + B << 2 * 10 / 30 ))"

# 2.7.1 Redirecting Input
foo < bla
foo 0< bla

# 2.7.2 Redirecting Output
foo > bla
foo 2>bla
foo 2>|bla

# 2.7.3 Appending Redirected Output
foo >> bla
foo 2>>bla

# 2.7.4 Here-Document
Non quoted here-doc 2<<BLA
If no part of word is ${quoted}, all lines of the here-document shall be
expanded for $parameter ${expansion}, `A=1 command` $(B=2 substitution >/dev/null),
and $((arithmetic expansion + 1 / 10)). In this case, the <backslash> in the input
behaves as the <backslash> inside double-quotes (see Double-Quotes).
( Here we are \$, \`, \", \\, but \nothing \! else )
However, the double-quote character ( ' )' shall not be treated specially
within a here-document, except when the double-quote appears
within "$()", "``", or "${}". (WTF?!)
BLA

Quoted here-doc <<-"FOO"
If any part of word is quoted, the delimiter shall be formed by performing
quote removal on word, and the here-document lines $shall not be $(expanded).
FOO

Single-quoted here-doc <<'FOO'
not $expanded
FOO

heredoc after redirection >foobar << BLA
with space before label
BLA

# 2.7.5 Duplicating an Input File Descriptor
1<&2 <&-

# 2.7.6 Duplicating an Output File Descriptor
1>&2 2>&-

# 2.7.7 Open File Descriptors for Reading and Writing
<>/blabla 1<> /blabla

# 2.9.1 Simple Commands / Command Search and Execution / builtin
# The command must be on the first place
alias foo=bla
bg alias cd
cd command A1=11
DEFINE_VAR=1 command
false
DEFINEVAR=2 command cd alias >/dev/null
DEFVAR=1 fc 1>&1
fg
getopts more parameters here
hash THIS_IS_PARAMETER_BUT_NOT_VARIABLE=1
jobs
kill
newgrp
pwd
read
true
umask
unalias
wait while do for in
#
# Special cases:
#
# Only the first buildin command must be highlighted
alias bg cd hash
# variables after buildin command must not be highlighted as are plain parameters
# however, variables after reserved words must be highlighted
alias VAR1=1
# reserved words must not be highlighted after builtin command
command while something; command

# 2.9.2 Pipelines
VAR1=1 foo bla | VAR=2 ! test cmd # exclamation mark is NOT highlighted

# 2.9.3 Lists
VAR1=1 foo bla && ! VAR=2 test cmd || VAR=3 command read # exclamation mark is highlighted
VAR=1 foo & && VAR=2 test cmd
R=1 date && V=1 who || VAR=1 ls; VAR=2 cat file
V=1 wc file > output & R=1 true
# Asynchronous Lists
V=1 background1 & V=2 background2
# Sequential Lists
V=1 command1; V=2 command2

# 2.9.4 Compound Commands
( V1=1 grouped command1; V=1 command2 )
(
   V1=1 command1 here
   V2=2 command2
   (
      V2= nested
      {
         V3=1 nested
      }
   )
)
( V1=1 command1
V2=2 command2 \) )

{ V1=1 group 1; V1= command2 here should be an error here because of the missing semicolon }
} # this one works
{ cmd1; cmd2; no error here; }
{
   cmd1
   V1=cmd1
   {
       nested
       \}
   }
}

if
fi # <- error here, there is no 'then'
then
fi # <- close the above 'if'

# The for Loop

for IFS in 1 2 3 # comment here
do
done

for IFS in $(V1=val command) 2 3; do command; done; # check special variable
for "IFS" in $(V1=val command) 2 3; do command; done; # check variable in quotes

for var in $VAR; do

done

for var in; error here do done
do
done

for var in; error here; do done

for var in; do done

for VAR in "BLA" "FOO" "BAR"; do; done

for VAR # comment here
do
done

for $(V1=val command here); do
   command
done

for VAR error here; do
done

for VAR; do
    command
    if [ -n "$FOO" ]; then
        something
    fi
done

for IFS; do command; done; # check special variable

for "IFS"; do command; done; # variable in quotes <- 'in' word must not activate the 'in' syntax for form
for "IFS"; do command; done; # variable _in quotes

# Case Conditional Construct

case $FOO in
a aaaaa    pat1) A=1 xdo; A=2 something  ;;
    pat2|fff\) BLA=123) B=2;;
    pat3)
        A=x cmd;;
    pat4)
        B=1 cmd
        C=3 cmd1
        if [ -x "$BLA" ]; then
           ffff
           case $BLA in
              fff) F=1;;
              bla) no the last ";;" here
           esac
        fi
        ;;
here pat) T=1 ttt;;
    $VAR_HERE) cmd;;
    $(V1=1 some command here)) cmd2;;
    *) bla
        fooo
        ;;
esac

# The if Conditional Construct

if foo; then
   C=1 cmd here 2>/dev/null
fi

if [ $BLABLA -gt 1 ]; then VAR=HERE cd blalbla; fi

if [ -x "$N" ]; then
    alias skdfjlkj
elif V=1 some command here; then
    V1=1 anything here
    blalba
elif [ -t -o 1 -x ]; then
    X=1 ffff
else
    command here
fi

if [ $BLABLA != "123" ]; then
    X=1 somecmd sfasfasd sfsfasdf afa sdf sdf;
    if foo; then
       cd sdfkjkjfkj
    fi
fi

if V=1 command here
then
   V1=2 we do something
   if nested; then
      nothing to do
   fi
fi

# The while Loop

while true; do
   something
done

while [ -x "$BLA" ]; do something here; done
while [ -x "FOO" ]; do while bla; do nothing; done; done

while x 2>&1; do
   while nested; do
      nothing
   done
done

# The until Loop

until true; do
   something
done

until [ -x "$BLA" ]; do something here; done

until x 2>&1; do
   while nested; do
      until [ -x nested ]; do
         nothing
      done
   done
done

# 2.9.5 Function Definition Command

somefn() sfkjskdfj;
no fn here

somefn () {
   still fn
   bla
   fnd2() {
      another fn
   }
}

somefn()

errorfn() { blalbla }
close the curved bracket from above; }

func(  ) cmd function with space between brackets
func    (  ) cmd function with space between brackets#2

# 2.14. Special Built-In Utilities

# NAME
#     break - exit from for, while, or until loop
# SYNOPSIS
#     break [n]

break
break; break; break
break 10
break "$VAR"; break '123'
break a10 # <- errors here
break; break 10; break error here; break 1; # the last is ok
break error here
break; # this is ok
break $SOMEVAR but error here
break $(V=1 eval something here) but error here

# NAME
#    colon - null utility
# SYNOPSIS
#    : [argument...]

:
: highlight only $VAR here and $(V=1 evaluations)

# NAME
#     continue - continue for, while, or until loop
# SYNOPSIS
#     continue [n]

continue
continue; continue; continue 10 20 # second parameter is an error
continue 10
continue a10 # <- errors here
continue; continue 10; continue error here; continue 1; # the last is ok
continue error here
continue; # this is ok
continue $SOMEVAR but error here
continue $(V=1 eval something here) but error here

# NAME
#     dot - execute commands in the current environment
# SYNOPSIS
#     . file

. file; . tttt
. file 2>/dev/null error here;
. file; . file $VAR error here; command next here
. file; . file error here # comment here

# NAME
#     eval - construct command by concatenating arguments
# SYNOPSIS
#     eval [argument...]

eval "something" 2>/dev/null
eval "something"
eval "one" "two" $(V1=1 cmd3 >/dev/null)
eval; V=1 another command here
eval   ; V=1 another command here
eval # comment here

# NAME
#     exec - execute commands and open, close, or copy file descriptors
# SYNOPSIS
#     exec [command [argument...]]

exec command is not highlighted as buildin 1>/dev/null
exec; V1=1 command here
exec  ; V1=1 command here too
exec 3< readfile
exec 4> writefile
exec 5<&0
exec 3<&-
foo=bar exec cmd

# NAME
#     exit - cause the shell to exit
# SYNOPSIS
#    exit [n]

exit
exit; exit; exit
exit 10
exit a10 # <- errors here
exit; exit 10; exit error here; exit 1; # the last is ok
exit error here
exit; # this is ok
exit $SOMEVAR but error here
exit $(V=1 eval something here) but error here

# NAME
#     export - set the export attribute for variables
# SYNOPSIS
#     export name[=word]...
#     export -p

export ; export VAR FOO BLA=1 PATH $IFS PATH=123 -wrong variable name
export X="fff" R="$(V=1 cmd here)" $VAR_ALSO 'quoted' 1wrong variable name
export -p; export only; #comment here
export -p a # <- error here
export -p  error here; export VAR one two
export X=$(false)

# NAME
#     readonly - set the readonly attribute for variables
# SYNOPSIS
#     readonly name[=word]...
#     readonly -p

readonly
readonly 1>/a123 FFF # <- error here
readonly DFF 1>/b123
readonly; readonly VAR FOO BLA=1 PATH $IFS PATH=123 -wrong variable name
readonly X="fff" R="$(V=1 cmd here)" $VAR_ALSO 'quoted' 1wrong variable name
readonly -p; readonly only; #comment here
readonly -p a # comment here
readonly -p  error here; readonly VAR one two
readonly X=$(false)

# NAME
#     return - return from a function or dot script
# SYNOPSIS
#     return [n]

return
return 2>/dev/null error here
return 10 2>/dev/null error here
return; return; return
return 10
return a10 <- errors here
return; return 10; return error here; return 1; # the last is ok
return error here
return; # this is ok
return $SOMEVAR but error here
return $(V=1 eval something here) but error here

# NAME
#     set - set or unset options and positional parameters
# SYNOPSIS
#     set [-abCefhmnuvx] [-o option] [argument...]
#     set [+abCefhmnuvx] [+o option] [argument...]
#     set -- [argument...]
#     set -o
#     set +o

set
set; set +a 1>/dev/null
set -o option $(cmd here); set -- "$VAR"
set -o
set +o

# NAME
#     shift - shift positional parameters
# SYNOPSIS
#     shift [n]

shift
shift 2>/dev/null error here
shift; shift; shift
shift 10
shift a10 <- errors here
shift; shift 10; shift error here; shift 1; # the last is ok
shift error here
shift; # this is ok
shift $SOMEVAR but error here
shift $(V=1 eval something here) but error here

# NAME
#     times - write process times
# SYNOPSIS
#     times

times; times error here; #comment here
times aaa # comment here
times error here; times 2>/dev/null sdfsdfasf

# NAME
#     trap - trap signals
# SYNOPSIS
#     trap n [condition...]
#     trap [action condition...]

trap 1 SIG1 SIG2 $SIG_AS_VARIABLE $(command here)
trap "some sction" SIG1 SIG2 2>/dev/null; V=1 the next command here
trap 1 1>/dev/null

# NAME
#     unset - unset values and attributes of variables and functions
# SYNOPSIS
#     unset [-fv] name...

unset -x; #<- error here
unset;
unset -f; unset -v; unset -fv; unset -vf
unset -f VAR VAR2; unset -v VAR VAR2; unset -vf VAR VAR ERR_HERE=1
unset VAR VAR2 IFS VAR3 $(V=1 cmd here) "quote" 'single' 2>/dev/null
unset VAR=234 FFFgger; # <- error here, no assignments

# 4. Utilities

# Special cases

test -x /some/file -o -n "$BLABLA" && test -n "$VAR"

batch; batch error hereas; batch $(AGAIN ERROR) fasdf # comment here

false; false error here; #comment

true; true error here; #comment

logname; logname error here; #comment

sleep; sleep 10; sleep $VAR; sleep a10 # <- error here

tty; tty error here; #comment

dirname; dirname $A; dirname test error here ;# comment
dirname $VAR error here; dirname foo

uname; uname -a; #comment here
uname -a error here

# Common cases

alias;
alias name; alias name='string' # comment here
alias name=$FOO; # comment here
ar -x; ar -r; #comment here
ar
ar; ar -p
at -l -1 bla; at; at -m '10' $(V1=1 cmd run)
awk; awk -F bla; awk $(TE=1 cmd) # comment here
basename; basename bla; basename $(TE=1 cmd) # comment here
bc; bc -l; bc foo $(V1=1 cmd) $VAR_HERE; # comment
bg; bg $ID; #comment here
cal 1 2020; cal; cal 1 $(C1=1 cmd here); #comment
cat; cat -u; cat /some/file; cat $FROM_VAR; # comment
cd -; cd /foo/bar; cd -L; # comment
chgrp; chgrp -h ${GROUP} /some/file; # comment
chmod; chmod -R 0666 /some/file; chmod -R; # comment
chown; chown -h root:root /some/file; chown -R; # comment
cksum; cksum /file; cksum ${VAR}; # comment
cmp; cmp -l; cmp file1 file2; # comment
comm; comm -1 file1 file2; comm $(V=1 cmd here); # comment
command some command here; command cd $FOO; #comment
compress; compress -c file; #comment
cp; cp a b; #comment
crontab; crontab file; #comment
csplit; csplit -k file; #comment
cut; cut -d1 -f; #comment
date; date +Z; # comment
dd; dd if=bla; #comment
df; df -m; # comment
diff; diff -r ba br; #comment
du; du foo; # comment
echo; echo "$SOMETHING"; #comment here
ed; ed bbbb; # comment
env; env foo; #comment
ex; ex file; #comment
expand; expand foo; #comment
expr; expr $A + 1; #comment
fc; fc -l; #comment here
fg; fg $ID; #comment here
file; file /dev/$FILE; #comment
find; find -x $XXX; #comment
fold; fold -bs /some/file; #comment
fuser; fuser -c /some/file; #comment
getconf; getconf $VAR; #comment
getopts; getopts "$VAR"; #comment
grep; grep blalba $VAR; #comment
hash; hash $FOO; #comment
head; head -n 1; head /file/$VAR; #comment
iconv; iconv -f bla -t foo; #comment
id; id -a; id $USER; #comment
ipcrm; ipcrm -q $ID; #comment
ipcs; ipcs -q $VAR; #comment
jobs; jobs -l; #comment
join; join -a $VAR; #comment
kill; kill -9 #ID; #comment
link; link file $VAR; #comment
ln; ln -s /ffff $VAR; #comment
locale; locale -a $VAR; #comment
localedef; localedef -a; #comment
logger; logger -a; #comment
ls; ls -a /foo; #comment here
mailx; mailx $FOO; #comment here
make; make -f makefile; # comment here
man; man foo; #comment here
mesg; mesg --option; #comment here
mkdir; mkdir -p; #comment here
mkfifo; mkfifo $FOO; #comment here
more; more $FOO; #comment here
mv; mv -f foo bla; #comment here
newgrp; newgrp -n $VAR; #comment here
nice; nice -c 1; #comment here
nl; nl $FOO; # comment here
nm; nm $FOO; #comment here
nohup; nohup test; #comment here
od; od $FOO; # comment here
paste; paste /from/file; #comment here
patch; patch -p0 /patch/file; #comment here
pathchk; pathchk $FOO; #comment here
pr; pr $FOO; #comment here
printf; printf -v BLA 'STRING'; #comment here
ps; ps -a; #comment here
pwd; pwd -L; #comment here
read; read -r VAR; #comment here
renice; renice -a; #comment here
rm; rm -rf; #comment here
rmdir; rmdir /test; #comment here
sed; sed -i $VAR; #comment here
sh; sh -c $FOO; #comment here
sort; sort $FOO; #comment here
split; split $FOO; #comment here
strings; strings /some/file; #comment here
strip; strip $FOO; #comment here
stty; stty -a; #comment here
tabs; tabs -t; #comment here
tail; tail -f /foo; #comment here
tee; tee /foo/bar; #comment here
time; time -a $VAR; #comment here
touch; touch $FOO; #comment here
tput; tput $FOO; #comment here
tr; tr 'ff' 'bbb'; #comment here
tsort; tsort $FILE; #comment here
type; type -p; #comment here
ulimit; ulimit -t; #comment here
umask; umask 0444; #comment here
unalias; unalias -a; #comment here
uncompress; uncompress $FOO; #comment here
unexpand; unexpand $FOO; #comment here
uniq; uniq --help; #comment here
unlink; unlink $FILE; #comment here
vi; vi $FILE; #comment here
wait; wait $PID1 $PID2; #comment here
wc; wc -l; wc $FILE; #comment here
who; who -a; who am i; #comment here
write; write $TEST; #comment here
xargs; xargs $FOO $BLA; #comment here
zcat; zcat $FILE; #comment here

# The usual chunks of code from:
# https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html

a=1
set 2
echo ${a}b-$ab-${1}0-${10}-$10

foo=asdf
echo ${foo-bar}xyz}

${x:-$(ls)}

unset X
echo ${X:=abc}

unset posix
echo ${posix:?}

set a b c
echo ${3:+posix}

HOME=/usr/posix
echo ${#HOME}

x=file.c
echo ${x%.c}.o

x=posix/src/std
echo ${x%%/*}

x=$HOME/src/cmd
echo ${x#$HOME}

x=/one/two/three
echo ${x##*/}

"${x#*}"

${x#"*"}

# repeat a command 100 times
x=100
while [ $x -gt 0 ]
do
    command
    x=$(($x-1))
done

# nested heredocs are not supported
#cat <<eof1; cat <<eof2
cat <<eof1 > /some/file
Hi,
eof1
Helene.
eof2

false && echo foo || echo bar
true || echo foo && echo bar

while
    # a couple of <newline>s


    # a list
    date && who || ls; cat file
    # a couple of <newline>s


    # another list
    wc file > output & true


do
    # 2 lists
    ls
    cat file
done

for i in *
do
    if test -d "$i"
    then break
    fi
done

foo() {
    for j in 1 2; do
        echo 'break 2' >/tmp/do_break
        echo "  sourcing /tmp/do_break ($j)..."
        # the behavior of the break from running the following command
        # results in unspecified behavior:
        . /tmp/do_break


        do_continue() { continue 2; }
        echo "  running do_continue ($j)..."
        # the behavior of the continue in the following function call
        # results in unspecified behavior (if execution reaches this
        # point):
        do_continue


        trap 'continue 2' USR1
        echo "  sending SIGUSR1 to self ($j)..."
        # the behavior of the continue in the trap invoked from the
        # following signal results in unspecified behavior (if
        # execution reaches this point):
        kill -s USR1 $$
        sleep 1
    done
}
for i in 1 2; do
    echo "running foo ($i)..."
    foo
done

: ${X=abc}
if     false
then   :
else   echo $X
fi

x=y : > z

for i in *
do
    if test -d "$i"
    then continue
    fi
    printf '"%s" is not a directory.\n' "$i"
done

cat foobar
. ./foobar
echo $foo $ba

eval " $commands"
eval " $(some_command)"
foo=10 x=foo
y='$'$x
echo $y
eval y='$'$x
echo $y

exec 3< readfile
exec 4> writefile
exec 5<&0
exec 3<&-
exec cat maggie
foo=bar exec cmd

exit 0
exit 1
(
    command1 || exit 1
    command2 || exit 1
    exec command3
) > outputfile || exit 1
echo "outputfile created successfully"

export X=$(false)
X=$(false)
export X

export PWD HOME
export PATH=/local/bin:$PATH
export -p > temp-file
unset a lot of variables

set -e
start() {
    some_server
    echo some_server started successfully
}
start || echo >&2 some_server failed
set
set c a b
set -xv
set --
set -- "$x"
set -- $x
set -- "$@"

trap "jobs -n" CLD

set a b c d e
shift 2
echo $*

save_traps=$(trap)
eval "$save_traps"

trap '"$HOME"/logout' EXIT
trap '"$HOME"/logout' 0
trap - INT QUIT TERM EXIT

trap 'read foo; echo "-$foo-"' 0
trap 'eval " $cmd"' 0
trap " $cmd" 0
