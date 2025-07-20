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

TESTING DEFINING WORDS: : ; CONSTANT VARIABLE CREATE DOES> >BODY

{> 123 CONSTANT X123 -> }
{> X123 -> 123 }

{>
   : EQU CONSTANT ;
-> }

{> X123 EQU Y123 -> }
{> Y123 -> 123 }

{> VARIABLE V1 -> }
{> 123 V1 ! -> }
{> V1 @ -> 123 }

{> : NOP : POSTPONE ; ; -> }
{> NOP NOP1 NOP NOP2 -> }
{> NOP1 -> }
{> NOP2 -> }

{>
   : DOES1 DOES> @ 1 + ;
-> }

{>
   : DOES2 DOES> @ 2 + ;
-> }

{> CREATE CR1 -> }
{> CR1 -> HERE }
{> ' CR1 >BODY -> HERE }
{> 1 , -> }
{> CR1 @ -> 1 }
{> DOES1 -> }
{> CR1 -> 2 }
{> DOES2 -> }
{> CR1 -> 3 }

{> : WEIRD: CREATE DOES> 1 + DOES> 2 + ; -> }
{> WEIRD: W1 -> }
{> ' W1 >BODY -> HERE }
{> W1 -> HERE 1 + }
{> W1 -> HERE 2 + }

