; ----------------------------------------------------------------------
; INNER INTERPRETER

DPUSH:  DEW     SP              ; -(SP) = BC
        LDA     R1.3
        STR     SP
        DEW     SP
        LDA     R1.2
        STR     SP
PUSH:   DEW     SP              ; -(SP) = DE
        LDA     R1.1
        STR     SP
        DEW     SP
        LDA     R1.0
        STR     SP
NEXT:   LDR     IP              ; WA = (IP)+
        STA     WA.0
        INW     IP
        LDR     IP
        STA     WA.1
        INW     IP
NEXT10: LDR     WA              ; R1 = (WA)+
        STA     R1.0
        INW     WA
        LDR     WA
        STA     R1.1
        INW     WA
        JPR     R1              ; jump @(R1)
