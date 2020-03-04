"Расшиpения pедактоpа.        Версия 1.2. 20 Ноября  1990."
B10 CR 12 ! SCOLOR TOS''
PROGRAM $EDEXT USE SYSTEM USE $EDIT
B8
[ '' NOP   '' ATT   '' POINT '' COPY   '' CTRLD '' EX    '' CTRLF '' GET
  0        1 A      2 B      3 C       4 D      5 E      6 F      7 G

 '' ERS    '' ГТ    '' DIV   '' STS    '' NSTR  '' .BK   '' NOP   '' NOP
 10 H      11 I     12 J     13 K      14 L     15 M     16 N     17 O

 '' ТАБ    '' TXT   '' DL    '' IC     '' DC    '' CTRLU '' IL    '' NOP
 20 P      21 Q     22 R     23 S      24 T     25 U     26 V     27 W

 '' ТАБ    '' !->   '' <-    '' AR2    '' UP    '' DOWN  '' ПРДМ  '' NOPOIN
 30 X      31 Y     32 Z     33 {      34 \     35 }     36 ^     37 _

 '' WINDOW '' TSTR  '' LDATE '' SK+    '' MARKS '' DATE  '' EXR   '' L1
 40        41       42       43        44       45       46       47

 '' AU+    '' .BSTR '' TOLMOV '' ZAPIS '' EDIT  '' REST  '' BEG   '' .ПС
 50        51       52        53       54       55       56       57

 '' ST3    '' RENSC '' TOPMOV '' SCHFL '' ZB    '' IFL
 60        61       62        63       64       65 ]

 4 EXE HEAD CTRLD
12 EXE HEAD DIV
13 EXE HEAD STS
15 EXE HEAD .BK
23 EXE HEAD IC
24 EXE HEAD DC
30 EXE HEAD TAB
31 EXE HEAD !->
32 EXE HEAD <-
34 EXE HEAD UP
35 EXE HEAD DOWN
40 EXE HEAD WINDOW
41 EXE HEAD TSTR
43 EXE HEAD SK+
44 EXE HEAD MARKS
46 EXE HEAD EXR
47 EXE HEAD L1
50 EXE HEAD AU+
51 EXE HEAD .BSTR
52 EXE HEAD TOLMOV
53 EXE HEAD ZAPIS
54 EXE HEAD EDIT
55 EXE HEAD REST
56 EXE HEAD BEG
57 EXE HEAD .PC
60 EXE HEAD ST3
61 EXE HEAD RENSC
62 EXE HEAD TOPMOV
63 EXE HEAD SCHFL
64 EXE HEAD ZB
65 EXE HEAD IFL

:: : ?SP #  = ;
:: : ?BK 12 = ;
:: : SPE #  TOB'' ;

[Форматирование]
VAR A
:: FIX VAR NDLS 113 ! NDLS
: ER [] MARKS [L,H,1/0] BR+ ER1 DD [] ;
: ER1 [L,H] SCHFL
  C2 - 1+ C2 [LINE] C ST3 5 - ST3 HS + 5 + SEG BR+ TOLMOV RENSC
  [L,SK] .BSTR ER2 [L] TSTR 1+ E2 WINDOW L1 TOLMOV [] ;

[Основной цикл]
: ER2 [SK] AF ! A RP OSTR D [] ;
  : OSTR [SK] A @B BR 12 OS1 40 OS2 #- OS3 ELSE OS4 [SK'] ;

: OS1 [SK] 1- C EX0 A AF -
  BR 0 OSTR0 NDLS OSTR0 DLS-1 OSTR0 ELSE OSTR1 [SK-1] ;
  : OSTR0 A+ AF A AF - UN C2 AU+ !SB !1+ TSTR ;
  : OSTR1 A 1+ @B BR 12 OSTR0 #  OSTR0 #- OSTR0
    #| OSTR0 177 OSTR0 ELSE OSTR2 ;
    : OSTR2 !1- LEN 40 A !TB A+ ;

: OS2 A AF - BR NDLS +STR DLS-1 +STR ELSE A+ ;
: +STR !1+ LEN 12 A !TB OSTR0 ;

: OS3 A 1+ @B ?BK BR+ OS31 OS4 ;
: OS31 A 1- @B BR #  OS4 #- OS4 ELSE OST1 ;
: OST1 [SK] 1- C EX0 !1- LEN AF A AF - AF 2+ ! AF AF !SB A+ A+ [SK-1] ;

: OS4 A AF - NDLS = BR+ STR1 A+ ;
: STR1 A 2- ! A A @B ?SP BR+ +STR STR2 ;
: STR2 40 A NDLS NEG SRCHB 1+ A + ! NSL
       40 A NDLS SRCHB 1- A + ! KSL
       A PER MESTOP BR0 NPER EPER +STR ;
: NPER NSL 1- ! A ;
: EPER AF MESTOP 1+ AF - AF 2- ! AF AF !SB MESTOP ! A #- A 1- !TB ;
: A+ !1+ A ;
: DLS-1 NDLS 1- ;

[Процедура переноса слов]
VAR NSL [Начало]
VAR KSL [Конец]
VAR LGL [Левая гласная, адр. или 0]
VAR RGL [Правая гласная, адр. или 0]
VAR DLINA [Адрес посл. возм. литеры в строке]
VAR MESTOP [Место пер., адр. посл.буквы]

[Вход: адр. посл. возможной
 буквы в строке (длина-1) в стеке, адр. первой и посл.
 букв слова в переменных NSL и KSL]
: PER [TEK] C ! DLINA PERENOS [] ;
: PERENOS [TEK] C RP ISKRGL D [TEK] RP ISKLGL D []
  LGL BR0 NETPER PEREN1 [] ;

[Правая гласная]
: ISKRGL [A] 1+ C @B [A+1B] C ?SP IF+ IRGL1
  GLAS? [A+1,1/0] IF+ IRGL2 [A+1] ;
[Кончилось]
: IRGL1 [A,40] D !0 RGL EX [A] ;
[Есть гласная]
: IRGL2 [A] C ! RGL EX [A] ;

[Левая гласная]
: ISKLGL [A] C @B [A,B] C ?SP IF+ ILGL1
  GLAS? [A,1/0] IF+ ILGL2 1- [A-1] ;
[Кончилось]
: ILGL1 [A,40] D !0 LGL EX [A] ;
[Есть гласная]
: ILGL2 [A] C ! LGL EX [A] ;

[Не переносится]
: NETPER [] !0 MESTOP [] ;

[Левая гласная есть, дальше]
: PEREN1 [] RGL BR0 PEREN11 PEREN2 [] ;
[Есть обе гласные]
: PEREN2 [] RGL LGL - [RGL-LGL] BR 1 PER0 2 PER1 ELSE PER2 [] ;
[Перенос невозможен, левее]
: PEREN11 [] LGL 1- PERENOS [] ;

[Гласные рядом]
: PER0 [] LGL NSL = NOT RGL KSL = NOT & LGL 1- @B SPEC? NOT &
  RGL 1+ @B SPEC? NOT & [1/0] BR+ PER01 PEREN11 [] ;
[Перенос возможен]
: PER01 [] LGL ! MESTOP [] ;

[Гласные через 1 букву]
: PER1 [] LGL 1+ @B #й = BR+ PER11 PER12 [] ;
[Перенос после й]
: PER11 [] LGL 1+ ! MESTOP MESTOP DLINA > IF+ PEREN11 [] ;
[Между гласными согласная]
: PER12 [] LGL NSL = NOT LGL 1- @B SPEC? NOT &
  [1/0] BR+ PER01 PEREN11 [] ;

[Между гласными 2 или больше букв]
: PER2 [] 0 LGL RGL LGL - 1- DO PER20 D [1/0] BR+ PEREN11 PER22 [] ;
[Есть ли между гласными SPEC?]
: PER20 [0,A] 1+ C @B SPEC? IF+ PER201 [1/0,A+1] ;
: PER201 [0,A] E2 T1 E2 EX [1,A] ;
[Анализ переноса возможен]
: PER22 [] LGL 2+ @B C #ъ = E2 #ь = &0 BR+ 2 1 LGL + ! MESTOP
  MESTOP DLINA > IF+ PEREN11 [] ;

[Проверка на SPEC?]
: SPEC? [B] BR #- 1  #/ 1  #_ 1  #, 1  #. 1  #! 1  #? 1  #; 1  #" 1
  #' 1  #( 1  #) 1  #[ 1  #] 1  #: 1  #> 1  #< 1
  ELSE 0 [1/0] ;
[Проверка на гласную]
: GLAS? [B] BR  #а 1  #е 1  #и 1  #о 1  #у 1  #э 1  #ы 1  #ю 1  #я 1
  #А 1  #Е 1  #И 1  #О 1  #У 1  #Э 1  #Ы 1  #Ю 1  #Я 1
  ELSE 0 [1/0] ;

: @A AF @B ;
: @U UN 1- @B ;
: AU1+ AF @B UN !TB !1+ AF !1+ UN ;

[AA - вставляется в ZAPIS, обработка символа в конце строки]
: AA [B] C BR #  MBK ELSE PEREP TAB ;
: MBK D .BK IL ;
' EL NUSE
'' AA ! EL
: PEREP [B] RP PEREP1 [B] BEG BR0 DBELL PEREP2 ;
: PEREP2 [B] !-> DIV .PC TAB ZAPIS [] ;
: PEREP1 <- @A ?SP @A ?BK &0 EX+ BEG EX0 ;
: DBELL D BELL ;

[AA1 -выравнивание по правому краю]
: AA1 [] .BW REST NDLS > BR+ BELL AAA1 .BK [] ;
: AAA1 [] NDLS REST - C TAB RP EXTENT DD [] ;
: EXTENT [J,I] C EX0 BEG IF0 TAB? <- @A ?SP @U ?SP NOT &
  IF+ IC2 [J,I НОВ.] ;
: IC2 IC 1- ;
: TAB? [J,I] C2 C2 = EX+ E2D C TAB [I,I] ;

' TRB @ HEAD OLDTRB
' TRB NUSE
FIX VAR INFTRB
FIX VAR BIGL 1 ! BIGL
: NEWTRB [] OLDTRB BIGL IF0 TBIG [B']
  C BR #> K.  #< #,  #. #>  #, #<  #= #-  #* #:  #+ #;
       #- #=  #: #*  #; #+  ELSE C  E2D [] ;

COPYW E E'
:: : E S( TRB BASE@ ) B10 INFTRB ! TRB E' ;
'' OLDTRB ! INFTRB

: K. !0 BIGL #. ;
: TBIG C #  > IF+ TBIG1 ;
: TBIG1 RUSCAP !1 BIGL ;

BYTE CNST CAP
#А #Б #В #Г #Д #Е #Ж #З #И #Й #К #Л #М #Н #О #П
#Р #С #Т #У #Ф #Х #Ц #Ч #Ш #Щ #Ъ #Ы #Ь #Э #Ю #Я ;

BYTE CNST LIT
#а #б #в #г #д #е #ж #з #и #й #к #л #м #н #о #п
#р #с #т #у #ф #х #ц #ч #ш #щ #ъ #ы #ь #э #ю #я ;

: TOCAP LATCAP RUSCAP ;
: RUSCAP [B] C 0 ' LIT 40 SRCHB [B,I] C 40 < BR+ CAP E2 E2D [B'] ;
: LATCAP [B] C #a #z SEG BR+ 40 0 - [B'] ;

[Расшифровка сокращений]
: K20 [] VVD FIND BR0 D K21 [] ;
: K21 [AZ] 'BA @ [BA] EXEC [A,DL] C2 @B #_ = IF+ BAC DO ZAS [] D ;
: BAC <- DC E2 1+ E2 1- ;
: ZAS [A] C @B C #* = BR+ ZAS1 ZAPIS 1+ [A+1] ;
: ZAS1 [*] D '' TRB RP EDITT D [] ;
: EDITT EDIT @U ?SP EX+ ;

[Прием сокращения]
: VVD [] 40 UN 1- BEG NEG SRCHB NEG [SK]
  UN C2 - C2 TWE [SK]
  SWIM PRS DO VVD1 D
  [SK] 1- DO ZB [] ;
: VVD1 [A] C @B TOCAP C2 !TB 1+ [A+1] ;

B16
: TWE #  !!! WIMAGE 7 MIN C SHR 7 ! WIMAGE SWIM C2 - 1+ 2000 0 !SB ;
: SLR INFTRB '' OLDTRB = BR+ MNEW MOLD C ! TRB ! INFTRB ;
: MNEW '' NEWTRB ;
: MOLD '' OLDTRB ;

: .W RCP T0 SCP ;
: .BW .W TSTR WINDOW ;

[Центрирование текста в строке]
: CENTR .PC UP AF [ADR] NOSP [DL] DO DC NDLS REST - SHR
  C BB > IF+ T0 DO IC .PC ;
  : NOSP [A] 0 RP NOSP1 E2D [I] ;
    : NOSP1 [A,I] C C3 + @B ?SP EX0 1+ [A,I+1] ;

: STRLEN [] S( BASE@ ) B10 .BW .STS 0C ! SCOLOR
  "Длина стpоки (Ввод - " TOS''
  NDLS 2 TON ") - " TOS'' 2 [TEXTCOLOR] ! SCOLOR
  ON NERR NOP TIN
  C BR0 NDLS C E2D 1 MAX DLS MIN ! NDLS .BW .STS L1 [] ;

B10
VAR USLOVIE
: WORDTORUS !0 USLOVIE TOEND TOSTART RP TORUS1 [] ;
  : TORUS1 [] AF @B C ?SP IF+ DEX C ?BK BR+ .PCDEX UCHNGR [] ;
    : DEX D EX [] ;
    : .PCDEX .PC DEX [] ;
    : UCHNGR USLOVIE BR0 CHNGR 0 E2 [DOP,B,B]
      C BR #. SBROS #  NOP #: NOP ELSE UST [] E2 IZMSDV ;
      : SBROS !1 USLOVIE ;
      : UST !0 USLOVIE ;
      : CHNGR C
        BR
        #A 95
        #B 96
        #C 158
        #E 96
        #P 32
        #O 95
        #K 95
        #M 95
        #T 142
        #X 141
        #H 101
        #А 32
        #Б 32
        #В 32
        #Г 32
        #Д 32
        #Е 32
        #Ж 32
        #З 32
        #И 32
        #Й 32
        #К 32
        #Л 32
        #М 32
        #Н 32
        #О 32
        #П 32

        #Р 80
        #С 80
        #Т 80
        #У 80
        #Ф 80
        #Х 80
        #Ц 80
        #Ч 80
        #Ш 80
        #Щ 80
        #Ъ 80
        #Ы 80
        #Ь 80
        #Э 80
        #Ю 80
        #Я 80
        ELSE 0 ;
      : IZMSDV + [B] C AF !TB TOB AU1+ [] ;


'' WORDTORU 69 [aF6]  C ' EXR NUSE ! EXR [+]

FIX BYTE VAR LINNEW 0 ! LINNEW
FIX BYTE VAR NEWPOSLIN 0 ! NEWPOSLIN

: IZMNEWLIN LINNEW NOT ! LINNEW [] ;


: STRZAMEN [] RP SYMZAMEN [] ;
  : SYMZAMEN [] OSTFREE EX0 @A C ?BK BR+ EXNEWLINE UCHNGR ;
    : EXNEWLINE NEWLINE EX [] ;
      : NEWLINE [B] D LEN TSTR - IF+ NEWSTR [] ;
        : NEWSTR [] .PC LINNEW IF0 PEREDV [] ;
          : PEREDV [] NEWPOSLIN OSTFREE C2 - IF- T0 DO !-> [] ;
            : OSTFREE [] KBUF AF - 1- ;

'' STRZAMEN 68 [aF6]  C ' EXR NUSE ! EXR [+]

[Формирование файла с помощью]
[ADDEHELP - добавить текст отмеченный маpкеpами как новую секцию в файл помощи]
       CHANNEL   CH0    [Канал для связи с файлом помощи]
       WORD VAR  N      [Номер секции]
       WORD VAR  HIGH   [Номеp стpоки веpхнего маpкеpа]
       WORD VAR  QSTRS  [Счетчик строк]
       BYTE VAR  SBPTR  [Указатель по вектоpу SBUF]
       WORD VAR  NSTROK [Сколько стpок пеpенести в файл]
       WORD VAR  LITTLE [Номеp стpоки нижнего маpкеpа]
       LONG VAR  OLDPOS [Позиция в файле помощи, куда надо пеpеписать
                         число строк в секции]
   FIX BYTE VAR  UDAL?  [Пеpеменная флаг - удалять текст после пеpенесенмя
                         в файл помощи (1) или нет (0)]
    79 BYTE VCTR SBUF   [Буфеp для выводимой стpоки]
FIX 11 BYTE VCTR NFHELP [Буфеp для имени файла помощи]

"COMDSSP.HLP" 0 ' NFHELP !SB

: IZMUDAL [] .BW .STS 113 ! SCOLOR
  "Вы действительно " TOS'' UDAL? BR+ "нехотите" "хотите"
  118 ! SCOLOR TOS'' 113 ! SCOLOR
  " удалять текст после его записи в HELPing (Y/N)" TOS'' TEXTCOLOR ! SCOLOR
  UDAL? TIB BR #Y NOT #y NOT ELSE NOP ! UDAL? .BW .STS L1 [] ;

: NAMEFHLP .BW .STS
  "Введите имя файла помощи - " #  !!! NFHELP
  14 ! SCOLOR TOS''
  0 ' NFHELP 12 TIS
  TEXTCOLOR ! SCOLOR .BW .STS L1 [] ;

: ADDEHELP [] MARKS [L,H,1/0] BR+ ADDEHLP DD [] ;
  : ADDEHLP [L,H] ! HIGH ! LITTLE
    BEG TSTR [Тек позиция и тек стpока]
    ST3 SGX 0 MAX
    [Тек позиция и тек стpока,ST3]
    EON EXERR NOP
    ON ZAPROS NAMEFHLP
    ON .RAS ".HLP"
    0 ' NFHELP 12 C2 C2 TOS
    CONNECT CH0 OPEN CH0

    .BW .STS
     14 ! SCOLOR
    "Номеp добавляемой секции - " TOS'' TIN ! N
    .BW .STS L1

    0 2 SPOS CH0 IW CH0 DO GH0 C
    BR0 CYCL SOOB CLOSE CH0
    -1 0 SCURS
    N 0 ' NFHELP 12 GENHELP
    6 8 SCURS E3 E2
    RENSC TOLMOV TOPMOV [EXIST STATUS] IF0 ?UDAL .BK ;
    : ?UDAL UDAL? IF+ UDALYT [] ;
    : SOOB .BW .STS "Данная секция уже есть !!!" TOS'' TRB D .BW .STS L1 ;

: CYCL 0 SPOS CH0
  TEXTCOLOR ! SCOLOR
  [L,H,Тек позиция и тек стpока,ST3,L,H]
  ADDEH0 ;
  : GH0 [есть ли данная секция в файле]
    [0] IW CH0 N = IF+ GH0' POS CH0 4 + SPOS CH0 [0] ;
    : GH0' [0] D IL CH0 EX ;

: FHM ."
Нет свободных секций в файле помощи " FNAME CH0 EXERR ;

: UDALYT [] HIGH ! M2 LITTLE ! M1 CTRLD [] ;

: ADDEH0 []
   EON EXERR NOP
   IW CH0 IW CH0 = IF+ FHM
   2 SPOS CH0 IW CH0 6 * 4 + SPOS CH0 N OW CH0 LENB CH0 OL CH0
   LENB CH0 ! OLDPOS
   LENB CH0 2+ SPOS CH0
   !0 QSTRS
   DOWN
   LITTLE HIGH C2 - 1+ [L,SK] E2 TOLMOV
   DO ADDEH1
   OLDPOS SPOS CH0
   QSTRS OW CH0
   2 SPOS CH0 IW CH0 1+ 2 SPOS CH0 OW CH0 [] ;

: ADDEH1 [Ввод и вывод одной строки]
   #  !!! SBUF
   13 78 ! SBUF 10 79 ! SBUF
   !0 SBPTR
   ADDEH2
   0 ' SBUF 80 OS CH0
   !1+ QSTRS DOWN [] ;

[Заполнение вуфера SBUF]
: ADDEH2 [] !0 SBPTR AF 80 DO ADDEH3 D [] ;
  : ADDEH3 [AF] C @B C 10 = IF+ ADDEH4 [B]
    SBPTR ! SBUF [AF] 1+ [AF'] !1+ SBPTR [] ;
    : ADDEH4 [B] D EX [] ;
B10
: helpcom
    BEG TSTR [Тек позиция и тек стpока]
    ST3 SGX 0 MAX CLS
    [Тек позиция и тек стpока,ST3]
    EON EXERR NOP
    ON .RAS ".HLP" ON ZAPROS NAMEFHLP
    20 "COMAND32.HLP" GENHELP
    RENSC TOLMOV TOPMOV .BK ;

[Стягивание текста в стpоке]
: STYG [] TAB AF [AFendstr] .BK UP RP STYGSTR D .BK [] ;
  : STYGSTR [AFendstr]
    KBUF AF - EX- C AF > EX0 TOEND RP OBRWORD [AFendstr] ;
    : OBRWORD []
      AF @B ?BK EX+
      AF 1+ @B ?SP BR+ DC EX ;

: NSTYG [] MARKS [L,H,1/0] BR+ DONSTYG DD [] ;
  : DONSTYG [L,H] C2 - 1+ E2 TOLMOV DO STYG [] ;

'' ER       25 [F7]   C ' EXR NUSE ! EXR
'' K20      26 [F8]   C ' EXR NUSE ! EXR
'' SLR      28 [F10]  C ' EXR NUSE ! EXR
'' IZMUDAL  49 [sF6]  C ' EXR NUSE ! EXR [+]
'' ADDEHELP 50 [sF7]  C ' EXR NUSE ! EXR [+]
'' AA1      51 [sF8]  C ' EXR NUSE ! EXR [+]
'' NAMEFHLP 53 [sF10] C ' EXR NUSE ! EXR [+]
'' NSTYG    60 [^SF7] C ' EXR NUSE ! EXR [+]
'' STYG     61 [^SF8] C ' EXR NUSE ! EXR [+]
'' [STRLEN] TOEND   70 [aF7]  C ' EXR NUSE ! EXR [+]
'' CENTR    71 [aF8]  C ' EXR NUSE ! EXR [+]
'' helpcom  72 [aF9]  C ' EXR NUSE ! EXR [+]

UNDEF
