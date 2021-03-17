; ----------------------------------------------------------------------
; FORTH PRIMARIES
;

HLIT:   DB      ^3 "LI" ^'T'                            ; ***** LIT
        DW      0
LIT:    DW      LIT0
LIT0:   JPS     _LIT            ; R1 = (IP)+
        JPA     PUSH            ; -(SP) = R1, NEXT

HEXEC:  DB      ^7 "EXECUT" ^'E'                        ; ***** EXECUTE
        DW      HLIT
EXEC:   DW      EXEC0
EXEC0:  LDR     SP              ; WA = (SP)+
        STA     WAlo
        INW     SP
        LDR     SP
        STA     WAhi
        INW     SP
        JPA     NEXT10          ; jump @(WA)+

HBRAN:  DB      ^6 "BRANC" ^'H'                         ; ***** BRANCH
        DW      HEXEC
BRAN:   DW      BRAN0
BRAN0:  JPS     _BRAN           ; IP = IP + (IP)
        JPA     NEXT

HZBRAN: DB      ^7 "0BRANC" ^'H'                        ; ***** 0BRANCH
        DW      HBRAN
ZBRAN:  DW      ZBRAN0
ZBRAN0: LDR     SP
        CPI     0               ; Low byte non-zero?
        BNE     ZBRA10          ; YES: Do not branch
        INW     SP
        LDR     SP
        CPI     0               ; High byte non-zero?
        BNE     ZBRA20          ; YES: Do not branch
        INW     SP
        JPA     BRAN0           ; IP = IP + (IP), NEXT
ZBRA10: INW     SP
ZBRA20: INW     SP
        INW     IP              ; Just skip jump offset
        INW     IP
        JPA     NEXT
