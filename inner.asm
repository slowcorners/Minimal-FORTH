; ----------------------------------------------------------------------
; INNER INTERPRETER

PUSH:   DEW     SP              ; -(SP) = R1
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

; ------------------------------
;       Push TRUE and FALSE

PUSHT:  CLW     R1              ; A zero
        DEW     R1              ; Make it into a -1 i.e. TRUE flag
        JPA     PUSH

PUSHF:  CLW     R1              ; A zero
        JPA     PUSH

; ------------------------------
;       Push R1X, MSB as TOS

DPUSH:
        DEW     SP              ; -(SP) = R1X
        LDA     R1.1
        STR     SP
        DEW     SP
        LDA     R1.0
        STR     SP
        DEW     SP
        LDA     R1.3
        STR     SP
        DEW     SP
        LDA     R1.2
        STR     SP
        JPA     NEXT
