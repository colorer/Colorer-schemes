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

HEX

TESTING CHAR [CHAR] [ ] BL S"

{> BL -> 20 }
{> CHAR X -> 58 }
{> CHAR HELLO -> 48 }
{> : GC1 [CHAR] X ; -> }
{> : GC2 [CHAR] HELLO ; -> }
{> GC1 -> 58 }
{> GC2 -> 48 }
{> : GC3 [
      GC1 ] LITERAL ; -> }
{> GC3 -> 58 }
{> : GC4 S" XY" ; -> }
{> GC4 SWAP DROP -> 2 }
{> GC4 DROP DUP C@ SWAP CHAR+ C@ -> 58 59 }

