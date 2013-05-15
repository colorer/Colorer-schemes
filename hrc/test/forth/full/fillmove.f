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

TESTING FILL MOVE

-? CREATE FBUF 00 C, 00 C, 00 C,
-? CREATE SBUF 12 C, 34 C, 56 C,
: SEEBUF FBUF C@  FBUF CHAR+ C@  FBUF CHAR+ CHAR+ C@ ;

{> FBUF 0 20 FILL -> }
{> SEEBUF -> 00 00 00 }

{> FBUF 1 20 FILL -> }
{> SEEBUF -> 20 00 00 }

{> FBUF 3 20 FILL -> }
{> SEEBUF -> 20 20 20 }

{> FBUF FBUF 3 CHARS MOVE -> }           \ Bizarre special case
{> SEEBUF -> 20 20 20 }

{> SBUF FBUF 0 CHARS MOVE -> }
{> SEEBUF -> 20 20 20 }

{> SBUF FBUF 1 CHARS MOVE -> }
{> SEEBUF -> 12 20 20 }

{> SBUF FBUF 3 CHARS MOVE -> }
{> SEEBUF -> 12 34 56 }

{> FBUF FBUF CHAR+ 2 CHARS MOVE -> }
{> SEEBUF -> 12 12 34 }

{> FBUF CHAR+ FBUF 2 CHARS MOVE -> }
{> SEEBUF -> 12 34 34 }

