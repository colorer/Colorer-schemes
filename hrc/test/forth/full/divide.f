{ =====================================================================
ANS Forth Test Suite

Copyright (c) 1998, FORTH, Incorporated

This set of tests has been taken from John Hayes' original Core.fr
Dated Mon, 27 Nov 95 13:10.  We retain the following statement as
required for its use:

(C) 1995 JOHNS HOPKINS UNIVERSITY / APPLIED PHYSICS LABORATORY
MAY BE DISTRIBUTED FREELY AS LONG AS THIS COPYRIGHT NOTICE REMAINS.

His last know update was VERSION 1.2

This program tests the core words of an ANS Forth system.
The program assumes a two's complement implementation where
the range of signed numbers is -2^(n-1) ... 2^(n-1)-1 and
the range of unsigned numbers is 0 ... 2^(n)-1.

Dependencies: {> -> } { {{ TESTING 1S MAX-UINT
MAX-INT MIN-INT

Exports:

===================================================================== }

TESTING DIVIDE: FM/MOD SM/REM UM/MOD */ */MOD / /MOD MOD

{> 0 S>D 1 FM/MOD -> 0 0 }
{> 1 S>D 1 FM/MOD -> 0 1 }
{> 2 S>D 1 FM/MOD -> 0 2 }
{> -1 S>D 1 FM/MOD -> 0 -1 }
{> -2 S>D 1 FM/MOD -> 0 -2 }
{> 0 S>D -1 FM/MOD -> 0 0 }
{> 1 S>D -1 FM/MOD -> 0 -1 }
{> 2 S>D -1 FM/MOD -> 0 -2 }
{> -1 S>D -1 FM/MOD -> 0 1 }
{> -2 S>D -1 FM/MOD -> 0 2 }
{> 2 S>D 2 FM/MOD -> 0 1 }
{> -1 S>D -1 FM/MOD -> 0 1 }
{> -2 S>D -2 FM/MOD -> 0 1 }
{>  7 S>D  3 FM/MOD -> 1 2 }
{>  7 S>D -3 FM/MOD -> -2 -3 }
{> -7 S>D  3 FM/MOD -> 2 -3 }
{> -7 S>D -3 FM/MOD -> -1 2 }
{> MAX-INT S>D 1 FM/MOD -> 0 MAX-INT }
{> MIN-INT S>D 1 FM/MOD -> 0 MIN-INT }
{> MAX-INT S>D MAX-INT FM/MOD -> 0 1 }
{> MIN-INT S>D MIN-INT FM/MOD -> 0 1 }
{> 1S 1 4 FM/MOD -> 3 MAX-INT }
{> 1 MIN-INT M* 1 FM/MOD -> 0 MIN-INT }
{> 1 MIN-INT M* MIN-INT FM/MOD -> 0 1 }
{> 2 MIN-INT M* 2 FM/MOD -> 0 MIN-INT }
{> 2 MIN-INT M* MIN-INT FM/MOD -> 0 2 }
{> 1 MAX-INT M* 1 FM/MOD -> 0 MAX-INT }
{> 1 MAX-INT M* MAX-INT FM/MOD -> 0 1 }
{> 2 MAX-INT M* 2 FM/MOD -> 0 MAX-INT }
{> 2 MAX-INT M* MAX-INT FM/MOD -> 0 2 }
{> MIN-INT MIN-INT M* MIN-INT FM/MOD -> 0 MIN-INT }
{> MIN-INT MAX-INT M* MIN-INT FM/MOD -> 0 MAX-INT }
{> MIN-INT MAX-INT M* MAX-INT FM/MOD -> 0 MIN-INT }
{> MAX-INT MAX-INT M* MAX-INT FM/MOD -> 0 MAX-INT }

{> 0 S>D 1 SM/REM -> 0 0 }
{> 1 S>D 1 SM/REM -> 0 1 }
{> 2 S>D 1 SM/REM -> 0 2 }
{> -1 S>D 1 SM/REM -> 0 -1 }
{> -2 S>D 1 SM/REM -> 0 -2 }
{> 0 S>D -1 SM/REM -> 0 0 }
{> 1 S>D -1 SM/REM -> 0 -1 }
{> 2 S>D -1 SM/REM -> 0 -2 }
{> -1 S>D -1 SM/REM -> 0 1 }
{> -2 S>D -1 SM/REM -> 0 2 }
{> 2 S>D 2 SM/REM -> 0 1 }
{> -1 S>D -1 SM/REM -> 0 1 }
{> -2 S>D -2 SM/REM -> 0 1 }
{>  7 S>D  3 SM/REM -> 1 2 }
{>  7 S>D -3 SM/REM -> 1 -2 }
{> -7 S>D  3 SM/REM -> -1 -2 }
{> -7 S>D -3 SM/REM -> -1 2 }
{> MAX-INT S>D 1 SM/REM -> 0 MAX-INT }
{> MIN-INT S>D 1 SM/REM -> 0 MIN-INT }
{> MAX-INT S>D MAX-INT SM/REM -> 0 1 }
{> MIN-INT S>D MIN-INT SM/REM -> 0 1 }
{> 1S 1 4 SM/REM -> 3 MAX-INT }
{> 2 MIN-INT M* 2 SM/REM -> 0 MIN-INT }
{> 2 MIN-INT M* MIN-INT SM/REM -> 0 2 }
{> 2 MAX-INT M* 2 SM/REM -> 0 MAX-INT }
{> 2 MAX-INT M* MAX-INT SM/REM -> 0 2 }
{> MIN-INT MIN-INT M* MIN-INT SM/REM -> 0 MIN-INT }
{> MIN-INT MAX-INT M* MIN-INT SM/REM -> 0 MAX-INT }
{> MIN-INT MAX-INT M* MAX-INT SM/REM -> 0 MIN-INT }
{> MAX-INT MAX-INT M* MAX-INT SM/REM -> 0 MAX-INT }

{> 0 0 1 UM/MOD -> 0 0 }
{> 1 0 1 UM/MOD -> 0 1 }
{> 1 0 2 UM/MOD -> 1 0 }
{> 3 0 2 UM/MOD -> 1 1 }
{> MAX-UINT 2 UM* 2 UM/MOD -> 0 MAX-UINT }
{> MAX-UINT 2 UM* MAX-UINT UM/MOD -> 0 2 }
{> MAX-UINT MAX-UINT UM* MAX-UINT UM/MOD -> 0 MAX-UINT }

: IFFLOORED   [
   -3 2 / -2 = INVERT
   ] LITERAL IF POSTPONE \ THEN ;

: IFSYM   [
   -3 2 / -1 = INVERT
   ] LITERAL IF POSTPONE \ THEN ;

\ The system might do either floored or symmetric division.
\ Since we have already tested M*, FM/MOD, and SM/REM
\ we can use them in tests.
IFFLOORED : T/MOD  >R S>D R> FM/MOD ;
IFFLOORED : T/     T/MOD SWAP DROP ;
IFFLOORED : TMOD   T/MOD DROP ;
IFFLOORED : T*/MOD >R M* R> FM/MOD ;
IFFLOORED : T*/    T*/MOD SWAP DROP ;
IFSYM     : T/MOD  >R S>D R> SM/REM ;
IFSYM     : T/     T/MOD SWAP DROP ;
IFSYM     : TMOD   T/MOD DROP ;
IFSYM     : T*/MOD >R M* R> SM/REM ;
IFSYM     : T*/    T*/MOD SWAP DROP ;

{> 0 1 /MOD -> 0 1 T/MOD }
{> 1 1 /MOD -> 1 1 T/MOD }
{> 2 1 /MOD -> 2 1 T/MOD }
{> -1 1 /MOD -> -1 1 T/MOD }
{> -2 1 /MOD -> -2 1 T/MOD }
{> 0 -1 /MOD -> 0 -1 T/MOD }
{> 1 -1 /MOD -> 1 -1 T/MOD }
{> 2 -1 /MOD -> 2 -1 T/MOD }
{> -1 -1 /MOD -> -1 -1 T/MOD }
{> -2 -1 /MOD -> -2 -1 T/MOD }
{> 2 2 /MOD -> 2 2 T/MOD }
{> -1 -1 /MOD -> -1 -1 T/MOD }
{> -2 -2 /MOD -> -2 -2 T/MOD }
{> 7 3 /MOD -> 7 3 T/MOD }
{> 7 -3 /MOD -> 7 -3 T/MOD }
{> -7 3 /MOD -> -7 3 T/MOD }
{> -7 -3 /MOD -> -7 -3 T/MOD }
{> MAX-INT 1 /MOD -> MAX-INT 1 T/MOD }
{> MIN-INT 1 /MOD -> MIN-INT 1 T/MOD }
{> MAX-INT MAX-INT /MOD -> MAX-INT MAX-INT T/MOD }
{> MIN-INT MIN-INT /MOD -> MIN-INT MIN-INT T/MOD }

{> 0 1 / -> 0 1 T/ }
{> 1 1 / -> 1 1 T/ }
{> 2 1 / -> 2 1 T/ }
{> -1 1 / -> -1 1 T/ }
{> -2 1 / -> -2 1 T/ }
{> 0 -1 / -> 0 -1 T/ }
{> 1 -1 / -> 1 -1 T/ }
{> 2 -1 / -> 2 -1 T/ }
{> -1 -1 / -> -1 -1 T/ }
{> -2 -1 / -> -2 -1 T/ }
{> 2 2 / -> 2 2 T/ }
{> -1 -1 / -> -1 -1 T/ }
{> -2 -2 / -> -2 -2 T/ }
{> 7 3 / -> 7 3 T/ }
{> 7 -3 / -> 7 -3 T/ }
{> -7 3 / -> -7 3 T/ }
{> -7 -3 / -> -7 -3 T/ }
{> MAX-INT 1 / -> MAX-INT 1 T/ }
{> MIN-INT 1 / -> MIN-INT 1 T/ }
{> MAX-INT MAX-INT / -> MAX-INT MAX-INT T/ }
{> MIN-INT MIN-INT / -> MIN-INT MIN-INT T/ }

{> 0 1 MOD -> 0 1 TMOD }
{> 1 1 MOD -> 1 1 TMOD }
{> 2 1 MOD -> 2 1 TMOD }
{> -1 1 MOD -> -1 1 TMOD }
{> -2 1 MOD -> -2 1 TMOD }
{> 0 -1 MOD -> 0 -1 TMOD }
{> 1 -1 MOD -> 1 -1 TMOD }
{> 2 -1 MOD -> 2 -1 TMOD }
{> -1 -1 MOD -> -1 -1 TMOD }
{> -2 -1 MOD -> -2 -1 TMOD }
{> 2 2 MOD -> 2 2 TMOD }
{> -1 -1 MOD -> -1 -1 TMOD }
{> -2 -2 MOD -> -2 -2 TMOD }
{> 7 3 MOD -> 7 3 TMOD }
{> 7 -3 MOD -> 7 -3 TMOD }
{> -7 3 MOD -> -7 3 TMOD }
{> -7 -3 MOD -> -7 -3 TMOD }
{> MAX-INT 1 MOD -> MAX-INT 1 TMOD }
{> MIN-INT 1 MOD -> MIN-INT 1 TMOD }
{> MAX-INT MAX-INT MOD -> MAX-INT MAX-INT TMOD }
{> MIN-INT MIN-INT MOD -> MIN-INT MIN-INT TMOD }

{> 0 2 1 */ -> 0 2 1 T*/ }
{> 1 2 1 */ -> 1 2 1 T*/ }
{> 2 2 1 */ -> 2 2 1 T*/ }
{> -1 2 1 */ -> -1 2 1 T*/ }
{> -2 2 1 */ -> -2 2 1 T*/ }
{> 0 2 -1 */ -> 0 2 -1 T*/ }
{> 1 2 -1 */ -> 1 2 -1 T*/ }
{> 2 2 -1 */ -> 2 2 -1 T*/ }
{> -1 2 -1 */ -> -1 2 -1 T*/ }
{> -2 2 -1 */ -> -2 2 -1 T*/ }
{> 2 2 2 */ -> 2 2 2 T*/ }
{> -1 2 -1 */ -> -1 2 -1 T*/ }
{> -2 2 -2 */ -> -2 2 -2 T*/ }
{> 7 2 3 */ -> 7 2 3 T*/ }
{> 7 2 -3 */ -> 7 2 -3 T*/ }
{> -7 2 3 */ -> -7 2 3 T*/ }
{> -7 2 -3 */ -> -7 2 -3 T*/ }
{> MAX-INT 2 MAX-INT */ -> MAX-INT 2 MAX-INT T*/ }
{> MIN-INT 2 MIN-INT */ -> MIN-INT 2 MIN-INT T*/ }

{> 0 2 1 */MOD -> 0 2 1 T*/MOD }
{> 1 2 1 */MOD -> 1 2 1 T*/MOD }
{> 2 2 1 */MOD -> 2 2 1 T*/MOD }
{> -1 2 1 */MOD -> -1 2 1 T*/MOD }
{> -2 2 1 */MOD -> -2 2 1 T*/MOD }
{> 0 2 -1 */MOD -> 0 2 -1 T*/MOD }
{> 1 2 -1 */MOD -> 1 2 -1 T*/MOD }
{> 2 2 -1 */MOD -> 2 2 -1 T*/MOD }
{> -1 2 -1 */MOD -> -1 2 -1 T*/MOD }
{> -2 2 -1 */MOD -> -2 2 -1 T*/MOD }
{> 2 2 2 */MOD -> 2 2 2 T*/MOD }
{> -1 2 -1 */MOD -> -1 2 -1 T*/MOD }
{> -2 2 -2 */MOD -> -2 2 -2 T*/MOD }
{> 7 2 3 */MOD -> 7 2 3 T*/MOD }
{> 7 2 -3 */MOD -> 7 2 -3 T*/MOD }
{> -7 2 3 */MOD -> -7 2 3 T*/MOD }
{> -7 2 -3 */MOD -> -7 2 -3 T*/MOD }
{> MAX-INT 2 MAX-INT */MOD -> MAX-INT 2 MAX-INT T*/MOD }
{> MIN-INT 2 MIN-INT */MOD -> MIN-INT 2 MIN-INT T*/MOD }

