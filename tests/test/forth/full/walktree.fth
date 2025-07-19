\ Walk by device's of tree in BootMon LNM 2000
cr ." Device tree parsing"
forth definitions decimal anew task-walktree.fth
defer workfornode \ Work that must executed on node point
' noop is workfornode 

: ptrmethwork ( Phandle AdrM LM -- )
    2 pick ( A L Phandle ) find-method ( XtW 1 | endVoc 0 )
    if space execute drop then ( Phandle ) ;
: testonnode ( Phandle ) s" TEST" ptrmethwork ( -- ) ;
: diagonnode ( Phandle ) s" TEST" ptrmethwork ( -- ) ;
' testonnode value ptstnode
' diagonnode value ptdiagnode

: endnode ( -- ) ." /" s" name" get-my-property not if type then (  ) ;
: tagshows ( ChPhandle ) cr dup . dup nodehandle ! endnode
    workfornode ( Phandle ) >code siblinghandle @ ( SiblHandle ) ;
: nodetarget-devs ( Phandle -- )  
    dup nodehandle @ swap dup nodehandle ! >code childhandle @ dup
    if  begin
            tagshows dup
            nodehandle @nt ihandle @ dup if ( showinst ) else drop then
            not
        until drop
    else drop then nodehandle ! ( Phandle -- ) ;
: walkbylevel ( Phandle )
    begin  ( Phandle )
        dup chnglevelnode ( Phandle )
        nodetarget-devs
        dup >code childhandle @ dup
        if \ Child are exists
            downtochild swap drop ( Phandle )
        else \ No child consist
            drop siblingorup ( Phandle )
        then ( Phandle )
        dup not
    until drop ( -- ) ;
: gotree ( -- ) nodehandle @ 0 leveltree !
    roothandle @ dup . ( ascii / emit ) walkbylevel nodehandle ! ( -- ) ;
: tsttree ( -- ) ptstnode is workfornode gotree ( -- ) ;
: diagtree ( -- ) ptdiagnode is workfornode gotree ( -- ) ;

: diagnostic ( -- ) cr ." Device diagnostics..." cr diagtree ( -- ) ;
: fulltest ( -- ) cr ." Full device diagnostics..." cr tsttree ( -- ) ;
: startbm ( -- ) cr ." BootMon v1.0a Russia Moscow SRISS 2000"
    use-nvramrc? if execscript then
    initbootmon
	diag-switch? if diagnostic else fulltest then
	selectIO
    auto-boot?   if gotoboot else cr ." I'm ready" then ( -- ) ;
0 [IF]
HEX \ For testing setprop operations

20 STRING ZSTR 
: TSP
	S" SELFTEST" ZSTR ST!
	ZSTR + 1+ 0 SWAP C!
	S" DISABLE NAVSEGDA" HERE 200 + SWAP MOVE
	10 HERE 200 + ZSTR DROP B41C SETPROP ;
DECIMAL
[THEN]
