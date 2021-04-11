FORTH DEFINITIONS DECIMAL

0 VARIABLE STORING
0 VARIABLE SCR-NUM
0 VARIABLE SCR-BUF
0 VARIABLE LINE
0 VARIABLE HEADING C/L ALLOT

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

: $LEN                          \ addr -- len
    DUP >R
    BEGIN
        DUP C@
    WHILE
        1+
    REPEAT
    R> -
;

: USE-SCR                       \ --
    ." Using screen " SCR-NUM @ . CR
    \ SCR @ BLOCK
    \ DUP 1024 BLANKS
    \ SCR-BUF !
    \ 0 LINE !
;

: NEXT-SCREEN                   \ --
    ." Next screen" 1 SCR-NUM +! CR
    \ UPDATE 1 SCR +! USE-SCR
;

: SET-HEADING
    ." New heading: " TIB @ 6 + DUP $LEN TYPE CR
;

: STORE-LINE
    ." Storing: " TIB @ DUP $LEN TYPE CR
;

: COMMAND?
    BL WORD HERE " \" $= IF
        BL WORD HERE " ---" $= IF
            SET-HEADING TRUE
        ELSE
            HERE " -->" $= IF
                NEXT-SCREEN TRUE
            ELSE
                HERE " --<" $= IF
                    FALSE STORING ! TRUE
                ELSE
                    FALSE
                ENDIF
            ENDIF
        ENDIF
    ELSE
        FALSE
    ENDIF
;

: STORE                     \ scr --
    SCR-NUM ! USE-SCR
    TRUE STORING !
    BEGIN
        QUERY COMMAND? NOT IF
            STORE-LINE
        ENDIF
        STORING @ NOT
    UNTIL
    QUIT
;
