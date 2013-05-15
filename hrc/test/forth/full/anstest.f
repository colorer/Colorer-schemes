OPTIONAL ANSTEST ANS Test Suite

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

I haven't figured out how to test KEY, QUIT, ABORT, or ABORT"...
I also haven't thought of a way to test ENVIRONMENT?...

Dependencies: EMPTY FORTH DEFINITIONS TESTING

Exports: VERBOSE

===================================================================== }

( ---------------------------------------------------------------------
Test control



VERBOSE set to true for more verbose output; this may allow you to tell
which test caused your system to hang.

--------------------------------------------------------------------- )

EMPTY  FORTH DEFINITIONS  CR


-? VARIABLE VERBOSE   TRUE VERBOSE !

INCLUDE Tester


TESTING CORE WORDS

INCLUDE Basics
INCLUDE Booleans
INCLUDE Shifts
INCLUDE Compares
INCLUDE DataStack
INCLUDE ReturnStack
INCLUDE AddSubtract
INCLUDE Multiply
INCLUDE Divide
INCLUDE Dictionary
INCLUDE Chars
INCLUDE Compiler
INCLUDE Structures
INCLUDE Loops
INCLUDE Defining
INCLUDE Evaluate
INCLUDE Source
INCLUDE Numbers
INCLUDE FillMove
INCLUDE Output
INCLUDE Input
INCLUDE Search
INCLUDE Alu

0 TO INITIAL-DEPTH \ Remove depth allowance

