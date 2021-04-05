; ----------------------------------------------------------------------
; INNER INTERPRETER

IPUSH:  DEW     SP              ; -(SP) = R1H
        LDA     R1.3
        STR     SP
        DEW     SP
        LDA     R1.2
        STR     SP
PUSH:   DEW     SP              ; -(SP) = R1L
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
NEXT10: LDR     WA              ; BC/TMP = (WA)+
        STA     BC
        INW     WA
        LDR     WA
        STA     TMP
        INW     WA
        INB     CLK0            ; Increment the fake clock tick counter
        BNE     NEXT20          ; :
        INB     CLK1            ; :
        BNE     NEXT20          ; :
        INB     CLK2            ; :
        BNE     NEXT20          ; :
        INB     CLK3            ; :
NEXT20: JPR     BC              ; jump @(BC/TMP)

; ------------------------------
;       Push TRUE and FALSE

PUSHT:  CLW     R1              ; A zero
        DEW     R1              ; Make it into a -1 i.e. TRUE flag
        JPA     PUSH

PUSHF:  CLW     R1              ; A zero
        JPA     PUSH

; ------------------------------
;       Push R1X, MSB as TOS

DPUSH:  DEW     SP              ; -(SP) = R1X
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
