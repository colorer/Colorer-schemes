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

Dependencies: {> -> } { {{ TESTING MSB 0S 1S

Exports: MAX-UINT MAX-INT MIN-INT MID-UINT MID-UINT+1 <FALSE>

===================================================================== }

TESTING COMPARISONS: 0= = 0< < > U< MIN MAX

0 INVERT                        CONSTANT MAX-UINT
0 INVERT 1 RSHIFT               CONSTANT MAX-INT
0 INVERT 1 RSHIFT INVERT        CONSTANT MIN-INT
0 INVERT 1 RSHIFT               CONSTANT MID-UINT
0 INVERT 1 RSHIFT INVERT        CONSTANT MID-UINT+1

0S CONSTANT <FALSE>
1S CONSTANT <TRUE>

{> 0 0= -> <TRUE> }
{> 1 0= -> <FALSE> }
{> 2 0= -> <FALSE> }
{> -1 0= -> <FALSE> }
{> MAX-UINT 0= -> <FALSE> }
{> MIN-INT 0= -> <FALSE> }
{> MAX-INT 0= -> <FALSE> }

{> 0 0 = -> <TRUE> }
{> 1 1 = -> <TRUE> }
{> -1 -1 = -> <TRUE> }
{> 1 0 = -> <FALSE> }
{> -1 0 = -> <FALSE> }
{> 0 1 = -> <FALSE> }
{> 0 -1 = -> <FALSE> }

{> 0 0< -> <FALSE> }
{> -1 0< -> <TRUE> }
{> MIN-INT 0< -> <TRUE> }
{> 1 0< -> <FALSE> }
{> MAX-INT 0< -> <FALSE> }

{> 0 1 < -> <TRUE> }
{> 1 2 < -> <TRUE> }
{> -1 0 < -> <TRUE> }
{> -1 1 < -> <TRUE> }
{> MIN-INT 0 < -> <TRUE> }
{> MIN-INT MAX-INT < -> <TRUE> }
{> 0 MAX-INT < -> <TRUE> }
{> 0 0 < -> <FALSE> }
{> 1 1 < -> <FALSE> }
{> 1 0 < -> <FALSE> }
{> 2 1 < -> <FALSE> }
{> 0 -1 < -> <FALSE> }
{> 1 -1 < -> <FALSE> }
{> 0 MIN-INT < -> <FALSE> }
{> MAX-INT MIN-INT < -> <FALSE> }
{> MAX-INT 0 < -> <FALSE> }

{> 0 1 > -> <FALSE> }
{> 1 2 > -> <FALSE> }
{> -1 0 > -> <FALSE> }
{> -1 1 > -> <FALSE> }
{> MIN-INT 0 > -> <FALSE> }
{> MIN-INT MAX-INT > -> <FALSE> }
{> 0 MAX-INT > -> <FALSE> }
{> 0 0 > -> <FALSE> }
{> 1 1 > -> <FALSE> }
{> 1 0 > -> <TRUE> }
{> 2 1 > -> <TRUE> }
{> 0 -1 > -> <TRUE> }
{> 1 -1 > -> <TRUE> }
{> 0 MIN-INT > -> <TRUE> }
{> MAX-INT MIN-INT > -> <TRUE> }
{> MAX-INT 0 > -> <TRUE> }

{> 0 1 U< -> <TRUE> }
{> 1 2 U< -> <TRUE> }
{> 0 MID-UINT U< -> <TRUE> }
{> 0 MAX-UINT U< -> <TRUE> }
{> MID-UINT MAX-UINT U< -> <TRUE> }
{> 0 0 U< -> <FALSE> }
{> 1 1 U< -> <FALSE> }
{> 1 0 U< -> <FALSE> }
{> 2 1 U< -> <FALSE> }
{> MID-UINT 0 U< -> <FALSE> }
{> MAX-UINT 0 U< -> <FALSE> }
{> MAX-UINT MID-UINT U< -> <FALSE> }

{> 0 1 MIN -> 0 }
{> 1 2 MIN -> 1 }
{> -1 0 MIN -> -1 }
{> -1 1 MIN -> -1 }
{> MIN-INT 0 MIN -> MIN-INT }
{> MIN-INT MAX-INT MIN -> MIN-INT }
{> 0 MAX-INT MIN -> 0 }
{> 0 0 MIN -> 0 }
{> 1 1 MIN -> 1 }
{> 1 0 MIN -> 0 }
{> 2 1 MIN -> 1 }
{> 0 -1 MIN -> -1 }
{> 1 -1 MIN -> -1 }
{> 0 MIN-INT MIN -> MIN-INT }
{> MAX-INT MIN-INT MIN -> MIN-INT }
{> MAX-INT 0 MIN -> 0 }

{> 0 1 MAX -> 1 }
{> 1 2 MAX -> 2 }
{> -1 0 MAX -> 0 }
{> -1 1 MAX -> 1 }
{> MIN-INT 0 MAX -> 0 }
{> MIN-INT MAX-INT MAX -> MAX-INT }
{> 0 MAX-INT MAX -> MAX-INT }
{> 0 0 MAX -> 0 }
{> 1 1 MAX -> 1 }
{> 1 0 MAX -> 1 }
{> 2 1 MAX -> 2 }
{> 0 -1 MAX -> 0 }
{> 1 -1 MAX -> 1 }
{> 0 MIN-INT MAX -> 0 }
{> MAX-INT MIN-INT MAX -> MAX-INT }
{> MAX-INT 0 MAX -> MAX-INT }

