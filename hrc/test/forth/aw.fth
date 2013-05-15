\ Additional words for working BOOTMON -- LNM 05-10-1999
." Additional words for BOOTMON"
include? task-instdata.fth instdata.fth
include? task-configur.fth configur.fth
anew task-aw.fth decimal

: norealize cr r@ new>name
    ."  - Error !!! The function " id. ."  is not realized once more !!!" cr cr ;
: .h base @ swap hex . base ! ;
: base$ ( base, <number> -- N , convert next number as hex )
    base @ swap base ! 32 lword number? num_type_single = not
    abort" Not a single number!" swap base ! state @
    IF [compile] literal THEN ;
: h# 16 base$ ; immediate
: d# 10 base$ ; immediate
: o#  8 base$ ; immediate

: leftsymbsrch ( Adr Len Symb )
    0 do dup c@ 2 pick = if leave then 1 + loop swap drop ( Adr Len AdrSymb ) ;
: left-split ( Adr Len Symb -- Adr LenSymb AdrSymb+1 Len-LenSymb-1 )
    2 pick 2 pick ( Adr Len Symb Adr Len )
    leftsymbsrch
    dup 3 pick - ( Adr Len AdrSymb LenSymb )
    rot swap -rot ( Adr LenSymb AdrSymb Len )
    swap 1+ swap 1- 2 pick - 0 max ( Adr LenSymb AdrSymb+1 Len-LenSymb-1 ) ;

: rightsymbsrch ( Adr Len Symb )
    0 do dup c@ 2 pick = if leave then 1 - loop swap drop ( Adr Len AdrSymb ) ;
: right-split ( Adr Len Symb -- Adr LenSymb AdrSymb+1 Len-LenSymb-1 )
    2 pick 2 pick + 1- 2 pick ( Adr Len Symb Adr+Len-1 Len )
    rightsymbsrch
    dup 3 pick - 0 max ( Adr Len AdrSymb LenSymb )
    rot swap -rot ( Adr LenSymb AdrSymb Len )
    swap 1+ swap 1- 2 pick - ( Adr LenSymb AdrSymb+1 Len-LenSymb-1 ) ;
: left-parse-string left-split ;
: unaligned-@ 0 4 0 do dup 8 << over 8 c@ + swap 1 + swap loop  ( Data ) ;
\ variable #out
: lcc ( char ) dup h# 41 h# 5a between if h# 20 + then ( char' ) ;
: upc ( char ) dup ascii a ascii z between if h# 20 - then ( char' ) ;
\ encode string to upper registr
: stupc ( A L ) dup if 2dup 0 do dup c@ upc over c! 1+ loop drop then ( A L ) ;

: allignhere ( -- ) here 4 mod dup
    if   4 swap - ( dup ." SmGr=" . )
         0 do 255 c, loop \ Aliigen for 4
    else drop then ( -- ) ;
: encode+ ( Padr1 Plen1 Padr2 Plen2 -- Padr1 Plen1+len2 )
    ASCII , rot c! + dup 1+ 2 pick c! ( Padr1 Plen1+len2 ) ; \ ++
: encode-bytes  here >r ( adr len ) dup c, 0 do dup c@ c, 1+ loop drop (  )
    r> here over - 1- ( adr len ) ; \ ++
: encode-string here >r ( adr len ) dup c, 0 do dup c@ c, 1+ loop drop (  )
    0 c, r> here over - 1- ( adr len ) ; \ ++
: encode-int ( n -- Padr Plen ) base @ >r hex
    \ LNM variant <# 0 8 0 do # loop #> ( adr len )
    (.) \ Classic variant
    encode-bytes r> base ! ( Padr Plen ) ; \ ++
: encode-2int >r encode-int r> encode-int encode+ ( Padr Plen ) ; \ ++
: //string tuck - >r + r> ;

15 constant obio
: decode-bytes ( pAdr1 pLen1 dLen -- pAdr1 pLen1 dAdr dLen )
    >r over r@ + swap r@ - rot r> ( pAdr1 pLen1 dAdr dLen ) ;
: decode-space dup 0=
    if drop  obio exit then   2dup " obio" $=
    if 2drop obio exit then   2dup " io" $=
    if 2drop obio exit then   ( ffd2c320 ) dup obio =
    if drop  obio exit then   dup 1 >
    if dup ." Invalid address" .h cr abort then ;
: decode-int ( Padr Plen ) base @ >r hex 0 0 2swap >number
    dup if 1- swap 1+ swap then 2swap drop
    r> base ! ( Padr' Plen' N ) ; \ ++++ 21-02-2000
: decode-unit ascii , left-parse-string 2swap decode-int -rot decode-space ;
: decode-string ( pAdr pLen -- pAdr' pLen' str len )
    2dup 0 do dup c@ not if leave then 1+ loop ( pAdr pLen pAdr' )
    dup 1+ swap 3 pick - ( pAdr pLen pAdr' StLen )
    rot ( pAdr pAdr' StLen pLen ) over - 1- swap -rot 2swap ( pAdr' pLen' str len ) ; \ ++++ 03-05-2000
: creanewvoc ( -- ) base @ hex
    voccount @ 1+ voccount !
    <# voccount @ 0 # # #
    ascii - hold
    ascii d hold
    ascii o hold
    ascii h hold
    ascii t hold
    ascii e hold
    ascii m hold
    #> ( Adr Len ) \ over over type
    over over tvocabulary
    ( also ) evaluate definitions  \ Set current Voc
    dictlist @ cell+ voclistbase @ - \ Adres of pointer's of latest created vocabulary
    nodehandle @nt methvochandle ! \ Store PtrVoc of metod's for this node
    base ! ( -- ) ;
: find_end_chain_sibling ( Adr ) begin dup @ while @nt siblinghandle repeat ( Adr ) ;
: creaendnode ( -- )
    0 ,     \ place child handle
    0 ,     \ place sibling handle
    0 ,     \ place property voc handle
    0 ,     \ place method voc handle
    0 ,     \ place adress arguments
    0 ,     \ place adress inst data
    0 ,     \ place len inst data
    0 ,     \ place ihandle 1'st instance
    ; \ +++

: makenode ( -- ) allignhere ( -- )
    here code> creanode ! \ store place for begining area new node
    nodehandle @ 0= \ It is 1'st node or not
    if
       here code> roothandle ! \ store the base of tree
       cr ." Root of tree ="
       here code> dup . ,  \ place protohandle
       creanode @ , ( ? More correct variant ) \ place parent handle
    else
       cr ." Leaf of tree ="
       here code> dup . dup ,  \ place protohandle
       ."  From node ="
       nodehandle @nt dup dup code> . ( cr ( here AdrPtrNode PtrNode ) -rot
       childhandle dup @ 0<> \ Have child?
       if @nt siblinghandle find_end_chain_sibling then
       ! \ Store adres of this node as child
       code> , \ place parent handle
    then creaendnode (  ) ; \ +++

: makeinstnode ( -- ) allignhere ( -- )
    here code> creanode ! \ store place for begining area new node
    nodehandle @ 0= \ It is 1'st node or not
    if abort" Tree are absent !!!"
    else
       cr ."      Instance="
       here code> dup . nodehandle @ ,  \ place protohandle
       ."  From node="
       nodehandle @ dup . >code ( here AdrPtrNode PtrNode )
       ihandle find_end_chain_sibling ! \ Store adres of this node as instance
       0 , \ place parent handle
    then creaendnode (  ) ; \ +++

: new-device ( -- )
    sizedefinst if ( creanode @ cr ."  Node=" . )
    save-instdata then \ Save inst data
    \ forth definitions ( set forth vocabulary as master )
    ini-instproc makenode   \ Create new node
    creanode @ dup nodehandle ! -> my-self  \ store last defined node as current   
    instbase @ creanode @nt adrinstdata ! \ Store adr of area placeing new instance data
    creanewvoc ( vocabulary for methods node ) ; \ +++
: ihandle>phandle ( ihandle ) @ ( phandle ) ;

\ Place string in vocabulary
: altovoc ( adr len ) 0 do dup c@ c, 1+ loop drop (  ) ;
\ Place string with her lenght at the begining in vocabulary
: placeinvoc ( adr len HereAdr -- hereVoc )
    -rot dup c, ( Here, adr, len ) \ Place len
    altovoc ( Here ( Store value in voc ) ; \ +++
: placeproperty ( Padr Plen Nadr Nlen -- Adr )
    allignhere here >r ( Padr Plen Nadr Nlen )
    nodehandle @nt prophandle @ , \ Place pointer to next property
    2swap swap ( Nadr Nlen Plen Padr )
    code> , \ Store ptr to value property
    ( 1- ) 1 max , \ Store lenght of property
    ( Nadr Nlen ) dup c, altovoc allignhere \ Alligen adress by 4
    r> ( PPadr ) ;
\ Create property
: attribute ( Padr, Plen, Nadr, Nlen -- AdrPropRec )
    placeproperty ( here ) code> nodehandle @nt prophandle ! ( -- ) ;
: .properties ( -- )
    nodehandle @nt prophandle @ ( Phandle ) dup
    if  ( Phandle )
        begin
            >code dup ptrvalprop @nt 1+
            over ptrlenvalprop @
            2 pick ptrnameprop
            count cr type ." =" type
            @ dup 0=
        until drop
    else
        drop cr ." No property defined for this node!!!"
    then ; \ +++
: next-property ( PreviousStr, PreviousLen, Phandle - Ap Lp T | F )
    >code over 0=
    if  \ Is the first property in list
        -rot 2drop ( Phandle ) prophandle @ dup
        if   \ Get first property name
            >code ptrnameprop count
        else \ Property list is empty
            drop false
        then
    else \ We must first of all find previous property in list
        ( PreviousStr, PreviousLen, Phandle )
        prophandle @nt ( PtrPropList )
        begin
            dup ptrnameprop count ( PtrNextProp, PtrName, Len )
            \ Comparing contents
            4 pick 4 pick compare 0= ( 1/0 )
            if \ We are finded previous property
                ( PreviousStr, PreviousLen, PtrNextProp )
                @nt ptrnameprop -rot 2drop
                count true exit ( NameStr, NameLen, True )
            then
            @ dup >code swap 0= ( PreviousStr, PreviousLen, PtrNextProp )
        until ( PreviousStr, PreviousLen, PtrNextProp )
        drop 2drop false ( F )
    then ;

variable PrevPropPtr \ Adres of Ptr current property
: eqpropname? ( Ptrnode -- F|T )
    dup >code ptrnameprop count 4 pick 4 pick compare 0= ( F | T ) ; \ +++
: delete-property ( NameStr, NameLen ) stupc
    nodehandle @nt ( NameStr, NameLen, Phandle )
    prophandle dup code> PrevPropPtr ! @ dup
    if \ Property list not empty
        eqpropname?
        if \ It is deleting property
            ( ,,NextPropPtr ) >code @ PrevPropPtr @ ! \ Delete Property
        else
            begin
                ( NameStr, NameLen, NextPropPtr ) >code @ dup
                if \ Working with next property
                    eqpropname?
                    if \ It is deleting property
                        ( NameStr, NameLen, PropPtr)
                        >code @ PrevPropPtr @nt ! True ( NameStr, NameLen, True )
                    else
                        dup PrevPropPtr ! false
                        ( NameStr, NameLen, NextPropPtr, False )
                    then
                else \ Its end of list
                    drop true
                then
            until
        then
    else \ Empty property list
        drop
    then 2drop \ Drop namestring
; \ +++

: ptrprop>valprop ( ptrprop ) >code dup ptrvalprop @nt 1+ swap ptrlenvalprop @ ( A L ) ;
: getPhandleProperty ( NameStr, NameLen, Phandle -- Adr Len False | True )
    >r stupc r>
    >code prophandle ( dup PrevPropPtr ! ) @ dup
    if \ Property list not empty
        eqpropname?
        if \ It is finding property
            ( ,,NextPropPtr ) ( ." It's true?" cr )
            ptrprop>valprop False
        else
            begin
                ( NameStr, NameLen, NextPropPtr ) >code @ dup
                if \ Working with next property
                    eqpropname?
                    if \ It is finding property
                        ( NameStr, NameLen, PropPtr)
                        ptrprop>valprop False True
                        ( ValAdr Len False True )
                    else
                        ( dup >code PrevPropPtr ! ) false
                        ( NameStr, NameLen, NextPropPtr, False )
                    then
                else \ Its end of list
                    true dup dup
                then
            until
        then
    else \ Empty property list
        true swap true
    then
    3 roll drop 3 roll drop ( Adr, Len, 0/1 ) dup
    if -rot 2drop \ Drop namestring
    then ( Adr Len False | True ) ; \ +++
: get-package-property ( NameStr NameLen Phandle -- Adr Len False | True )
    getPhandleProperty ;
: get-my-property ( NameStr, NameLen -- Adr Len False | True )
    stupc nodehandle @ ( NameStr, NameLen, Phandle )
    getPhandleProperty ( Adr Len False | True ) ; \ +++

: oldplace ( Padr Plen PadrOldV PlenOldV PtrProperty -- AdrPropRec )
    2dup ptrlenvalprop ! \ Story new lenght
    >r drop \ Drop old lenght
    ( Padr Plen PadrOldV )
    over over 1- c! swap move ( -- ) \ Rewrite value of old property
    r> ( AdrPropRec ) ;
: newplace ( Padr Plen PadrOldV PlenOldV PtrProperty -- AdrPropRec )
    -rot 2drop -rot dup 3 pick ptrlenvalprop ! \ Story new lenght of value property
    ( PtrProperty Padr Plen )
    here placeinvoc ( PtrProperty Adr )
    code> over ptrvalprop ! ( AdrPropRec ) ;

: changevalueproperty ( Padr Plen Nadr Nlen PadrOldV PlenOldV )
\    4 pick ( ... NewLen ) < if oldplace else newplase then
    2drop ( Padr Plen Nadr Nlen )
    nodehandle @nt prophandle @ ( Padr Plen NameStr NameLen Phandle )
    begin
        eqpropname? not
        over >code @ and
    while
        >code @ \ Go to next proprty
    repeat -rot 2drop ( Padr Plen PtrProperty ) dup
    if   ( Padr Plen PtrProperty )
         >code dup -rot ( Padr PtrProperty Plen PtrProperty )
         ptrlenvalprop ! swap code> swap ptrvalprop ! ( -- )
    else ( Padr Plen PtrProperty )
         drop 2drop abort" Error !!! Property not find in list chain"
    then ( AdrPropRec ) ;

: property ( Padr, Plen, Nadr, Nlen -- AdrPropRec )
    \ cr .s
	stupc \ Name to upper registr
	\ .s 2dup space type
    2dup get-my-property if attribute else changevalueproperty then ; \ +++
: addproperty property drop ( -- ) ;
: device-name ( A L -- ) ."  Name=" 2dup type encode-string s" name" property ; \ +++
: device-type ( A L -- ) encode-string s" device-type" property ; \ +++
: model       ( A L -- ) encode-string s" model"       property ; \ +++
: set-args ( arg-str, arg-len, reg-str, reg-len )
    s" reg" property ( arg-str, arg-len ) \ Story Reg-str i property REG
    placeinvoc \ Place arg-ar to voc
    ( adrargstr ) my-self >code adrarguments ! ( -- ) ;
: izvlargs ( node ) >code adrarguments @ dup 0<>
    if >code count else 0 then ( Adr, Len ) ;                    \ +
: my-args ( -- ) my-self dup if izvlargs else drop then (  ) ; \ +
: typechainchild ( Pnode )
    begin dup while dup . space >code childhandle   @ repeat drop ( -- ) ; \ +
: typechainsibl ( Pnode )
    begin dup while dup . space >code siblinghandle @ repeat drop ( -- ) ; \ +

c" bvfind" find swap drop not [IF]
: bvfind ( AdrW LenW VocPtr -- XtW 1 | endVoc 0 )
    @ ( AdrW LenW LatestTVoc )
    begin
        dup @ 0<>
        if  ( AdrW LenW Nfa )
            dup count 4 pick 4 pick compare 0=
            if  ( We find it ! )
                false
            else
                true
            then
        else
            false
        then
    while
        prevname
    repeat ( AdrW LenW Nfa )
    -rot 2drop dup @ 0<> ( Nfa 1 | endVoc 0 ) swap over
    if name> then swap ( XtW 1 | endVoc 0 ) ; [THEN]
: .nm cr ." Words-" dup count type ;
: xtfindinvoc ( Xt LNFAVoc -- Xt )
    begin
        dup @ 0<>
        if
            dup cell- @ dup is.primitive?
            if
            drop true
            else
                >code
                begin
                    dup @ dup 0<>
                    if
                        3 pick =
                        if
                            cr? ?pause drop dup id. tab true false
                        else
                            true true
                        then
                    else
                        swap drop ( ,, 0 ) true swap
                    then
                while
                    drop cell+
                repeat
            then
        else
            false
        then
    while
        prevname
    repeat ;

\ Show all words that included Xt in own body
: .calls ( xt -- )
    dictlist @ swap ( PtrVoc Xt )
    begin
        over dup @ 0<>
        if
            dup cell 4 * + cr ." Voc-" id.  cr
            cell+ @ @ dup @ 0<>
            if xtfindinvoc true else drop then
        else
            false
        then
    while
        drop swap @ swap
    repeat drop drop cr ( -- ) ;
: find-method ( MethStr MethLen Phandle -- False | Xt True )
    >code methvochandle @ voclistbase @ + @ ( MethStr MethLen Pvoc )
    bvfind ( xt true | ptrvoc false )
    dup 0= if swap drop then ( False | Xt True ) ;
: $call-method ( MethStr MethLen Phandle -- )
    nodehandle @ >r dup nodehandle !
    find-method ( False | Xt True )
    if execute
    else abort" Sorry this method dosn't consist in this node !!!"
    then r> nodehandle ! (  ) ;

: headers norealize ;

: 3drop ( i j k -- ) 2drop drop (  ) ;
: 2rot  ( 1 2 3 4 5 6 )     5 roll 5 roll ( 3 4 5 6 1 2 ) ;
: 3rot  ( 1 2 3 4 5 6 7 8 ) 7 roll 7 roll ( 3 4 5 6 7 8 1 2 ) ;

: fcode-version2 h# 00020001 ;
: fcode-revision h# 00020001 ;
variable fcode-debug? 0 fcode-debug? ! \ Flag for debuging fcode programm
variable fcode-end

: scsi-selftest norealize ;
: .. .s ( cr ." It dont worked !!!" ) ;
: x+ encode+ ;

: get-buffers here 1000 allot ;

: $open-package norealize ;
: close-package norealize ;
: my-parent ( -- Inode ) my-self >code parenthandle @ ( Inode ) ;
: $call-parent ( Am Lm ) my-parent $call-method ( ??? ) ;

: version norealize ;
: sdc . norealize ;
: external norealize ;
: end0  00 norealize ;
: end1 255 norealize ;

\ For example 3-1
: bounds 10 ;
: #out 20 ;
: l@ @ ;

defer b(:) ( 0xb7 )
decimal
: get-phan-inher-prop ( NameStr NameLen node )
    begin
\        s" name" 2 pick get-package-property
\        not if cr ." Node=" type space then
        2 pick 2 pick 2 pick ( NameStr NameLen Inode )
        get-package-property ( Adr Len False | True )
        dup dup if 2 pick >code parenthandle @ else false then and
    while ( NameStr NameLen Inode )
        drop >code parenthandle @
    repeat
    dup if 2drop drop else 2rot 2drop 2swap swap drop -rot then
    ( Adr Len False | True ) ; \ ++
: get-inherited-property ( NameStr NameLen -- Adr Len False | True )
    my-self ( NameStr NameLen Inode ) get-phan-inher-prop ( Adr Len False | True ) ;
: decode-physadr ( A L -- PhysHi ...  PhysLo Aend Lend Size )
    s" #address-cells" nodehandle @ get-phan-inher-prop ( Adr Len False | True )
    if 1 else decode-int -rot 2drop then ( A L AC ) >r
    r@ 0   do decode-int -rot loop 
    r@ 0   do decode-int -rot loop 
    r@ 0   do decode-int -rot loop
    r> \ For standart variant dup dup + + 1+ dup >r roll r@ roll r> roll
    ( PhysHi ...  PhysLo Aend Lend Size ) ;
: decode-phys ( A L -- PhysHi ...  PhysLo Aend Lend Size )
    decode-physadr ( PhysHi ...  PhysLo Aend Lend Size )
    r> dup dup + + \ 3 *
    dup 1+ swap 0 do dup >r roll r> loop drop
    ( Aend Lend PhysHi ...  PhysLo Size ) ;
: encode-phys ( PhysHi ...  PhysLo Size )
    s" #address-cells" nodehandle @ get-phan-inher-prop ( Adr Len False | True )
\    br0 decode-int 1  ( N ( Ncells by adress )
    if 1 else decode-int -rot 2drop then
    3 * dup >r 1- roll encode-int 2 r> do i roll encode-int encode+ -1 +loop
    ( Padr Plen ) ; \ ++
: my-unit ( -- phys.lo .... phys.hi )
    s" reg" my-self get-package-property ( Adr Len False | True )
    if \ No property "reg" defined
        s" #address-cells" my-self get-phan-inher-prop
        if 2 else decode-int -rot 2drop then dup
        >r 0 do 0 loop  r@ 0 do 0 loop  r> 0 do 0 loop \ ?????
    else ( Adr Len ) decode-physadr drop 2drop ( phys.lo .... phys.hi )
    then (  phys.lo .... phys.hi ) ;
\ Convert interrup to CPU inerupt
: intr>cpu ;
: reg ( Phys.lo Phys.hi Size ) >r encode-phys r> encode-int ( A1 L1 A2 L2 )
    encode+ ( A L ) s" reg" property (  ) ;
: name ( adr len -- ) encode-string s" name" property ( -- ) ;
: intr ( Level Vector ) >r intr>cpu encode-int r> encode-int encode+
    ( adr len ) s" intr" property ( -- ) ;

: mask-lo-part ( phis.lo .... phys.hi ) drop ( phis.lo .... ) ; 
: mask-hi-part ( phis.lo .... phys.hi ) >r
	s" #address-cells" my-self get-phan-inher-prop ( A L F | T )
	if 1 else decode-int -rot 2drop then 1 << ( ( 2 component: LO & HI )
	0 do drop loop r> ( phis.hi ) ; 

: my-address ( -- phys.lo ) my-unit mask-lo-part ( phys.lo ) ;
: my-space   ( -- phys.hi ) my-unit mask-hi-part ( phys.hi ) ;
: >reg-spec ( offset size -- encodereg )
    >r my-address + my-space encode-phys
    r> encode-int encode+ ( 2dup type ( A L ) ;

: getnamehandleproperty ( A L A L ) 2drop 2drop norealize
    s" 120,400000" ( A L ) ;
: btest ( -- bit ) s" testbit" get-my-property ( A L F|T )
    if abort" No define testbit property !!!"
    else
        decode-int -rot 2drop ( i ) /mod ( i ost n ) 2 <<
        s" adrtestbittable" s" /options" getnamehandleproperty
        encode-phys + @ swap 1 swap << and ( bit )
    then ;
