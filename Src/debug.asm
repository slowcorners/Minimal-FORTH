; ----------------------------------------------------------------------
; TEMP DEBUG FUNCTIONS FOR BRINGING UP THE SYSTEM
;

DBG:    DB      0
OUTC:   DB      0

_LNYB:  LDA     OUTC
        LSL
        LSL
        LSL
        LSL
        JPA     _HNYB1
_HNYB:  LDA     OUTC
_HNYB1: LSR
        LSR
        LSR
        LSR
        STA     OUTC
        RTS

; ------------------------------
;       "COUT"

_COUT:  LDA     OUTC
        OUT
_OWAIT: NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        RTS

; ------------------------------
;       "OUTHX"

_OUTHX: LDA     OUTC
        CPI     10
        BMI     _OUTH1
        SBI     10
        ADI     'A'
        STA     OUTC
        JPA     _COUT
_OUTH1: ADI     '0'
        STA     OUTC
        JPA     _COUT

; ------------------------------
;       "DUMP"

_DUMP:  LDA     R2.0
        CPI     0
        BNE     _DUMP1
        RTS
        ;
_DUMP1:
        DEW     R1
        LDR     R1
        STA     OUTC
        JPS     _HNYB
        JPS     _OUTHX
        LDR     R1
        STA     OUTC
        JPS     _LNYB
        JPS     _OUTHX

        DEW     R1
        LDR     R1
        STA     OUTC
        JPS     _HNYB
        JPS     _OUTHX
        LDR     R1
        STA     OUTC
        JPS     _LNYB
        JPS     _OUTHX

        LDI     32
        STA     OUTC
        JPS     _COUT

        DEB     R2.0
        DEB     R2.0
        BNE     _DUMP1
        RTS

_REG:   LDI     2
        STA     R2.0
        INW     R1              ; High byte first
_REG10: LDR     R1
        STA     OUTC
        JPS     _HNYB
        JPS     _OUTHX
        LDR     R1
        STA     OUTC
        JPS     _LNYB
        JPS     _OUTHX
        DEW     R1
        DEB     R2.0
        BNE     _REG10
        RTS

; ------------------------------
;       "CRLF"

_CRLF:  LDI     0x0D
        STA     OUTC
        JPS     _COUT
        LDI     0x0A
        STA     OUTC
        JPS     _COUT
        RTS

; ------------------------------
;       "DDST" "DRST"

_DDST:  LDI     <SP
        STA     R1.0
        LDI     >SP
        STA     R1.1
        JPS     _REG
        LDI     'S'
        STA     OUTC
        JPS     _COUT
        LDI     32
        STA     OUTC
        JPS     _COUT
        ;
        LDI     <XSP
        STA     R1.0
        LDI     >XSP
        STA     R1.1
        LDI     <XSP
        SBA     SP.0
        STA     R2.0
        LDI     >XSP
        SCA     SP.1
        STA     R2.1
        JPS     _DUMP
        RTS

_DRST:  LDI     <RP
        STA     R1.0
        LDI     >RP
        STA     R1.1
        JPS     _REG
        LDI     'R'
        STA     OUTC
        JPS     _COUT
        LDI     32
        STA     OUTC
        JPS     _COUT
        ;
        LDI     <XRP
        STA     R1.0
        LDI     >XRP
        STA     R1.1
        LDI     <XRP
        SBA     RP.0
        STA     R2.0
        LDI     >XRP
        SCA     RP.1
        STA     R2.1
        JPS     _DUMP
        RTS

; ------------------------------
;       "DEBUG"

DEBUG:
        JPS     _CRLF
        JPS     _DRST
        JPS     _CRLF
        JPS     _DDST
        JPS     _CRLF
        LDI     <IP
        STA     R1.0
        LDI     >IP
        STA     R1.1
        JPS     _REG
        LDI     '>'
        STA     OUTC
        JPS     _COUT
        LDI     32
        STA     OUTC
        JPS     _COUT
KWAIT:  INP
        CPI     0xFF
        BEQ     KWAIT
        CPI     CH_BL
        BEQ     KWAI10
        CPI     CH_BSP
        BNE     KWAI20
        LDI     0
        STA     DBG
        JPA     0
KWAI10: LDI     0
        STA     DBG
KWAI20: RTS

; ------------------------------
;

_DEBON: DW      _DEBO0
_DEBO0: LDI     1
        STA     DBG
        JPA     NEXT

_DEBOF: DW      _DEBF0
_DEBF0: LDI     0
        STA     DBG
        JPA     NEXT

_HALT:  DW      _HALT0
_HALT0: JPA     _HALT0
