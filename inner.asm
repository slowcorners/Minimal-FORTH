; ----------------------------------------------------------------------
; INNER INTERPRETER

DPUSH:  DEW     SP              ; move R2, -(SP)
        LDA     R2hi
        STR     SP
        DEW     SP
        LDA     R2lo
        STR     SP
PUSH:   DEW     SP              ; move R1, -(SP)
        LDA     R1hi
        STR     SP
        DEW     SP
        LDA     R1lo
        STR     SP
NEXT:   LDR     IP              ; move (IP)+, WA
        STA     WAlo
        INW     IP
        LDR     IP
        STA     WAhi
        INW     IP
NEXT10: LDR     WA              ; move (WA)+, TMP
        STA     R1lo
        INW     WA
        LDR     WA
        STA     R1hi
        INW     WA
        JPR     R1              ; jump *TMP
