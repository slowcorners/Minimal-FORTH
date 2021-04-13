\ Text to screens loader v 0.1
FORTH DEFINITIONS DECIMAL

VOCABULARY STORER IMMEDIATE

STORER DEFINITIONS

0 VARIABLE STORING
0 VARIABLE SCREEN
0 VARIABLE LINE
0 VARIABLE HEADING C/L ALLOT
\ -->
\ : String handling routines $=
: $=
    2DUP C@ SWAP C@ = IF
        DUP C@ >R
        BEGIN
            1+ SWAP 1+
            2DUP C@ SWAP C@ = R AND
        WHILE
            R> 1 - >R
        REPEAT
        2DROP R>
    ELSE
        2DROP -1
    ENDIF
    0=
;
\ -->
\ : : $#
: $#
    DUP >R
    BEGIN
        DUP C@
    WHILE
        1+
    REPEAT
    R> -
;
\ -->
\ : USE-SCR, POS and ++SCR
: USE-SCR
    SCR @ BLOCK
    DUP 1024 BLANKS
    SCREEN !
    0 LINE !
;

: POS   C/L * + + ;         \ scrAddr col row -- addr

: ++SCR
    " -->" DUP 1+ SWAP C@ SCREEN @ 53 16 POS SWAP CMOVE
    UPDATE 1 SCR +! USE-SCR
;
\ -->
\ : !LINE
: !LINE
    TIB @ $# IF
        TIB @ DUP $# SCREEN @ 0 LINE @ POS
        SWAP CMOVE
    ENDIF
    1 LINE +!
    LINE @ 16 > IF ++SCR 1 LINE ! ENDIF
;
\ -->
\ : COMMAND?
: COMMAND?
    BL WORD HERE " \" $= IF
        BL WORD HERE " -->" $= IF
            ++SCR TRUE
        ELSE
            HERE " --." $= IF
                UPDATE FLUSH FALSE STORING ! TRUE
            ELSE
                FALSE
            ENDIF
        ENDIF
    ELSE
        FALSE
    ENDIF
;
\ -->
\ : Main word: >SCREENS
: >SCREENS                      \ scr --
    SCR ! USE-SCR TRUE STORING ! CR
    BEGIN
        QUERY TIB @ $# 4 > IF
            COMMAND? NOT IF
                !LINE
            ENDIF
        ELSE
            !LINE
        ENDIF
        CR STORING @ NOT
    UNTIL
    ." Done" CR QUIT
;
FORTH DEFINITIONS
\ --.
