(* Copyright (C) 1987 Jensen & Partners International *)

(*$N,V-,I-,R-,A-,S-*)
IMPLEMENTATION MODULE Graph;
IMPORT Lib, SYSTEM;

TYPE
  tinyint      = [0..7];
  bs           = SET OF tinyint;
  bp           = POINTER TO bs;
  HercMapType  = ARRAY[0..(HercDepth DIV 4)-1] OF
                   ARRAY[0..(HercWidth DIV 8)-1] OF bs;
  ATTMapType   = ARRAY[0..(ATTDepth DIV 4)-1] OF
                   ARRAY[0..(ATTWidth DIV 8)-1] OF bs;
VAR
  HercBitMap   : ARRAY[0..3] OF POINTER TO HercMapType;
  ATTBitMap    : ARRAY[0..3] OF POINTER TO ATTMapType;
  EGAScreen [0A000H:0] : ARRAY[0..0] OF bs;


(* == CGA specific routines == *)


PROCEDURE CGAGraphMode;
VAR r : SYSTEM.Registers;
BEGIN
  r.AX := 5;
  Lib.Intr( r,10H );
END CGAGraphMode;

PROCEDURE CGATextMode;
VAR r : SYSTEM.Registers;
BEGIN
  r.AX := 3;
  Lib.Intr( r,10H );
END CGATextMode;

PROCEDURE CGAPlot(x,y:CARDINAL;c:CARDINAL);
VAR
  off : CARDINAL;
  seg : CARDINAL;
  tmp : CARDINAL;
BEGIN
  IF (x >= CGAWidth) OR (y >= CGADepth) THEN RETURN END;
  off := x >> 2;
  IF ODD(y) THEN INC( off, 2000H - 40 ) END;
  INC( y, y << 2 );
  INC( off, y << 3 );
  x := 3 - CARDINAL( BITSET(x) * BITSET(3) );
  x := x << 1;
  tmp := 0B800H; seg := tmp;
  [seg:off bp]^ := ( [seg:off bp]^ - bs(3<<x) ) + bs(c<<x);
END CGAPlot;

PROCEDURE CGAPoint(x,y:CARDINAL) : CARDINAL;
VAR
  off : CARDINAL;
  seg : CARDINAL;
  tmp : CARDINAL;
BEGIN
  IF (x >= CGAWidth) OR (y >= CGADepth) THEN RETURN MAX(CARDINAL) END;
  off := x >> 2;
  IF ODD(y) THEN INC( off, 2000H - 40 ) END;
  INC( y, y << 2 );
  INC( off, y << 3 );
  x := 3 - CARDINAL( BITSET(x) * BITSET(3) );
  x := x << 1;
  tmp := 0B800H; seg := tmp;
  RETURN CARDINAL( [seg:off bp]^ * bs(3<<x) ) >> x;
END CGAPoint;

PROCEDURE CGAHLine ( x,y,x2 : CARDINAL; c:CARDINAL );
VAR
  off  : CARDINAL;
  seg  : CARDINAL;
  tmp  : CARDINAL;
  n    : CARDINAL;
  w    : bs;
  mask : bs;
  fillc: SHORTCARD;
BEGIN
  IF y > CGADepth-1 THEN RETURN END;
  IF INTEGER(x) >= INTEGER(CGAWidth) THEN RETURN END;
  IF INTEGER(x) < 0 THEN x := 0; END;
  IF x2 >= CGAWidth THEN x2 := CGAWidth-1 END;

  n := ( x2 - x ) + 1;
  off := x >> 2;
  IF ODD(y) THEN
    INC( off, 2000H - 40 );
    c := ( c >> 2 + c << 2 ) MOD 16;
  END;
  c := c + c * 16;
  INC( y, y << 2 );
  INC( off, y << 3 );
  x := 3 - CARDINAL( BITSET(x) * BITSET(3) );
  x := x << 1;
  tmp := 0B800H; seg := tmp;

  w := [seg:off bp]^;
  REPEAT
    mask := bs(3 << x);
    w := ( w - mask ) + bs(c)*mask;
    DEC(n);
    DEC(x,2);
  UNTIL (n=0) OR (x=CARDINAL(-2));
  [seg:off bp]^ := w;

  INC(off);
  Lib.Fill( [seg:off], n >> 2, SHORTCARD(c) );
  INC( off, n >> 2 );
  n := n MOD 4;
  x := 6;
  w := [seg:off bp]^;
  WHILE n <> 0 DO
    mask := bs(3 << x);
    w := ( w - mask ) + bs(c)*mask;
    DEC(n);
    DEC(x,2);
  END;
  [seg:off bp]^ := w;
END CGAHLine;

PROCEDURE InitCGA ;
BEGIN
  Width := CGAWidth ;
  Depth := CGADepth ;
  NumColor := 4 ;
  TextMode := CGATextMode ;
  GraphMode := CGAGraphMode ;
  Plot := CGAPlot ;
  Point := CGAPoint ;
  HLine := CGAHLine ;
END InitCGA ;

(* == EGA/VGA specific routines == *)

PROCEDURE EGAGraphMode; (* Also VGA *)
VAR r : SYSTEM.Registers;
BEGIN
  IF Depth=480 THEN r.AX := 12H ELSE r.AX := 10H END ;
  Lib.Intr( r,10H );
END EGAGraphMode;


PROCEDURE EGAPlot( x,y,c : CARDINAL); (* Also VGA *)
VAR
  t:bs;
  p,b,s:CARDINAL;
BEGIN
   IF (x < EGAWidth) AND (y < Depth) THEN
      b := 1 << (7-(x MOD 8));
      p := y*80+(x DIV 8);
      SYSTEM.Out( 3CEH,8);SYSTEM.Out( 3CFH,SHORTCARD(b));
      SYSTEM.Out( 3C4H,2);SYSTEM.Out( 3C5H,0FH);
      s := 0A000H;
      t := [s:p bp]^;
      [s:p bp]^ := bs{};
      SYSTEM.Out( 3C4H,2);SYSTEM.Out( 3C5H,SHORTCARD(c));
      [s:p bp]^ := bs{0..7};
      SYSTEM.Out( 3CEH,8);SYSTEM.Out( 3CFH,0FFH);
      SYSTEM.Out( 3C4H,2);SYSTEM.Out( 3C5H,0FH);
   END;
END EGAPlot;

PROCEDURE EGAPoint(x,y:CARDINAL) : CARDINAL; (* Also VGA *)
VAR
  t:bs;
  p,b,s:CARDINAL;
  c:CARDINAL;
BEGIN
  IF (x < EGAWidth) AND (y < Depth) THEN
    b := 1 << (7-(x MOD 8));
    p := y*80+(x DIV 8  );

    s := 0A000H;

    SYSTEM.Out( 3CEH, 4 ); (* read map sel *)

    SYSTEM.Out( 3CFH, 3 );
    t := [s:p bp]^;
    t := t * bs(b);
    c := CARDINAL( SHORTCARD(t) );

    SYSTEM.Out( 3CFH, 2 );
    t := [s:p bp]^;
    t := t * bs(b);
    c := c * 2 + CARDINAL( SHORTCARD(t) );

    SYSTEM.Out( 3CFH, 1 );
    t := [s:p bp]^;
    t := t * bs(b);
    c := c * 2 + CARDINAL( SHORTCARD(t) );

    SYSTEM.Out( 3CFH, 0 );
    t := [s:p bp]^;
    t := t * bs(b);
    c := c * 2 + CARDINAL( SHORTCARD(t) );

    c := c >> ( 7 - ( x MOD 8 ) );

    RETURN c;
  ELSE
    RETURN 0;
  END;
END EGAPoint;

PROCEDURE EGAHLine ( x,y,x2 : CARDINAL; c:CARDINAL ); (* Also VGA *)
VAR c1,c2 : CARDINAL;
BEGIN
  IF y > Depth-1 THEN RETURN END;
  IF INTEGER(x) >= INTEGER(EGAWidth) THEN RETURN END;
  IF INTEGER(x) < 0 THEN x := 0; END;
  IF x2 >= EGAWidth THEN x2 := EGAWidth-1 END;
  WHILE (x MOD 8 # 0)  AND (x <= x2) DO
    EGAPlot( x  , y , c ); INC( x  );
  END;
  WHILE (x2 MOD 8 # 7) AND (x <= x2) DO
    EGAPlot( x2 , y , c ); DEC( x2 );
  END;
  IF INTEGER(x) > INTEGER(x2) THEN RETURN; END;
  SYSTEM.Out( 3CEH,8);SYSTEM.Out( 3CFH,0FFH);
  SYSTEM.Out( 3C4H,2);SYSTEM.Out( 3C5H,0FH);
  SYSTEM.Out( 3CEH,5);SYSTEM.Out( 3CFH,2);
  y := y*80;
  x := x DIV 8;
  x2 := x2 DIV 8;
  WHILE x <= x2 DO
    EGAScreen[y+x] := bs(c);
    INC( x );
  END;
  SYSTEM.Out( 3CEH,5);SYSTEM.Out( 3CFH,0);
END EGAHLine;


PROCEDURE InitEGA ;
BEGIN
  Width     := EGAWidth ;
  Depth     := EGADepth ;
  NumColor  := 16 ;
  TextMode  := CGATextMode ;
  GraphMode := EGAGraphMode ;
  Plot      := EGAPlot ;
  Point     := EGAPoint ;
  HLine     := EGAHLine ;
END InitEGA ;

PROCEDURE InitVGA ;
BEGIN
  InitEGA ;
  Depth := VGADepth ; (* Width same as EGA *)
END InitVGA ;


(* == Hercules specific routines == *)


PROCEDURE HercGraphMode;
TYPE
  DataType = ARRAY[0..11] OF SHORTCARD ;
CONST
  Data = DataType(35H,2DH,2EH,07H,5BH,02H,57H,57H,02H,03H,00H,00H);
VAR
  I: CARDINAL;
BEGIN
    SYSTEM.Out(3BFH,03H);    (* Remove this if do NOT want to override
                                the hercules text mode lock *)
    Lib.Delay(10);
    SYSTEM.Out(3B8H,02H);
    FOR I:= 0 TO 11 DO
        SYSTEM.Out(3B4H,SHORTCARD(I));
        SYSTEM.Out(3B5H,Data[I])
    END;
    Lib.WordFill([0B000H:0],4000H,0);
    Lib.Delay(500);
    SYSTEM.Out(3B8H,0AH)
END HercGraphMode;

PROCEDURE HercTextMode;
TYPE
  DataType = ARRAY[0..11] OF SHORTCARD ;
CONST
  Data = DataType(61H,50H,52H,0FH,19H,06H,19H,19H,02H,0DH,0BH,0CH);
VAR
  I: CARDINAL;
BEGIN
    SYSTEM.Out(3B8H,20H);
    FOR I:= 0 TO 11 DO
        SYSTEM.Out(3B4H,SHORTCARD(I));
        SYSTEM.Out(3B5H,Data[I])
    END;
    Lib.WordFill([0B000H:0],2000,720H);
    Lib.Delay(500);
    SYSTEM.Out(3B8H,28H)
END HercTextMode;

PROCEDURE HercPlot(x,y:CARDINAL;c:CARDINAL);
BEGIN
  IF (x >= HercWidth) OR (y >= HercDepth) THEN RETURN END;
  IF c = 0 THEN
     EXCL(HercBitMap[y MOD 4]^[y >> 2][x >> 3], 7-(x MOD 8))
  ELSE
     INCL(HercBitMap[y MOD 4]^[y >> 2][x >> 3], 7-(x MOD 8))
  END
END HercPlot;

PROCEDURE HercPoint(x,y:CARDINAL) : CARDINAL;
BEGIN
  IF (x >= HercWidth) OR (y >= HercDepth) THEN RETURN MAX(CARDINAL); END;
  RETURN CARDINAL(7-(x MOD 8) IN HercBitMap[y MOD 4]^[y >> 2][x >> 3])
END HercPoint;

PROCEDURE HercHLine ( x,y,x2 : CARDINAL; c:CARDINAL );
VAR
  I         : CARDINAL;
  MapNum    : CARDINAL;
  Byte1     : CARDINAL;
  Byte2     : CARDINAL;
  Bitx      : CARDINAL;
  Bitx2     : CARDINAL;
  Mask      : bs;
  IMask     : bs;
BEGIN
  IF y > HercDepth-1 THEN RETURN END;
  IF INTEGER(x) >= INTEGER(HercWidth) THEN RETURN END;
  IF INTEGER(x) < 0 THEN x := 0; END;
  IF x2 >= HercWidth THEN x2 := HercWidth-1 END;
  IF c = 0 THEN
     (* No Mask needed *)
  ELSIF c MOD (HercNumColor+1) = 0 THEN
     Mask:= bs{0..7}
  ELSE
     Mask:= bs(0AAH >> CARDINAL(ODD(y)));
  END;

  MapNum    := y MOD 4;
  y         := y >> 2;
  Byte1     := x >> 3;
  Byte2     := x2 >> 3;
  Bitx      := 7-(x MOD 8);
  Bitx2     := 7-(x2 MOD 8);

  IF c = 0 THEN
     IF Byte2 = Byte1 THEN
        HercBitMap[MapNum]^[y][Byte1]:=
        (HercBitMap[MapNum]^[y][Byte1] - bs{Bitx2..Bitx});
     ELSE
        HercBitMap[MapNum]^[y][Byte1]:=
        (HercBitMap[MapNum]^[y][Byte1] - bs{0..Bitx});

        IF Byte2-Byte1 > 1 THEN
           Lib.Fill(ADR(HercBitMap[MapNum]^[y][Byte1+1]),Byte2-Byte1-1,0)
        END;

        HercBitMap[MapNum]^[y][Byte2]:=
        (HercBitMap[MapNum]^[y][Byte2] - bs{Bitx2..7});
     END
  ELSE
     IF Byte2 = Byte1 THEN
        HercBitMap[MapNum]^[y][Byte1]:=
        ((HercBitMap[MapNum]^[y][Byte1]-bs{Bitx2..Bitx})
        + (Mask * bs{Bitx2..Bitx}));
     ELSE
        HercBitMap[MapNum]^[y][Byte1]:=
        ((HercBitMap[MapNum]^[y][Byte1]-bs{0..Bitx})
        + (Mask * bs{0..Bitx}));

        IF Byte2-Byte1 > 1 THEN
           Lib.Fill(ADR(HercBitMap[MapNum]^[y][Byte1+1]),Byte2-Byte1-1,
                    Mask)
        END;

        HercBitMap[MapNum]^[y][Byte2]:=
        ((HercBitMap[MapNum]^[y][Byte2]-bs{Bitx2..7})
        + (Mask * bs{Bitx2..7}));
     END
  END
END HercHLine;

PROCEDURE InitHerc ;
BEGIN
  Width     := HercWidth ;
  Depth     := HercDepth ;
  NumColor  := 2 ;
  TextMode  := HercTextMode ;
  GraphMode := HercGraphMode ;
  Plot      := HercPlot ;
  Point     := HercPoint ;
  HLine     := HercHLine ;
  HercBitMap[0]:= [0B000H:0];      (* Initialise BitMap pointers *)
  HercBitMap[1]:= [0B000H:02000H];
  HercBitMap[2]:= [0B000H:04000H];
  HercBitMap[3]:= [0B000H:06000H];
END InitHerc ;

(* == AT&T 400 specific routines == *)



PROCEDURE ATTGraphMode;
VAR r : SYSTEM.Registers;
BEGIN
  r.AX := 64;
  Lib.Intr( r,10H );
END ATTGraphMode;


PROCEDURE ATTPlot(x,y:CARDINAL;c:CARDINAL);
BEGIN
  IF (x >= ATTWidth) OR (y >= ATTDepth) THEN RETURN END;
  IF c = 0 THEN
     EXCL(ATTBitMap[y MOD 4]^[y >> 2][x >> 3], 7-(x MOD 8))
  ELSE
     INCL(ATTBitMap[y MOD 4]^[y >> 2][x >> 3], 7-(x MOD 8))
  END
END ATTPlot;

PROCEDURE ATTPoint(x,y:CARDINAL) : CARDINAL;
BEGIN
  IF (x >= ATTWidth) OR (y >= ATTDepth) THEN RETURN MAX(CARDINAL); END;
  RETURN CARDINAL(7-(x MOD 8) IN ATTBitMap[y MOD 4]^[y >> 2][x >> 3])
END ATTPoint;

PROCEDURE ATTHLine ( x,y,x2 : CARDINAL; c:CARDINAL );
VAR
  I         : CARDINAL;
  MapNum    : CARDINAL;
  Byte1     : CARDINAL;
  Byte2     : CARDINAL;
  Bitx      : CARDINAL;
  Bitx2     : CARDINAL;
  Mask      : bs;
BEGIN
  IF y > ATTDepth-1 THEN RETURN END;
  IF INTEGER(x) >= INTEGER(ATTWidth) THEN RETURN END;
  IF INTEGER(x) < 0 THEN x := 0; END;
  IF x2 >= ATTWidth THEN x2 := ATTWidth-1 END;

  IF c = 0 THEN
     (* No Mask needed *)
  ELSIF c MOD (ATTNumColor+1) = 0 THEN
     Mask:= bs{0..7}
  ELSE
     Mask:= bs(0AAH >> CARDINAL(ODD(y)));
  END;

  MapNum    := y MOD 4;
  y         := y >> 2;
  Byte1     := x >> 3;
  Byte2     := x2 >> 3;
  Bitx      := 7-(x MOD 8);
  Bitx2     := 7-(x2 MOD 8);

  IF c = 0 THEN
     IF Byte2 = Byte1 THEN
        ATTBitMap[MapNum]^[y][Byte1]:=
        (ATTBitMap[MapNum]^[y][Byte1] - bs{Bitx2..Bitx});
     ELSE
        ATTBitMap[MapNum]^[y][Byte1]:=
        (ATTBitMap[MapNum]^[y][Byte1] - bs{0..Bitx});

        IF Byte2-Byte1 > 1 THEN
           Lib.Fill(ADR(ATTBitMap[MapNum]^[y][Byte1+1]),Byte2-Byte1-1,0)
        END;

        ATTBitMap[MapNum]^[y][Byte2]:=
        (ATTBitMap[MapNum]^[y][Byte2] - bs{Bitx2..7});
     END
  ELSE
     IF Byte2 = Byte1 THEN
        ATTBitMap[MapNum]^[y][Byte1]:=
        ((ATTBitMap[MapNum]^[y][Byte1]-bs{Bitx2..Bitx})
        + (Mask * bs{Bitx2..Bitx}));
     ELSE
        ATTBitMap[MapNum]^[y][Byte1]:=
        ((ATTBitMap[MapNum]^[y][Byte1]-bs{0..Bitx})
        + (Mask * bs{0..Bitx}));

        IF Byte2-Byte1 > 1 THEN
           Lib.Fill(ADR(ATTBitMap[MapNum]^[y][Byte1+1]),Byte2-Byte1-1,
                    Mask)
        END;

        ATTBitMap[MapNum]^[y][Byte2]:=
        ((ATTBitMap[MapNum]^[y][Byte2]-bs{Bitx2..7})
        + (Mask * bs{Bitx2..7}));
     END
  END
END ATTHLine;

PROCEDURE InitATT ;
BEGIN
  Width     := ATTWidth ;
  Depth     := ATTDepth ;
  NumColor  := 2 ;
  TextMode  := CGATextMode ;
  GraphMode := ATTGraphMode ;
  Plot      := ATTPlot ;
  Point     := ATTPoint ;
  HLine     := ATTHLine ;
  ATTBitMap[0]:= [0B000H:8000H];  (* Initialise BitMap pointers *)
  ATTBitMap[1]:= [0B000H:0A000H];
  ATTBitMap[2]:= [0B000H:0C000H];
  ATTBitMap[3]:= [0B000H:0E000H];
END InitATT ;


(* ------  Device independant routines ------ *)




PROCEDURE Line(x1,y1,x2,y2: CARDINAL; c: CARDINAL);
VAR
  dx,dy,e,tmp : INTEGER;
BEGIN
  IF x1 > x2 THEN (* ensure that x2 >= x1 *)
    tmp := x1; x1 := x2; x2 := tmp;
    tmp := y1; y1 := y2; y2 := tmp;
  END;

  dx := x2-x1;
  e  := 0;
  IF y1 <= y2 THEN (* case where y increases *)
    dy := (y2-y1);
    IF dx >= dy THEN
      LOOP
        Plot( x1,y1,c );
        IF x1 = x2 THEN EXIT END;
        INC(x1);
        INC(e,dy);
        INC(e,dy);
        IF e > dx THEN
          DEC(e,dx);
          DEC(e,dx);
          INC(y1);
        END;
      END;
    ELSE
      LOOP
        Plot( x1,y1,c );
        IF y1 = y2 THEN EXIT END;
        INC(y1);
        INC(e,dx);
        INC(e,dx);
        IF e > dy THEN
          DEC(e,dy);
          DEC(e,dy);
          INC(x1);
        END;
      END;
    END;
  ELSE
    (* case where y decreases *)
    dy := (y1-y2);
    IF dx >= dy THEN
      LOOP
        Plot( x1,y1,c );
        IF x1 = x2 THEN EXIT END;
        INC(x1);
        INC(e,dy);
        INC(e,dy);
        IF e > dx THEN
          DEC(e,dx);
          DEC(e,dx);
          DEC(y1);
        END;
      END;
    ELSE
      LOOP
        Plot( x1,y1,c );
        IF y1 = y2 THEN EXIT END;
        DEC(y1);
        INC(e,dx);
        INC(e,dx);
        IF e > dy THEN
          DEC(e,dy);
          DEC(e,dy);
          INC(x1);
        END;
      END;
    END;
  END;
END Line;


CONST
  dx = 2;
  dy = 2;

PROCEDURE Disc(x0,y0,r: CARDINAL; c: CARDINAL);
VAR
  e   : INTEGER;
  x,y : CARDINAL;
BEGIN
  x := r; y := 0; e := 0;
  WHILE INTEGER(y) <= INTEGER(x) DO
    HLine(x0-x,y0+y,x0+x,c);
    HLine(x0-x,y0-y,x0+x,c);
    INC(y);
    INC(e,y*dy-1);
    IF e > INTEGER(x) THEN
      DEC(x);
      DEC(e,x*dx+1);
      HLine(x0-y,y0+x,x0+y,c);
      HLine(x0-y,y0-x,x0+y,c);
    END;
  END;
END Disc;

PROCEDURE Circle(x0,y0,r: CARDINAL; c: CARDINAL);
VAR
  e   : INTEGER;
  x,y : CARDINAL;
BEGIN
  x := r; y := 0; e := 0;
  WHILE INTEGER(y) <= INTEGER(x) DO
    Plot(x0+x,y0+y,c);
    Plot(x0-x,y0+y,c);
    Plot(x0+x,y0-y,c);
    Plot(x0-x,y0-y,c);
    Plot(x0+y,y0+x,c);
    Plot(x0-y,y0+x,c);
    Plot(x0+y,y0-x,c);
    Plot(x0-y,y0-x,c);
    INC(y);
    INC(e,y*dy-1);
    IF e > INTEGER(x) THEN
      DEC(x);
      DEC(e,x*dx+1);
    END;
  END;
END Circle;

PROCEDURE Ellipse ( x0,y0 : CARDINAL ;  (* center *)
                    a0,b0 : CARDINAL ;  (* semi-axes *)
                    c     : CARDINAL ;  (* color *)
                    fill  : BOOLEAN ) ; (* wether filled *)
VAR
  x,y : CARDINAL ;
  a,b : LONGINT ;
  asq,asq2,bsq,bsq2 : LONGINT ;
  d,dx,dy           : LONGINT ;
BEGIN
  x := 0 ;
  y := b0 ;
  a := LONGINT(a0) ;
  b := LONGINT(b0) ;
  asq := a*a ;
  asq2 := asq*2 ;
  bsq := b*b ;
  bsq2 := bsq*2 ;
  d := bsq-(asq*b)+(asq DIV 4) ;
  dx := 0 ;
  dy := asq2*b ;
  WHILE dx<dy DO
    IF fill THEN
      HLine(x0-x,y0+y,x0+x,c);
      HLine(x0-x,y0-y,x0+x,c);
    ELSE
      Plot(x0+x,y0+y,c) ;
      Plot(x0-x,y0+y,c) ;
      Plot(x0+x,y0-y,c) ;
      Plot(x0-x,y0-y,c) ;
    END ;
    IF d>0 THEN
      DEC(y) ;
      DEC(dy,asq2) ;
      DEC(d,dy) ;
    END ;
    INC(x) ;
    INC(dx,bsq2) ;
    INC(d,bsq+dx) ;
  END ;
  INC(d,(3*(asq-bsq)DIV 2-(dx+dy))DIV 2) ;
  WHILE INTEGER(y)>=0 DO
    IF fill THEN
      HLine(x0-x,y0+y,x0+x,c);
      HLine(x0-x,y0-y,x0+x,c);
    ELSE
      Plot(x0+x,y0+y,c) ;
      Plot(x0-x,y0+y,c) ;
      Plot(x0+x,y0-y,c) ;
      Plot(x0-x,y0-y,c) ;
    END ;
    IF d<0 THEN
      INC(x) ;
      INC(dx,bsq2) ;
      INC(d,dx) ;
    END ;
    DEC(y) ;
    DEC(dy,asq2) ;
    INC(d,asq-dy) ;
  END ;
END Ellipse ;


PROCEDURE Polygon(n: CARDINAL; px,py: ARRAY OF CARDINAL; c: CARDINAL);
CONST
  MaxPts = 20;
VAR
  y,miny,maxy,x0,y0,x1,y1,temp,i,edge,next_edge,active : INTEGER;
  xord : ARRAY [0..MaxPts] OF INTEGER;
  x    : ARRAY [0..MaxPts] OF CARDINAL;
  e    : ARRAY [0..MaxPts] OF INTEGER;

PROCEDURE quicksort(l,r: INTEGER);
VAR
  i,j,temp : INTEGER;
  key : CARDINAL;
BEGIN
  WHILE ( l < r ) DO
    i := l; j := r; key := x[xord[j]];
    REPEAT
      WHILE ( i < j ) AND ( x[xord[i]] <= key ) DO i := i + 1 END;
      WHILE ( i < j ) AND ( key <= x[xord[j]] ) DO j := j - 1 END;
      IF i < j THEN
        temp := xord[i]; xord[i] := xord[j]; xord[j] := temp;
      END;
    UNTIL ( i >= j );
    temp := xord[i]; xord[i] := xord[r]; xord[r] := temp;
    IF (i-l < r-i) THEN
      quicksort( l, i-1 ); l := i+1;
    ELSE
      quicksort( i+1, r ); r := i-1;
    END;
  END;
END quicksort;

BEGIN
  IF n > MaxPts THEN n := MaxPts END;

  (* find extremal y points *)
  miny := py[0]; maxy := miny;
  FOR i := 0 TO n-1 DO
    IF INTEGER(py[i]) < miny THEN miny := py[i]; END;
    IF INTEGER(py[i]) > maxy THEN maxy := py[i]; END;
  END;

  FOR y := miny TO maxy DO
    active := -1;
    FOR edge := 0 TO n-1 DO
      IF edge = INTEGER(n-1) THEN next_edge := 0
                             ELSE next_edge := edge + 1;
      END;
      x0 := px[edge]; y0 := py[edge];
      x1 := px[next_edge]; y1 := py[next_edge];
      IF y0 > y1 THEN temp := x0; x0 := x1; x1 := temp;
                      temp := y0; y0 := y1; y1 := temp END;
      IF y = y0 THEN e[edge] :=  0; x[edge] := x0
      ELSIF ( y0 <= y ) AND ( y <= y1 ) THEN
        IF x1 >= x0 THEN (* x increases with y *)
          INC( e[edge], 2*(x1-x0) );
          WHILE e[edge] > INTEGER(y1-y0) DO
            DEC( e[edge], 2*(y1-y0) ); INC(x[edge]);
          END;
        ELSE (* x decreases with y *)
          INC( e[edge], 2*(x0-x1) );
          WHILE e[edge] > INTEGER(y1-y0) DO
            DEC( e[edge], 2*(y1-y0) ); DEC(x[edge]);
          END;
        END;
        active := active + 1;
        xord[active] := edge;
      END;
    END;
    quicksort(0,active);
    i := 0;
    WHILE i < active DO
      HLine( x[xord[i]], y, x[xord[i+1]], c );
      i := i + 2;
    END;
  END; (* for y := .. *)
END Polygon;




(* - Auto reset to text mode

VAR Continue:PROC;
PROCEDURE Finish;
BEGIN
  TextMode;
  Continue;
END Finish;

BEGIN
  Lib.Terminate( Finish, Continue );
  InitCGA ;
END Gr.

*)

BEGIN
  InitEGA ; (* Change this for other adaptors *)
END Graph.


