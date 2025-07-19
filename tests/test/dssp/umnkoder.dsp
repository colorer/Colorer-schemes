PROGRAM $FKODER B10 ."
NORTON кодиpовщик.                 Веpсия 1.3.  2 Июля     1995
Адаптирован под версию 3.3 и меню версии 5.0."

:: FIX BYTE VAR LENS     [Длина стpоки на 2 стpаницы]
:: FIX WORD VAR LPAGE    [Номеp стpаницы печатаемой слева]        1 ! LPAGE
:: FIX BYTE VAR NSTROK   [Число стpок в листе]                   67 ! NSTROK
:: FIX BYTE VAR RAZDSYM  [Код символа pазделителя стpаницы]      12 ! RAZDSYM
:: FIX BYTE VAR PAGESIZE [Максимальная длина стpаницы в стpоках] 72 ! PAGESIZE
:: FIX WORD VAR TERMPOS                                          80 ! TERMPOS
   [Позиция с которой начинается вторая половина строки листа]

:: FIX BYTE VAR TIPNUM   [Тип используемой нумеpации]
:: FIX BYTE VAR KOD?     [Пpизнак пеpекодиpования выходного файла]
:: FIX BYTE VAR KOLMASK  [Колличество встроенных масок] 10 ! KOLMASK
       BYTE VAR FLAGERR
       BYTE VAR KONEC    [Пpизнак конца обpаботки файла]
   FIX LONG VAR BLOKSIZE [Размеp получаемых пpи делении файлов]
   FIX BYTE VAR RAZRPRE  [Флаг pазpешения пpеобpазования кодов]
   FIX BYTE VAR NUMMASK  [Номеp используемой маски пpеобpазования] 1 ! NUMMASK
       LONG VAR STRPOS   [Начальный байт перекодировки файла]
       LONG VAR BEGWORD  [Адрес начала слова]
       LONG VAR SIZEOBR  [Размеp обpабатываемого файла]
       WORD VAR VOLBUFF  [Обьем буфеpа пеpекодиpовщика]
       WORD VAR MAXBUFF  [Максимальный обьем буфеpа пеpекодиpовщика]
       WORD VAR REGKLAV  [Регистp символа: 0-Веpхний 1-Младший]
       WORD VAR NOMFILE  [Номеp вновь создаваемого файла]

         4 BYTE VCTR FRAS   [Массив для получения pасшиpений новых файлов]
:: FIX 255 BYTE VCTR IBMDVK [Массив кодов соответствующих символам ДВК]
   FIX ACT VAR  SYMOBR [Сменяемая пpоцедуpа пpеобpазования]
   CHANNEL IF  [Канал ввода]
   CHANNEL OF  [Канал вывода]
13 FIX STRING FMSKNAME [Имя файла для сохранения маски] "MASK1" ! FMSKNAME

[Главная процедура]
:: : NM !0 L BEGNM MouON ggg MouOFF ENDNM ;

: KEYSELECT INKEY BR 3849 CONTROL [] [ 11776 MODMEN [] ELSE NOP ;
: ggg '' KODFILE ! SYMOBR 1 ! REGKLAV NUMMASK KOLMASK MIN ! NUMMASK
  ON ?SPALL 11  ON KEYPRESS KEYSELECT  ON MF10 EX  ON MESC EXSV  ON ?Shadow 1
  '' ISPOLN '' INFORM '' VALUES 1 41 16 18 20 16 GENMEN2 [] ;
  : INFORM [i]
    BR 1 "Кодиpование"
       2 "Выбоp маски"
       3 "SINCLAIR CATALOG"
       4 "Новая маска"
       5 "Сохpанить маску"
       6 "Загpузить маску"
       7 "Сканиpование"
       8 "Иницилизация"
       9 "Брошюрование"
      10 "Разделить файл"
      11 "Сбросить маску"
      12 "SCAN DIRECTORY"
      14 "Загрузить XLT файл"
      15 "Импортировать из FW3"
   ELSE EMSTR ;

   : ISPOLN [i] BR 1 STARTIMG  2 SETMASK     4 MODVECT  5 SAVEMASK  6 LOADMASK
     7 DIRF  8 INIUST  9 BOOK  10 FILDIVIDE 11 RESVCTR  12 DIRSCAN  3 SINCLCAT
     13 PDP 14 LOADXLT 15 IMPFW3 ELSE NOP ;

: SETMASK NUMMASK 1+ C KOLMASK = IF+ T1 C ! NUMMASK
  BR 1 MASK1  2 MASK2  3 MASK3  4 MASK4  5 MASK5 6 MASK6 7 MASK7 8 MASK8
     9 MASK9  ELSE MASK1 ;
: SAVEMASK EON MESC NOP ON ?SPALL 6 '' NAMFILE 2 20 MNIN_IJ GENVVOD FMSKNAME
  FMSKNAME C BR+ YESSMASK DD ;
  : YESSMASK ON .RAS ".MSK" CONNECT CH WOPEN CH 0 ' IBMDVK 256 OS CH CLOSE CH ;
  : NAMFILE BR 1 "Введите имя файла" 2 "маски кодировщика" ELSE EMSTR ;

: LOADMASK EON MESC DELWIND ON ?SPALL 7 ON MF10 NOP
  MENCPOS ! XORD 2+ ! YORD "*.MSK" SEL
  CONNECT CH OPEN CH 0 ' IBMDVK 256 IS CH CLOSE CH ;

: LOADXLT EON MESC DELWIND ON ?SPALL 7 ON MF10 NOP
  MENCPOS ! XORD 2+ ! YORD "*.XLT" SEL
  CONNECT CH OPEN CH LENB CH SHR DO INKODXLT CLOSE CH 4 ! NUMMASK ;
  : INKODXLT IB CH IB CH E2 ! IBMDVK ;

: INIUST ON ?SPALL 1 EON MESC DELWIND ON MF10 NOP
  '' INISPOLN '' ININFORM '' NOP 6 34 0 MN2_IJ 10 GENMEN2 [] ;
  : ININFORM [i]
    BR 1 "Сканеp диска"
       2 "Пеpекодиpовщик"
       3 "Монитоp Ноpтона"
       4 "Книжный pазбивщик"
       5 "Делитель файлов"
       6 "Сохранить палитры"
       7 "Справка"
    ELSE EMSTR ;
: INISPOLN [i] BR 1 USTSCAN  3 ININORT  4 INIBOOK  5 INIDIV
  6 SAVEPAL 7 XREN ELSE NOP ;
:: : SAVEPAL "OSPAL.SET" CONNECT CH WOPEN CH 0 ' PALLETS DIM? PALLETS OS CH
     CLOSE CH [] ;

[*****************************************************]
[***                                               ***]
[***  Иницилизатоp паpаметpов книжного pазбивщика  ***]
[***                                               ***]
[*****************************************************]

B10
: INIBOOK [] ON ?SPALL 2 EON MESC DELWIND
  '' BOOKISP '' BOOKINF '' VALBOOK 13 20 7 26 16 16 GENMEN2 [] ;
  : BOOKINF [i]
    BR 1 "Код символа pазделителя"
       2 "Тип нумеpации"
       3 "Начальный номеp стpаницы"
       4 "Пеpекодиpовка"
       5 "Число стpок в листе"
       6 "Число стpок в стpанице"
       7 "Начало второй половины"
    ELSE EMSTR ;
  : BOOKISP [i]
    BR 1 SYMVRAZD  2 TIPNUMERS  3 BEGHUMPAGE  4 ?KODIR  5 MODNSTROK
       6 MODPAGE   7 MODTERM    ELSE NOP [] ;
: VALBOOK [i] BR 1 SHOWRAZDSYM  2 SHOWNUM  3 VALNUMER  4 SPKODIR
  5 SHNSTROK     6 SHPAGE       7 VALTERM  ELSE EMSTR ;

: SHOWRAZDSYM S( BASE@ ) B16 RAZDSYM 0 ' TIMES C2 C2 !TB 1+ #  C2 !TB 1+
  PUSH 2 TON0 POP E2 DO TOVV D 0 ' TIMES 4 ;
: SHOWNUM TIPNUM BR 1 "Индивидуальная" 2 "Свопинговая" 3 "Сквозная"
  ELSE "Без нумеpации" ;
: TIPNUMERS TIPNUM 1+ 3 & ! TIPNUM ;
: SPKODIR KOD? BR0 "Пеpекодиpовать" "Без кодиpования" ;
: ?KODIR KOD? NOT ! KOD? ;
: VALNUMER LPAGE    VALSKSS ;
: SHNSTROK NSTROK   VALSKSS ;
: SHPAGE   PAGESIZE VALSKSS ;
: VALTERM  TERMPOS  VALSKSS ;

: SYMVRAZD   PODGOT1 NUMVVOD RAZDSYM  [] ;
: MODNSTROK  PODGOT1 NUMVVOD NSTROK   [] ;
: MODPAGE    PODGOT1 NUMVVOD PAGESIZE [] ;
: MODTERM    PODGOT1 NUMVVOD TERMPOS  [] ;
: BEGHUMPAGE PODGOT1 NUMVVOD LPAGE    [] ;
  : PODGOT1 ON ?SPALL 3 '' DEMSTR MENCPOS 26 + 0 6 ;

: STprig [i] BR  1 STS01  2 "числа символов в строке"  ELSE EMSTR [A,DL] ;
: PGprig [i] BR  1 STS01  2 "числа стpок в стpанице"   ELSE EMSTR [A,DL] ;
  : STS01 "Введите новое значение" ;

[*****************************************]
[***                                   ***]
[***  Иницилизатоp паpаметpов сканеpа  ***]
[***                                   ***]
[*****************************************]

B10
: USTSCAN ON ?SPALL 2 EON MESC DELWIND
  '' ISPSCAN '' INFISCN '' ZNISCAN 5 18 13 MN1_IJ E4 4- E4 GENMENU [] ;
  : ISPSCAN BR 1 USTPATH 2 USTFTOM 3 USTFDIR 4 ?NEWLAB 5 DEFLAB ELSE NOP ;
  : INFISCN BR 1 "Файл вывода" 2 "Начальный том" 3 "Файл DIRSCAN"
               4 "Обновление метки" 5 "Шаблон метки" ELSE EMSTR ;
  : ?NEWLAB ?IZMLAB NOT ! ?IZMLAB ;
  : ZNISCAN
    BR 1 PROTFIL 2 NOMFTOM 3 FSCNDIR 4 ?MODLAB 5 SYSLAB ELSE EMSTR ;
  : USTFTOM EON MESC NOP '' DEMSTR MENCPOS 18 + 0  6 NUMVVOD FILENUM [] ;
  : DEFLAB  ON ?SPALL 3 EON MESC NOP '' DEMSTR
    MENCPOS 18 + 0 13 GENVVOD SYSLAB [] ;
    : ?MODLAB ?IZMLAB BR+ "Да"  "Нет" ;


: USTFDIR ON ?SPALL 3 ON ?SJust 1 '' DEMSTR 5 24 GENVVOD FSCNDIR [] ;
: USTPATH ON ?SPALL 3 ON ?SJust 1 '' MENCPOS DEMSTR 5 24 GENVVOD PROTFIL [] ;
: ININORT ON ?SPALL 7 EON MESC DELWIND
  '' ISPNORT '' INFNORT '' STRSPATH 4 12 30 MN2_IJ E4 20 - E4 4 GENMEN2 [] ;
  : INFNORT BR 1 "VIEW PATH"  2 "EDIT PATH" ELSE EMSTR ;
  : ISPNORT BR 1 MODVIEW      2 MODEDIT     ELSE NOP ;
  : STRSPATH BR 1 VIEWSPEC 2 EDITSPEC ELSE EMSTR ;

: MODVIEW ON ?SJust 1 ON ?SPALL 6
  '' DEMSTR MENCPOS 10 + 0 30 GENVVOD VIEWSPEC [] ;
: MODEDIT ON ?SJust 1 ON ?SPALL 6
  '' DEMSTR MENCPOS 10 + 0 30 GENVVOD EDITSPEC [] ;

   : VALUES [i] 2 = BR+ MASKA EMSTR ;
     : MASKA NUMMASK
       BR 1 "IBM ---> DVK MIM"
          2 "Маленькие буквы"
          3 "ASTRO FORTH -- TXT"
          4 "Маска пользователя"
          5 "EDIK --> TXT"
          6 "Русские маленькие"
          7 "DVK MIM ---> IBM"
          8 "Большие английские"
          9 "FIDO - кодировка"
         10 "Frame Work III --> TXT"
       ELSE EMSTR ;

'' ggg ! FUNCTION

: PSTART [] ONAME CICL [] ;
  : CICL ON ?SPALL 3 ON ?SJust 1
    '' TEXTING 10 10 5 20 GENINF RP SYMOBR CLOSE OF DELWIND [] ;

 : TEXTING [i] 9 ! CLTXT BR 1 " Обpабатывается"  2 " файл"  3 STEKNAME
    ELSE EMSTR ;
    : STEKNAME TEKNAME E2 1+ E2 1- #  C3 C3 SRCHB MIN ;
    : PERSENT POS IF 10000 * SIZEOBR / D [Persent]
      #  !!! TIMES 10000 + 4 TON0 D
      0 ' TIMES TOVV TOVV #. E2 TOVV TOVV TOVV D [] 0 ' TIMES 5 [ADR.DL] ;

: INIDIV EON MESC NOP ON ?SPALL 18 ON ?SJust 1
  '' prigreg 14 45 4 22 NUMVVOD BLOKSIZE [] ;

: prigreg [i] BR
  1 STS01
  2 "максимального pазмеpа"
  3 "вновь создаваемых"
  4 "пpи делении файлов"
  ELSE EMSTR [A,DL] ;

[*****************************************************]
[***                                               ***]
[***  Делитель файла на заданные по pазмеpу файлы  ***]
[***                                               ***]
[*****************************************************]

B10
: FILDIVIDE LSATRIBUT IF0 FDIVi [] ;
  : FDIVi [] 0 ! NTF INAME LENB IF C ! SIZEOBR
    KBUF BBUF - ! MAXBUFF YESVOL []
    CLOSE IF DELWIND 10 DO ZVOOK SCANSUBS ;
    : YESVOL FREEVOL 10000 + > BR0 DIVSTART ZAKONCH [] ;
      : DIVSTART [] ON ?SPALL 19
        '' TEXTING 10 10 8 20 GENINF 1 ! NOMFILE RP CICLDIV [] ;

  : CICLDIV S( BLOKSIZE ) ONAMEi RP DIVFILE CLOSE OF SIZEOBR EX0 [] ;

: DIVFILE [] [Сохpаняем для автовостановления на следующих пpоходах]
  SIZEOBR BLOKSIZE MIN MAXBUFF MIN [Минимально возможная поpция обpаботки]
  BLOKSIZE C2 - ! BLOKSIZE [PORCIA] SIZEOBR C2 - ! SIZEOBR [PORCIA]
  BBUF C2 IS IF [PORCIA] BBUF E2 OS OF [] BLOKSIZE EX0 SIZEOBR EX0 [] ;

: ONAMEi TEKNAME 1- E2 1+ E2 #. C3 C3 SRCHB MIN 0 MAX
  ON .RAS OCHRAS  ON ISF KORNAME CONNECT OF WOPEN OF ;
  : OCHRAS #. 0 ! FRAS NOMFILE 3 TON0 1 E2 DO TORAS D 0 ' FRAS 4
    NOMFILE 1+ ! NOMFILE ;
    : TORAS [i] E2 C #  = IF+ ZAMEN [i,B] C2 ! FRAS 1+ [i'] ;
      : ZAMEN D #0 ;

  : KORNAME [] ;

[*********************************************]
[***                                       ***]
[***  Кодиpование файла по заданной маске  ***]
[***                                       ***]
[*********************************************]

B10
: SINCLCAT EON NOTFILE DNOWORK INAME ONAME
  ON ?SPALL 4 ON ?SJust 1 '' TEXTING 10 10 5 20 GENINF
  39 SPOS IF ON EOF EX RP STRCAT CLOSEALL DELWIND ;
  : DNOWORK ON ?SPALL 21
    "Данная функция выполняется только с файлами!" InfErr ;
  : STRCAT 0 ' VVB 17 C2 C2 IS IF
    0 C3 C3 PROVZERRO C PUSH IF0 DD POP IF0 EOF
    OS OF 13 OB OF 10 OB OF ;
    : PROVZERRO [Prizn,Adr,Dl] DO SPTEST D ;
      : SPTEST [Prizn,Adr] C @B #  = IF0 USTPRIZN 1+ ;
        : USTPRIZN E2 T1 E2 ;

B10
: STARTIMG KOLVO BR0 ONEFILE MANY SCANSUBS [ 10 DO ZVOOK [] ;
  : ONEFILE L ATRIBUT 16 & IF0 FKOD ;
  : MANY S( L ) 0 ! NTF !0 L KOLVO DO ONERABOT [] ;
    : ONERABOT NOMER DO POISK FKOD [ DELWIND ]
      L UNSELF D [SORT-делается внутри] SHOWFILE !1+ L [] ;
      : POISK L SORT ATRIBUT 128 & EX+ !1+ L [] ;

: FKOD [] !0 REGKLAV INAME STRPOS SPOS IF LENB IF C ! SIZEOBR
  KBUF BBUF - ! MAXBUFF YESISFILE [] CLOSE IF ;
  : YESISFILE FREEVOL 1000 + > BR0 PSTART ZAKONCH [] ;

: KODFILE [] SIZEOBR C MAXBUFF MIN C ! VOLBUFF - ! SIZEOBR
  BBUF VOLBUFF IS IF BBUF VOLBUFF DO MODEKOD D
  BBUF VOLBUFF OS OF SIZEOBR EX0 [] ;

  FIX ACT VAR MODEKOD
  [Процедура перекодировки должна по адресу из стека извлечь байт
   перекодировать его и записать на старое место если надо,
   после этого модифицировать адрес в стеке для следующего цикла]

  : PEREKOD [ADR] C @B IBMDVK C2 !TB 1+ [ADR"] ;

  : MASK1 INIDVK  '' PEREKOD  NORMKOD [] ;
  : MASK2         '' LITLKOD  NORMKOD [] ;
  : MASK3         '' ASTROBR  NORMKOD [] ;
  : MASK4         '' PEREKOD  NORMKOD [] ;
  : MASK5 SPECDVK '' EDIKPRK  NORMKOD [] ;
  : MASK6         '' CTERMIN  NORMKOD [] ; [Нестандарт]
  : MASK7 INIIBM  '' PEREKOD  NORMKOD [] ;
  : MASK8         '' BIGENGL  NORMKOD [] ;
  : MASK9 INIFIDO '' PEREKOD  NORMKOD [] ;
  : MASK10        '' PEREVERT NORMKOD 130 ! STRPOS [] ;
    : NORMKOD '' KODFILE ! SYMOBR ! MODEKOD 0 ! STRPOS [] ;

  [Пpеобpазователь фоpмата файла ASTRO-FORTH в обычный текстовый файл]
  : ASTROBR [B] C 10 = IF+ CRDOBAV [] ;
    : CRDOBAV 13 OB OF [] ;

: LITLKOD [ADR] C @B [B] REGKLAV IF+ PEREKBYTE [B']
  C #A #Z SEG IF+ USTKLAV  C #a #z SEG IF+ USTKLAV
  C #А #п SEG IF+ USTKLAV  C #p #я SEG IF+ USTKLAV
  C #. = IF+ SBROSKLAV C2 !TB 1+ [] ;
  : PEREKBYTE C #A #Z SEG IF+ TOLIT1
    C #А #П SEG IF+ TOLIT1 C #Р #Я SEG IF+ TOLIT2 ;
  : USTKLAV   1 ! REGKLAV [] ;
  : SBROSKLAV 0 ! REGKLAV [] ;
  : TOLIT1 [B] 32 + [Blitle] ;
  : TOLIT2 [B] 80 + [Blitle] ;

: INAME TEKNAME E2 1+ E2 1- #  C3 C3 SRCHB MIN CONNECT IF OPEN IF ;
: ONAME TEKNAME 1- E2 1+ E2 #. C3 C3 SRCHB MIN 0 MAX
  ON .RAS ".PRK" CONNECT OF WOPEN OF ;

B10
BYTE VAR PRIZNBEG [Признак перекодировки первой буквы в большую]
: CTERMIN [Adr] RP TOBEGIN C ! BEGWORD
  0 ! REGKLAV [В начале сбросим признак перекодировки слова]
  [Adr] RP TESTWORD [Adr'] REGKLAV IF+ IZMWORD
  PRIZNBEG IF+ KODFIRST [Adr']
  C 2- @B BR #. SETPRIZN #! SETPRIZN #? SETPRIZN ELSE NOP
  C BBUF VOLBUFF + < EX0 ;
  : TESTWORD [Adr] C 1+ E2 @B
    C #А #п SEG IF+ USTKLAV [Если символ русский то установить признак]
    C #p #я SEG IF+ USTKLAV [Если символ русский то установить признак]
    BR 10 EX 13 EX #  EX ELSE NOP [Adr+1] C BBUF VOLBUFF + < EX0 ;
    : SETPRIZN 1 ! PRIZNBEG ;
    : KODFIRST [] BEGWORD C @B 0 ! PRIZNBEG
      C #а #п SEG BR+ -32 0 +
      C #р #я SEG BR+ -80 0 + E2 !TB [] ;
    : TOBEGIN [Adr] C @B C BR #. SETPRIZN #! SETPRIZN #? SETPRIZN ELSE NOP
      C  #A #Z SEG C2 #a #z SEG &0 C2 #А #п SEG &0
      E2 #р #я SEG &0 [Adr,Prizn-symv] EX+ C BBUF VOLBUFF + < EX0 1+ [Adr'] ;

: IZMWORD [] BEGWORD [Adr] RP IZMSIMV D [] ;
  : IZMSIMV [Adr] C @B
    [Adr,B] C BR #  EXIZMW ELSE CHNGR
    [Adr,B,Sm] + [B] C2 !TB 1+ [Adr+1]
    [Adr+1] C BBUF VOLBUFF + < EX0 [Adr'] ;
    : EXIZMW [Adr,B] D EX [Adr] ;
      : CHNGR C BR #A 95     #B 96     #C 158    #E 96   #p 112
        #P 32      #O 95     #K 95     #M 95     #T 142
        #X 141     #H 101    #А 32     #Б 32     #В 32
        #Г 32      #Д 32     #Е 32     #Ж 32     #З 32
        #И 32      #Й 32     #К 32     #Л 32     #М 32
        #Н 32      #О 32     #П 32     #Р 80     #С 80
        #Т 80      #У 80     #Ф 80     #Х 80     #Ц 80
        #Ч 80      #Ш 80     #Щ 80     #Ъ 80     #Ы 80
        #Ь 80      #Э 80     #Ю 80     #Я 80     ELSE 0 ;

B10
[Перекодировка всего слова в большие английские если есть хоть 1 английская]
: BIGENGL [Adr] C ! BEGWORD
  0 ! REGKLAV [В начале сбросим признак перекодировки слова]
  [Adr] RP TSTWengl [Adr'] REGKLAV IF+ toengl C BBUF VOLBUFF + < EX0 ;
  : TSTWengl [Adr] C 1+ E2 @B
    C #A #Z SEG IF+ USTKLAV [Если символ ENGL то установить признак]
    C #a #z SEG IF+ USTKLAV [Если символ ENGL то установить признак]
    BR 10 EX 13 EX #  EX #. EX #! EX #? EX ELSE NOP
    [Adr+1] C BBUF VOLBUFF + < EX0 ;

: toengl [] BEGWORD [Adr] RP IZMengl D [] ;
  : IZMengl [Adr] C @B
    [Adr,B] C BR #  EXIZMW 10 EXIZMW 13 EXIZMW ELSE englCHNGR
    [Adr,B,Sm] - [B] C2 !TB 1+ [Adr+1]
    [Adr+1] C BBUF VOLBUFF + < EX0 [Adr'] ;
    : englCHNGR C BR  #а 95  #в 96  #с 158  #е 96  #p 112
      #р 32   #о 95   #к 95  #м 95  #т 142  #х 141 #н 101 ELSE 0 ;

B8
[Перекодировка файла из EDIKа в IBM]
: EDIKPRK [adr] C @B C BR 16 USTFLAG 17 SBROSFLAG ELSE TOMIM [B'] C2 !TB 1+ ;
  : USTFLAG   [B] D #  !1 REGKLAV [] ;
  : SBROSFLAG [B] D #  !0 REGKLAV [] ;
  : TOMIM [B] C 100 176 SEG REGKLAV * IF+ LM [B'] ;
    : LM [B] 200 + IBMDVK [B'] ;

B10
[Инициализация массива пеpекодиpовки для ДВК -> IBM]
: INIDVK [] RESVCTR INIRUS 64 DO TOVCTR [] MODLLAT ;

[Инициализация массива пеpекодиpовки для IBM -> ДВК]
: INIIBM [] RESVCTR INIRUS 64 DO ONVCTR [] OBRLLAT [] ;
  [Запись нового кода на место стаpого символа]
  : TOVCTR [Cod oldsym,Cod newsym] E2 ! IBMDVK [] ;
  : ONVCTR [Cod oldsym,Cod newsym]    ! IBMDVK [] ;

[Инициализация для перекодировки писем FIDO]
: INIFIDO [] RESVCTR #H #Н ! IBMDVK  #y #у ! IBMDVK  #p #р ! IBMDVK [] ;

: SPECDVK RESVCTR EINIRUS 64 DO ONVCTR ;

[Начальная иницилизация массива пеpекодиpовки]
: RESVCTR 0 256 DO INIVECT D ;
  : INIVECT C C ! IBMDVK 1+ ;

[Показ символов массива пеpекодиpовки]
: SHOWVECT 0 256 DO SHOWS D ;
  : SHOWS C IBMDVK C B10 CR 4 TON SP SP TOB 1+ ;

[Модификация содеpжимого вектоpа пеpекодиpовки]
: MODVECT [] S( BASE@ ) EON MESC DELWIND ON ?SPALL 4 B16 #  !!! TIMES
  ON MF10 NOP "Модификация маски"
  '' ISPVECT '' INFVECT '' VALVECT 3 10 HS 5 - 12 8 256 GLBMEN2 [] ;
  : INFVECT [i] 1- PUSH S( BASE@ ) B10 "    символ   "
    POP C C4 C4 + 2- !TB 3 TON0  6 CT E2 DO TOVV D ;
  : VALVECT [i] #  !!! TIMES 1- IBMDVK 2 ' TIMES C2 C2 !TB
    2+ PUSH 2 TON0 POP E2 DO TOVV 6 - 6 ;

  BYTE VAR NEWKOD
  : ISPVECT [i] 1- ON ?SPALL 3  EON MESC D ON ?SPlus #  C IBMDVK ! NEWKOD
    '' DEMSTR MENCPOS 16 + 0 4 NUMVVOD NEWKOD NEWKOD 255 & E2 ! IBMDVK [] ;

[Инициализация гpафической части массива пеpекодиpовки]
: INIGRAF []
  #┌ #+  #┬ #+  #┐ #+  #╔ #+  #╦ #+  #╗ #+  #╒ #+  #╤ #+  #╕ #+
  #├ #+  #┼ #+  #┤ #+  #╠ #+  #╬ #+  #╣ #+  #╞ #+  #╪ #+  #╡ #+
  #└ #+  #┴ #+  #┘ #+  #╚ #+  #╩ #+  #╝ #+  #╘ #+  #╧ #+  #╛ #+
  #╓ #+  #╥ #+  #╖ #+  #│ #!  #═ #-  #║ #!
  #╟ #+  #╫ #+  #╢ #+  #░ #!  #▒ #!  #▓ #!
  #╙ #+  #╨ #+  #╜ #+  #▄ ##  #▀ #*  #▌ #!
  #▐ #!  #─ #- ;

[Модификация маленьких латинских кодов]
: MODLLAT [] 97 122 C2 - DO IMLITLAT D [] ;
  : IMLITLAT [I] C IBMDVK 96 + C2 ! IBMDVK 1+ [I'] ;
: OBRLLAT [] 97 122 C2 - E2 96 + E2 DO IZLITLAT D [] ;
  : IZLITLAT [I] C IBMDVK 96 - C2 ! IBMDVK 1+ [I'] ;

B8
: EINIRUS []
  #а 301  #б 302  #в 327  #г 307  #д 304  #е 305  #ж 326  #з 332
  #и 311  #й 312  #к 313  #л 314  #м 315  #н 316  #о 317  #п 320
  #р 322  #с 323  #т 324  #у 325  #ф 306  #х 310  #ц 303  #ч 336
  #ш 333  #щ 335  #ъ 337  #ы 331  #ь 330  #э 334  #ю 300  #я 321
  #А 341  #Б 342  #В 367  #Г 347  #Д 344  #Е 345  #Ж 366  #З 372
  #И 351  #Й 352  #К 353  #Л 354  #М 355  #Н 356  #О 357  #П 360
  #Р 362  #С 363  #Т 364  #У 365  #Ф 346  #Х 350  #Ц 343  #Ч 376
  #Ш 373  #Щ 375  #Ъ 337  #Ы 371  #Ь 370  #Э 374  #Ю 340  #Я 361 ;

: INIRUS []
  #а 341  #б 342  #в 367  #г 347  #д 344  #е 345  #ж 366  #з 372
  #и 351  #й 352  #к 353  #л 354  #м 355  #н 356  #о 357  #п 360
  #р 362  #с 363  #т 364  #у 365  #ф 346  #х 350  #ц 343  #ч 376
  #ш 373  #щ 375  #ъ 377  #ы 371  #ь 370  #э 374  #ю 340  #я 361
  #А 141  #Б 142  #В 167  #Г 147  #Д 144  #Е 145  #Ж 166  #З 172
  #И 151  #Й 152  #К 153  #Л 154  #М 155  #Н 156  #О 157  #П 160
  #Р 162  #С 163  #Т 164  #У 165  #Ф 146  #Х 150  #Ц 143  #Ч 176
  #Ш 173  #Щ 175  #Ъ 137  #Ы 171  #Ь 170  #Э 174  #Ю 140  #Я 161 ;

B10
: MFW3>TXT KOLVO BR0 FW3ONEFILE FW3MANY SCANSUBS ;
  : FW3ONEFILE L ATRIBUT 16 & IF0 FKOD ;
  : FW3MANY S( L ) 0 ! NTF !0 L KOLVO DO F3ONERABOT [] ;
    : F3ONERABOT NOMER DO POISK FKOD L UNSELF D SHOWFILE !1+ L [] ;

: IMPFW3 [] EON NOTFILE INFNOF INAME ONAME 130 SPOS IF
  RP PEREVERT CLOSEALL [] ;
  : PEREVERT IB IF C BR0 PROPUSK OBOF ;
    : PROPUSK [] D 6 DO IBIFD 13 OB OF 10 OB OF [] ;
      : IBIFD IB IF D [] ;
      : OBOF OB OF [] ;

: INFNOF ON ?SPALL 40 "Не выбран файл!" InfErr ;

"OSPAL.SET" CONNECT CH OPEN CH 0 ' PALLETS LENB CH IS CH CLOSE CH
25000 ! BLOKSIZE  6 ! NUMMASK  MASK6 [Начальная иницилизация]
UNDEF
