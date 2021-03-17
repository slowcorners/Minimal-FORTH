; ----------------------------------------------------------------------
; INNER INTERPRETER

DPUSH:  DEW     SP              ; -(SP) = R2
        LDA     R2hi
        STR     SP
        DEW     SP
        LDA     R2lo
        STR     SP
PUSH:   DEW     SP              ; -(SP) = R1
        LDA     R1hi
        STR     SP
        DEW     SP
        LDA     R1lo
        STR     SP
NEXT:   LDR     IP              ; WA = (IP)+
        STA     WAlo
        INW     IP
        LDR     IP
        STA     WAhi
        INW     IP
NEXT10: LDR     WA              ; R1 = (WA)+
        STA     R1lo
        INW     WA
        LDR     WA
        STA     R1hi
        INW     WA
        JPR     R1              ; jump @(TMP)
