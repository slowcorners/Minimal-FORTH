; ----------------------------------------------------------------------
; MISCELLANEOUS HIGHER LEVEL

HTICK:  DB      ^^1 ^39                                 ; ***** '
        DW      HQUOTE
TICK:   DW      DOCOL DFIND ZEQU ZERO QERR DROP LITER SEMIS

HFORGE: DB      ^6 "FORGE" ^'T'                         ; ***** FORGET
        DW      HTICK
FORGE:  DW      DOCOL CURR AT CONT AT SUB LIT 24
        DW      QERR TICK DUP FENCE AT LESS LIT 21
        DW      QERR DUP NFA DP STORE LFA AT CONT
        DW      AT STORE SEMIS

HBACK:  DB      ^4 "BAC" ^'K'                           ; ***** BACK
        DW      HFORGE
BACK:   DW      DOCOL HERE SUB COMMA SEMIS

HBEGIN: DB      ^^5 "BEGI" ^'N'                         ; ***** BEGIN
        DW      HBACK
BEGIN:  DW      DOCOL QCOMP HERE ONE SEMIS

HENDIF: DB      ^^5 "ENDI" ^'F'                         ; ***** ENDIF
        DW      HBEGIN
ENDIF:  DW      DOCOL QCOMP TWO QPAIR HERE
        DW      OVER SUB SWAP STORE SEMIS

HTHEN:  DB      ^^4 "THE" ^'N'                          ; ***** THEN
        DW      HENDIF
THEN:   DW      DOCOL ENDIF SEMIS

HDO:    DB      ^^2 "D" ^'O'                            ; ***** DO
        DW      HTHEN
DO:     DW      DOCOL COMP XDO HERE LIT 3 SEMIS

HLOOP:  DB      ^^4 "LOO" ^'P'                          ; ***** LOOP
        DW      HDO
LOOP:   DW      DOCOL LIT 3 QPAIR COMP XLOOP BACK SEMIS

HPLOOP: DB      ^^5 "+LOO" ^'P'                         ; ***** +LOOP
        DW      HLOOP
PLOOP:  DW      DOCOL LIT 3 QPAIR COMP XPLOO BACK SEMIS

HUNTIL: DB      ^^5 "UNTI" ^'L'                         ; ***** UNTIL
        DW      HPLOOP
UNTIL:  DW      DOCOL ONE QPAIR COMP ZBRAN BACK SEMIS

HEND:   DB      ^^3 "EN" ^'D'                           ; ***** ENDI
        DW      HUNTIL
END:    DW      DOCOL UNTIL SEMIS

HAGAIN: DB      ^^5 "AGAI" ^'N'                         ; ***** AGAIN
        DW      HEND
AGAIN:  DW      DOCOL ONE QPAIR COMP BRAN BACK SEMIS

HREPEA: DB      ^^6 "REPEA" ^'T'                        ; ***** REPEAT
        DW      HAGAIN
REPEA:  DW      DOCOL TOR TOR AGAIN FROMR FROMR
        DW      TWO SUB ENDIF SEMIS

HIF:    DB      ^^2 "I" ^'F'                            ; ***** IF
        DW      HREPEA
IF:     DW      DOCOL COMP ZBRAN HERE ZERO COMMA TWO SEMIS

HELSE:  DB      ^^4 "ELS" ^'E'                          ; ***** ELSE
        DW      HIF
ELSE:   DW      DOCOL TWO QPAIR COMP BRAN HERE TWO COMMA
        DW      SWAP TWO ENDIF TWO SEMIS

HWHILE: DB      ^^5 "WHIL" ^'E'                         ; ***** WHILE
        DW      HELSE
WHILE:  DW      DOCOL IF TWOP SEMIS

HSPACS: DB      ^6 "SPACE" ^'S'                         ; ***** SPACES
        DW      HWHILE
SPACS:  DW      DOCOL ZERO MAX DDUP ZBRAN +SPAC20
        DW      ZERO XDO
SPAC10: DW      SPACE XLOOP +SPAC10
SPAC20: DW      SEMIS

HBDIGS: DB      ^2 "<" ^'#'                             ; ***** <#
        DW      HSPACS
BDIGS:  DW      DOCOL PAD HLD STORE SEMIS

HEDIGS: DB      ^2 "#" ^'>'                             ; ***** #>
        DW      HBDIGS
EDIGS:  DW      DOCOL DROP DROP HLD AT
        DW      PAD OVER SUB SEMIS

HSIGN:  DB      ^4 "SIG" ^'N'                           ; ***** SIGN
        DW      HEDIGS
SIGN:   DW      DOCOL ROT ZLESS ZBRAN +SIGN10
        DW      LIT '-' HOLD
SIGN10: DW      SEMIS

HDIG:   DB      ^1 ^'#'                                 ; ***** #
        DW      HSIGN
DIG:    DW      DOCOL BASE AT MSMOD ROT
        DW      LIT 9 OVER LESS ZBRAN +DIG10
        DW      LIT 7 PLUS
DIG10:  DW      LIT '0' PLUS HOLD SEMIS

HDIGS:  DB      ^2 "#" ^'S'                             ; ***** #S
        DW      HDIG
DIGS:   DW      DOCOL
DIGS10: DW      DIG OVER OVER OR ZEQU ZBRAN +DIGS10
        DW      SEMIS

HDDOTR: DB      ^3 "D." ^'R'                            ; ***** D.R
        DW      HDIGS
DDOTR:  DW      DOCOL TOR SWAP OVER DABS
        DW      BDIGS DIGS SIGN EDIGS
        DW      FROMR OVER SUB SPACS TYPE SEMIS

HDOTR:  DB      ^2 "." ^'R'                             ; ***** .R
        DW      HDDOTR
DOTR:   DW      DOCOL TOR STOD FROMR DDOTR SEMIS

HDDOT:  DB      ^2 "D" ^'.'                             ; ***** D.
        DW      HDOTR
DDOT:   DW      DOCOL ZERO DDOTR SPACE SEMIS

HDOT:   DB      ^1 ^'.'                                 ; ***** .
        DW      HDDOT
DOT:    DW      DOCOL STOD DDOT SEMIS

HQUEST: DB      ^1 ^'?'                                 ; ***** ?
        DW      HDOT
QUEST:  DW      DOCOL AT DOT SEMIS

HUDOT:  DB      ^2 "U" ^'.'                             ; ***** U.
        DW      HQUEST
UDOT:   DW      DOCOL ZERO DDOT SEMIS

; ----------------------------------
; UTILITY WORDS

HLIST:  DB      ^4 "LIS" ^'T'                           ; ***** LIST
        DW      HUDOT
LIST:   DW      DOCOL DEC CR DUP SCR STORE PDOTQ
        DB      6 "SCR" 32 "#" 32
        DW      DOT LIT 16 ZERO XDO
LIST10: DW      CR I THREE DOTR SPACE
        DW      I SCR AT DLINE XLOOP +LIST10
        DW      CR SEMIS

HINDEX: DB      ^5 "INDE" ^'X'                          ; ***** INDEX
        DW      HLIST
INDEX:  DW      DOCOL CR ONEP SWAP XDO
INDE10: DW      CR I THREE DOTR SPACE ZERO I DLINE
        DW      QTERM ZBRAN +INDE20
        DW      LEAVE
INDE20: DW      XLOOP +INDE10
        DW      SEMIS

HVLIST: DB      ^5 "VLIS" ^'T'                          ; ***** VLIST
        DW      HINDEX
VLIST:  DW      DOCOL LIT 128 OUT STORE CONT AT AT
VLIS10: DW      OUT AT CL LIT 10 SUB
        DW      GREAT ZBRAN +VLIS20
        DW      CR ZERO OUT STORE
VLIS20: DW      DUP IDDOT SPACE PFA LFA AT
        DW      DUP ZEQU QTERM OR ZBRAN +VLIS10
        DW      DROP SEMIS

HSCODE: DB      ^^5 ";COD" ^'E'                         ; ***** ;CODE
        DW      HVLIST
SCODE:  DW      DOCOL QCSP COMP PSCOD LBRAC SMUDG SEMIS

HBYE:   DB      ^3 "BY" ^'E'                            ; ***** BYE
        DW      HSCODE
BYE:    DW      BYE0
BYE0:   LDI     0               ; Select EEPROM bank 0
        BNK                     ; :
        JPA     0               ; Re-start monitor

HFORTH: DB      ^^5 "FORT" ^'H'                         ; ***** FORTH
        DW      HBYE
FORTH:  DW      DODOE DOVOC 0xA081 HFORTH
XXVOC:  DW      0

XDP:    DB      0
