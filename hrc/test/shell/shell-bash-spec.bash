#!/usr/bin/env bash

# 3.1.2.4 ANSI-C Quoting

$'\nfoo\e'
A=$'\\\'\"\?no special meaning'
CDPATH=$'octal \1 \12 \123 foo' $'octal error \9 \19 \181 foo'
command ${CDPATH%$'test\rtest'} `in backquote $'test\1test'`
( in subshell $'\1' )
{ in group $'1'; }
command $'hex \x1 \x1a \xFFnospecial meaning'
A=$(foo $'unicode \u1 \uF1 \uFFA \udeadno special meaning')
$'unicode \U1 \UF1 \UFFA \Udead \UDEAD1 \U12345 \U123456 \U1234567 \U12345678no special meaning'
$'control-x \cx no cpecial meaning'

# 3.1.2.5 Locale-Specific Translation

$"some message"
A=$"some message $VAR inside"
CDPATH=$"msg $'ansi-c\\here\r'"
command ${CDPATH%$"msg $(command)"}
( in subshell $"msg" )
{ in group $"msg"; }
A=$(foo $"something $'ansi-c\t\\' ${CDPATH#$"msg"}") `in bq $"some\$th\\i\ng"`

# 3.2.5.1 Looping Constructs
# for (( expr1 ; expr2 ; expr3 )) ; do commands ; done

for (( i = 0; $i < $VAR; i++ )); do
   cmd
done

for (( i = 0; i < $VAR; i++ )); do
   cmd
done

for (( i = 0; $i < '$NO_VAR'; i = $i + $'ansi-c' ))
do
   cmd
done

for (( i = "123"; $i < ${CDPATH}; i = $i / 100 )); do V1=456 command here; done
for ((;;)); do V1=456 command here; done

# 3.2.5.2 Conditional Constructs

# select

select var in $VAR; do

done

select var in; do done

select VAR in "BLA" "FOO" "BAR"; do; done

select VAR; do
    command
    if [ -n "$FOO" ]; then
        something
        select VAR; do
        done
    fi
    select VAR; do
        select VAR; do
        done
    done
done

select IFS in; do done # POSIX special variable
select CDPATH in; do done # Bash special variable

( select VAR; do done )
{ select VAR; do done; }


# (( ... ))

(( "asd" '123' $'\r\t123' $"foo" 1 )) # test strings / numbers
(( $(V1=1 command) `command` )) # evaluations
(( \$ \" \' \$ )) # escapes
(( $VAR $IFS $CDPATH )) # variables
(( ${VAR%10} ${IFS#10} ${CDPATH%10} )) # parameter expansion
(( i++ i-- ++IFS --CDPATH )) # increment / decrement
(( 1 + 1 - 2 ! 1 ~ 3 ** 3 * 4 / 5 % -6 >> 10 << 20 )) # operations
(( 1 <= 2 >= 4 < 1 > 4 == 5 != 4 & 1 ^ 5 | 8 && 10 || 20 ? 30 : 2 )) # operations
(( a = 1 || w *= 1 || IFS /= 10 || CDPATH %= 10 || x += 10 || y -= 10 )) # assignment
(( a <<= 10 || b >>= 30 || c &= 1 || f |= 40 )) # assignment

(( 0174 + 0$VAR + 8#123 + 09874 + 8#845 )) # octal + octal var + bad octal numbers
(( 0x12F + 0XDeaDBeEf111 + 0x$VAR + 16#411Ab + 0x1Z23 + 16#123K )) # hex + hex var + bad hex numbers
(( 3#10 + 10#$VAR + 44#50 + 65#567 )) # any base + wrong base (65+)
(( 2#45 + 10#45A )) # bad bin/dec bases

# [[ ... ]]

[[ a -f e || -f /bla || -o fofofof || -v varname || -R varname && -z "$STRING" ]]
[[ 1 > 2 ]]
[[ "asd" '123' $'\r\t123' $"foo" 1 ]] # test strings / numbers
[[ $(V1=1 command) `command` ]] # evaluations
[[ \$ \" \' \$ ]] # escapes
[[ $VAR $IFS $CDPATH ]] # variables
[[ ${VAR%10} ${IFS#10} ${CDPATH%10} ]] # parameter expansion
[[ $fffj =~ [[:space:]]*(a)?b ]]
[[ $line =~ ^"initial string" ]]
[[ $line =~ "^initial string" ]]
pattern='[[:space:]]*(a)?b'
[[ $line =~ $pattern ]]
[[ $line =~ $CDPATH ]] # special variable
[[ 'Hello World' =~ Hello ]]
[[ $digit =~ [0-9] ]]
[[ $REPLY =~ ^[0-9]+$ ]] # special variable
[[ "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,4}$ ]]
[[ $ip =~ ^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$ ]]

# 3.2.6 Coprocesses

coproc CDPATH {
    select far in; do
    done
} 2>/dev/null

coproc name_as_variable { V=1 command here; } 2>/dev/null 1<foo

coproc command here 1>/dev/null

coproc name_as_var {
   V=1 command here
}

coproc {
   V1=1 command here
}

# 3.3 Shell Functions

func-name () command here 2>/dev/null

func%name () {
    command here
} 2>/dev/null

func-name () { command here; }

,func-name-comma () { command here; }

function fu1[nc]name command here 1>/dev/null

function f-un[c () command here

function f123 () {
    command here
}

function func-name { command here; }

function -error here;

# 3.5.3 Shell Parameter Expansion

${A:-word} ${BASH:-word}
${A:=word} ${BASH:=word}
${A:?word} ${BASH:?word}
${A:+word} ${BASH:+word}

${A:0} ${A:0:10} ${A: -1} ${A: -1:-10} ${BASH:0} ${BASH:0:10} ${BASH: -1} ${BASH: -1:-10}
${@:7} ${@:1:2} ${*:1} ${*:1:2}
${A:$(( ${#B} + 10 )):$(command here)} ${A:"10":$'\r\t10'}

${!prefix*} ${!prefix@} ${!1@}

${!name[@]} ${!name[*]}
${!A} ${!BASH} ${!1} ${!@}

${#A} ${#BASH} ${#*} ${#@}
${A#word} ${BASH#word} ${A##word} ${BASH##word}
${A%word} ${BASH%word} ${A%%word} ${BASH%%word}

${A/pat/str} ${BASH/pat/str} ${A//pat/str} ${BASH//pat/str}
${A/#pat/str} ${BASH/#pat/str} ${A/%pat/str} ${BASH/%pat/str}
${A/$(command)/`test`"dbl"$'ansi'}

" ${A/pat/str} ${A/$(command)/`test`"dbl"$'ansi'} " # <- in double quoted strings

${A^pat} ${BASH^pat} ${A^^pat} ${BASH^^pat}
${A,pat} ${BASH,pat} ${A,,pat} ${BASH,,pat}
${A^$(command here)} ${BASH,,`test`"sdfasdf"$'\r\t\e'}

${A@U} ${A@u} ${A@L} ${A@Q} ${A@E} ${A@P} ${A@A} ${A@K} ${A@a} ${A@k}
${BASH@U} ${BASH@u} ${BASH@L} ${BASH@Q} ${BASH@E} ${BASH@P} ${BASH@A} ${BASH@K} ${BASH@a} ${BASH@k}

for i in; do
   "'${M:$i:1}" # <- test in for loop
done

# 5.1 Bourne Shell Variables

$CDPATH $HOME $IFS $MAIL $MAILPATH $OPTARG $OPTIND $PATH $PS1 $PS2

${#CDPATH}

CDPATH=1 CDPATH=somestring

# 3.5.6 Process Substitution

command here <(V=1 command here) >(V=1 command here)

command here < <(V=1 command here)

# 3.6 Redirections

ls > dirlist 2>&1
ls 2>&1 > dirlist

# 3.6.1 Redirecting Input

command < test < $VAR
command 2< test 1<$CDPATH

# 3.6.2 Redirecting Output

command >test >$VAR
command >|test >|$VAR
command 1>test 2>$VAR
command 1>|test 0>|$VAR

# 3.6.3 Appending Redirected Output

command >>test >>$VAR
command 2>>test 2>>$VAR

# 3.6.4 Redirecting Standard Output and Standard Error

command &>test >&test
command >test 2>&1

# 3.6.5 Appending Standard Output and Standard Error

command &>>test

# 3.6.7 Here Strings

command <<< word
command <<< $VAR
command <<< $(V=1 command here)
command 1<<< word
command 1<<< "string"$'ansi''single'
command <<< "HERE STRING"

for i in; do
    if bla; then
        while read -r; do
        done <<< "HERE STRING"
    fi
done

# 3.6.8 Duplicating File Descriptors

command <&1
command 1<&1
command 1<&$VAR
command 1<&-
command >&1
command 2>&3
command 1>&$VAR
command 1>&-

# 3.6.9 Moving File Descriptors

command <&1-
command 1<&1-
command >&1-
command 1>&1-

# 3.6.10 Opening File Descriptors for Reading and Writing

command <> test
command 1<>test

# 4.1 Bourne Shell Builtins

: a b c d
. file arg1 arg2 arg3
break; break $VAR; break 1; break error here
cd; cd -L -e dir
continue; continue $VAR; continue 1; continue error here
eval a b c d
exec -c -a foo command a f g
exit; exit $VAR; exit 1; exit error here
export -fn -p VARNAME VAR="value" BASH CDPATH
getopts optstring NAME foo rrr ooo
hash -r -p name
pwd; pwd -L -P
readonly -aA VARNAME VAR="value" BASH IFS
return; return $VAR; return 1; return error here
shift; shift $VAR; shift 1; shift error here
test -x foo -o $ASD
[ -x foo -o $VAR ]
times; times error here
trap; trap -l -p a s df
umask -p -S 0444
unset -f -n -v VAR1 VAR2 $VAR_IN_VAR CDPATH BASH

# 4.2 Bash Builtin Commands

alias; alias -p foo=bla
bind; bind -m aaa -f foo
builtin; builtin umask 0444 # <- should be as a command
caller; caller $VAR; caller 123 error here
command -pV grep here
declare -aA -p VAR1 VAR2=$FOO VAR3=$(command here) VAR4="str"'str'$'str'
echo -neE foo
enable -a -d fff
help -d patt
local -aA -p VAR1 VAR2=$FOO VAR3=$(command here) VAR4="str"'str'$'str'
logout; logout $VAR; logout 1; logout error here
mapfile -d 'f' file array
printf -v VAR 'format' foo
read -a -r VAR bla
readarray -d dd -C call array
source file; source file error here
type -af name
typeset -afFg VAR1 VAR2=$FOO VAR3=$(command here) VAR4="str"'str'$'str'
ulimit; ulimit -a; ulimit -H name
unalias; unalias -a; unalias name1 name2

let a=4
let z=a++
let y=--b
let result=~a
let "result=a<<2"
let "result=a&b"
let i=5 result=~a "result=a<<2"
let "myvar=7" "myvar2=4" "myvar3= myvar ^ myvar2"

# 4.3.1 The Set Builtin

set -a a b d

# 4.3.2 The Shopt Builtin

shopt -p -o opt

# 5.2 Bash Variables

$_ $BASH $BASHOPTS $BASHPID $BASH_ALIASES $BASH_ARGC
$BASH_ARGV $BASH_ARGV0 $BASH_CMDS $BASH_COMMAND $BASH_COMPAT $BASH_ENV
$BASH_EXECUTION_STRING $BASH_LINENO $BASH_LOADABLES_PATH $BASH_REMATCH
$BASH_SOURCE $BASH_SUBSHELL $BASH_VERSINFO $BASH_VERSION $BASH_XTRACEFD
$CHILD_MAX $COLUMNS $COMP_CWORD $COMP_LINE $COMP_POINT $COMP_TYPE $COMP_KEY
$COMP_WORDBREAKS $COMP_WORDS $COMPREPLY $COPROC $DIRSTACK $EMACS $ENV $EPOCHREALTIME
$EPOCHSECONDS $EUID $EXECIGNORE $FCEDIT $FIGNORE $FUNCNAME $FUNCNEST $GLOBIGNORE
$GROUPS $histchars $HISTCMD $HISTCONTROL $HISTFILE $HISTFILESIZE $HISTIGNORE
$HISTSIZE $HISTTIMEFORMAT $HOSTFILE $HOSTNAME $HOSTTYPE $IGNOREEOF $INPUTRC
$INSIDE_EMACS $LANG $LC_ALL $LC_COLLATE $LC_CTYPE $LC_MESSAGES $LC_NUMERIC
$LC_TIME $LINENO $LINES $MACHTYPE $MAILCHECK $MAPFILE $OLDPWD $OPTERR $OSTYPE
$PIPESTATUS $POSIXLY_CORRECT $PPID $PROMPT_COMMAND $PROMPT_DIRTRIM $PS0 $PS3 $PS4
$PWD $RANDOM $READLINE_ARGUMENT $READLINE_LINE $READLINE_MARK $READLINE_POINT
$REPLY $SECONDS $SHELL $SHELLOPTS $SHLVL $SRANDOM $TIMEFORMAT $TMOUT $TMPDIR $UID

${#BASH}

BASH=1 BASH=somestring

# Bash variables in for loop

for CDPATH; do
    foo
done

for CDPATH in 1 2 3; do
    foo
done

# Bash variables in commands that take variable names

export CDPATH CDPATH=123
unset CDPATH

# 6.1 Invoking Bash

bash; bash -c fff

# 6.7 Arrays

ADD=()
ARR=("val1" "val2" value\$one  "val3" $(command here; echo \)) $'ansi-str')
ARR+=("val1" "val2"   "val3" $(command here; echo \)) $'ansi-str')
ARR=(["foo"]="val1"    [$VAR $VAR2 \] $VAR3]="val2" [$(V=1 command)]="foo" ["str"'str'$'\rstr']="str"'str'$'\rstr' )

${!A[1]} ${!A["idx"]}

ARR[1]="val"

ARR["FOO"]="val" [sdfsdf] # '[sdfsdf]' is a command
ARR[$IDX]="val"
ADD[${IDX[0]}]="foo" # <- index as array element
ADD[${#IDX[@]}]="foo" # <- index as array element

echo $A["foo"] # <- here is A["foo"] is not an array, it is "$A" and '["foo"]'
echo ${A["foo"]} # <- here is A["foo"] is an array

A[$(echo bla)] # <- this should be the command 'A[bla]', not a variable/array
A[$(echo bla)]=1 command here foo # <- this should be an array assignment and a command

A[fla echo 1]=1 # assignment
A[fla "echo]=" 1]=foo # assignment
echo ${A[fla "echo]=" 1]} # echo the assignment

# Arrays + Shell Parameter Expansion

${A[foo]:-word} ${A['sdf']:=word} ${A[1]:?word} ${A[fff]:+word}

${A[foo]:0} ${A[$'bla']:0:10} ${A[$(command)]: -1} ${A[10]: -1:-10}
${A[1]:$(( ${#B} + 10 )):$(command here)} ${A[foo]:"10":$'\r\t10'}
${A[0]:7} ${A[0]:1:10} ${A[@]:1} ${A[*]:1}

${#A[foo]}

${A[1]#word} ${A[foo]##word} ${A['sdf']%word} ${A[$(test)]%%word}

" ${A[1]#word} ${A[foo]##word} ${A['sdf']%word} ${A[$(test)]%%word} " # <- in double quoted strings

${A[10]/pat/str} ${A[foo]//pat/str} ${A["a"]/#pat/str} ${A[0]/%pat/str}
${A[foo]/$(command)/`test`"dbl"$'ansi'}

${A[10]^pat} ${A[foo]^^pat} ${A["bla bla"],pat} ${A[iii],,pat}
${A[0]^$(command here)} ${A[1],,`test`"sdfasdf"$'\r\t\e'}

${A[0]@U} ${A[1]@u} ${A[foo]@L} ${A["bla"]@Q} ${A[1]@E}
${A[$'ansi']@P} ${A[$(command here)]@A} ${A[`command here`]@K} ${A[$VAR]@a} ${A[0]@k}

# 6.8.1 Directory Stack Builtins

dirs -c -l +N; dirs
popd; popd -n
pushd; pushd -n dir

# 7.2 Job Control Builtins

bg; bg 1
fg; fg 1 error here
jobs; jobs -l 123
kill; kill -l 1
wait; wait -f 10 1
disown; disown -a id $ID
suspend; suspend -f; suspend -f error here

# 8.7 Programmable Completion Builtins

compgen -o word
complete -a name name
compopt -o opt name

# 9.2 Bash History Builtins

fc; fc -e name
history; history 1; history -c
