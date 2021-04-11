\ --- FORTH screen editor
FORTH DEFINITIONS DECIMAL

: TEXT
    HERE C/L 1+ BLANKS WORD HERE PAD C/L 1+ CMOVE ;
: LINE
    DUP 16 > 23 ?ERROR
    SCR @ (LINE) DROP ;

VOCABULARY EDITOR IMMEDIATE

: WHERE
    DUP B/SCR / DUP SCR ! ." SCR # " DECIMAL .
    SWAP C/L /MOD C/L * ROT BLOCK + CR C/L TYPE
    CR HERE C@ - SPACES ASCII ^ EMIT
    [COMPILE] EDITOR QUIT ;
\ -->
EDITOR DEFINITIONS

: #LOCATE   R# @ C/L /MOD ;
: #LEAD     #LOCATE LINE SWAP ;
: #LAG      #LEAD DUP >R + C/L R> - ;
: -MOVE     LINE C/L CMOVE UPDATE ;
: H         LINE PAD 1+ C/L DUP PAD C! CMOVE ;
: E         LINE C/L BLANKS UPDATE ;
: S
    DUP 1 - 15
    DO
        I LINE I 1+ -MOVE -1 
    +LOOP
    E
;
\ -->
: D
    DUP H 15 DUP ROT
    DO
        I 1+ LINE I -MOVE
    LOOP
    E
;

: M
    R# +! CR SPACE #LEAD TYPE ASCII ^ EMIT
    #LAG TYPE #LOCATE . DROP ;
\ -->
: T         DUP C/L * R# ! DUP H 0 M ;
: L         SCR @ LIST 0 M ;
: R         PAD 1+ SWAP -MOVE ;
: P         1 TEXT R ;
: I         DUP S R ;
: TOP       0 R# ! ;
: CLEAR     DUP SCR ! BLOCK 1024 BLANKS UPDATE ;
: COPY      SWAP BLOCK 2 - ! UPDATE ;
: CLRN      SWAP DO FORTH I EDITOR CLEAR
            ASCII . EMIT LOOP ;
\ -->
: -TEXT
    SWAP -DUP
    IF
        OVER + SWAP
        DO
            DUP C@ FORTH I C@ -
            IF  0=  LEAVE
            ELSE  1+  THEN
        LOOP
    ELSE
        DROP 0=
    THEN
;
\ -->
: MATCH
    >R >R 2DUP R> R> 2SWAP OVER + SWAP
    DO
        2DUP FORTH I -TEXT
        IF
            >R 2DROP R> - I SWAP -
            0 SWAP 0 0 LEAVE
        THEN
    LOOP
    2DROP SWAP 0= SWAP
;
\ -->
: 1LINE     #LAG PAD COUNT MATCH R# +! ;
:  FIND
    BEGIN
        R# @ 1019 >
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
\ -->
: N     FIND 0 M ;
: F     1 TEXT N ;
: B     PAD C@ MINUS M ;
: X     1 TEXT FIND PAD C@ DELETE 0 M ;
: Z
    #LEAD + 1 TEXT 1LINE 0= 0 ?ERROR
    #LEAD + SWAP - DELETE 0 M ;
: C
    1 TEXT PAD COUNT #LAG ROT OVER MIN >R
    FORTH R R# +! R - >R DUP HERE R CMOVE
    HERE #LEAD + R> CMOVE R> CMOVE UPDATE
    0 M ;

FORTH  DEFINITIONS   DECIMAL
\ --<
