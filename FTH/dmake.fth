: NOTHING ;

\ : DOES-PFA  2+ ;

: DOER
    <BUILDS
        ' NOTHING ,
    DOES>
        @ >R
;

0 VARIABLE MARKER

: (MAKE)
    R> DUP 2+ DUP 2+ SWAP @ 2+ 2+ !
    @ -DUP IF >R ENDIF
;

: MAKE
    STATE @
    IF
        COMPILE (MAKE) HERE MARKER ! 0 ,
    ELSE
        HERE [COMPILE] ' 2+ !
        SMUDGE [COMPILE] ]
    ENDIF
; IMMEDIATE

: ;AND  COMPILE ;S HERE MARKER @ ! ; IMMEDIATE
: UNDO  ' NOTHING [COMPILE] ' 2+ ! ;

DOER TEST

TEST

MAKE TEST ." First test" ;

TEST

: T2    MAKE TEST ." Test #2" ;
: T3    MAKE TEST ." Test #3" ;AND ." T3 done." ;

T2
TEST

T3
TEST

UNDO TEST
TEST
