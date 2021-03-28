; ----------------------------------------------------------------------
; DISK I/O

HPBUF:  DB      ^4 "+BU" ^'F'                           ; ***** +BUF
        DW      HMSMOD
PBUF:   DW      DOCOL BBUF LIT 4 PLUS
        DW      DUP LIMIT AT EQUAL ZBRAN +PBUF10
        DW      DROP FIRST AT
PBUF10: DW      DUP PREV AT SUB SEMIS

HUPDAT: DB      ^6 "UPDAT" ^'E'                         ; ***** UPDATE
        DW      HPBUF
UPDAT:  DW      DOCOL PREV AT AT LIT 0x8000
        DW      OR PREV AT STORE SEMIS

HMTBUF: DB      ^13 "EMPTY-BUFFER" ^'S'                 ; ***** EMPTY-BUFFERS
        DW      HUPDAT
MTBUF:  DW      DOCOL FIRST AT LIMIT AT
        DW      OVER SUB ERASE SEMIS

HFLUSH: DB      ^5 "FLUS" ^'H'                          ; ***** FLUSH
        DW      HMTBUF
FLUSH:  DW      DOCOL LIMIT AT FIRST AT XDO
FLUS10: DW      I AT ZLESS ZBRAN +FLUS20
        DW      I TWOP I AT LIT 0x7FFF
        DW      AND ZERO RW
FLUS20: DW      BBUF LIT 4 PLUS XPLOO +FLUS10
        DW      MTBUF SEMIS

HBUFFE: DB      ^6 "BUFFE" ^'R'                         ; ***** BUFFER
        DW      HFLUSH
BUFFE:  DW      DOCOL USE AT DUP TOR
BUFF10: DW      PBUF ZBRAN +BUFF10
        DW      USE STORE R AT LESS ZBRAN +BUFF20
        DW      R TWOP R AT LIT 0x7FFF
        DW      AND ZERO RW
BUFF20: DW      R STORE R PREV STORE FROMR TWOP SEMIS

HBLOCK: DB      ^5 "BLOC" ^'K'                          ; ***** BLOCK
        DW      HBUFFE
BLOCK:  DW      DOCOL TOR PREV AT DUP
        DW      AT LIT 0x7FFF AND R SUB ZBRAN +BLOC30
BLOC10: DW      PBUF ZEQU ZBRAN +BLOC20
        DW      DROP R BUFFE DUP R
        DW      ONE RW TWO SUB
BLOC20: DW      DUP AT LIT 0x7FFF AND R
        DW      SUB ZEQU ZBRAN +BLOC10
        DW      DUP PREV STORE
BLOC30: DW      FROMR DROP TWOP SEMIS

HPLINE: DB      ^6 "(LINE" ^')'                         ; ***** (LINE)
        DW      HBLOCK
PLINE:  DW      DOCOL TOR CL BBUF SSMOD FROMR BSCR
        DW      STAR PLUS BLOCK PLUS CL SEMIS

HDLINE: DB      ^5 ".LIN" ^'E'                          ; ***** .LINE
        DW      HPLINE
DLINE:  DW      DOCOL PLINE DTRAI TYPE SEMIS

HMESS:  DB      ^7 "MESSAG" ^'E'                        ; ***** MESSAGE
        DW      HDLINE
MESS:   DW      DOCOL WARN AT ZBRAN +MESS20
        DW      DDUP ZBRAN +MESS10
        DW      LIT 16 SLMOD LIT 4 PLUS DLINE
MESS10: DW      BRAN +MESS30
MESS20: DW      PDOTQ
        DB      6 "MSG" 32 '#' 32
        DW      DOT
MESS30: DW      SEMIS

HLOAD:  DB      ^4 "LOA" ^'D'                           ; ***** LOAD
        DW      HMESS
LOAD:   DW      DOCOL BLK AT TOR IN AT TOR ZERO IN
        DW      STORE BSCR STAR BLK STORE INTER FROMR
        DW      IN STORE FROMR BLK STORE SEMIS

HARROW: DB      ^^3 "--" ^'>'                           ; ***** -->
        DW      HLOAD
ARROW:  DW      DOCOL QLOAD ZERO IN STORE BSCR BLK AT
        DW      OVER MOD SUB BLK PSTOR SEMIS
