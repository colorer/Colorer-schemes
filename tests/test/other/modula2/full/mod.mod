(* Copyright (C) 1987 Jensen & Partners International *)

(*$S-,R-,I-*)
IMPLEMENTATION MODULE FIO;

FROM Str    IMPORT CHARSET,Length,Compare,IntToStr,CardToStr,RealToStr,
                   StrToInt,StrToCard,StrToReal,Copy;
FROM SYSTEM IMPORT Seg,Ofs,Registers,CarryFlag;

IMPORT AsmLib;


CONST
  TrueStr   = 'TRUE';
  MaxHandle = MaxOpenFiles+3;

(*$V-*)

TYPE
  FileInf   = POINTER TO BufRec;
VAR
  IOR    : CARDINAL; (* MSDOS result value *)

  BufInf : ARRAY[0..MaxHandle] OF FileInf;


CONST
  ErrMsg2  = 'file not found';
  ErrMsg3  = 'path not found';
  ErrMsg4  = 'too many open files';
  ErrMsg5  = 'access denied';
  ErrMsg6  = 'invalid handle';
  ErrMsg15 = 'invalid drive';
  ErrMsg16 = 'current directory';
  ErrMsg17 = 'different device';
  ErrMsgDiskFull = 'disk full';



PROCEDURE ErrorCheckNamed ( VAR r : Registers;
                            str   : ARRAY OF CHAR;
                            name  : ARRAY OF CHAR);
VAR
  s  : ARRAY[0..100] OF CHAR;
  ns : ARRAY[0..3] OF CHAR;
  sp : POINTER TO ARRAY[0..79] OF CHAR;

  PROCEDURE AddErr(es: ARRAY OF CHAR);
  BEGIN
    Str.Append(s,es);
  END AddErr;

BEGIN
  WITH r DO
     IF (BITSET{CarryFlag} * Flags) # BITSET{} THEN
       IOR := AX;
       IF IOcheck THEN
         s := CHR(0);
         Copy(s,str);
         AddErr(' : ');
         CASE IOR OF
         2 :   sp := ADR(ErrMsg2)            |
         3 :   sp := ADR(ErrMsg3)            |
         4 :   sp := ADR(ErrMsg4)            |
         5 :   sp := ADR(ErrMsg5)            |
         6 :   sp := ADR(ErrMsg6)            |
         15:   sp := ADR(ErrMsg15)           |
         16:   sp := ADR(ErrMsg16)           |
         17:   sp := ADR(ErrMsg17)           |
         DiskFull: sp := ADR(ErrMsgDiskFull) |
         ELSE  AddErr('MSDOS error # ') ;
               ns[0] := CHR(IOR DIV 10+48);
               ns[1] := CHR(IOR MOD 10+48);
               ns[2] := CHR(0);
               sp := ADR(ns);
         END;
         AddErr(sp^);
         IF name[0] # CHR(0) THEN
           AddErr(' (');
           AddErr(name);
           AddErr(')');
         END;
         Lib.FatalError(s);
       END;
     ELSE
       IOR := 0;
     END;
  END;
END ErrorCheckNamed;

PROCEDURE ErrorCheck(VAR r: Registers; str: ARRAY OF CHAR);
BEGIN
  IF (BITSET{CarryFlag} * r.Flags) # BITSET{} THEN
    ErrorCheckNamed(r,str,CHR(0));
  ELSE
    IOR := 0;
  END;
END ErrorCheck;

PROCEDURE IOresult () : CARDINAL;
BEGIN
  RETURN IOR;
END IOresult;



PROCEDURE Write(F: File; Buf: ARRAY OF BYTE; Count: CARDINAL);
VAR r : Registers;
BEGIN
  IF Count = 0 THEN RETURN END;
  WITH r DO
    DS := Seg(Buf);
    DX := Ofs(Buf);
    AH := 40H;  (* file write *)
    BX := F;
    CX := Count;
    Lib.Dos(r);
    IF (AX # CX) AND ((BITSET{CarryFlag} * Flags) = BITSET{}) THEN
      AX := DiskFull;
      Flags := BITSET{CarryFlag};
    END;
    ErrorCheck(r,'Write');
  END;
END Write;

PROCEDURE Flush(F: File);
VAR x : FileInf;
  r : Registers;
  conv : RECORD
           CASE : BOOLEAN OF
            | TRUE  : lo,hi: CARDINAL;
            | FALSE : long : LONGINT;
           END;
         END;
BEGIN
  IF (F <= MaxHandle) THEN
    x := BufInf[F];
    IF (x # NIL) THEN
      WITH x^ DO
        IF RWPos > EOB THEN
          Write( F,Buffer,RWPos );
        ELSIF RWPos < EOB THEN (* last was read, move DOS pointer back *)
          conv.long := LONGINT(RWPos) - LONGINT(EOB);
          WITH r DO
            CX := conv.hi;
            DX := conv.lo;
            AX := 4201H; (* seek relative *)
            BX := F;
            Lib.Dos(r);
            ErrorCheck(r,'Flush');
          END;
        END;
        RWPos := 0;
        EOB   := 0;
      END;
    END;
  END;
END Flush;

PROCEDURE Truncate(F: File);
VAR r : Registers;
BEGIN
  Flush( F );
  WITH r DO
    AH := 40H; (* file write *)
    BX := F;
    CX := 0;
    Lib.Dos(r);
    ErrorCheck(r,'Truncate');
  END;
END Truncate;

PROCEDURE Read(F: File; VAR Buf: ARRAY OF BYTE; Count: CARDINAL) : CARDINAL;
VAR r : Registers;
BEGIN
  WITH r DO
    DS := Seg(Buf);
    DX := Ofs(Buf);
    AH := 3FH; (* file read *)
    BX := F;
    CX := Count;
    Lib.Dos(r);
    ErrorCheck(r,'Read');
    IF IOR = 0 THEN
      RETURN AX;
    ELSE
      RETURN 0;
    END;
  END;
END Read;

PROCEDURE WrStr(F: File; Buf: ARRAY OF CHAR);
VAR Count : CARDINAL;
BEGIN
  OK := TRUE;
  Count := Str.Length( Buf );
  WrBin( F,Buf,Count );
END WrStr;

PROCEDURE WrLn(F: File);
TYPE a = ARRAY [ 0..1 ] OF CHAR;
BEGIN
  WrStr( F, a( CHR( 13 ),CHR( 10 ) ) );
END WrLn;

PROCEDURE RdChar(F: File ) : CHAR;
VAR c : CHAR;
BEGIN
  OK := TRUE;
  IF (F <= MaxHandle) AND (BufInf[F] # NIL) THEN
    WITH BufInf[F]^ DO
      IF RWPos < EOB THEN
        c := CHAR(Buffer[ RWPos ]);
        INC(RWPos);
        EOF := (c = CHR(26));
        RETURN c;
      END;
    END;
  END;
  IF RdBin( F,c,1 ) = 0 THEN
    OK := FALSE;
    c  := CHR(26);
  END;
  EOF := (c = CHR(26));
  RETURN c;
END RdChar;

PROCEDURE RdStr(F: File; VAR Buf: ARRAY OF CHAR);
VAR
  i,h : CARDINAL;
  c   : CHAR;
BEGIN
  i  := 0;
  h  := HIGH( Buf );
  OK := TRUE;
  LOOP
     IF i > h THEN RETURN END;
     c := RdChar( F );
     IF c = CHR( 26 ) THEN
       Buf[ i ] := CHR(0);
       EOF := (i = 0);
       RETURN;
     ELSIF c = CHR( 13 ) THEN
       Buf[ i ] := CHR(0);
       RETURN;
     ELSIF c # CHR( 10 ) THEN
       Buf[ i ] := c;
       INC( i );
     END;
  END;
END RdStr;

PROCEDURE RdItem( F : File; VAR S : ARRAY OF CHAR );
VAR c : CHAR; i,L : CARDINAL;
BEGIN
  i := 0;
  LOOP
    c := RdChar( F );
    IF NOT OK OR NOT (c IN Separators) THEN EXIT; END;
  END;
  L := HIGH( S );
  LOOP
    IF NOT OK OR ( c IN Separators ) THEN EXIT; END;
    S[i] := c;
    INC( i );
    IF i > L THEN
      EXIT;
    ELSE
      c := RdChar( F );
      IF c = CHR(26) THEN OK := TRUE; EXIT; END;
    END;
  END;
  IF i <= L THEN S[i] := 0C; END;
END RdItem;


(*$V+*)

PROCEDURE WrStrAdj(F: File; S: ARRAY OF CHAR; Length: INTEGER);
VAR
  L : CARDINAL;
  a : INTEGER;
BEGIN
  OK := TRUE;
  L  := Str.Length( S );
  a  := ABS( Length ) - INTEGER( L );
  IF (a < 0) AND ChopOff THEN
    L := CARDINAL(ABS(Length));
    IF L>HIGH(S) THEN
      L := HIGH(S)+1;
    ELSE
      S[L] := CHR(0);
    END;
    WHILE (L>0) DO DEC(L) ; S[L] := '?'; END;
    OK := FALSE;
    a  := 0;
  END;
  IF (Length > 0) AND (a > 0) THEN WrCharRep( F,' ',a ); END;
  WrStr( F,S );
  IF (Length < 0) AND (a > 0) THEN WrCharRep( F,' ',a ); END;
END WrStrAdj;

(*$V-*)

PROCEDURE WrChar(F: File; V: CHAR);
BEGIN
  OK := TRUE;
  WrBin( F,V,1 );
END WrChar;

PROCEDURE WrCharRep(F: File; V: CHAR ; Count: CARDINAL);
VAR
  S   : ARRAY[0..80] OF CHAR;
  i,j : CARDINAL;
BEGIN
  WHILE Count>0 DO
    i := SIZE(S)-2;
    IF i > Count THEN i := Count END;
    DEC(Count,i);
    j := 0;
    WHILE (j < i) DO S[j] := V; INC(j) END;
    OK := TRUE;
    WrBin( F,S,j );
    IF NOT OK THEN RETURN END ;
  END;
END WrCharRep;

PROCEDURE WrBool(F: File; V: BOOLEAN; Length: INTEGER);
BEGIN
  IF V THEN
    WrStrAdj( F,TrueStr,Length );
  ELSE
    WrStrAdj( F,'FALSE',Length );
  END;
END WrBool;

PROCEDURE WrShtInt(F: File; V: SHORTINT; Length: INTEGER);
VAR S : ARRAY[0..80] OF CHAR;
BEGIN
  IntToStr( VAL( LONGINT,V ),S,10,OK );
  IF OK THEN WrStrAdj( F,S,Length ); END;
END WrShtInt;

PROCEDURE WrInt(F: File; V: INTEGER; Length: INTEGER);
VAR S : ARRAY[0..80] OF CHAR;
BEGIN
  IntToStr( VAL( LONGINT,V ),S,10,OK );
  IF OK THEN WrStrAdj( F,S,Length ); END;
END WrInt;

PROCEDURE WrLngInt(F: File; V: LONGINT; Length: INTEGER);
VAR S : ARRAY[0..80] OF CHAR;
BEGIN
  IntToStr( V,S,10,OK );
  IF OK THEN WrStrAdj( F,S,Length ); END;
END WrLngInt;

PROCEDURE WrShtCard(F: File; V: SHORTCARD; Length: INTEGER);
VAR S : ARRAY[0..80] OF CHAR;
BEGIN
  CardToStr( VAL( LONGCARD,V ),S,10,OK );
  IF OK THEN WrStrAdj( F,S,Length ); END;
END WrShtCard;

PROCEDURE WrCard(F: File; V: CARDINAL; Length: INTEGER);
VAR S : ARRAY[0..80] OF CHAR;
BEGIN
  CardToStr( VAL( LONGCARD,V ),S,10,OK );
  IF OK THEN WrStrAdj( F,S,Length ); END;
END WrCard;

PROCEDURE WrLngCard(F: File; V: LONGCARD; Length: INTEGER);
VAR S : ARRAY[0..80] OF CHAR;
BEGIN
  CardToStr( V,S,10,OK );
  IF OK THEN WrStrAdj( F,S,Length ); END;
END WrLngCard;

PROCEDURE WrShtHex(F: File; V: SHORTCARD; Length: INTEGER);
VAR S : ARRAY[0..80] OF CHAR;
BEGIN
  CardToStr( VAL( LONGCARD,V ),S,16,OK );
  IF OK THEN WrStrAdj( F,S,Length ); END;
END WrShtHex;

PROCEDURE WrHex(F: File; V: CARDINAL; Length: INTEGER);
VAR S : ARRAY[0..80] OF CHAR;
BEGIN
  CardToStr( VAL( LONGCARD,V ),S,16,OK );
  IF OK THEN WrStrAdj( F,S,Length ); END;
END WrHex;

PROCEDURE WrLngHex(F: File; V: LONGCARD; Length: INTEGER);
VAR S : ARRAY[0..80] OF CHAR;
BEGIN
  CardToStr( V,S,16,OK );
  IF OK THEN WrStrAdj( F,S,Length ); END;
END WrLngHex;

PROCEDURE WrReal(F: File; V: REAL; Precision: CARDINAL; Length: INTEGER);
VAR S : ARRAY[0..80] OF CHAR;
BEGIN
  RealToStr( VAL( LONGREAL,V ),Precision,Eng,S,OK );
  IF OK THEN WrStrAdj( F,S,Length ); END;
END WrReal;

PROCEDURE WrLngReal(F: File; V: LONGREAL; Precision: CARDINAL; Length: INTEGER);
VAR S : ARRAY[0..80] OF CHAR;
BEGIN
  RealToStr( V,Precision,Eng,S,OK );
  IF OK THEN WrStrAdj( F,S,Length ); END;
END WrLngReal;

PROCEDURE RdBool(F: File) : BOOLEAN;
VAR S : ARRAY[0..80] OF CHAR;
BEGIN
  RdItem( F,S );
  RETURN Compare(S,TrueStr) = 0;
END RdBool;

PROCEDURE RdShtInt(F: File) : SHORTINT;
VAR
  S : ARRAY[0..80] OF CHAR;
  i : LONGINT;
BEGIN
  RdItem( F,S );
  i  := StrToInt( S,10,OK );
  OK := OK AND (i >= -80H) AND (i <= 7FH);
  RETURN SHORTINT( i );
END RdShtInt;

PROCEDURE RdInt(F: File) : INTEGER;
VAR
  S : ARRAY[0..80] OF CHAR;
  i : LONGINT;
BEGIN
  RdItem( F,S );
  i  := StrToInt( S,10,OK );
  OK := OK AND (i >= -8000H) AND (i <= 7FFFH);
  RETURN INTEGER(i);
END RdInt;

PROCEDURE RdLngInt(F: File) : LONGINT;
VAR S : ARRAY[0..80] OF CHAR;
BEGIN
  RdItem( F,S );
  RETURN StrToInt( S,10,OK );
END RdLngInt;

PROCEDURE RdShtCard(F: File) : SHORTCARD;
VAR
  S : ARRAY[0..80] OF CHAR;
  i : LONGCARD;
BEGIN
  RdItem( F,S );
  i  := StrToCard( S,10,OK );
  OK := OK AND (i < 0FFH);
  RETURN SHORTINT( i );
END RdShtCard;

PROCEDURE RdCard(F: File) : CARDINAL;
VAR
  S : ARRAY[0..80] OF CHAR;
  i : LONGCARD;
BEGIN
  RdItem( F,S );
  i  := StrToCard( S,10,OK );
  OK := OK AND (i < 10000H);
  RETURN INTEGER( i );
END RdCard;

PROCEDURE RdLngCard(F: File) : LONGCARD;
VAR S : ARRAY[0..80] OF CHAR;
BEGIN
  RdItem( F,S );
  RETURN StrToCard( S,10,OK );
END RdLngCard;

PROCEDURE RdShtHex(F: File) : SHORTCARD;
VAR
  S : ARRAY[0..80] OF CHAR;
  i : LONGCARD;
BEGIN
  RdItem( F,S );
  i  := StrToCard( S,16,OK );
  OK := OK AND (i < 0FFH);
  RETURN SHORTINT( i );
END RdShtHex;

PROCEDURE RdHex(F: File) : CARDINAL;
VAR
  S : ARRAY[0..80] OF CHAR;
  i : LONGCARD;
BEGIN
  RdItem( F,S );
  i  := StrToCard( S,16,OK );
  OK := OK AND (i < 10000H);
  RETURN INTEGER( i );
END RdHex;

PROCEDURE RdLngHex(F: File) : LONGCARD;
VAR S : ARRAY[0..80] OF CHAR;
BEGIN
  RdItem( F,S );
  RETURN StrToCard( S,16,OK );
END RdLngHex ;

PROCEDURE RdReal(F: File): REAL;
VAR
  S   : ARRAY[0..80] OF CHAR;
  r,a : LONGREAL;
BEGIN
  RdItem( F,S );
  r  := StrToReal( S,OK );
  a  := ABS( r );
  OK := OK AND (a >= 1.2E-38 ) AND (a <= 3.4E38 );
  RETURN VAL( REAL,r );
END RdReal;

PROCEDURE RdLngReal(F: File) : LONGREAL;
VAR S : ARRAY[0..80] OF CHAR;
BEGIN
  RdItem( F,S );
  RETURN StrToReal( S,OK );
END RdLngReal;

PROCEDURE WrBin(F: File; Buf: ARRAY OF BYTE; Count: CARDINAL);
VAR i : CARDINAL;
BEGIN
  OK := TRUE;
  i  := 0;
  IF (F > MaxHandle) OR (BufInf[F] = NIL) THEN
    Write( F,Buf,Count );
    OK := (IOR = 0);
  ELSE
    WITH BufInf[F]^ DO
      IF RWPos <= EOB THEN (* last was read *)
        Flush(F);
      END;
      i := 0;
      WHILE Count > i DO
        WHILE (RWPos < BufSize) AND ( Count > i ) DO
          Buffer[ RWPos ] := SHORTCARD(Buf[i]);
          INC( i );
          INC( RWPos );
        END;
        IF RWPos = BufSize THEN
          Write( F,Buffer,BufSize );
          RWPos := 0;
        END;
      END;
    END;
  END;
END WrBin;


PROCEDURE RdBin(F: File; VAR Buf: ARRAY OF BYTE; Count: CARDINAL) : CARDINAL;
VAR i,h,j : CARDINAL;
BEGIN
  i   := 0;
  OK  := TRUE;
  EOF := FALSE;
  IF Count > 0 THEN
    IF (F > MaxHandle) OR (BufInf[F] = NIL) THEN
      i  := Read( F,Buf,Count );
      OK := (IOR=0);
    ELSE
      WITH BufInf[F]^ DO
        IF RWPos > EOB THEN (* Last was write *) Flush( F ); END;
        i := 0;
        LOOP
          IF Count = i THEN EXIT; END;
          IF RWPos >= EOB THEN
            EOB   := Read( F,Buffer,BufSize );
            OK    := (IOR=0);
            RWPos := 0;
            IF EOB=0 THEN EXIT; END;
          END;
          WHILE (RWPos < EOB) AND (Count > i) DO
            Buf[i] := BYTE(Buffer[ RWPos ]);
            INC( i );
            INC( RWPos );
          END;
        END;
      END;
    END;
    IF (i = 0) THEN EOF := TRUE; END;
  END;
  RETURN i;
END RdBin;



PROCEDURE GetName(name: ARRAY OF CHAR; VAR fn: PathStr);
BEGIN
  Copy(fn,name);
  fn[SIZE(fn)-1] := CHR(0);
END GetName;


PROCEDURE Open(Name: ARRAY OF CHAR) : File;
VAR
  r : Registers;
  fn: PathStr;
BEGIN
  GetName(Name,fn);
  WITH r DO
    DS := Seg(fn);
    DX := Ofs(fn);
    CX := 0;
    AX := 3D02H;   (* open for read and write *)
    Lib.Dos(r);
    IF ((BITSET{CarryFlag} * Flags) # BITSET{}) AND (AX = 5) THEN
      (* access denied *)
      AX := 3D00H; (* open for read *)
      Lib.Dos(r);
    END;
    ErrorCheckNamed(r,'Open',fn);
    IF IOR = 0 THEN
      IF AX <= MaxHandle THEN BufInf[AX] := NIL; END;
      RETURN AX;
    END ;
    RETURN MAX(CARDINAL);
  END;
END Open;

PROCEDURE Exists(Name: ARRAY OF CHAR) : BOOLEAN;
VAR d : DirEntry;
    r : Registers ;
    b : BOOLEAN ;
BEGIN
  r.AX := 2F00H ;      (* save DTA *)
  Lib.Dos(r);
  b := ReadFirstEntry(Name,FileAttr{},d);
  r.AX := 1A00H ;
  r.DS := r.ES ;
  r.DX := r.BX ;
  Lib.Dos(r);          (* restore DTA *)
  RETURN b;
END Exists;

PROCEDURE Append(Name: ARRAY OF CHAR) : File;
VAR F : CARDINAL;
BEGIN
  F := Open( Name );
  Seek( F,Size( F ) );
  RETURN F;
END Append;

PROCEDURE Create(Name: ARRAY OF CHAR) : File;
VAR
  r : Registers;
  fn: PathStr;
BEGIN
  GetName(Name,fn);
  WITH r DO
    DS := Seg(fn);
    DX := Ofs(fn);
    CX := 0;
    AH := 3CH;
    Lib.Dos(r); (* Create, open for read and write *)
    ErrorCheckNamed(r,'Create',fn);
    IF IOR = 0 THEN
      IF AX <= MaxHandle THEN BufInf[AX] := NIL; END;
      RETURN AX;
    END ;
    RETURN MAX(CARDINAL);
  END;
END Create;

PROCEDURE Close(F: File);
VAR
  r : Registers;
  x : FileInf;
BEGIN
  Flush( F );
  IF F <= MaxHandle THEN
    BufInf[F] := NIL;
  END;
  WITH r DO
    BX := F;
    AH := 3EH; (* close file *)
    Lib.Dos(r);
    ErrorCheck(r,'Close');
  END;
END Close;

PROCEDURE GetPos(F: File) : LONGCARD;
VAR
  r    : Registers;
  x    : FileInf;
  conv : RECORD
           CASE : BOOLEAN OF
            | TRUE  : lo,hi: CARDINAL;
            | FALSE : long : LONGCARD;
           END;
         END;
BEGIN
  WITH r DO
    CX := 0;
    DX := 0;
    AX := 4201H; (* seek relative *)
    BX := F;
    Lib.Dos(r);
    ErrorCheck(r,'GetPos');
    conv.lo := AX;
    conv.hi := DX;
    IF (F <= MaxHandle) THEN
      x := BufInf[F];
      IF (x # NIL) THEN
        WITH x^ DO
          IF RWPos > EOB THEN
            INC(conv.long,VAL(LONGCARD,RWPos));
          ELSIF RWPos < EOB THEN
            DEC(conv.long,VAL(LONGCARD,EOB-RWPos));
          END;
        END;
      END;
    END;
    RETURN conv.long;
  END;
END GetPos;

PROCEDURE Seek( F : File; pos:LONGCARD );
VAR
  EOBpos : LONGCARD;
  r    : Registers;
  conv : RECORD
           CASE : BOOLEAN OF
            | TRUE  : lo,hi: CARDINAL;
            | FALSE : long : LONGCARD;
           END;
         END;

BEGIN
  IF (F<=MaxHandle) AND (BufInf[F]<>NIL) THEN
    WITH BufInf[F]^ DO
      IF (EOB>0) AND (RWPos<=EOB) THEN
        (* there are read bytes in the buffer *)
        (* find out where we are in the file *)
        WITH r DO
          CX := 0; DX := 0;
          AX := 4201H; (* seek relative *)
          BX := F;
          Lib.Dos(r); ErrorCheck(r,'Seek');
          conv.lo := AX; conv.hi := DX; EOBpos := conv.long;
        END;
        IF (pos>=EOBpos-LONGCARD(EOB)) AND (pos<EOBpos) THEN
          (* we can seek within the buffer *)
          RWPos := EOB - CARDINAL(EOBpos-pos);
          RETURN;
        END;
      ELSE
        IF RWPos > EOB THEN (* last was write, bring DOS up to date *)
          Write( F,Buffer,RWPos );
        END;
      END;
      (* the buffer contents are finished with now *)
      RWPos := 0;
      EOB := 0;
    END;
  END;
  (* we haven't done an in-buffer seek - so get DOS to do it for us *)
  conv.long := pos;
  WITH r DO
    CX := conv.hi;
    DX := conv.lo;
    AX := 4200H; (* seek absolute *)
    BX := F;
    Lib.Dos(r);
    ErrorCheck(r,'Seek');
  END;
END Seek;

PROCEDURE Size(F: File) : LONGCARD;
VAR
  r     : Registers;
  conv1,
  conv2 : RECORD
            CASE : BOOLEAN OF
             | TRUE  : lo,hi: CARDINAL;
             | FALSE : long : LONGCARD;
            END;
          END;

BEGIN
  Flush( F );
  WITH r DO
    CX := 0;
    DX := 0;
    AX := 4201H;   (* seek relative *)
    BX := F;
    Lib.Dos(r);
    conv1.hi := DX;
    conv1.lo := AX;
    CX := 0;
    DX := 0;
    AX := 4202H;   (* seek relative to end *)
    Lib.Dos(r);
    conv2.hi := DX;
    conv2.lo := AX;
    CX := conv1.hi;
    DX := conv1.lo;
    AX := 4200H;   (* seek absolute *)
    Lib.Dos(r);
    ErrorCheck(r,'Size');
  END;
  RETURN conv2.long;
END Size;


PROCEDURE Erase(Name:ARRAY OF CHAR);
VAR
  r  : Registers;
  fn : PathStr;
BEGIN
  GetName(Name,fn);
  WITH r DO
    DS := Seg(fn);
    DX := Ofs(fn);
    AH := 41H;
    Lib.Dos(r);
    IF ((BITSET{CarryFlag} * Flags) # BITSET{}) AND (AX = 2) THEN
      Flags := BITSET{};
    END;
    ErrorCheckNamed(r,'Erase',fn);
  END;
END Erase;


PROCEDURE Rename(Name,newname: ARRAY OF CHAR);
VAR
  r : Registers;
  fn,fn2: PathStr;
BEGIN
  GetName(Name,fn);
  GetName(newname,fn2);
  WITH r DO
    DS := Seg(fn);
    DX := Ofs(fn);
    ES := Seg(fn2);
    DI := Ofs(fn2);
    AH := 56H;
    Lib.Dos(r);
    ErrorCheckNamed(r,'Rename',fn);
  END;
END Rename;


PROCEDURE ReadFirstEntry ( DirName : ARRAY OF CHAR;
                           Attr    : FileAttr;
                           VAR D   : DirEntry) : BOOLEAN;
VAR
  r  : Registers;
  fn : PathStr;
BEGIN
  GetName(DirName,fn);
  WITH r DO
    AH := 1AH;
    DS := Seg(D);
    DX := Ofs(D);
    Lib.Dos(r);    (* set DTA *)
    AH := 4EH;
    DS := Seg(fn);
    DX := Ofs(fn);
    CL := SHORTCARD(Attr);
    Lib.Dos(r);
    IF ((BITSET{CarryFlag} * Flags) # BITSET{}) AND (AX = 18) THEN
      IOR := 0;
      RETURN FALSE;
    END;
    ErrorCheckNamed(r,'ReadFirstEntry',fn);
  END;
  RETURN TRUE;
END ReadFirstEntry;

PROCEDURE ReadNextEntry(VAR D: DirEntry) : BOOLEAN;
VAR
  r : Registers;
BEGIN
  WITH r DO
    AH := 1AH;
    DS := Seg(D);
    DX := Ofs(D);
    Lib.Dos(r);    (* set DTA *)
    AH := 4FH;
    Lib.Dos(r);
    IF ((BITSET{CarryFlag} * Flags) # BITSET{}) AND (AX = 18) THEN
      IOR := 0;
      RETURN FALSE;
    END;
    ErrorCheck(r,'ReadNextEntry');
  END;
  RETURN TRUE;
END ReadNextEntry;


PROCEDURE ChDir(Name: ARRAY OF CHAR);
VAR
  r  : Registers;
  fn : PathStr;
BEGIN
  GetName(Name,fn);
  WITH r DO
    IF fn[1] = ':' THEN
      AH := 0EH;
      DL := SHORTCARD(CAP(fn[0]))-SHORTCARD('A');
      Lib.Dos(r);
    END;
    DS := Seg(fn);
    DX := Ofs(fn);
    AH := 3BH;
    Lib.Dos(r);
    ErrorCheckNamed(r,'ChDir',fn);
  END;
END ChDir;

PROCEDURE MkDir(Name: ARRAY OF CHAR);
VAR
  r  : Registers;
  fn : PathStr;
BEGIN
  GetName(Name,fn);
  WITH r DO
    DS := Seg(fn);
    DX := Ofs(fn);
    AH := 39H;
    Lib.Dos(r);
    ErrorCheckNamed(r,'MkDir',fn);
  END;
END MkDir;

PROCEDURE RmDir(Name: ARRAY OF CHAR);
VAR
  r  : Registers;
  fn : PathStr;
BEGIN
  GetName(Name,fn);
  WITH r DO
    DS := Seg(fn);
    DX := Ofs(fn);
    AH := 3AH;
    Lib.Dos(r);
    ErrorCheckNamed(r,'RmDir',fn);
  END;
END RmDir;

PROCEDURE GetDir(drive: SHORTCARD; VAR Name: ARRAY OF CHAR);
VAR
  r  : Registers;
  fn : PathStr;
BEGIN
  WITH r DO
    DS := Seg(fn);
    SI := Ofs(fn);
    DL := drive;
    AH := 47H;
    Lib.Dos(r);
    ErrorCheck(r,'GetDir');
  END;
  Copy(Name,fn);
END GetDir;


PROCEDURE InitBufInf;
VAR i : CARDINAL;
BEGIN
  FOR i := 0 TO MaxHandle DO BufInf[i] := NIL; END;
END InitBufInf;

PROCEDURE AssignBuffer(F: File; VAR Buf: ARRAY OF BYTE);
BEGIN
  IF (F <= MaxHandle) AND ( HIGH(Buf) > SIZE(BufRec) ) THEN
    BufInf[F] := ADR(Buf);
    WITH BufInf[F]^ DO
      RWPos   := 0;
      EOB     := 0;
      BufSize := HIGH(Buf)-SIZE(BufRec)+2;
    END;
  END;
END AssignBuffer;


BEGIN
  Eng     := FALSE;
  IOcheck := TRUE;
  OK      := TRUE;
  ChopOff := FALSE;
  Separators := CHARSET{CHR(9),CHR(10),CHR(13),CHR(26),' '};
  InitBufInf;
END FIO.

