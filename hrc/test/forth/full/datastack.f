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

Dependencies: {> -> } { {{ TESTING

Exports:

===================================================================== }

TESTING STACK OPS: 2DROP 2DUP 2OVER 2SWAP ?DUP DEPTH DROP DUP OVER ROT SWAP

{> 1 2 2DROP -> }
{> 1 2 2DUP -> 1 2 1 2 }
{> 1 2 3 4 2OVER -> 1 2 3 4 1 2 }
{> 1 2 3 4 2SWAP -> 3 4 1 2 }
{> 0 ?DUP -> 0 }
{> 1 ?DUP -> 1 1 }
{> -1 ?DUP -> -1 -1 }
{> DEPTH -> 0 }
{> 0 DEPTH -> 0 1 }
{> 0 1 DEPTH -> 0 1 2 }
{> 0 DROP -> }
{> 1 2 DROP -> 1 }
{> 1 DUP -> 1 1 }
{> 1 2 OVER -> 1 2 1 }
{> 1 2 3 ROT -> 2 3 1 }
{> 1 2 SWAP -> 2 1 }

