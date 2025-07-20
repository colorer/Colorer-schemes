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

ATHENA Contributions to Johns Hopkins test suite.  6/7/93

  Greg Bailey     |  ATHENA Programming, Inc  |  503-621-3215  |
----------------  |  24680 NW Dixie Mtn Road  |  fax 621-3954  |
greg@minerva.com  |  Hillsboro, OR 97124  US  |

S/M needs an advocate.

Dependencies: {> -> } { {{ TESTING MSB

Exports:

===================================================================== }

HEX

TESTING ALU BOUNDARY CONDITIONS

: ALU ( -- n )
   -1 TRUE = IF
      2
   ELSE  1 -1 XOR  TRUE = IF
      1
   ELSE  ( s/m ) 0
   THEN THEN ;

ALU DUP 2 = CONSTANT 2'S  ( expect full width signed numbers! )
    DUP 1 = CONSTANT 1'S  ( expect full width signed numbers! )
        0 = CONSTANT S/M  ( expect to be enlightened in future )

: if{> ( t ) IF {> ELSE 7D WORD DROP THEN ;

2'S if{> MSB INVERT 1 + -> MSB }  ( circular )
2'S if{> MSB 1 - -> MSB INVERT }  ( circular )
2'S if{> MSB INVERT  DUP + -> -2 }   ( overflow )
2'S if{> MSB DUP + -> 0 }   ( overflow )

1'S if{> TRUE 0 = -> 0 }   ( -0 must test nonzero )
1'S if{> TRUE 1 + -> 0 }   ( clean zero from arith... )
1'S if{> 1 TRUE + -> 0 }
1'S if{> 0 TRUE + -> 0 }
1'S if{> TRUE 0 + -> 0 }
1'S if{> 0 TRUE - -> 0 }
1'S if{> TRUE 0 - -> 0 }
1'S if{> TRUE TRUE + -> 0 }
1'S if{> TRUE TRUE - -> 0 }

