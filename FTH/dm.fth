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
    [COMPILE] ' 2+ [COMPILE] '
    STATE @
    IF
\        [COMPILE] LITERAL [COMPILE] LITERAL COMPILE SWAP COMPILE !
        . .
    ELSE
        SWAP !
    ENDIF
; IMMEDIATE


: TESTWORD ." Testing" ;
DOER TEST
TEST
MAKE TEST TESTWORD
TEST
