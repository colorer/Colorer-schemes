\ Client interface for BootMon. Chapter 6
." Client interface"
include? task-rp.fth rp.fth anew task-ClientInt.fth decimal
vocabulary client also client definitions
dictlist @ cell+ @ value clientvoc \ Adr vocabulary of client interface

\ Convert zerro terminated string to S" string
: z>s-string ( Azstr -- A L ) dup
    0 begin over c@ while 1+ swap 1+ swap repeat ( A Aend L )
    swap drop 1- ( A L ) ;
\ Test of existanse target method
: test ( Azstr -- F/T ) z>s-string
    clientvoc vfind ( XtW 1 | endVoc 0 ) swap drop not ( F/T ) ;
\ Peer
: Psibl ( Phandle ) >code siblinghandle @ ( SiblingHandle ) ;
: Proot ( Phandle ) drop roothandle @ ( SiblingHandle ) ;
: peer  ( Phandle ) dup br0 Proot Psibl ( SiblingHandle ) ; \ ++ 16-02-2000
\ Child
\ : child ( Phandle ) >code childhandle @ ( ChildHandle ) ;
\ getproplen
: getproplen ( Azstr Phandle -- Len | F )
    swap z>s-string rot ( A L Phandle ) getPhandleProperty
    ( Adr Len False | True  ) dup not if drop swap drop then ( Lprop ) ; \ ++ 16-02-2000
\ getprop
: getprop ( LenBuf AdrBuf Azstr Phandle -- Len | F )
    swap z>s-string rot ( LenBuf AdrBuf A L Phandle ) getPhandleProperty
    ( LenBuf AdrBuf Adr Len False | True ) not
    if  ( LenBuf AdrBuf Adr Len )
        2swap rot ( Adr AdrBuf Len LenBuf AdrBuf )
        min ( Adr AdrBuf LenMin ) dup >r move r> ( Len )
    else ( AdrBuf LenBuf ) 2drop true ( T ) then ( Lprop ) ; \ ++ 16-02-2000
\ nextprop
: nextprop ( AdrBuf Azstr Phandle -- T | F )
    swap z>s-string rot ( AdrBuf A L Phandle )
    next-property ( AdrBuf Anp Lnp T | AdrBuf F )
    if ( AdrBuf Anp Lnp )
        2 pick over + 1+ 0 swap c! \ Write 0 for zerro terminated string
        dup >r swap -rot move r> ( L )
    else drop false ( F ) then ( L ) ; \ ++ 16-02-2000

: setprop ( Len Buf SnameProp Phandle -- Size ) dup 4 mod
    if 2drop 2drop true
    else
        provphandle ( ... Phandle/T ) dup true =
        if 2drop 2drop true
        else
            2swap swap dup >r encode-string 2swap ( Buf Len Sname Phandle )
            swap z>s-string 2DUP TYPE rot ( Buf Len A L Phandle )
            nodehandle @ >r nodehandle !
            .S property \ Change value or make new property
            r> nodehandle ! r> ( Len )
        then
    then ( T | size ) ; \ ++ 17-02-2000

\ Instance-to-package
: proverprototype ( Ihandle -- Phandle | T ) @ \ Get prototip phandle
    provphandle ( Phandle | T ) ;
: instance-to-package ( Ihandle -- Phandle | T )
    dup 4 mod if drop true else proverprototype then ( Phandle | T ) ;
: getnamepnode ( Phandle Lbuf Abuf )
    rot s" name" rot getPhandleProperty ( A L 0 | T ) ;
: fullstore ( Lbuf Abuf A L ) swap 2 pick 2 pick move ( Lbuf Abuf L )
    swap over + -rot - swap ( Lbuf Abuf ) ;
: ukorot ( Lbuf Abuf A L ) drop over ( Lbuf Abuf A Abuf ) 3 pick move
    ( Lbuf Abuf ) + 0 swap  ( Lbuf Abuf ) ;
: storename ( Lbuf Abuf A L )
    2swap ascii / over c! 1+ swap 1- swap 2swap ( Lbuf-1 Abuf+1 A L )
    3 pick over < if ukorot else fullstore then ( Lbuf-L Abuf+L ) ;
: getbyroot ( Phandle -- PhandleN ...... PhandleR N )
    2 ( Phandle 1 )
    begin
        over parent ( Parent )
        dup  parent roothandle @ = not ( ? Parent is Root )
    while
        swap 1+
    repeat swap ( PhandleN ...... PhandleR N ) ;
: getnodepath ( Phandle ) dup parent roothandle @ = not
    if getbyroot else 1 then ( Abuf PhandleN ...... PhandleR N ) ;
: upbychain ( Lbuf Abuf Phandle )
    over >r rot >r
    getnodepath ( Abuf PhandleN ...... PhandleR N )
    r> r> rot 0
    do
        getnamepnode not
        if  ( Abuf PhandleN ...... PhandleM Lbuf Abuf A L )
        	decode-string 2swap 2drop storename
        then
    loop swap drop swap - ( LenPath ) ;
: package-to-path ( Lbuf Abuf Phandle -- LenPath )
    dup provphandle true =
    if  2drop drop true
    else ( Lbuf Abuf Phandle ) upbychain ( LenPath )
    then ( LenPath ) ;
: pwd ( Phandle -- ) 200 here rot package-to-path
    here swap ( AdrPath LenPath ) type ( -- ) ;
: finddevice ( AdrZstring -- Phandle ) norealize ;
: canon ( Lbuf Abuf StringZSpecif -- LenPath ) norealize ;

: gotoup ( A L ) 2drop nodehandle @nt dup roothandle @ = not
    if parenthandle @ nodehandle ! then ( -- ) ;
: gotodown ( A L ) type ( -- ) norealize ;
: tcd ( -- ) bl word count ( A L ) 2dup s" .." compare not
    if gotoup else gotodown then ( -- ) ;

: name>node ( An Ln ) norealize 2drop roothandle @  ( Node ) ;
: get-name-node-prop ( Anp Lnp Node -- Ap Lp F | T )
    name>node get-package-property ( Ap Lp F | T ) ;
: set-name-node-prop ( Avp Lvp Anp Lnp AnN LnN -- AdrPropRec )
	name>node get-package-property ( AdrPropRec ) ;

31 string namepropgs
31 string newvalpropgs
: p$setenv ( Av Lv ) newvalpropgs st! ( -- )
    \ space space namepropgs type ." ->" newvalpropgs type
	namepropgs /chosen get-package-property
	( A L F | T )
	if  cr ." No defined enviroment!" ( -- )
	else ( Aov Lov )
		2drop newvalpropgs encode-string namepropgs ( Av Lv An Ln )
		/chosen nodehandle dup @ >r ! property r> nodehandle ! ( -- )
	then ( -- ) ;
: $setenv ( Av Lv An Ln -- ) namepropgs st! ( -- ) ( Av Lv ) p$setenv ( -- ) ;
: setenv ( -- )
	bl word count namepropgs st! ( -- )
	carret word count ( Av Lv ) p$setenv ( -- ) ;
: $set-default ( A L -- ) 2dup namepropgs st!
	/options get-package-property ( A L F | T )
	if  cr ." No defined enviroment!" ( -- )
	else ( Aov Lov )
		2drop namepropgs /default get-package-property
		if	cr ." No defined default value!" ( -- )
		else
            decode-string 2swap 2drop encode-string namepropgs
            /options nodehandle dup @ >r ! property r> nodehandle ! ( -- )
        then
	then ( -- ) ;
: set-default ( -- ) bl word count ( -- ) \ space space 2dup type
    $set-default ( -- ) ;
: set-defaults ( -- )
	/default >code prophandle @ \ Pointer to the first property name
	begin
        >code dup ptrnameprop count ( Phandle A L A L )
        2dup 2dup cr type s" name" compare
        if   $set-default
	    else 2drop 2drop
	    then
        @ dup 0=
    until drop ( -- ) ;
: printenv ( -- )
	cr ." Variable Name     Value            Default Value" cr
    /options >code prophandle @ ( Phandle )
    begin
        >code dup ptrvalprop @nt 1+
        over ptrlenvalprop @
        2 pick ptrnameprop count ( Phandle A L A L )
        2dup s" name" compare
        if
	        cr 2dup type ."    " 2swap 20 space.to.column type
	        /default ( A L P ) getPhandleProperty not if ."     "
            50 space.to.column type then
	    else 2drop 2drop
	    then
        @ dup 0=
    until drop ( -- ) cr ;

0 [if] \ Only for testing package-to-path
120 string mm
: tptp ( Phandle ) 120 mm drop rot package-to-path .s mm drop swap type cr (  ) ;
[then]
\ previous base ! cr
