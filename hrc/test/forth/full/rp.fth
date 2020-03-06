\ Resolve path device procedure LNM 04-11-1999 based on IEEE 1275-1994
." Resolve path device procedure"
include? task-aw.fth        aw.fth
include? task-showdevs.fth  showdevs.fth
forth definitions anew task-rp.fth decimal

255 value sizestr
0 string emptystr    \ Empty string for varios needs
sizestr string shead \ String for head of sourse string
sizestr string stail \ String for tail of sourse string
sizestr string path_name \ Target full alias name
sizestr string arguments \ Arguments string
31      string unit_addr
31      string node_name \ The current node name

variable targetnode \ Pnode of finded name
variable active-package  0 active-package ! \ Current active package
variable parentnode
2variable ptail      \ Pointer to tail string
2variable phead      \ Pointer to head string
2variable paliasargs \ Pointer to string alias arguments
variable unit_phys 0 unit_phys ! \ Physical adress of unit

\ Parent
: parent ( Phandle ) >code parenthandle @ ( ParentHandle ) ; \ ++ 16-02-2000
\ If Phandle exist in device tree return Phandle else return true
: provphandle ( Phandle -- Phandle | T ) dup 25 0
    do  ( Phandle )
        parent dup ( Parent )
        \ not
        roothandle @ = if leave then
    loop ( PhandleBeg PhandleEnd )
    roothandle @ = not
    if drop true then ( Phandle | T ) ; \ ++ 16-05-2000
\ Child
: child ( PhandleParent -- PhandleChild ) provphandle dup
    if >code childhandle @ then ( PhandleChild ) ;
: findalias ( Adr Len -- AdrAlias LenAlias 0 | 1 )
    aliashandle @ getPhandleProperty ( Adr Len 0 | 1 ) ;

\ Concatenate 2 string and 1 symbol to shead string
: conc2str&symb ( AStr1 LStr1 AStr2 LStr2 Symb -- A L ) { symb -- }
    2swap ( AStr2 LStr2 AStr1 LStr1 )
    shead st! \ Story count in shead
    shead 2dup + symb swap c! ( AStr2 LStr2 Ash Lsh )
    1 + 2 pick over + ( AStr2 LStr2 Ash Lsh Lnew )
    2 pick 1 - c! ( AStr2 LStr2 Ash Lsh ) \ Story new len in shead
    + swap move ( ( Story content of alias_shead ) shead ( A L ) ;

\ 4.3.1.A.3 Change alias by real name
: workwithalias ( AdrAlias LenAlias )
    paliasargs 2@ swap drop \ Not empty args of alias
    ( AdrAlias LenAlias AdrAlArg LenAlArg LenAlArg )
    if  \ 3-ii Alias args is not empty
        \ 3-ii-a
        ascii / right-split ( AdrAlHead LenAlhead AdrAlTail LenAltail )
        \ 3-ii-b
        ascii : right-split ( AdrAlHead LenAlhead AdrAlTail LenAltail ADeadArg LDeadArg )
        2drop ( AdrAlHead LenAlhead AdrAlTail LenAltail  )
        2 pick \ AliasHead length
        if  \ 3-ii-c concatenate (alias_head,"/",Alias_tail)
            ascii / conc2str&symb ( A L )
        else 
            2swap 2drop ( AdrAlTail LenAltail )
        then
        ( A L ) paliasargs 2@ ascii : conc2str&symb
        \ 3-ii-d concatinate aliastail : aliasargs
    then  ( AdrAlias' LenAlias' ) ;

: setroot \ cr ." I must set root active package !!!!"
    roothandle @ dup nodehandle ! active-package ! (  ) ;

: copynode ( -- ) nodehandle @nt creanode @nt sizenode move ;
: copydata ( -- ) nodehandle @nt dup adrinstdata @nt swap leninstdata @ ( Adr Dl )
    dup if here -rot altovoc code> else 2drop false then ( adr )
    creanode @nt adrinstdata ! ( ( Copy and store adrinsdata ) ;
: copyproperty ( -- )
    0 creanode @nt prophandle ! \ No property in created instance before copying's
    nodehandle @ ( Phandle )
    creanode @ nodehandle ! ( Phandle )
    dup >code prophandle ( Phandle AdrPtrChainProp )
    begin
        dup @ (  )
    while
        \ >code
        code> ptrprop>valprop ( Av Lv An Ln )
\        @nt dup cell+ dup cell+ swap @nt count rot count
        \ cr 2dup type space 3 pick 3 pick type
        property (  .s key drop )
    repeat drop
    ( Phandle ) nodehandle ! ( -- ) ;
: resolvelinks ( -- )
    nodehandle @ creanode @nt ! \ Story phandle of prototype
    0 creanode @nt childhandle ! \ No child on new created instance
    0 creanode @nt siblinghandle ! \ No sibling on new created instance
    0 creanode @nt ihandle ! \ No instance on new created instance
    \ creanode @ dup p.node
    ( >code @ p.node insinchainsibling (  ) ;
: copyfromprototype ( -- )
\   ."  Go "
    copynode
\   ."  node "
    copydata
\   ."  Data "
    copyproperty
\   ."  Property "
    resolvelinks
\   ."  Links "
\    creanode @ p.node   key drop
    (   ) ;
: first-component ( Adr Dl ) 0 0 2swap >number drop ( N ) ;
: setmy-unit ( -- )
    unit_addr swap drop ( L ) 0=
    if  s" reg" get-my-property false =
        if  ( Adr Dl )
            first-component my-unit ! \ 4.3.2.e.1.i
        else
            0 my-unit ! \ 4.3.2.e.1.ii
        then
    else
        unit_phys @ my-unit ! \ 4.3.2.e.2
    then ;

: crinst \ Create new instance, add it to instance chain, and set various fields
    makeinstnode \ 4.3.2.a
\    ."  Crea "
    copyfromprototype \ cr ." Save new arguments!"
    ( ."  Inst. of " node_name type ) 40 space.to.column
    arguments ( A L ) dup if here placeinvoc ( Ahere ) code> else swap drop then
    creanode @nt adrarguments ! \ 4.3.2.b cr ." 4.3.2.b"
    parentnode @ creanode @nt parenthandle ! \ 4.3.2.c Set my-parent field Story parent ihandle Story parent ihandle
    creanode @ parentnode @nt childhandle ! \ NEW added in BM - Store child field in parentnode
    \ cr ." 4.3.2.c Set my-parent field"
    creanode @ parentnode ! \ 4.3.2.d cr ." 4.3.2.d"
    setmy-unit ( ( 4.3.2.d ) ;

\ 4.3.6. Node name match
: afternamecomma ( -- )  node_name s" name" get-my-property ascii ,
    left-split  2swap 2drop compare not ;
: namecompare ( Al Ll AN LN ) compare br0 true afternamecomma ( T/F ) ;
: 2dropfalse 2drop false ;
: nocomma ( Al Ll Ar Lr ) 2drop s" name" get-my-property
    br0 namecompare 2dropfalse ;

: iscomma ( Al Ll Ar Lr ) 2drop 2drop node_name s" name" get-my-property drop
    compare not ( T/F ) ;
: prov_vender  ( -- T/F )
    node_name ( Adr Dl ) ascii , left-split dup br0 nocomma iscomma ( T/F ) ;

\ 4.3.5. Wildcard math
: contnoempty ( -- ) node_name swap drop 0= unit_addr swap drop 0= and not ;
: noempty ( -- ) s" reg" get-my-property br0 2dropfalse contnoempty ;

: withemptynode ( AN LN ) 2drop s" name" get-my-property -rot 2drop
    br0 prov_vender false ;
: wildeq? ( -- T/F ) node_name dup br0 withemptynode noempty ;

\ 4.3.4. Exact match
: cmp_phys ( -- ) s" reg" get-my-property
    if abort" No adres defined" else 0 0 2swap >number 2drop drop then
    unit_phys = ( T/F ) ;

: nuempty? ( -- ) s" name" get-my-property
    br0 cmp_phys false ( T/F ) ;
: exactemptynode ( -- ) unit_addr swap drop br0 nuempty? cmp_phys ;
: exactmatch ( -- ) node_name swap drop br0 exactemptynode prov_vender ( T/F ) ;

\ 4.3.3. Matching child node
: recursivefindmatch ( False -- T/F ) nodehandle @ swap norealize
    swap nodehandle ! ( T/F ) ;
: findwildmatch ( False -- T/F ) norealize ex ;
: findexactmatch ( False -- T/F ) norealize ex ;
: rpfindwildmatch rp findwildmatch ( T/F ) ;
: contmatchchild ( -- ) 0 rp findexactmatch ( T/F )
    dup if0 rpfindwildmatch ( T/F ) dup if0 recursivefindmatch ( T/F ) ;
: exmetphys ( Xt T ) drop unit_addr rot execute unit_phys ! ( Rezult ) ;
: execdecodeunit ( -- ) s" decode-unit" nodehandle @ find-method
    ( False | Xt True ) dup not if0 exmetphys ( T/F ) ;
: matchchild ( -- ) unit_addr swap drop ( len )
    br0 execdecodeunit contmatchchild ( T/F ) ;
: initocrugenie ( -- ) 0 parentnode ! emptystr arguments st!
    emptystr unit_addr st! (  ) ;
: ?root ( A L -- T | F ) over c@ ascii / = ( T | F ) ;
: exchangealiasbyvalue ( AdrAlias LenAlias )
    2swap 2drop workwithalias ( AValAlias LValAlias )
    ptail 2@ ascii / over if conc2str&symb else 2drop then ( A' L' ) ;
: extractalias ( A L )
    ascii / left-split ( AdrL LenL AdrR LenR ) ptail 2! \ 4.3.1.A.1
    ascii : left-split ( AdrAlN LenAlN AdrAlArg LenAlArg ) \ 4.3.1.A.2
    paliasargs 2! \ Store string's arguments for alias
    2dup findalias ( AdrAlias LenAlias 1 | 0 ) not
    if exchangealiasbyvalue then ( A' L' ) ;

: findchildnode ( -- T/F )
    nodehandle @nt ( Phandle ) childhandle @ ( Phandle )
    begin
        s" name" 2 pick getPhandleProperty ( A L F | T ) not
        if  \ cr 2dup type 
            node_name compare 0<> ( False if equ )
        else true
        then
        ( Phandle Flag ) over >code siblinghandle @ over and ( Phandle Flag )
    while
        drop >code siblinghandle @ ( Phandle' )
    repeat ( Phandle' F/T ) not swap targetnode ! ( T/F ) ;
: creacall creanode @ $call-method (  ) ;
: execopen  ( -- ) s" OPEN" creacall (  ) ;

: gototargetnode ( -- ) targetnode @ nodehandle ! crinst drop \ In final node Len=0
    dup if execopen then (  ) ;
: razbornode ( A L )
    ascii / left-split ( 2Component 2PathName ) 2swap
    ascii : left-split ( 2PathName 2NodeAdr 2Arguments ) 2swap
    ascii @ left-split ( 2PathName 2Arguments 2NodeName 2Unit_Adr )
    unit_addr st! ( 2PathName 2Arguments 2NodeName )
    node_name st! ( 2PathName 2Arguments )
    arguments st! ( 2PathName ) ( Aost Lost ) ;
: inode creanode @ ( Inode ) ( norealize ) ;
: fullotkat ( 2PathName ) inode ( Phandle )
    begin ( Phandle ) \ map .s key drop
        s" CLOSE" 2 pick $call-method
        \ dup here - allot \ Release memory assigned for this node !!!
        parent ( Parent ) dup roothandle @ = not
    until ( False ) ;

: gobynodefrompath ( A L )
    razbornode
    findchildnode ( 2PathName T/F )
    if   gototargetnode true \ 4.3.1.K
    else fullotkat \ 4.3.1.L
    then ( A L ) ;
defer execfinalnode ' noop is execfinalnode
variable oldnode \ Node  before beginig procedure, for restoring in crash finding
variable oldinst \ Inode before beginig procedure, for restoring in crash finding

\ Path resolve procedure 4.3.1 Variant 2
: shpath 2dup path_name st! cr ." Full path=" 2dup type ;
: contgopath ( Adr Len ) shpath true \ Special initial flag
    begin
        drop gobynodefrompath ( Adr Len T/F ) over not over not or
    until ( Adr False )
    if 2drop execfinalnode inode ( Inode ) else 2drop (  ) then (  ) ;
: extalias
    ( Adr Len XtFinalExec -- Inode ) is execfinalnode ( Adr Len )
    nodehandle @ oldnode ! \ Saving node
    inode oldinst ! \ Saving Inode
    ?root if setroot else extractalias then ( Adr Len )
    ?root if setroot 1- swap 1+ swap then ( Adr Len ( 4.3.1.b ) ;
: gobypath ( A L ) extalias active-package @
    if contgopath ( ( 4.3.1.c ) else 2dropfalse then ( F | Inode ) ;

: open-dev ( Adr Len ) ['] execopen gobypath (  ) ;
: find-dev ( Adr Len ) ['] noop     gobypath (  ) ;

31 string ispmethod \ Name of method that will be executed on last node
: execispmethod ( -- ) ispmethod creacall (  ) ;
: execute-device-method ( Am Lm Ap Lp ) 2swap ispmethod st! ( Ap Lp )
    ['] execispmethod gobypath (  ) ;

: begin-package ( arg-str, arg-len, reg-str, reg-len, dev-str, dev-len -- )
    open-dev    ( arg-str, arg-len, reg-str, reg-len )
    new-device  ( arg-str, arg-len, reg-str, reg-len )
    set-args creanewvoc ( -- ) ;
: savenode       norealize ;
: delnode        norealize ;
: deleteinstance norealize ;
: selectparent   ( norealize )
				 nodehandle @ parenthandle >code @
				 \ cr ."  Parent =" .s
				 dup dup nodehandle ! -> my-self
                 parent parentnode ! ( -- ) ;
: close-dev      norealize ;
: finish-device ( -- )
\    s" name" creanode @ getPhandleProperty ( A L F | T )
\    ."  Property taken"
\    if delnode else 2drop savenode then
\    deleteinstance
	forth ( previous ) definitions \ set Forth as main vocabulary
\	order vocs key drop
    selectparent (  ) ;
: end-package ( -- )
	finish-device
	previous \ set Forth as main vocabulary
	close-dev (  ) ;
: bprp ( -- ) s" bus:120,123456/espdma@f,400000"
\ /sp@f,800000
    ['] execopen gobypath drop (  ) ;
\ options/openprom
\ Для пpовеpки пpавильности изменения значения свойства
: er (  ) s" /espdma@f,400000/esp@f,800000" s" SDDEV" property drop (  ) ;

: .name ( Pnode ) space space
    s" name" 2 pick getPhandleProperty not if type then ( Pnode ) ;
: ls ( -- ) nodehandle @nt childhandle @ dup
    if .name ( Phandle )
        begin >code siblinghandle @ dup while .name repeat drop (  )
    else drop then cr ( -- ) ;
