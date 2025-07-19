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

How to search for non-existent word?

Dependencies: {> -> } { {{ TESTING <FALSE>

Exports:

===================================================================== }

TESTING ' ['] FIND EXECUTE IMMEDIATE COUNT LITERAL POSTPONE STATE

{> : GT1 123 ; -> }
{> ' GT1 EXECUTE -> 123 }
{> : GT2 ['] GT1 ; IMMEDIATE -> }

HERE 3 C, CHAR G C, CHAR T C, CHAR 1 C, CONSTANT GT1STRING
HERE 3 C, CHAR G C, CHAR T C, CHAR 2 C, CONSTANT GT2STRING

{> GT2 EXECUTE -> 123 }
{> GT1STRING FIND -> ' GT1 -1 }
{> GT2STRING FIND -> ' GT2 1 }
{> : GT3 GT2 LITERAL ; -> }
{> GT3 -> ' GT1 }

{> GT1STRING COUNT -> GT1STRING CHAR+ 3 }

{>
   : GT4 POSTPONE GT1 ; IMMEDIATE
-> }

{> : GT5 GT4 ; -> }
{> GT5 -> 123 }
{> : GT6 345 ; IMMEDIATE -> }

{>
   : GT7 POSTPONE GT6 ;
-> }

{> GT7 -> 345 }

{>
   : GT8 STATE @ ; IMMEDIATE
-> }

{> GT8 -> 0 }

{> : GT9 GT8 LITERAL ; -> }
{> GT9 0= -> <FALSE> }

