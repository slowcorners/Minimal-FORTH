; ----------------------------------------------------------------------
; MATHEMATICS WORDS

HSTOD:  DB      ^4 "S->" ^'D'                           ; ***** S->D
        DW      HCOLD
STOD:   DW      DOCOL DUP ZLESS ZBRAN +STOD10
        DW      LIT -1 BRAN +STOD20
STOD10: DW      ZERO
STOD20: DW      SEMIS
; STOD0:  CLW     R1              ; Assume high word zero
;        INW     SP              ; Get operand high byte
;        LDR     SP              ; :
;        DEW     SP              ; :
;        CPI     0               ; Negative?
;        BMI     STOD10          ; YES: Push 0xFFFF
;        JPA     PUSH            ; NO: Push 0x0000
; STOD10: DEW     R1              ; Make 0x0000 into 0xFFFF
;        JPA     PUSH            ; Done

HPM:    DB      ^2 "+" ^'-'                             ; ***** +-
        DW      HSTOD
PM:     DW      DOCOL ZLESS ZBRAN +PM10
        DW      MINUS
PM10:   DW      SEMIS

HDPM:   DB      ^3 "D+" ^'-'                            ; ***** D+-
        DW      HPM
DPM:    DW      DOCOL ZLESS ZBRAN +DPM10
        DW      DMINU
DPM10:  DW      SEMIS

HABS:   DB      ^3 "AB" ^'S'                            ; ***** ABS
        DW      HDPM
ABS:    DW      DOCOL DUP PM SEMIS

HDABS:  DB      ^4 "DAB" ^'S'                           ; ***** DABS
        DW      HABS
DABS:   DW      DOCOL DUP DPM SEMIS

HMIN:   DB      ^3 "MI" ^'N'                            ; ***** MIN
        DW      HDABS
MIN:    DW      DOCOL OVER OVER GREAT ZBRAN +MIN10
        DW      SWAP
MIN10:  DW      DROP SEMIS

HMAX:   DB      ^3 "MA" ^'X'                            ; ***** MAX
        DW      HMIN
MAX:    DW      DOCOL OVER OVER LESS ZBRAN +MAX10
        DW      SWAP
MAX10:  DW      DROP SEMIS

HMSTAR: DB      ^2 "M" ^'*'                             ; ****** M*
        DW      HMAX
MSTAR:  DW      DOCOL OVER OVER XOR TOR ABS SWAP ABS
        DW      USTAR FROMR DPM SEMIS

HMSLAS: DB      ^2 "M" ^'/'                             ; ***** M/
        DW      HMSTAR
MSLAS:  DW      DOCOL OVER TOR TOR DABS R ABS
        DW      USLAS FROMR R XOR PM SWAP
        DW      FROMR PM SWAP SEMIS

HSTAR:  DB      ^1 ^'*'                                 ; ***** *
        DW      HMSLAS
STAR:   DW      DOCOL MSTAR DROP SEMIS

HSLMOD: DB      ^4 "/MO" ^'D'                           ; ***** /MOD
        DW      HSTAR
SLMOD:  DW      DOCOL TOR STOD FROMR MSLAS SEMIS

HSLAS:  DB      ^1 ^'/'                                 ; ***** /
        DW      HSLMOD
SLASH:  DW      DOCOL SLMOD SWAP DROP SEMIS

HMOD:   DB      ^3 "MO" ^'D'                            ; ***** MOD
        DW      HSLAS
MOD:    DW      DOCOL SLMOD DROP SEMIS

HSSMOD: DB      ^5 "*/MO" ^'D'                          ; ***** */MOD
        DW      HMOD
SSMOD:  DW      DOCOL TOR MSTAR FROMR MSLAS SEMIS

HSSLA:  DB      ^2 "*" ^'/'                             ; ***** */
        DW      HSSMOD
SSLA:   DW      DOCOL SSMOD SWAP DROP SEMIS

HMSMOD: DB      ^5 "M/MO" ^'D'                          ; ***** M/MOD
        DW      HSSMOD
MSMOD:  DW      DOCOL TOR ZERO R USLAS FROMR
        DW      SWAP TOR USLAS FROMR SEMIS
