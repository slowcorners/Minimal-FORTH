FORTH DEFINITIONS

: 2DROP     DROP DROP ;
: 2DUP      OVER OVER ;
: 2SWAP     ROT R> ROT R> ;


VOCABULARY EDITOR IMMEDIATE

EDITOR DEFINITIONS HEX

: TEXT
    HERE C/L 1+ BLANKS
    WORD PAD C/L 1+ CMOVE ;

: LINE
    DUP 0FFF0 AND 17 ?ERROR
    SCR @ (LINE) DROP ;

: -MOVE
    LINE C/L CMOVE UPDATE ;

: E     LINE C/L BLANKS UPDATE ;
: H     LINE PAD 1+ C/L DUP PAD C! CMOVE ;
: R     PAD 1+ SWAP -MOVE ;
: P     1 TEXT R ;

: S
    DUP 1 - 0E
    DO
        I LINE I 1+ -MOVE -1
    +LOOP
    E ;

: D
    DUP H 0F DUP ROT
    DO
        I 1+ LINE I MOVE
    LOOP
    E ;

: I     DUP S R ;

: CLEAR
    SCR ! 10 0 DO
        FORTH I EDITOR E
    LOOP
;

: COPY   SWAP BLOCK 2 - ! UPDATE FLUSH ;

: -TEXT
    SWAP -DUP
    IF
        OVER + SWAP
        DO
            DUP C@ FORTH I C@ -
            IF
                0= LEAVE
            ELSE
                1+
            ENDIF
        LOOP
    ELSE
        DROP 0=
    ENDIF
;

: MATCH
    >R >R 2DUP R> R> 2SWAP OVER + SWAP
    DO
        2DUP FORTH I -TEXT
        IF
            >R 2DROP R> - I SWAP - 0 SWAP 0 0 LEAVE
        ENDIF
    LOOP
    2DROP SWAP 0= SWAP
;

: MATCH
    >R >R 2DUP R> R> 2SWAP OVER + SWAP
    DO
        2DUP FORTH I -TEXT
        IF
            >R 2DROP R> - I SWAP - 0 SWAP 0 0 LEAVE
        ENDIF
    LOOP
    2DROP SWAP 0= SWAP
;

: TOP       0 R# ! ;
: #LOCATE   R# @ C/L /MOD ;
: #LEAD     #LOCATE LINE SWAP ;
: #LAG      #LEAD DUP >R + C/L R> - ;

: M     R# +! CR SPACE #LEAD TYPE 05F EMIT
        #LAG TYPE #LOCATE . DROP ;

: T     DUP C/L * R# ! H 0 M ;
: L     SCR @ LIST 0 M ;
: 1LINE #LAG PAD COUNT MATCH R# +! ;

: FIND
    BEGIN
        03FF R# @ <
        IF
            TOP PAD HERE C/L 1+ CMOVE 0 ERROR
        ENDIF
        1LINE
    UNTIL
;

: DELETE
    >R #LAG + FORTH R - #LAG R MINUS R# +!
    #LEAD + SWAP CMOVE R> BLANKS UPDATE
;

: N     FIND 0 M ;
: F     1 TEXT N ;
: B     PAD C@ MINUS M ;
: X     1 TEXT FIND PAD C@ DELETE 0 M ;

: TILL  #LEAD + 1 TEXT 1LINE 0= 0 ?ERROR
        #LEAD + SWAP - DELETE 0 M
;

: C     1 TEXT PAD COUNT #LAG ROT OVER MIN >R
        FORTH R R# +! R - >R DUP HERE CMOVE
        HERE #LEAD + R> CMOVE UPDATE 0 M
;
