; ----------------------------------------------------------------------
; INNER INTERPRETER

DPUSH:  DEW     SP              ; -(SP) = BC
        LDA     RegC
        STR     SP
        DEW     SP
        LDA     RegB
        STR     SP
PUSH:   DEW     SP              ; -(SP) = DE
        LDA     RegE
        STR     SP
        DEW     SP
        LDA     RegD
        STR     SP
NEXT:   LDR     IP              ; WA = (IP)+
        STA     WAlo
        INW     IP
        LDR     IP
        STA     WAhi
        INW     IP
NEXT10: LDR     WA              ; DE = (WA)+
        STA     RegE
        INW     WA
        LDR     WA
        STA     RegD
        INW     WA
        JPR     RegDE           ; jump @(DE)
