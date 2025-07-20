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

Exports: 0S 1S

===================================================================== }

TESTING BOOLEANS: INVERT AND OR XOR

{> 0 0 AND -> 0 }
{> 0 1 AND -> 0 }
{> 1 0 AND -> 0 }
{> 1 1 AND -> 1 }

{> 0 INVERT 1 AND -> 1 }
{> 1 INVERT 1 AND -> 0 }

0        CONSTANT 0S
0 INVERT CONSTANT 1S

{> 0S INVERT -> 1S }
{> 1S INVERT -> 0S }

{> 0S 0S AND -> 0S }
{> 0S 1S AND -> 0S }
{> 1S 0S AND -> 0S }
{> 1S 1S AND -> 1S }

{> 0S 0S OR -> 0S }
{> 0S 1S OR -> 1S }
{> 1S 0S OR -> 1S }
{> 1S 1S OR -> 1S }

{> 0S 0S XOR -> 0S }
{> 0S 1S XOR -> 1S }
{> 1S 0S XOR -> 1S }
{> 1S 1S XOR -> 0S }

