(* Copyright (C) 1987 Jensen & Partners International *)
(*$V-,R-,S-,I-,A-,O-*)
IMPLEMENTATION MODULE Window;

FROM SYSTEM  IMPORT Registers,CurrentProcess,Seg,Ofs;
FROM Storage IMPORT ALLOCATE,DEALLOCATE;
FROM Str     IMPORT Length,CHARSET,Copy;
FROM Lib     IMPORT Move,WordMove,Fill,WordFill,ScanR,FatalError;
FROM AsmLib  IMPORT BufferToScreen,BufferWrite,ActivePage,PalXlat,
                    ScreenToBuffer,InitScreenType;

IMPORT Lib,IO;

TYPE
  UseListPtr  = POINTER TO UseListLink;
  UseListLink = RECORD
                  Next : UseListPtr;
                  Proc : ADDRESS;
                  Wind : WinType;
                END;
VAR
  UseList      : UseListPtr;
  WindowStack  : WinType;
  CursorStack  : WinType;
  MultiP       : BOOLEAN;
  Lock,Unlock  : PROC;
  CursorLines  : CARDINAL ;


CONST
  GuardConst = 4A4EH;


PROCEDURE CheckWindow (*$N*) ( W : WinType );
BEGIN
  IF W^.Guard-Seg(W^) <> GuardConst THEN
    FatalError('Window, Fatal error : Invalid window');
  END;
END CheckWindow;



PROCEDURE (*$N*) ClipFrame ( W : WinType );
VAR
  i : CARDINAL;
BEGIN
  WITH W^ DO
    IF WDef.FrameOn THEN i := 1 ELSE i := 0 END;
    IF XA < WDef.X1+i THEN
      XA := WDef.X1+i
    ELSIF XA > WDef.X2-i THEN
      XA := WDef.X2-i
    END;
    IF XB > WDef.X2-i THEN
      XB := WDef.X2-i
    ELSIF XB < WDef.X1+i THEN
      XB := WDef.X1+i
    END;
    IF YA < WDef.Y1+i THEN
      YA := WDef.Y1+i
    ELSIF YA > WDef.Y2-i THEN
      YA := WDef.Y2-i
    END;
    IF YB > WDef.Y2-i THEN
      YB := WDef.Y2-i
    ELSIF YB < WDef.Y1+i THEN
      YB := WDef.Y1+i
    END;
    Width := XB-XA+1; Depth := YB-YA+1;
  END;
END ClipFrame;

PROCEDURE ClipXY ( W : WinType; VAR X,Y : RelCoord );
VAR
  mw,md : CARDINAL;
BEGIN
  WITH W^ DO
    mw := Width; md := Depth;
    IF WDef.FrameOn AND NOT WDef.WrapOn THEN
      INC(md); INC(mw)
    ELSE
      IF X=0 THEN X := 1 END;
      IF Y=0 THEN Y := 1 END;
    END;
    IF X>mw THEN X := mw END;
    IF Y>md THEN Y := md END;
  END;
END ClipXY;


PROCEDURE (*$N*) BufferSpaceFill ( W : WinType; pos : CARDINAL; len : CARDINAL );
BEGIN
  WITH W^ DO
    IF IsPalette THEN
      WordFill(ADR(Buffer^[pos]),len,32
               +VAL(CARDINAL,CurPalColor)*256);
    ELSE
      WordFill(ADR(Buffer^[pos]),len,32+
               ORD(WDef.Foreground)*256+ORD(WDef.Background)*4096);
    END;
  END;
END BufferSpaceFill;



PROCEDURE (*$N*) CurWin () : WinType;
(*
    Returns The current window being used for output for this process
    If no window assigned by Use then returns Top
    NB Locks window system and leaves locked if MultiP set
*)
VAR
  u : UseListPtr;
  p : ADDRESS;
BEGIN
  IF MultiP THEN
    Lock();
    p := CurrentProcess();
    u := UseList^.Next;
    LOOP
      IF u=NIL THEN
        RETURN WindowStack (* Top() *)
      ELSIF p=u^.Proc THEN
        RETURN u^.Wind;
      END;
      u := u^.Next;
    END;
  END;
  u := UseList^.Next;
  IF u = NIL THEN RETURN WindowStack (* Top() *) END;
  RETURN u^.Wind;
END CurWin;



PROCEDURE (*$N*) ResetCursor;
VAR
  R    : Registers;
  mode : CARDINAL;
BEGIN
  IF (CursorStack = NIL) OR
     ObscuredAt(CursorStack,CursorStack^.CurrentX,CursorStack^.CurrentY) THEN
    mode := 2000H;
  ELSE
    WITH CursorStack^ DO
      WITH R DO
        AH := 2;
        BH := ActivePage();
        DL := SHORTCARD(XA+CurrentX-1);
        DH := SHORTCARD(YA+CurrentY-1);
      END;
      Lib.Intr(R,10H);
    END;
    mode := CursorLines;
  END;
  R.AH := 1;
  R.CX := mode;
  Lib.Intr(R,10H);
END ResetCursor;


PROCEDURE (*$N*) UnlinkCursor ( W : WinType );
VAR
  w : WinType;
BEGIN
  w := CursorStack;
  IF w = W THEN CursorStack := w^.CursorChain END;
  LOOP
    IF w = NIL THEN RETURN END;
    IF w^.CursorChain = W THEN
      w^.CursorChain := W^.CursorChain;
      RETURN;
    END;
    w := w^.CursorChain;
  END;
END UnlinkCursor;

(* ------------------------- *)
(* Cursor Control            *)
(* ------------------------- *)



PROCEDURE (*$F*) CursorOn;
VAR
  w,cw : WinType;
BEGIN
  cw := CurWin();
  UnlinkCursor(cw);
  cw^.WDef.CursorOn := TRUE;
  IF NOT cw^.WDef.Hidden THEN
    cw^.CursorChain := CursorStack;
    CursorStack := cw;
  END;
  ResetCursor;
  Unlock();
END CursorOn;

PROCEDURE (*$F*) CursorOff;
VAR
  w,cw : WinType;
BEGIN
  cw := CurWin();
  UnlinkCursor(cw);
  cw^.WDef.CursorOn := FALSE;
  ResetCursor;
  Unlock();
END CursorOff;

(* ------------------------- *)
(* Window creation           *)
(* ------------------------- *)


PROCEDURE (*$N*) MakeWindow ( VAR WD : WinDef ) : WinType;

(*
  Creates a new Window descriptor
  The size is Inclusive of frame if needed
  does not allocate buffer
*)
VAR W : WinType; min : CARDINAL ;
BEGIN
  NEW(W);
  WITH W^ DO
    WITH WD DO
      IF X2 >= ScreenWidth THEN X2:=ScreenWidth-1 END;
      IF Y2 >= ScreenDepth THEN Y2:=ScreenDepth-1 END;
      IF WD.FrameOn THEN min := 2 ELSE min := 0 END ;
      IF (X1+min>X2) THEN X2 := X1+min END ;
      IF (Y1+min>Y2) THEN Y2 := Y1+min END ;
      XA  := X1; YA  := Y1; XB := X2; YB := Y2;
      Width := X2-X1+1    ; Depth := Y2-Y1+1;
    END;
    WDef := WD;
    OWidth := Width     ; ODepth := Depth;
    CurrentX   := 1;
    CurrentY   := 1;
    Next       := NIL;
    Buffer     := NIL;
    UserRecord := NIL;
    IsPalette  := FALSE;
    CurPalColor:= NormalPaletteColor;
    TMode      := NoTitle;
    Guard      := GuardConst+Seg(W^);
    Title      := NIL;
  END;
  ClipFrame(W);
  RETURN W;
END MakeWindow;

PROCEDURE (*$F*) Open ( WD : WinDef ) : WinType;
(*
  Opens a window on the screen ready for use
*)
VAR
  W : WinType;
BEGIN
  Lock();
  W := MakeWindow (WD);
  WITH W^ DO
    ALLOCATE ( Buffer,OWidth*ODepth*2);
    BufferSpaceFill(W,0,OWidth*ODepth);
    IF WD.FrameOn THEN
      SetFrame(W,WDef.FrameDef,WDef.FrameFore,WDef.FrameBack);
    END;
  END;
  IF WD.Hidden THEN
    Use ( W )
  ELSE
    PutOnTop ( W )
  END;
  Unlock();
  RETURN W;
END Open;


(* ------------------------- *)
(* Window stack manipulation *)
(* and screen redraw         *)
(* ------------------------- *)



PROCEDURE (*$F*) Use ( W : WinType );
(*
   Causes all subsequent output (by the current process)
   to appear in the specified Window
   NB does not have to be Top Window (or in fact on the screen at all)
   UseList is the MRU window
*)
VAR
  p  : ADDRESS;
  u  : UseListPtr;
  up : UseListPtr;
BEGIN
  Lock();
  CheckWindow(W);
  p  := CurrentProcess();
  up := UseList;
  u  := up^.Next;
  LOOP
    IF u = NIL THEN NEW(u); u^.Proc := p; EXIT END;
    IF p = u^.Proc THEN up^.Next := u^.Next; EXIT END;
    up := u; u := u^.Next;
  END;
  u^.Next := UseList^.Next;
  UseList^.Next := u;
  u^.Wind := W;
  Unlock();
END Use;

PROCEDURE (*$N*) TakeOffStack ( W : WinType ); (* Private *)
VAR pw : WinType;
BEGIN
  IF W = WindowStack THEN
    WindowStack := W^.Next;
  ELSE
    pw := WindowStack;
    IF W <> pw THEN
      LOOP
        IF (pw = NIL) THEN EXIT END;
        IF (pw^.Next = W) THEN pw^.Next := W^.Next; EXIT END;
        pw := pw^.Next;
      END;
    END;
  END;
  W^.Next := NIL;
END TakeOffStack;



PROCEDURE (*$N*) UpdateScreen ( W : WinType; X,Y : AbsCoord; Len : CARDINAL );
(* Updates the screen from the window buffer *)
VAR
  NextLen,
  NextX : AbsCoord;
  w     : WinType;
  oxa,oxb,ax,bx : AbsCoord;
  buff  : ARRAY[0..ScreenWidth-1] OF CARDINAL;
  a     : ADDRESS;
BEGIN
  IF W^.WDef.Hidden THEN RETURN END;
  WHILE Len<>0 DO
    (* adjust co ordinates for crossing windows *)
    NextLen := 0;
    w := WindowStack;
    ax := X; bx := X+Len-1;
    LOOP
      IF (w = W)OR(w=NIL) THEN EXIT END;
      WITH w^ DO
        IF (Y>=WDef.Y1) AND (Y<=WDef.Y2) THEN
          oxa := WDef.X1; oxb := WDef.X2;
          IF (ax>=oxa) AND (bx<=oxb) THEN    (* wiped out *)
            ax := bx+1; EXIT;
          ELSIF (ax<=oxb) AND (bx>=oxa) THEN (* some interaction *)
            IF (ax<oxa) AND (bx>oxb) THEN    (* cut into two *)
              bx := oxa-1;
              NextX := oxb+1;
              NextLen := X+Len-NextX;
            ELSIF (bx>oxb) THEN (* left edge cut off *)
              ax := oxb+1;
            ELSIF (ax<oxa) THEN (* right edge cut off *)
              bx := oxa-1;
            END;
          END;
        END;
        w := Next;
      END;
    END;
    Len := bx-ax+1;
    IF Len <> 0 THEN
      WITH W^ DO
        a := ADR(Buffer^[(ax-WDef.X1)+(Y-WDef.Y1)*OWidth]);
        IF IsPalette THEN
          PalXlat(ADR(buff),a,Len,ADR(PalAttr));
          a := ADR(buff);
        END;
        BufferToScreen ( ax,Y,a,Len);
      END;
    END;
    X   := NextX;
    Len := NextLen;
  END;
END UpdateScreen;


PROCEDURE (*$N*) RedrawSection ( W : WinType;
                                 X1,Y1,X2,Y2 : AbsCoord ); (* Private *)
(* redraws rectangular portion of the window from the buffer *)
VAR
  Y : AbsCoord;
BEGIN
  FOR Y := Y1 TO Y2 DO
    UpdateScreen(W,X1,Y,X2-X1+1);
  END;
END RedrawSection;

PROCEDURE (*$N*) RedrawWindow ( W : WinType ); (* Private *)
BEGIN
  WITH W^ DO
    RedrawSection ( W,WDef.X1,WDef.Y1,WDef.X2,WDef.Y2 );
  END;
END RedrawWindow;

PROCEDURE (*$N*) RedrawWindowPane ( W : WinType ); (* Private *)
BEGIN
  WITH W^ DO
    RedrawSection ( W,XA,YA,XB,YB );
  END;
END RedrawWindowPane;


PROCEDURE (*$N*) DisplayBeneath ( W : WinType; NW : WinType ); (* Private *)
(* Re-displays windows Obscured by W from NW *)
VAR
  x1,x2,y1,y2 : AbsCoord;
BEGIN
  WITH W^ DO
    WHILE NW<>NIL DO
      IF ((WDef.X2>=NW^.WDef.X1)AND(NW^.WDef.X2>=WDef.X1) AND
          (WDef.Y2>=NW^.WDef.Y1)AND(NW^.WDef.Y2>=WDef.Y1)) THEN (* windows cross *)
         (* calculate Intersection *)
         IF WDef.X1>NW^.WDef.X1 THEN
           x1 := WDef.X1
         ELSE
           x1 := NW^.WDef.X1
         END;
         IF WDef.X2<NW^.WDef.X2 THEN
           x2 := WDef.X2
         ELSE
           x2 := NW^.WDef.X2
         END;
         IF WDef.Y1>NW^.WDef.Y1 THEN
           y1 := WDef.Y1
         ELSE
           y1 := NW^.WDef.Y1
         END;
         IF WDef.Y2<NW^.WDef.Y2 THEN
           y2 := WDef.Y2
         ELSE
           y2 := NW^.WDef.Y2
         END;
         RedrawSection (NW, x1,y1,x2,y2 );
      END;
      NW := NW^.Next;
    END;
  END;
END DisplayBeneath;




PROCEDURE (*$F*) PutOnTop ( W : WinType );
(*
   Puts the specified window on the top of the window stack
   Ensuring that it is fully visible.
   If this results in other windows becoming obscured then a buffer
   is allocated for each of these windows.
   All otherwise undirected output (ie with no Use) will appear
   within this window.
*)

BEGIN
  Lock();
  CheckWindow(W);
  IF W <> WindowStack THEN
    TakeOffStack( W );
    W^.Next     := WindowStack;
    WindowStack := W;
    WITH W^ DO
      WDef.Hidden := FALSE;
      RedrawWindow ( W );
      IF WDef.CursorOn THEN
        Use ( W );
        CursorOn;
      END;
    END;
  END;
  Use ( W );
  ResetCursor;
  Unlock();
END PutOnTop;


PROCEDURE (*$F*) Hide ( W : WinType );
(*
    Removes window from the Window stack and also the screen
    Placing the windows contents in a buffer for possible re-display later
    Uncovers obscured windows
*)
VAR
  p : WinType;
  w : WinType;
BEGIN
  Lock();
  CheckWindow(W);
  WITH W^ DO
    IF NOT WDef.Hidden THEN
      w := W^.Next;
      TakeOffStack ( W );
      DisplayBeneath ( W, w );
      IF WDef.CursorOn THEN CursorOff; WDef.CursorOn := TRUE; END;
      WDef.Hidden := TRUE;
    END;
  END;
  ResetCursor;
  Unlock();
END Hide;

PROCEDURE (*$F*) PutBeneath ( W : WinType; WA : WinType );
(*
    Puts window W beneath window WA
*)
VAR
  p : WinType;
  w : WinType;
BEGIN
  Hide(W);
  Lock();
  CheckWindow(WA);
  WITH WA^ DO
    IF NOT WDef.Hidden THEN
      w := Next;
      Next := W;
      W^.Next := w;
      W^.WDef.Hidden := FALSE;
      RedrawWindow ( W );
    END;
  END;
  ResetCursor;
  Unlock();
END PutBeneath;

PROCEDURE (*$F*) SnapShot;
(* Updates the Window buffer from the screen *)
(* only works with non palette windows       *)
VAR
  W : WinType;
  y : CARDINAL;
  p : CARDINAL;
BEGIN
  W := CurWin();
  WITH W^ DO
    WITH WDef DO
      IF NOT IsPalette THEN
        p := 0;
        FOR y := Y1 TO Y2 DO
          ScreenToBuffer(X1,y,ADR(Buffer^[p]),OWidth);
          INC(p,OWidth);
        END;
      END;
    END;
  END;
  Unlock();
END SnapShot;


(* ------------------------- *)
(* Window disposal           *)
(* ------------------------- *)

PROCEDURE (*$N*) DisposeTitle ( W : WinType );
BEGIN
  WITH W^ DO
    IF TMode <> NoTitle THEN
      DEALLOCATE(Title,Length(Title^)+1);
      TMode := NoTitle;
    END;
  END;
END DisposeTitle;



PROCEDURE (*$F*) Close ( VAR W : WinType );
(*
     removes the specified window from the screen
     deletes window descriptor and
     de-allocates any buffers previously allocated.
*)
VAR
  w       : WinType;
  u,up,un : UseListPtr;
BEGIN
  Lock();
  Hide ( W );
  TakeOffStack (W);
  UnlinkCursor(W);
  WITH W^ DO
    IF (Buffer <> NIL) THEN DEALLOCATE(Buffer,OWidth * ODepth * 2); END;
  END;
  up := UseList;
  u := up^.Next;
  WHILE (u<>NIL) DO
    un := u^.Next;
    IF (u^.Wind = W) THEN
      up^.Next := un;
      DISPOSE(u);
    ELSE
      up := u;
    END;
    u := un;
  END;
  DisposeTitle(W);
  W^.Guard := GuardConst; (* Invalidate guard *)
  DISPOSE(W);
  Unlock();
END Close;




PROCEDURE (*$F*) Used () : WinType;
(*
    Returns The current window being used for output for this process
    If no window assigned by Use then returns Top
*)
VAR
  w : WinType;
BEGIN
  w := CurWin();
  Unlock();
  RETURN w;
END Used;

PROCEDURE (*$F*) Top () : WinType;
(*
    Returns The current top Window
*)
VAR w : WinType;
BEGIN
  Lock();
  w := WindowStack;
  Unlock();
  RETURN w;
END Top;



PROCEDURE (*$F*) At (X,Y : AbsCoord) : WinType;
(*
    Returns the window displayed at the absolute position X,Y
*)
VAR
  W : WinType;
BEGIN
  Lock();
  W := WindowStack;
  LOOP
    IF W = NIL THEN EXIT END;
    WITH W^ DO
      IF (Y >= WDef.Y1) AND (Y <= WDef.Y2) AND
         (X >= WDef.X1) AND (X <= WDef.X2) THEN
        EXIT
      END;
      W := Next;
    END;
  END;
  Unlock();
  RETURN W;
END At;

PROCEDURE (*$F*) ObscuredAt (W : WinType; X,Y : RelCoord ) : BOOLEAN;
(*
    Returns if the specified window is obscured at the specified position
*)
VAR
  b : BOOLEAN;
  w : WinType;
BEGIN
  Lock();
  CheckWindow(W);
  WITH W^ DO
    IF WDef.Hidden THEN
      b:= TRUE;
    ELSE
      INC(X,XA-1); INC(Y,YA-1);
      w := WindowStack;
      LOOP
        IF w = W THEN b := FALSE; EXIT END;
        WITH w^ DO
          IF (Y>=WDef.Y1) AND (Y<=WDef.Y2) AND
             (X>=WDef.X1) AND (X<=WDef.X2) THEN
            b := TRUE;
            EXIT
          END;
          w := Next;
        END;
      END;
    END;
  END;
  Unlock();
  RETURN b;
END ObscuredAt;



PROCEDURE (*$N*) WindowWrite ( W     : WinType;
                               x,y   : RelCoord;
                               Len   : CARDINAL;
                               str   : ADDRESS;
                               frame : BOOLEAN ); (* Private *)
VAR
  Attr : CARDINAL;
  X,Y  : AbsCoord;
BEGIN
  IF Len>0 THEN
    WITH W^ DO
      IF IsPalette THEN
        IF frame THEN
          Attr := VAL(CARDINAL,FramePaletteColor);
        ELSE
          Attr := VAL(CARDINAL,CurPalColor);
        END;
      ELSIF frame THEN
        Attr := ORD(WDef.FrameFore)+ORD(WDef.FrameBack)*16;
      ELSE
        Attr := ORD(WDef.Foreground)+ORD(WDef.Background)*16;
      END;
      X := x+XA-1; Y := y+YA-1;
      IF Len+X-1 > WDef.X2 THEN Len := WDef.X2+1-X END;
      BufferWrite (ADR(Buffer^[X-WDef.X1+(Y-WDef.Y1)*OWidth]),str,Len,Attr);
      UpdateScreen(W,X,Y,Len);
    END;
  END;
END WindowWrite;

PROCEDURE (*$N*) DrawFrame ( W : WinType );
VAR
  s      : ARRAY[0..81] OF CHAR;
  w,l,tl : CARDINAL;
  i      : CARDINAL;

  PROCEDURE PutTitle ( mode : CARDINAL; row : CARDINAL );
  VAR
    i,j : CARDINAL;
  BEGIN
    WITH W^ DO
      CASE mode OF
        0 : i := 1                     |
        1 : i := (Width-tl) DIV 2 + 1; |
        2 : i := Width+1-tl            |
      ELSE
        i := MAX(CARDINAL);
      END;
      j := 0;
      WHILE (i<=Width)AND(j<tl) DO
        s[i] := Title^[j]; INC(i); INC(j)
      END;
      WindowWrite (W,0,row,OWidth,ADR(s),TRUE);
    END;
  END PutTitle;


BEGIN
  WITH W^ DO
    IF NOT WDef.FrameOn THEN
      IF (OWidth<3)OR(ODepth<3) THEN RETURN END; (* No Room *)
      WDef.FrameOn := TRUE;
      ClipFrame(W);
      ResetCursor;
    END;
    s[0] := WDef.FrameDef[0];
    Fill(ADR(s[1]),Width,WDef.FrameDef[1]);
    s[Width+1] := WDef.FrameDef[2];
    IF TMode <> NoTitle THEN
      tl := Length(Title^);
      IF tl>Width THEN tl := Width END;
    END;
    PutTitle(ORD(TMode-LeftUpperTitle),0);
    (* Sides *)
    FOR i := 1 TO Depth DO
      WindowWrite(W,0,i,1,ADR(WDef.FrameDef[3]),TRUE);
      WindowWrite(W,Width+1,i,1,ADR(WDef.FrameDef[4]),TRUE);
    END;
    s[0] := WDef.FrameDef[5];
    Fill(ADR(s[1]),Width,WDef.FrameDef[6]);
    s[Width+1] := WDef.FrameDef[7];
    PutTitle(ORD(TMode-LeftLowerTitle),Depth+1);
  END;
END DrawFrame;



PROCEDURE  (*$F*) SetFrame ( W     : WinType;
                             Frame : FrameStr;
                             Fore, Back  : Color );
(*
   Put a frame around the specified window
   With Title String and border definition (see above)
   having specified fore/background colours for the border
*)
BEGIN
  Lock();
  CheckWindow(W);
  WITH W^ DO
    WDef.FrameDef := Frame;
    WDef.FrameFore := Fore;
    WDef.FrameBack := Back;
  END;
  DrawFrame(W);
  Unlock();
END SetFrame;



PROCEDURE (*$N*) MergeWindows ( s,d : WinType );
(* slightly complicated procedure to merge two windows
   s is new (hidden) window
   d is old window to be merged into
*)
VAR
  w : WinDescriptor;
  r,wd        : CARDINAL;
  sw,sd,so,sp : CARDINAL;
  dw,dd,do,dp : CARDINAL;
BEGIN
  s^.CurrentX    := d^.CurrentX;
  s^.CurrentY    := d^.CurrentY;
  s^.CursorChain := d^.CursorChain;
  s^.UserRecord  := d^.UserRecord;
  s^.CurPalColor := d^.CurPalColor;
  s^.Title       := d^.Title;
  s^.TMode       := d^.TMode;
  d^.TMode       := NoTitle;
  d^.WDef.CursorOn  := FALSE;
  w := d^; d^ := s^; s^ := w;
  WITH s^ DO
    sw := OWidth; sd := ODepth;
    IF WDef.FrameOn THEN
      DEC(sw,2); DEC(sd,2);
      sp := (OWidth+1);
    ELSE
      sp := 0;
    END;
    Guard := GuardConst+Seg(s^);
  END;
  WITH d^ DO
    dw := OWidth; dd := ODepth;
    IF WDef.FrameOn THEN
      DEC(dw,2); DEC(dd,2);
      dp := OWidth+1;
    ELSE
      dp := 0;
    END;
    Guard := GuardConst+Seg(d^);
  END;
  IF sd < dd THEN wd := sd ELSE wd := dd END;
  FOR r := 0 TO wd-1 DO
    IF sw>=dw THEN
      WordMove(ADR(s^.Buffer^[sp]),ADR(d^.Buffer^[dp]),dw);
    ELSE
      WordMove(ADR(s^.Buffer^[sp]),ADR(d^.Buffer^[dp]),sw);
      BufferSpaceFill(d,dp+sw,dw-sw);
    END;
    INC(sp,s^.OWidth); INC(dp,d^.OWidth);
  END;
  (* now fill rest *)
  IF wd<dd THEN
    FOR r := wd TO dd-1 DO
      BufferSpaceFill(d,dp,dw);
      INC(dp,d^.OWidth);
    END
  END;
  IF d^.WDef.FrameOn THEN DrawFrame(d) END;
  IF NOT s^.WDef.Hidden THEN
    d^.Next := s;
    d^.WDef.Hidden := FALSE;
    RedrawWindow(d);
  END;
  Close(s);
END MergeWindows;


PROCEDURE (*$N*) IGotoXY ( W : WinType; X,Y : RelCoord );
(*
    Sets the current X Y position of the pane currently being used
*)
BEGIN
  WITH W^ DO CurrentX := X; CurrentY := Y END;
  IF CursorStack = W THEN ResetCursor END;
END IGotoXY;




(* ------------------------- *)
(* Palette procedures        *)
(* ------------------------- *)



PROCEDURE (*$N*) GetPal ( W : WinType; VAR Pal : PaletteDef );
VAR
  i : PaletteRange;
BEGIN
  CheckWindow(W);
  WITH W^ DO
    FOR i := 0 TO PaletteMax DO
      Pal[i].Fore := Color(PalAttr[i] MOD 16);
      Pal[i].Back := Color(PalAttr[i] DIV 16);
    END;
  END;
END GetPal;

PROCEDURE (*$N*) SetPal ( W : WinType; VAR Pal : PaletteDef );
VAR
  i : PaletteRange;
BEGIN
  CheckWindow(W);
  WITH W^ DO
    FOR i := 0 TO PaletteMax DO
      PalAttr[i] := VAL(SHORTCARD,ORD(Pal[i].Fore)+ORD(Pal[i].Back)*16);
    END;
    IsPalette := TRUE;
  END;
END SetPal;




PROCEDURE (*$F*) PaletteOpen(WD: WinDef; Pal: PaletteDef) : WinType;
(*
  Opens a window on the screen ready for use
*)
VAR
  W : WinType;
BEGIN
  Lock();
  W := MakeWindow (WD);
  SetPal(W,Pal);
  WITH W^ DO
    ALLOCATE ( Buffer,OWidth*ODepth*2);
    BufferSpaceFill(W,0,OWidth*ODepth);
    IF WD.FrameOn THEN
      SetFrame(W,WDef.FrameDef,WDef.FrameFore,WDef.FrameBack);
    END;
  END;
  IF WD.Hidden THEN
    Use ( W )
  ELSE
    PutOnTop ( W )
  END;
  Unlock();
  RETURN W;
END PaletteOpen;


PROCEDURE (*$F*) SetPaletteColor ( c : PaletteRange );
VAR
  W : WinType;
BEGIN
  W := CurWin();
  W^.CurPalColor := c;
  Unlock();
END SetPaletteColor;


PROCEDURE (*$F*) PaletteColor() : PaletteRange;
VAR
  W : WinType;
BEGIN
  W := CurWin();
  Unlock();
  RETURN W^.CurPalColor;
END PaletteColor;

PROCEDURE (*$F*) SetPalette(W: WinType; Pal: PaletteDef);
(*
   Changes the Palette of the specified window,
   redisplaying the changed colors
*)
BEGIN
  Lock();
  SetPal(W,Pal);
  RedrawWindow(W);
  Unlock();
END SetPalette;


PROCEDURE (*$F*) PaletteColorUsed(W: WinType; pc: PaletteRange) : BOOLEAN;
(*
   Returns if color in use anywhere in the window
*)
VAR
  p  : CARDINAL;
  l  : CARDINAL;
  m  : CARDINAL;
  ba : POINTER TO ARRAY[0..MAX(CARDINAL)] OF SHORTCARD;
BEGIN
  CheckWindow(W);
  WITH W^ DO
    ba := ADR(Buffer^);
    p  := 0;
    m  := OWidth*ODepth*2;
    LOOP
      l := m-p;
      p := p+ScanR(ADR(ba^[p]),l,pc);
      IF p >= m THEN RETURN FALSE END;
      IF ODD(p) THEN RETURN TRUE END;
      INC(p);
    END;
  END;
END PaletteColorUsed;



(* ------------------------- *)
(* Move resize procedure     *)
(* ------------------------- *)




PROCEDURE (*$F*) Change ( W : WinType; X1,Y1,X2,Y2 : AbsCoord );
(*
   Changes the size and/or position of the specified window
   The contents of the window will be moved with it
*)
VAR
  nw   : WinType;
  wd   : WinDef;
  pal  : PaletteDef;
  save : WinType;
  min  : CARDINAL ;
BEGIN
  CheckWindow(W);
  save := CurWin();
  WITH W^ DO
    IF X2>=ScreenWidth THEN X2:=ScreenWidth-1 END;
    IF Y2>=ScreenDepth THEN Y2:=ScreenDepth-1 END;
    wd := WDef;
    IF wd.FrameOn THEN min := 2 ELSE min := 0 END ;
    IF (X1+min>X2)OR(Y1+min>Y2) THEN RETURN END ;
    wd.X1 := X1; wd.Y1 := Y1;
    wd.X2 := X2; wd.Y2 := Y2;
    wd.Hidden := TRUE;
    IF IsPalette THEN
      GetPal(W,pal);
      nw := PaletteOpen(wd,pal);
    ELSE
      nw := Open( wd );
    END;
    MergeWindows(nw,W);
    ClipFrame (W);
    IF CurrentX>Width THEN CurrentX := Width END;
    IF CurrentY>Depth THEN CurrentY := Depth END;
    ResetCursor;
  END;
  Use(save); (* restore used window *)
  Unlock();
END Change;

(* ------------------------- *)
(* Multi process support     *)
(* ------------------------- *)



PROCEDURE (*$F*) NullProc;
BEGIN
END NullProc;

PROCEDURE (*$F*) SetProcessLocks ( LockProc,UnlockProc : PROC );
BEGIN
  Lock   := LockProc;
  Unlock := UnlockProc;
  MultiP := TRUE;
END SetProcessLocks;

(* ------------------------- *)
(* Window output             *)
(* ------------------------- *)


PROCEDURE (*$F*) DeleteLine ( W : WinType; Y : RelCoord );
VAR
  r,p : CARDINAL;
BEGIN
  CheckWindow(W);
  WITH W^ DO
    p := XA-WDef.X1+(YA-WDef.Y1+Y-1)*OWidth;
    FOR r := Y TO Depth-1 DO
      Move(ADR(Buffer^[p+OWidth]),ADR(Buffer^[p]),Width*2);
      INC(p,OWidth);
    END;
    BufferSpaceFill(W,p,Width);
    RedrawSection ( W,XA,Y+YA-1,XB,YB );
  END;
END DeleteLine;



PROCEDURE (*$F*) Clear;
(*
  clears the current window
*)
VAR
  r,p : CARDINAL;
  W   : WinType;
BEGIN
  W := CurWin();
  WITH W^ DO
    p := XA-WDef.X1+(YA-WDef.Y1)*OWidth;
    FOR r := 1 TO Depth DO
      BufferSpaceFill(W,p,Width);
      INC(p,OWidth);
    END;
    RedrawWindowPane(W);
  END;
  IGotoXY(W,1,1);
  Unlock();
END Clear;

PROCEDURE (*$F*) ClrEol;
(*
   clears from the cursor to the end of line
*)
VAR
  W : WinType;
BEGIN
  W := CurWin();
  WITH W^ DO
    BufferSpaceFill(W,XA-WDef.X1+CurrentX-1+(YA-WDef.Y1+CurrentY-1)*OWidth,
          Width-CurrentX+1);
    RedrawSection ( W,XA-1+CurrentX,YA-1+CurrentY,XB,YA-1+CurrentY );
  END;
  Unlock();
END ClrEol;

PROCEDURE Bell;
VAR
  R : Registers;
BEGIN
  WITH R DO
    AX := 0E07H;
    BL := 0;
    Lib.Intr(R,10H);
  END;
END Bell;


PROCEDURE (*$N*) WriteC ( W : WinType; C : CHAR);
VAR
  nx : CARDINAL;
BEGIN
  WITH W^ DO
    CASE C OF
       CHR(12) : Clear;
                 IGotoXY(W,1,1);
     | CHR(10) : IF CurrentY=Depth THEN
                   DeleteLine ( W, 1 );
                 ELSE
                   IGotoXY(W,CurrentX,CurrentY+1);
                 END;
     | CHR(13) : (*ClrEol; change 1/7/88*) IGotoXY(W,1,CurrentY);
     | CHR(08) : IF CurrentX>1 THEN
                   IGotoXY(W,CurrentX-1,CurrentY); WriteC(W,' ');
                   IGotoXY(W,CurrentX-1,CurrentY);
                 END;
     | CHR(7)  : Bell;
    ELSE
        IF CurrentX > Width THEN RETURN END;
        WindowWrite(W,CurrentX,CurrentY,1,ADR(C),FALSE);
        IF (CurrentX<>Width)OR NOT WDef.WrapOn THEN
          IGotoXY(W,CurrentX+1,CurrentY);
        ELSE
          IF CurrentY=Depth THEN
            DeleteLine ( W, 1 );
            IGotoXY(W,1,CurrentY);
          ELSE
            IGotoXY(W,1,CurrentY+1);
          END;
        END;
    END;
  END;
END WriteC;

PROCEDURE (*$F*) WriteOut (S : ARRAY OF CHAR);
VAR
  W     : WinType;
  p,q,m : CARDINAL;
  ss    : CARDINAL;
BEGIN
  W := CurWin();
  WITH W^ DO
    ss := HIGH(S)+1;
    p := 0;
    q := 0;
    LOOP
      (* first accumulate normal chars on same line *)
      m := Width+p-CurrentX;
      IF NOT W^.WDef.WrapOn THEN INC(m) END; (* can fit another char in *)
      IF m > ss THEN m := ss END;
      WHILE (q<m)AND(S[q]>=' ') DO INC(q) END;
      (* now output the line *)
      IF q > p THEN
        WindowWrite(W,CurrentX,CurrentY,q-p,ADR(S[p]),FALSE);
        IGotoXY(W,CurrentX+q-p,CurrentY);
      END;
      (* now output the special char *)
      IF (S[q] = CHR(0)) OR (q > HIGH(S)) THEN EXIT ELSE WriteC(W,S[q]);
      END;
      INC(q);
      p := q;
    END;
  END;
  Unlock();
END WriteOut;

PROCEDURE (*$F*) DirectWrite ( X,Y : RelCoord;      (* start co-ords *)
                               A   : ADDRESS;       (* address of char array *)
                               Len : CARDINAL );    (* length to be written *)
(*
   writes directly to current window at the specified X,Y coordinates
   with no check for special (ie control) chars or eol wrap
*)
VAR
  W : WinType;
BEGIN
  W := CurWin();
  ClipXY(W,X,Y);
  WindowWrite(W,X,Y,Len,A,FALSE);
  Unlock();
END DirectWrite;


PROCEDURE (*$F*) GotoXY ( X,Y : RelCoord );
VAR
  W : WinType;
BEGIN
  W := CurWin();
  ClipXY(W,X,Y);
  IGotoXY(W,X,Y);
  Unlock();
END GotoXY;

PROCEDURE (*$F*) WhereX ( ) : RelCoord;
VAR
  W : WinType;
BEGIN
  W := CurWin();
  Unlock();
  RETURN W^.CurrentX;
END WhereX;

PROCEDURE (*$F*) WhereY ( ) : RelCoord;
VAR
  W : WinType;
BEGIN
  W := CurWin();
  Unlock();
  RETURN W^.CurrentY;
END WhereY;

PROCEDURE (*$F*) ConvertCoords ( W         : WinType  ;
                                 X,Y       : RelCoord;
                                 VAR XO,YO : AbsCoord );
BEGIN
  CheckWindow(W);
  XO := X+W^.XA-1; YO := Y+W^.YA-1;
END ConvertCoords;


PROCEDURE (*$F*) InsLine;
VAR
  W : WinType;
  r,p,p1 : CARDINAL;
BEGIN
  W := CurWin();
  WITH W^ DO
    p := XA-WDef.X1+(YA-WDef.Y1+Depth-1)*OWidth;
    FOR r := CurrentY TO Depth-1 DO
      DEC(p,OWidth);
      Move(ADR(Buffer^[p]),ADR(Buffer^[p+OWidth]),Width*2);
    END;
    BufferSpaceFill(W,p,Width);
    RedrawSection ( W,XA,CurrentY+YA-1,XB,YB );
  END;
  Unlock();
END InsLine;

PROCEDURE (*$F*) DelLine;
VAR
  W : WinType;
BEGIN
  W := CurWin();
  DeleteLine(W,W^.CurrentY);
  Unlock();
END DelLine;

PROCEDURE (*$F*) TextColor ( c : Color );
VAR
  W : WinType;
BEGIN
  W := CurWin();
  W^.WDef.Foreground := c;
  Unlock();
END TextColor;

PROCEDURE (*$F*) TextBackground ( c : Color );
VAR
  W : WinType;
BEGIN
  W := CurWin();
  W^.WDef.Background := c;
  Unlock();
END TextBackground;

PROCEDURE (*$F*) SetWrap ( on : BOOLEAN );
VAR
  W : WinType;
BEGIN
  W := CurWin();
  W^.WDef.WrapOn := on;
  Unlock();
END SetWrap;

PROCEDURE Info (*$F*) ( W : WinType; VAR WD : WinDef );
(* gets information for specified window *)
BEGIN
  Lock();
  WD := W^.WDef ;
  Unlock();
END Info;


(* ------------------------- *)
(* Title procedure           *)
(* ------------------------- *)
PROCEDURE SetTitle ( W        : WinType;
                     NewTitle : ARRAY OF CHAR;
                     Mode     : TitleMode );
(*
  updates the window title within the window frame,
  positioning it in the position defined by the title mode
*)
VAR
  l : CARDINAL;
BEGIN
  CheckWindow(W);
  Lock();
  DisposeTitle(W);
  WITH W^ DO
    IF Mode <> NoTitle THEN
      l := Length(NewTitle);
      ALLOCATE(Title,l+1);
      Move(ADR(NewTitle),ADR(Title^),l);
      Title^[l] := CHR(0);
    END;
    TMode := Mode;
  END;
  DrawFrame(W);
  Unlock;
END SetTitle;


PROCEDURE ReadString  ( VAR string : ARRAY OF CHAR );
VAR
  c   : CHAR;
  line: ARRAY[0..82] OF CHAR;
  p,H : CARDINAL;
  W   : WinType;
  con : BOOLEAN;
BEGIN
  W := CurWin();
  PutOnTop(W);
  con := W^.WDef.CursorOn;
  CursorOn;
  H := HIGH(string);
  IF H>79 THEN H := 79 END;
  p := 0;
  LOOP
    c := IO.RdKey();
    IF (c=CHR(8))OR(c=CHR(127)) THEN
      IF p>0 THEN DEC(p); IO.WrChar(CHR(8)) END;
    ELSIF (c>=' ') THEN
      IF p<=H THEN
        IO.WrChar(c);
        line[p] := c;
        INC(p);
      END;
    ELSIF c=CHR(13) THEN
      EXIT;
    END;
  END;
  line[p] := CHR(0);
  Copy(string,line);
  IF NOT con THEN CursorOff END;
  Unlock;
  IO.WrLn;
END ReadString;

(* Low level routines to read and write to the window buffer direct *)

PROCEDURE (*$F*) RdBufferLn ( W    : WinType;        (* Source window *)
                              X,Y  : RelCoord;      (* start co-ords *)
                              Dest : ADDRESS;       (* address of buffer *)
                              Len  : CARDINAL );    (* length in WORDs *)
VAR
  AX,AY  : AbsCoord;
BEGIN
  WITH W^ DO
      AX := X+XA-1; AY := Y+YA-1;
      Lib.WordMove(ADR(Buffer^[AX-WDef.X1+(AY-WDef.Y1)*OWidth]),Dest,Len);
  END ;
END RdBufferLn ;

PROCEDURE (*$F*) WrBufferLn ( W    : WinType;       (* Dest window *)
                              X,Y  : RelCoord;      (* start co-ords *)
                              Src  : ADDRESS;       (* address of buffer *)
                              Len  : CARDINAL );    (* length in WORDs *)
VAR
  AX,AY  : AbsCoord;
BEGIN
  WITH W^ DO
      AX := X+XA-1; AY := Y+YA-1;
      Lib.WordMove(Src,ADR(Buffer^[AX-WDef.X1+(AY-WDef.Y1)*OWidth]),Len);
      UpdateScreen(W,AX,AY,Len);
  END ;
END WrBufferLn ;


(* ------------------------- *)
(* Main initialization       *)
(* ------------------------- *)
PROCEDURE Init ;
CONST
  ClearOnEntry = TRUE ;    (* Change to FALSE if automatic clear
                              NOT required *)
VAR
  R : Registers ;
  WD : WinDef ;
BEGIN
  InitScreenType(FALSE); (* FALSE = no snow *)
  R.AH := 3;
  R.BH := ActivePage();
  Lib.Intr(R,10H);
  IF (R.CH<20H)AND(R.CL>0)  THEN
     CursorLines := R.CX ;
  ELSE
     CursorLines := 0607H ;
  END ;
  Lock := NullProc;
  Unlock := NullProc;
  MultiP := FALSE;
  WindowStack := NIL;
  NEW(UseList);
  UseList^.Next := NIL;        (* dummy *)
  CursorStack := NIL;
  IO.WrStrRedirect := WriteOut;
  IO.RdStrRedirect := ReadString;
  IF ClearOnEntry THEN
    FullScreen       := Open(FullScreenDef);
  ELSE
    WD := FullScreenDef ;
    WD.Hidden := TRUE ;
    FullScreen       := Open(WD);
    SnapShot ;
    PutOnTop(FullScreen);
    GotoXY(ORD(R.DL)+1,ORD(R.DH)+1);
  END ;
END Init ;

BEGIN
  Init ;
END Window.
