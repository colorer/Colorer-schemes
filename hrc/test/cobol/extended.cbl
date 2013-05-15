000000*example of a cobol source...
000020 IDENTIFICATION DIVISION.                                         000000
000030 PROGRAM-ID.  ACF940.                                             ACF940
AAAA.                                                                             
000033D debug comment                                         aaaaaaaaaa000000
000040 AUTHOR.         John Doe.                                        ACF940
000050 DATE-COMPILED.  25/07/03.                                        ACF940
000000 REMARKS.  some comment                                           ACF940
000060 ENVIRONMENT DIVISION.                                            ACF940
120222*comment          
120223/next type of comment                                                   
******************************************************************************  
      *hilite all SECTIONs and DIVISIONs:
000000   WHATEVER DIVISION.                                             ACF940
000000   WHATEVER SECTION.                                              ACF940
******************************************************************************  
000070 CONFIGURATION SECTION.                                           ACF940
000080 SOURCE-COMPUTER. IBM-370.                                        ACF940
000090 OBJECT-COMPUTER. IBM-370.                                        ACF940
000100 INPUT-OUTPUT SECTION.                                            ACF.40
00.110 FILE-CONTROL.                                                    ACF940
00:120      SELECT     EA-FICHIER    ASSIGN    UT-S-R1.                 ACF940
000130      SELECT     PA-FICHIER    ASSIGN    UT-S-P1.                 ACF940
000140      SELECT     PB-FICHIER    ASSIGN    UT-S-P2.                 ACF940
000150 DATA DIVISION.                                                   ACF940
000160 FILE SECTION.                                                    ACF940
000170 FD                 EA-FILE-CA                                    ACF940
000180      BLOCK              00000 RECORDS                            ACF940
000190      RECORDING  F.                                               ACF940 
000200 01                 EA00.                                         ACF940
DATA 0   05              EA00-SUITE.                                    ACF940
000220      15       FILLER         PICTURE  X(00080).                  ACF940
000230 01                 EA02.                                         ACF940
000240      10            EA02-COAD   PICTURE  X.                       ACF940
000250      10            EA02-NUCO40 PICTURE  X(11).                   ACF940
000260      10            EA02-NUCOI  PICTURE  X(11).                   ACF940
000270      10            EA02-FILLER PICTURE  X(57).                   ACF940
000280 COPY someincludefile.                                            ACF940
000350 FD                 PB-FICHIER                                    ACF940
000360      BLOCK              00000 RECORDS                            ACF940
000370      RECORDING  F.                                               ACF940
000380 01                 PB00.                                         ACF940
000390      10            PB00-YDABAT PICTURE  X(8).                    ACF940
000400      10            PB00-YDAJOU PICTURE  X(-8).                   ACF940
000410      10            PB00-ZA064  PICTURE  X(64).                   ACF940
000420 WORKING-STORAGE SECTION.                                         ACF940
000430 01                 9M01.                                         ACF940
000440      10            9M01-YLIVAR PICTURE  X(72).                   ACF940
000450 01                 9M02.                                         ACF940
000460      10            9M02-YCOUTI PICTURE  X(8).                    ACF940
000470      10            9M02-YCNUGN PICTURE  X(5).                    ACF940
000480      10            9M02-YDATGN PICTURE  X(8).                    ACF940
000490      10            9M02-YHEUGN PICTURE  X(8).                    ACF940
000500 01                 9M04.                                         ACF940
000510      10            9M04-YCOSDP PICTURE  XX.                      ACF940
000520      10            9M04-YLIDDN PICTURE  X(8).                    ACF940
000530      10            9M04-YQTENR PICTURE  9(9).                    ACF940
000680     EXEC SQL INCLUDE SQLCA END-EXEC.                             7BD050
000690 01   W-CALL-DSNTIAR PIC X(8) VALUE 'DSNTIAR '.                   7BD120
000700 01   W-MESS.                                                     7BD130
000710   05             W-MESS-YQSQLM                                   7BD140
000720                  PICTURE S9(4)                                   7BD140
000730                    COMPUTATIONAL                                 7BD140
000740                     VALUE  +720.                                 7BD150
000750   05             W-MESS-YLSQLM                                   7BD160
000760                  PICTURE X(72)                                   7BD160
000770                     OCCURS 10.                                   7BD170
000780 77               W-MESS-YQSQLS                                   7BD180
000790                  PICTURE S9(9)                                   7BD180
000800                    COMPUTATIONAL                                 7BD180
000810                     VALUE  -72.                                  7BD190
002780*BEGIN DB2          TD44                                          ACF940
002790 01                 TD44.                                         ACF940
002800      10            TD44-COAD   PICTURE  X.                       ACF940
002810      10            TD44-NUMA40 PICTURE  X(7).                    ACF940
002820      10            TD44-NUCO40 PICTURE  X(11).                   ACF940
002830      10            TD44-NUMAX  PICTURE  X(7).                    ACF940
002840      10            TD44-NUCOI  PICTURE  X(11).                   ACF940
002850      10            TD44-CTRELC PICTURE  X(3).                    ACF940
002860      10            TD44-DAREL  PICTURE  S9(8)                    ACF940
002870                    COMPUTATIONAL-3.                              ACF940
002880*END DB2                                                          ACF940
005430 01   ZONES-UTILISATEUR PICTURE X.                                ACF940
005440 PROCEDURE DIVISION.                                              ACF940
005450 F0A.           EXIT.                                             P000
005460     MOVE        '0A'   TO 9M99-YCOFSF.                           PCARP015
005470 F0A-FN.   EXIT.                                                  P000
005480 F0C.                                                             P000
005490     MOVE        '0C'   TO 9M99-YCOFSF.                           PCARP015
005500     MOVE        0 TO SQLCODE IK                                  P100
005510     EXEC SQL    WHENEVER SQLWARNING CONTINUE          END-EXEC.  P120
005520     EXEC SQL    WHENEVER SQLERROR CONTINUE            END-EXEC.  P140
005530         GO TO     F0C-FN.                                        P160
005540 F0C-FN.   EXIT.                                                  P160
005610 F0MBB-A.                                                         P000
005620     ADD         1                        TO J0MBBR.              P000
005630 F0MBB-B.                                                         P000
005640     IF          999                      <  J0MBBR               P000
005650                              GO TO     F0MBB-FN.                 P000
005660     MOVE        ZERO TO W-STAT-YQTSEQ (J0MBBR).                  P100
005670 F0MBB-900. GO TO F0MBB-A.                                        P100
005680 F0MBB-FN. EXIT.                                                  P100
005690 F0M-FN.   EXIT.                                                  P100
008550 F95-TD44-D .                                                     PROC-DB2
008560     MOVE        'TD44' TO 9M99-YCOSGP.                           PCARP015
008570     MOVE        'D '   TO 9M99-YCTSQL.                           PCARP015
008690              PERFORM F98BD THRU F98BD-FN.                        PROC-DB2
******************************************************************************
008551*problem with margins within embedded sql                         000000
008580     EXEC SQL                                                     000000
008590              DELETE   FROM   V0TD44                              000000  
008600              WHERE                                               DB2  
008610           COAD               =            :TD44-COAD             PROC-DB2
008620     AND                                                          PROC-DB2
008630           CTRELC             =            :TD44-CTRELC           PROC-DB2
008640     AND                                                          PROC-DB2
008650           NUCO40             =            :TD44-NUCO40           PROC-DB2
008660     AND                                                          PROC-DB2
008670           NUCOI              =            :TD44-NUCOI            PROC-DB2
008680     END-EXEC.                                                    PROC-DB2
******************************************************************************
******************************************************************************
008560*problems with multiline string, which colors whole line:         000000
008561     MOVE        "aaaa                                            000000
008561-                "bbbb                                            000000
008563-                "cccc" TO 9M99-YCOSGP.                           000000
008560*problems with unended string ", which colors rest of file:       000000
008561     MOVE        "aaaa                                            000000
008562*problems with unended string ', which colors rest of file:       000000
008563     MOVE        'aaaa                                            000000
******************************************************************************
011680 F98-FN.   EXIT.                                                  P100
