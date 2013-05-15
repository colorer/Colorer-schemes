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

Missing test: negative ALLOT
TBD: How to find number of bits?

Dependencies: {> -> } { {{ TESTING MSB 1S <FALSE> <TRUE>

Exports:

===================================================================== }

HEX

TESTING HERE , @ ! CELL+ CELLS C, C@ C! CHARS 2@ 2! ALIGN ALIGNED +! ALLOT

HERE 1 ALLOT
HERE
CONSTANT 2NDA
CONSTANT 1STA
{> 1STA 2NDA U< -> <TRUE> }              \ Here must grow with allot
{> 1STA 1+ -> 2NDA }                     \ ... by one address unit

HERE 1 ,
HERE 2 ,
CONSTANT 2ND
CONSTANT 1ST
{> 1ST 2ND U< -> <TRUE> }                \ Here must grow with allot
{> 1ST CELL+ -> 2ND }                    \ ... by one cell
{> 1ST 1 CELLS + -> 2ND }
{> 1ST @ 2ND @ -> 1 2 }
{> 5 1ST ! -> }
{> 1ST @ 2ND @ -> 5 2 }
{> 6 2ND ! -> }
{> 1ST @ 2ND @ -> 5 6 }
{> 1ST 2@ -> 6 5 }
{> 2 1 1ST 2! -> }
{> 1ST 2@ -> 2 1 }
{> 1S 1ST !  1ST @ -> 1S }               \ Can store cell-wide value

HERE 1 C,
HERE 2 C,
CONSTANT 2NDC
CONSTANT 1STC
{> 1STC 2NDC U< -> <TRUE> }              \ Here must grow with allot
{> 1STC CHAR+ -> 2NDC }                  \ ... by one char
{> 1STC 1 CHARS + -> 2NDC }
{> 1STC C@ 2NDC C@ -> 1 2 }
{> 3 1STC C! -> }
{> 1STC C@ 2NDC C@ -> 3 2 }
{> 4 2NDC C! -> }
{> 1STC C@ 2NDC C@ -> 3 4 }

ALIGN 1 ALLOT HERE ALIGN HERE 3 CELLS ALLOT
CONSTANT A-ADDR  CONSTANT UA-ADDR
{> UA-ADDR ALIGNED -> A-ADDR }
{>    1 A-ADDR C!  A-ADDR C@ ->    1 }
{> 1234 A-ADDR  !  A-ADDR  @ -> 1234 }
{> 123 456 A-ADDR 2!  A-ADDR 2@ -> 123 456 }
{> 2 A-ADDR CHAR+ C!  A-ADDR CHAR+ C@ -> 2 }
{> 3 A-ADDR CELL+ C!  A-ADDR CELL+ C@ -> 3 }
{> 1234 A-ADDR CELL+ !  A-ADDR CELL+ @ -> 1234 }
{> 123 456 A-ADDR CELL+ 2!  A-ADDR CELL+ 2@ -> 123 456 }

: BITS ( X -- U )
   0 SWAP BEGIN
      DUP WHILE
         DUP MSB AND IF
            >R 1+ R>
   THEN  2*  REPEAT  DROP ;

\ Characters >= 1 au, <= size of cell, >= 8 bits
{> 1 CHARS 1 < -> <FALSE> }
{> 1 CHARS 1 CELLS > -> <FALSE> }

\ Cells >= 1 au, integral multiple of char size, >= 16 bits
{> 1 CELLS 1 < -> <FALSE> }
{> 1 CELLS 1 CHARS MOD -> 0 }
{> 1S BITS 10 < -> <FALSE> }

{> 0 1ST ! -> }
{> 1 1ST +! -> }
{> 1ST @ -> 1 }
{> -1 1ST +! 1ST @ -> 0 }

