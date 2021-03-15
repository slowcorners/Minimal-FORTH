; ----------------------------------------------------------------------
; FORTH PRIMARIES
;

HLIT:   DB      ^3 "LI" ^'T'                            ; ***** LIT
        DW      0
LIT:    DW      LIT0
LIT0:   JPS     _LIT            ; move (IP)+, R1
        JPS     _PUSH           ; push R1
        JPA     NEXT

HEXEC:  DB      ^7 "EXECUT" ^'E'                        ; ***** EXECUTE
        DW      HLIT
EXEC:   DW      EXEC0
EXEC0:  LDR     SP              ; move (SP)+, WA
        STA     WAlo
        INW     SP
        LDR     SP
        STA     WAhi
        INW     SP
        JPA     NEXT10          ; jump @(WA)+

HBRAN:  DB      ^6 "BRANC" ^'H'                         ; ***** BRANCH
        DW      HEXEC
BRAN:   DW      BRAN0
BRAN0:  JPS     _BRAN           ; add (IP), IP
        JPA     NEXT

HZBRAN: DB      ^7 "0BRANC" ^'H'                        ; ***** BRANCH
        DW      HBRAN
ZBRAN:  DW      ZBRAN0
ZBRAN0: LDR     SP
        ROL
        BNE     ZBRA30          ; Low byte non-zero?
        INW     SP
        LDR     SP
        ROL
        BNE     ZBRA50          ; High byte non-zero?
        INW     SP
        JPS     _BRAN           ; add (IP), IP
        JPA     NEXT
ZBRA30: INW     SP
ZBRA50: INW     IP              ; Just skip jump offset
        INW     IP
        JPA     NEXT
