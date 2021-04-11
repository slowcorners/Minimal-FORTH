; ----------------------------------------------------------------------
; EXTRAS (added by SlowCorners)

HNOOP:  DB      ^4 "NOO" ^'P'                           ; ***** NOOP
        DW      HARROW
NOOP:   DW      DOCOL
NOO10:  DW      SEMIS

HASCII: DB      ^^5 "ASCI" ^'I'                         ; ***** ASCII
        DW      HNOOP
ASCII:  DW      DOCOL BL WORD HERE ONEP
        DW      CAT STATE AT ZBRAN +ASCI10
        DW      LITER
ASCI10: DW      SEMIS

HBSLAS: DB      ^^1 ^'\'                                ; ***** \
        DW      HASCII
BSLAS:  DW      DOCOL BLK AT ZBRAN +BSLA10
        DW      IN AT DUP CL MOD CL SWAP
        DW      SUB PLUS IN STORE BRAN +BSLA20
BSLA10: DW      ONE WORD
BSLA20: DW      SEMIS

HTASK:  DB      ^4 "TAS" ^'K'                           ; ***** TASK
        DW      HBSLAS
TASK:   DW      DOCOL BUILD ZERO COMMA
        DW      LIT NOOP COMMA ZERO COMMA DOES
DOTAS:  DW      SEMIS

HRUNS:  DB      ^4 "RUN" ^'S'                           ; ***** RUNS
        DW      HTASK
RUNS:   DW      DOCOL TICK CFA SWAP TWOP STORE SEMIS

; To be added as primaries: STOP AFTER NOW

HRQUIR: DB      ^7 "REQUIR" ^'E'                        ; ***** REQUIRE
        DW      HRUNS
RQUIR:  DW      DOCOL DFIND BRAN +RQUI10
        DW      TDROP BRAN +RQUI20
RQUI10: DW      LIT 34 ERROR
RQUI20: DW      SEMIS

HBOUND: DB      ^2 ">" ^'<'                             ; ***** ><
        DW      HRQUIR
BOUND:  DW      DOCOL TOR MAX FROMR MIN SEMIS

HDOER:  DB      ^4 "DOE" ^'R'                           ; ***** DOER
        DW      HBOUND
DOER:   DW      DOCOL BUILD LIT NOO10 COMMA DOES
DODOR:  DW      AT TOR SEMIS

HMAKE:  DB      ^4 "MAK" ^'E'                           ; ***** MAKE
        DW      HDOER
MAKE:   DW      DOCOL DFIND ZEQU ZERO QERR DROP TWOP DFIND
        DW      ZEQU ZERO QERR DROP STATE AT ZBRAN +MAKE10
        DW      LITER LITER COMP STORE BRAN +MAKE20
MAKE10: DW      SWAP STORE
MAKE20: DW      SEMIS

HPTRUE: DB      ^6 "(TRUE" ^')'                         ; ***** (TRUE)
        DW      HMAKE
PTRUE:  DW      DOCOL
PTR10:  DW      MONE SEMIS

HTRUE:  DB      ^4 "TRU" ^'E'                           ; ***** TRUE
        DW      HPTRUE
TRUE:   DW      DODOE DODOR PTR10

HFALSE: DB      ^5 "FALS" ^'E'                          ; ***** FALSE
        DW      HTRUE
FALSE:  DW      DOCON 0

HPEMIT: DB      ^6 "(EMIT" ^')'                         ; ***** (EMIT)
        DW      HFALSE
PEMIT:  DW      DOCOL
PEM10:  DW      XEMIT ONE OUT PSTOR SEMIS
        ;
XEMIT:  DW      XEMIT0
XEMIT0: JPS     _POP1           ; Get character
        LDA     R1.0            ; Send char to terminal
        OUT                     ; :
        JPA     NEXT            ; Done

HEMIT:  DB      ^4 "EMI" ^'T'                           ; ***** EMIT
        DW      HPEMIT
EMIT:   DW      DODOE DODOR PEM10

HPKEY:  DB      ^5 "(KEY" ^')'                          ; ***** (KEY)
        DW      HEMIT
PKEY:   DW      DOCOL
PKE10:  DW      PQTER ZBRAN +PKE10
        DW      XKEY SEMIS
        ;
XKEY:   DW      XKEY0
XKEY0:  CLB     R1.1            ; Clear MSB of result
        LDA     CHIN            ; Any character buffered?
        CPI     0xFF            ; :
        BNE     XKEY10          ; YES: We use the buffered character
        INP                     ; NO: Read whatever is on the input port
XKEY10: STA     R1.0            ; YES: This is in any case the result
        LDI     0xFF            ; Mark input buffer as empty
        STA     CHIN            ; :
        JPA     PUSH            ; Done

HKEY:   DB      ^3 "KE" ^'Y'                            ; ***** KEY
        DW      HPKEY
KEY:    DW      DODOE DODOR PKE10

HPQTER: DB      ^11 "(?TERMINAL" ^')'                    ; ***** (?TERMINAL)
        DW      HKEY
PQTER:  DW      DOCOL
PQT10:  DW      XQTER SEMIS
        ;
XQTER:  DW      XQTER0
XQTER0: CLW     R1              ; Default FALSE to return
        INP                     ; Get char from terminal
        CPI     0xFF            ; Did we get a character?
        BEQ     QTER10          ; NO: Return FALSE
        STA     CHIN            ; YES: Put into buffer
        DEW     R1              ; Make default FALSE into TRUE
QTER10: JPA     PUSH            ; Push R1; NEXT

HQTERM: DB      ^9 "?TERMINA" ^'L'                      ; ***** ?TERMINAL
        DW      HPQTER
QTERM:  DW      DODOE DODOR PQT10

HCR:    DB      ^2 "C" ^'R'                             ; ***** CR
        DW      HQTERM
CR:     DW      DOCOL EOL ONEP CAT DDUP ZBRAN +CR10
        DW      EMIT
CR10:   DW      EOL CAT DDUP ZBRAN +CR20
        DW      EMIT
CR20:   DW      SEMIS

HWIN:   DB      ^7 "WINDOW" ^'S'                        ; ***** WINDOWS
        DW      HCR
WIN:    DW      DOCOL LIT 0x0D0A EOL STORE
        DW      LIT 0x0D ENTER STORE
        DW      LIT 0x7F DEL STORE SEMIS

HUNIX:  DB      ^4 "UNI" ^'X'                           ; ***** UNIX
        DW      HWIN
UNIX:   DW      DOCOL LIT 0x000A EOL STORE
        DW      LIT 0x0A ENTER STORE
        DW      LIT 0x08 DEL STORE SEMIS

HEXPEC: DB      ^6 "EXPEC" ^'T'                         ; ***** EXPECT
        DW      HUNIX
EXPEC:  DW      DODOE DODOR PEXP05

HPQUOT: DB      ^3 '(' '"' ^')'                         ; ***** (")
        DW      HEXPEC
PQUOT:  DW      DOCOL R DUP CAT ONEP
        DW      FROMR PLUS TOR SEMIS

HQUOTE: DB      ^^1 ^'"'                                ; ***** "
        DW      HPQUOT
QUOTE:  DW      DOCOL LIT CH_DQUOTE STATE AT ZBRAN +QUOT10
        DW      COMP PQUOT WORD HERE
        DW      CAT ONEP ALLOT BRAN +QUOT20
QUOT10: DW      WORD HERE PAD OVER CAT ONEP CMOVE PAD
QUOT20: DW      SEMIS

