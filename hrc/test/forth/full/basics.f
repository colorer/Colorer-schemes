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

TESTING BASIC ASSUMPTIONS

{> -> }                         \ Start with clean slate

\ Test if any bits are set; answer in base 1
{> : BITSSET? IF 0 0 ELSE 0 THEN ; -> }
{>  0 BITSSET? -> 0 }           \ Zero is all bits clear
{>  1 BITSSET? -> 0 0 }         \ Other numbers have at least one bit
{> -1 BITSSET? -> 0 0 }

