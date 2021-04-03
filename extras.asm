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

HBOUND: DB      ^2 ">" ^'<'                         ; ***** ><
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

HEMIT:  DB      ^4 "EMI" ^'T'                           ; ***** EMIT
        DW      HFALSE
EMIT:   DW      EMIT0
EMIT0:  JPS     _EMIT
        JPA     NEXT
        ;
_EMIT:  JPS     _POP1           ; Get character
        LDA     R1.0            ; Send char to terminal
        OUT                     ; :
        LDI     34              ; OUT++
        STA     R2.0            ; : R2 = Index to OUT
        JPS     _USER           ; : R3 = Addr to OUT
        JPS     _LD16           ; : R1 = OUT
        INW     R1              ; : R1++
        JPS     _ST16           ; : OUT = R1'
        RTS                     ; Done

HKEY:   DB      ^3 "KE" ^'Y'                            ; ***** KEY
        DW      HEMIT
KEY:    DW      KEY0
KEY0:   INP                     ; Get char from terminal
        CPI     0xFF            ; Did we get a character?
        BEQ     KEY0            ; NO: Try again
        STA     R1.0            ; YES: Push character
        CLB     R1.1            ; :
        JPA     PUSH            ; Push R1; NEXT

HQTERM: DB      ^9 "?TERMINA" ^'L'                      ; ***** ?TERMINAL
        DW      HKEY
QTERM:  DW      QTERM0
QTERM0: CLW     R1              ; Default FALSE to return
        INP                     ; Get char from terminal
        CPI     0xFF            ; Did we get a character?
        BEQ     QTER10          ; NO: Return FALSE
        DEW     R1              ; Make default FALSE into TRUE
QTER10: JPA     PUSH            ; Push R1; NEXT

HCR:    DB      ^2 "C" ^'R'                             ; ***** CR
        DW      HQTERM
CR:     DW      DOCOL LIT 13 EMIT LIT 10 EMIT SEMIS

HPQUOT: DB      ^3 '(' '"' ^')'                         ; ***** (")
        DW      HCR
PQUOT:  DW      DOCOL R DUP CAT ONEP
        DW      FROMR PLUS TOR SEMIS

HQUOTE: DB      ^^1 ^'"'                                ; ***** "
        DW      HPQUOT
QUOTE:  DW      DOCOL LIT CH_DQUOTE STATE AT ZBRAN +QUOT10
        DW      COMP PQUOT WORD HERE
        DW      CAT ONEP ALLOT BRAN +QUOT20
QUOT10: DW      WORD HERE PAD OVER CAT ONEP CMOVE PAD
QUOT20: DW      SEMIS

