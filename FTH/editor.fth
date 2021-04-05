VOCABULARY EDITOR IMMEDIATE

EDITOR DEFINITIONS DECIMAL

: #OUTSIDE? 2 PICK >R >< R> SWAP - ;
: >R#<      R# @ 0 1023 >< R# ! ;

: TEXT      HERE C/L 1+ BLANKS WORD HERE PAD C/L 1+ CMOVE ;
: LINE      DUP -16 AND 23 ?ERROR SCR @ (LINE) DROP ;
: -MOVE     LINE C/L CMOVE UPDATE ;

: E         LINE C/L BLANKS UPDATE ;
: H         LINE PAD 1+ C/L DUP PAD C! CMOVE ;
: R         PAD 1+ SWAP -MOVE ;
: P         1 TEXT R ;

: S
    DUP 1 - 14
    DO
        FORTH I LINE I 1+ EDITOR -MOVE -1
    +LOOP
    E ;

: D
    DUP H 15 DUP ROT
    DO
        I 1+ LINE I -MOVE
    LOOP
    E ;

: I         DUP S R ;
: A         DUP S P ;

: Z
    SCR ! 16 0 DO
        FORTH I EDITOR E
    LOOP
;

: COPY      SWAP BLOCK 2 - ! UPDATE FLUSH ;

: -TEXT
    SWAP -DUP
    IF
        OVER + SWAP
        DO
            DUP C@ FORTH I EDITOR C@ -
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

: TOP       0 R# ! ;
: #LOCATE   R# @ C/L /MOD ;
: #LEAD     #LOCATE LINE SWAP ;
: #LAG      #LEAD DUP >R + C/L R> - ;

: M
    R# +! >R#<
    CR #LOCATE 3 .R DROP
    SPACE #LEAD TYPE ASCII ^ EMIT #LAG TYPE ;

: T         DUP C/L * R# ! H 0 M ;
: L         SCR @ LIST 0 M ;
: 1LINE     #LAG PAD COUNT MATCH R# +! ;

: FIND
    BEGIN
        R# @ 1023 >
        IF
            TOP PAD HERE C/L 1+ CMOVE 0 ERROR
        ENDIF
        1LINE
    UNTIL
;

: DELETE
    >R #LAG + FORTH R - #LAG R MINUS R# +!
    #LEAD + SWAP CMOVE R> EDITOR BLANKS UPDATE
;

: N     FIND 0 M ;
: F     1 TEXT N ;
: B     PAD C@ MINUS M ;
: X     1 TEXT FIND PAD C@ DELETE 0 M ;
: G     0 15 >< C/L * R# ! 0 M ;

: TILL
    #LEAD + 1 TEXT 1LINE 0= 0 ?ERROR
    #LEAD + SWAP - DELETE 0 M
;

: C
    1 TEXT PAD COUNT
    #LAG ROT OVER MIN >R
    FORTH R R# +! R - >R
    DUP HERE R CMOVE
    HERE #LEAD + R> CMOVE R> CMOVE
    EDITOR UPDATE 0 M
;

FORTH DEFINITIONS
