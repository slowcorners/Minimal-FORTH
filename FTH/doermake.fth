: NOOP ." no-op" ;

: DOER
    <BUILDS
    ' NOOP ,
    DOES>
        @ >R
;

\ : (MAKE)
\    R> DUP 2+ DUP 2+ SWAP @ 2+ 2+ !
\    @ -DUP IF >R ENDIF
\ ;

: MAKE
    \ [COMPILE] ' 2+ [COMPILE] '
    [COMPILE] ' 2+ [COMPILE] '
    STATE @
    IF
        COMPILE LIT , COMPILE LIT , COMPILE !
    ELSE
        SWAP !
    ENDIF
; IMMEDIATE


: TESTWORD ." Testing" ;
DOER TEST
MAKE TEST TESTWORD
