MODULE ovl;
(* Copyright (C) 1987 Jensen & Partners International *)
IMPORT Lib,Str,FIO,IO,Storage;

CONST
  MaxOverlay = 9;

TYPE
  String = ARRAY [0..99] OF CHAR;

  tUnit = RECORD
     Name:String;
     Start:LONGCARD;
     StartSeg:CARDINAL; (* == CARDINAL(Start DIV 16) *)
     Diff:CARDINAL; (* in paras between new and old position *)
     Overlay:[0..MaxOverlay];
     UnitPadding:ARRAY [1..128-( SIZE(String)+4+2+2+2 )] OF BYTE;
  END;

  tfix=RECORD
     locoff:SHORTCARD; (* high 4 bits = overlay number *)
     locseg:CARDINAL;
     target:CARDINAL;
  END;

  texeheader = RECORD
    magic : CARDINAL;
    sizemod512 : CARDINAL;
    sizediv512 : CARDINAL;
    numrelocitem : CARDINAL;
    headerparas : CARDINAL;
    heapminparas : CARDINAL;
    heapmaxparas : CARDINAL;
    initialss : CARDINAL;
    initialsp : CARDINAL;
    checksum : CARDINAL;
    initialip : CARDINAL;
    initialcs : CARDINAL;
    relocations : CARDINAL;
    ovrlay : CARDINAL;
    undocumented : CARDINAL;
    (* relocation items follow *)
  END;

  Str4 = ARRAY[0..3] OF CHAR ;


VAR
  exefile,exefile1,mapfile,ovlfile,newmapfile:FIO.File;

  nmap:CARDINAL;
  map:ARRAY [1..300] OF tUnit;

  ovlheaders:ARRAY [0..MaxOverlay] OF RECORD
    Alloc:   LONGCARD; (* total size *)
    Init:    LONGCARD; (* size of initialised part *)
    nifix:   CARDINAL;
    nefix:   CARDINAL;
    copyr:   Str4 ;    (* used for checking overlay version *)
  END;

  ovlfiles:ARRAY [0..MaxOverlay] OF CARDINAL;

PROCEDURE GiveBuf( f:FIO.File );
TYPE buf = ARRAY [0..517] OF BYTE;
VAR bufp :POINTER TO buf;
BEGIN
  Storage.ALLOCATE(bufp,SIZE(buf));
  FIO.AssignBuffer(f,bufp^);
END GiveBuf;

PROCEDURE ReadHex(s:ARRAY OF BYTE;i:CARDINAL):LONGCARD;
VAR res:LONGCARD; c:SHORTCARD;
BEGIN
  res := 0;
  LOOP
    c := SHORTCARD(s[i]);
    INC(i);
    CASE CHAR(c) OF
      'A'..'F': c := c - ( SHORTCARD('A') - 10 ) ;
    | '0'..'9': c := c - SHORTCARD('0');
    ELSE EXIT;
    END;
    res := res * 16 + VAL(LONGCARD, c );
  END;
  RETURN res;
END ReadHex;

PROCEDURE ReadMap;
CONST
  delim = Str.CHARSET{' '};
VAR
  done:BOOLEAN; i:CARDINAL;
  sname,gname,token,line:String;
  start:LONGCARD;
BEGIN
  nmap := 0;
  REPEAT
    FIO.RdStr(mapfile,line) ;
  UNTIL (line[0]<>CHAR(0)) AND (line[1]>='0') AND (line[1]<='9') ;
  LOOP
  (*  IO.WrStr(line);IO.WrLn; *)
    IF Str.Length(line) < 60 THEN EXIT END;

    Str.Item( token, line, delim, 0 );
    start := ReadHex( token,0 );

    Str.Item( sname, line, delim, 3 );

    Str.Item( gname, line, delim, 5 );

    IF ( Str.Compare(gname,'(none)') = 0 ) THEN
      gname := sname;
    END;

    IF ( nmap = 0 )
    OR ( Str.Compare(gname,map[nmap].Name) <> 0 )
    THEN
      INC(nmap);
      WITH map[nmap] DO
        Name := gname;
        Start := start;
        StartSeg := CARDINAL(start DIV 16);
        Overlay := 0;
      END;
    END;
    FIO.RdStr(mapfile,line);
  END;
  map[nmap+1] := map[nmap]; (* sentinel *)
END ReadMap;

PROCEDURE too_small_check;
VAR i:CARDINAL;
BEGIN
  FOR i := 1 TO nmap-1 DO
    IF ( map[i+1].StartSeg = map[i].StartSeg )
    AND ( map[i+1].Overlay <> map[i].Overlay ) THEN
      IO.WrStr( map[i].Name);
      IO.WrStr(' too small !!');
      IO.WrLn;
      HALT;
    END;
  END;
END too_small_check;

PROCEDURE ReadOvl;
VAR c:CHAR;

  PROCEDURE nextc;
  BEGIN
    c := FIO.RdChar(ovlfile);
  END nextc;

VAR
    ovln:CARDINAL;
    name:String;
    i:CARDINAL;
BEGIN
  LOOP
    LOOP
      nextc;
      WHILE c <= ' ' DO
        IF c = CHAR(1AH) THEN EXIT END;
        nextc;
      END;
      IF c = ';' THEN (* comment *)
        WHILE c >= ' ' DO nextc END ;
      ELSE
        EXIT ;
      END ;
    END ;
    IF c = CHAR(1AH) THEN EXIT END;

    ovln := 0;

    WHILE ( c >= '0' ) AND ( c <= '9' ) DO
      ovln := ovln*10 + ORD(c) - ORD('0');
      nextc;
    END;

    WHILE c = ' ' DO nextc END;

    i := 0;
    WHILE ( c > ' ' ) DO
      name[i] := c;
      INC(i);
      nextc;
    END;
    name[i] := CHAR(0);

    (* search table *)
    i := 0;
    LOOP
      INC(i);
      IF i > nmap THEN
        IO.WrStr('Segment/group name ');
        IO.WrStr(name);
        IO.WrStr(' not found');
        IO.WrLn;
        EXIT;
      END;
      WITH map[i] DO
        IF Str.Compare( Name, name ) = 0 THEN
          Overlay := ovln;
          EXIT;
        END;
      END;
    END;
  END;
END ReadOvl;

VAR newseg_in_exe:BOOLEAN;

PROCEDURE newseg( seg,off:CARDINAL ):CARDINAL;
VAR loc:LONGCARD;
    k:CARDINAL;
BEGIN
  loc := 16*VAL(LONGCARD,seg) + VAL(LONGCARD,off);
  k := 1;
  (* search for location segment = k *)
  WHILE ( k <= nmap ) AND ( loc >= map[k].Start ) DO INC(k) END;
  DEC(k);
  newseg_in_exe := ( map[k].Overlay = 0 );
  RETURN seg - map[k].Diff;
END newseg;

PROCEDURE hex(n:CARDINAL):CHAR;
BEGIN
  n := n MOD 16;
  IF n > 9 THEN
    RETURN CHAR( n + ORD('A') - 10 )
  ELSE
    RETURN CHAR( n + ORD('0') );
  END;
END hex;

PROCEDURE EditMap;
VAR line:String;
    i:CARDINAL;
    seg,off:CARDINAL;
    addr:LONGCARD;
BEGIN
  FIO.Seek(mapfile,0);
  LOOP
    FIO.RdStr(mapfile,line);
    newseg_in_exe := TRUE;
    IF FIO.EOF THEN EXIT END;
    IF ( line[0] = ' ' ) AND ( line[5] = ':' ) THEN
      seg := CARDINAL(ReadHex(line,1));
      off := CARDINAL(ReadHex(line,6));
      seg := newseg( seg, off );
      line[4] := hex(seg); seg := seg DIV 16;
      line[3] := hex(seg); seg := seg DIV 16;
      line[2] := hex(seg); seg := seg DIV 16;
      line[1] := hex(seg); seg := seg DIV 16;
    ELSIF ( line[0] = ' ' ) AND ( line[6] = 'H' ) THEN
      addr := ReadHex(line,1);
      seg := CARDINAL(addr DIV 16);
      off := CARDINAL(addr) MOD 16;
      seg := newseg( seg, off );
      addr := LONGCARD(seg)*16 + LONGCARD(off) + ReadHex(line,15);
      line[4] := hex(seg); seg := seg DIV 16;
      line[3] := hex(seg); seg := seg DIV 16;
      line[2] := hex(seg); seg := seg DIV 16;
      line[1] := hex(seg); seg := seg DIV 16;
      seg := CARDINAL(addr DIV 16);
      line[11] := hex(seg); seg := seg DIV 16;
      line[10] := hex(seg); seg := seg DIV 16;
      line[9] := hex(seg); seg := seg DIV 16;
      line[8] := hex(seg); seg := seg DIV 16;
    END;
(*    IF NOT newseg_in_exe THEN
      IO.WrStr(line);
      IO.WrLn;
      END;
*)
    IF newseg_in_exe THEN
      IF line[0] <> CHAR(0) THEN
        FIO.WrStr(newmapfile,line);
      END;
      FIO.WrLn(newmapfile);
    END;
  END;
END EditMap;

PROCEDURE PrintMap;
VAR i:CARDINAL;
BEGIN
  FOR i := 1 TO nmap DO
    WITH map[i] DO
      IO.WrStr(' Start=');  IO.WrLngCard(Start,6);
      IO.WrStr(' Diff='); IO.WrCard(Diff,5);
      IO.WrCard(Overlay,3);
      IO.WrStr(' ');
      IO.WrStr(Name);
      IO.WrLn;
    END;
  END;
END PrintMap;

PROCEDURE ChkRead( VAR buf:ARRAY OF BYTE; count:CARDINAL );
BEGIN
  IF FIO.RdBin( exefile, buf, count ) <> count THEN
    IO.WrStr('?? on read');
    HALT;
  END;
END ChkRead;

PROCEDURE ChkRead1( VAR buf:ARRAY OF BYTE; count:CARDINAL );
BEGIN
  IF FIO.RdBin( exefile1, buf, count ) <> count THEN
    IO.WrStr('?? on read');
    HALT;
  END;
END ChkRead1;

PROCEDURE Copy(src,dst:CARDINAL; count:CARDINAL):CARDINAL;
VAR amount:CARDINAL; actual:CARDINAL;
    buf:ARRAY [0..0FFFH] OF SHORTCARD;
    res:CARDINAL;
BEGIN
  res := 0;
  WHILE count > 0 DO
    amount := count;
    IF amount > SIZE(buf) THEN
      amount := SIZE(buf);
    END;
    actual := FIO.RdBin( src, buf, amount );
    IF actual <> 0 THEN
      FIO.WrBin( dst, buf, actual );
    END;
    DEC(count,amount);
    INC(res,actual);
  END;
  RETURN res;
END Copy;

PROCEDURE LongCopy(src,dst:CARDINAL; count:LONGCARD);
VAR junk:CARDINAL;
BEGIN
  WHILE count > 8000H DO
    junk := Copy(src,dst,8000H);
    DEC(count,8000H);
  END;
  junk := Copy( src,dst,CARDINAL(count) );
END LongCopy;


PROCEDURE resetexe;
VAR filename:ARRAY[0..255] OF CHAR;
BEGIN
  Str.Concat( filename, Lib.CommandLine^, '.exe');
  exefile := FIO.Create(filename);
END resetexe;

PROCEDURE MakeFix( k:CARDINAL; loc:LONGCARD; j:CARDINAL; target:CARDINAL; internalfix:BOOLEAN );
VAR
   tmp:CARDINAL;
   fix:tfix;
BEGIN
  (*
  IO.WrStr('k='); IO.WrCard(k,1);
  IO.WrStr('j='); IO.WrCard(j,1);

  IO.WrStr( ' map[k].Overlay=' ); IO.WrCard( ORD(map[k].Overlay),1 );
  IO.WrStr( ' map[j].Overlay=' ); IO.WrCard( ORD(map[j].Overlay),1 );
  IO.WrStr( ' loc=' ); IO.WrLngCard( loc, 1 );
  IO.WrStr( ' target=' ); IO.WrCard( target, 1 );
  IO.WrLn;
  *)
  IF internalfix THEN
    IF map[k].Overlay = 0 THEN
      IF map[j].Overlay <> 0 THEN
        RETURN; (* overlay 0 requires only internal fixups to itself *)
      END;
    END;
    INC( ovlheaders[map[k].Overlay].nifix );
    tmp := j; j := k; k := tmp;
  ELSE
    IF map[j].Overlay = 0 THEN RETURN END;
    IF map[j].Overlay = map[k].Overlay THEN RETURN END;
    INC( ovlheaders[map[j].Overlay].nefix );
  END;

  fix.locoff := ( SHORTCARD(loc) MOD 16 ) + 16*SHORTCARD( map[k].Overlay );
  fix.locseg := CARDINAL(loc DIV 16);
  fix.target := target;
  FIO.WrBin( ovlfiles[map[j].Overlay], fix, SIZE(fix) );

END MakeFix;

PROCEDURE Main;
VAR
  exe:texeheader;
  dummy:CARDINAL;
  i,j,k:CARDINAL;
  hsize:LONGCARD;
  filename:String;
  ext:ARRAY[0..3] OF CHAR;
  pad:ARRAY[0..15] OF SHORTCARD;
  padsize:CARDINAL;
  copysize:CARDINAL;
  target:CARDINAL;
  internalfix:BOOLEAN;
  fixlocabs:LONGCARD;
  fsize:LONGCARD;
  hpage:CARDINAL;
  fix:tfix;
  exefix:RECORD off,seg:CARDINAL END;
  file:CARDINAL;

BEGIN
  ChkRead( exe, SIZE(exe) );
  hsize := VAL(LONGCARD,exe.headerparas)*16;

  FOR i := 0 TO MaxOverlay DO
    ovlfiles[i] := CARDINAL(-1);
    WITH ovlheaders[i] DO
      Alloc := 0;
      Init := 0;
      nifix := 0;
      nefix := 0;
      copyr := 'JPI' ;
    END;
  END;

  FOR i := 0 TO 15 DO pad[i] := 0 END;

  (* Now read through exe file redistributing segments *)
  FIO.Seek( exefile, hsize );
  FOR i := 1 TO nmap DO
    WITH map[i] DO
      WITH ovlheaders[Overlay] DO
        file := ovlfiles[Overlay];
        IF file = CARDINAL(-1) THEN
           ext := '.ov ';
           ext[3] := CHAR( Overlay+ORD('0') );
           Str.Concat( filename, Lib.CommandLine^, ext );
           file := FIO.Create( filename );
           ovlfiles[Overlay] := file;
           FIO.WrBin( file, pad, 16 );
         END;
        padsize := ( CARDINAL(Start) - CARDINAL(Alloc) ) MOD 16;
        FIO.WrBin( file, pad, padsize );
        INC( Init, VAL(LONGCARD, padsize) );
        INC( Alloc, VAL(LONGCARD,padsize) );
        Diff := CARDINAL(Start DIV 16) - CARDINAL(Alloc DIV 16);
        copysize := CARDINAL(map[i+1].Start-Start);
        INC( Init, VAL(LONGCARD, Copy( exefile, file, copysize ) ) );
        INC( Alloc , VAL(LONGCARD,copysize) ) ;
      END;
    END;
  END;

  (* OK. We now have the overlay files, so work out the fixups *)


  (* First allocate buffers for overlays *)
  FOR i := 0 TO MaxOverlay DO
    IF ovlfiles[i] <> CARDINAL(-1) THEN
      GiveBuf( ovlfiles[i] );
    END;
  END;

  FOR internalfix := FALSE TO TRUE DO
    FIO.Seek( exefile1, VAL(LONGCARD,exe.relocations) );
    FOR i := 1 TO exe.numrelocitem DO
      ChkRead1( exefix, SIZE(exefix) );
      fixlocabs := VAL(LONGCARD,exefix.off)+16*VAL(LONGCARD,exefix.seg);
      FIO.Seek( exefile, hsize+fixlocabs);
      ChkRead( target, SIZE(target) );

      k := 1;
      (* search for location segment = k *)
      WHILE ( k <= nmap ) AND ( fixlocabs >= map[k].Start ) DO INC(k) END;
      DEC(k);

  (*
          IO.WrCard(target,1);
          IO.WrStr(' at ');
          IO.WrLngCard(fixlocabs,1);
          IO.WrLn;
  *)

      j := 0;
      LOOP (* search for target segment = j *)
        INC(j);
        IF ( j > nmap ) OR ( target < map[j].StartSeg ) THEN
          DEC(j);
          MakeFix( k, fixlocabs - VAL(LONGCARD,map[k].Diff)*16,
                   j, target - map[j].Diff, internalfix );
          EXIT;
        END;
      END;
    END;
  END;

  (* Phew ! *)
  (* Now save the headers *)

  FOR i := 0 TO MaxOverlay DO
    WITH ovlheaders[i] DO
      file := ovlfiles[i];
      IF file <> CARDINAL(-1) THEN
        FIO.Seek( file, 0 );
        FIO.WrBin( file, ovlheaders[i], 16 );
      END;
    END;
  END;


  (* Now rewrite exe file *)

  resetexe;
  hpage := ( 4*ovlheaders[0].nifix + SIZE(texeheader) + 511 ) DIV 512;
  hsize := VAL(LONGCARD,hpage * 512);

  FIO.Seek( exefile, VAL(LONGCARD,512*hpage) );
  file := ovlfiles[0];
  FIO.Seek( file, 16 );
  LongCopy( file, exefile, ovlheaders[0].Init );

  FIO.Seek( exefile, 0 );

  exe.numrelocitem := ovlheaders[0].nifix;
  exe.headerparas := hpage*32;
  exe.relocations := SIZE(texeheader);
  exe.initialcs := newseg(exe.initialcs,exe.initialip);
  exe.initialss := newseg(exe.initialss,16);
  fsize := FIO.Size(exefile);
  exe.sizemod512 := CARDINAL(fsize) MOD 512;
  exe.sizediv512 := CARDINAL((fsize+511) DIV 512);

  FIO.WrBin( exefile, exe, SIZE(texeheader) );
  FOR i := 1 TO ovlheaders[0].nifix DO
    dummy := FIO.RdBin( file, fix, SIZE(fix) );
    fixlocabs := VAL(LONGCARD,fix.locoff)+16*VAL(LONGCARD,fix.locseg);


    FIO.Seek( exefile, hsize+fixlocabs);
    FIO.WrBin( exefile, fix.target, 2 );
  (*
  IO.WrStr('Repatch at');
  IO.WrLngCard( hsize+fixlocabs,1 );
  IO.WrStr(' value ');
  IO.WrCard( fix.target, 1 );
  IO.WrLn;
  *)
    FIO.Seek( exefile, VAL(LONGCARD, SIZE(texeheader) + (i-1)*4 ) );
    exefix.off := VAL(CARDINAL,fix.locoff);
    exefix.seg := fix.locseg;
    FIO.WrBin( exefile, exefix, SIZE(exefix) );
  END;

  (* close buffered ovl files *)
  FOR i := 0 TO MaxOverlay DO
    IF ovlfiles[i] <> CARDINAL(-1) THEN
      FIO.Close( ovlfiles[i] );
    END;
  END;

END Main;

VAR filename:ARRAY[0..255] OF CHAR;

PROCEDURE init;
VAR
  renname : FIO.PathStr ;
BEGIN
  Str.Concat( filename, Lib.CommandLine^, '.exe');
  exefile := FIO.Open(filename); (* no buffering because random access *)
  exefile1 := FIO.Open(filename); GiveBuf(exefile1);
  Str.Concat( filename, Lib.CommandLine^, '.ovl');
  ovlfile := FIO.Open(filename); GiveBuf(ovlfile);
  Str.Concat( filename, Lib.CommandLine^, '.map');
  Str.Concat( renname, Lib.CommandLine^, '.omp');
  FIO.Erase(renname) ;
  FIO.Rename(filename,renname);
  mapfile := FIO.Open(renname); GiveBuf(mapfile);
  newmapfile := FIO.Create(filename); GiveBuf(newmapfile);
END init;

BEGIN
  init;
  ReadMap;
  ReadOvl;
  too_small_check;
  Main;
(*  PrintMap; *)
  EditMap;
  Str.Concat( filename, Lib.CommandLine^, '.ov0');
  FIO.Erase(filename) ;
  FIO.Close(newmapfile) ;
END ovl.


