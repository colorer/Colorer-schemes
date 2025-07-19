USE SYSTEM USE $SCRWORK
DEFINE? $DATTIM %IF USE $DATTIM %FI
PROGRAM $WATCH BASE@ ."
Процесс TIMER для выдачи времени на экран."
[*****************************************************************************]
0 [<= КОНФИГУРАЦИЯ:  0 - часы:минуты:секунды    1 - часы:минуты  ]
B10

:: FIX VAR TimFon 3 ! TimFon
:: FIX VAR TimTxt 0 ! TimTxt
:: FIX VAR TimI   0 ! TimI
:: FIX VAR TimJ  70 ! TimJ
   LONG VAR Btime [системное время в милисекундах]

: PTIM [] TIME 55 * Btime  +  1000 / D [время в секундах]
  60 / [tm,s] E2 60 / E2 [s,m,h]  ShowTim  DDD [] ;

20 100 100 '' PTIM :: TASK TIMER  18 INTV TIMER
: OUT2N [N,J] E2 10 /  [J,NH,NL] #0 + C3 1+ ! TEXTIM
  [J,NH] C NOT C3 1 = & IF+ H#SP   #0 + E2 ! TEXTIM [] ;
  : H#SP [0] D #  #0 - [K] ;

[K]  C NOT %IF
FIX 10 BYTE VCTR TEXTIM  "   :  :   " 0 ' TEXTIM !SB
:: : ShowTim [S,M,H]  1 OUT2N 4 OUT2N 7 OUT2N
     TimFon TimTxt  TimI TimJ 0 ' TEXTIM 10 OLDCLTS [] ;
           %FI

[K] %IF
FIX 8 BYTE VCTR TEXTIM  "   :   " 0 ' TEXTIM !SB
:: : ShowTim [S,M,H] 1 OUT2N 4 OUT2N [S] D INV:  []
     TimFon TimTxt  TimI TimJ 0 ' TEXTIM 7 OLDCLTS [] ;
     : INV: [] 3 TEXTIM #  = BR+ #: #  3 ! TEXTIM [] ;
     72 ! TimJ
    %FI

:: : IniTim  [] TIME [SS,S,M,H] 60 * + 60 * + 100 * + 10 * ! Btime
     [0 ! Time [] ;

DEFINE? OLDCLTS NOT %IF : OLDCLTS CLTOS ; %FI

UNDEF ! BASE@ [CLEAR $WATCH]
