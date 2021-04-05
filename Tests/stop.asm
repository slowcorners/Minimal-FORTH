HSTOP:  DB      ^4 "STO" ^'P'                           ; ***** STOP
        DW      HRUNS
STOP:   DW      STOP0
STOP0:  JPS     _POP2           ; R2 = taddr
        LDI     <XTASKS         ; Get address of prevL
        STA     R3.0            ; : i.e. address of TASKS
        LDI     >XTASKS         ; :
        STA     R3.1            ; :
        ; Is pointer zero? (i.e. we are at end of list)
STOP10: JPS     _LD16           ; R1 = actual pointer
        LDA     R1.0            ; Check LSB
        CPI     0               ; Zero?
        BNE     STOP20          ; NO: Go check taddr
        LDA     R1.1            ; LSB is zero, also check MSB
        CPI     0               ; Zero?
        BNE     STOP20          ; NO: Go check taddr
        JPA     NEXT            ; End of list, done
        ; Is this the requested "taddr"?
STOP20: LDA     R1.0            ; Check LSB
        CPA     R2.0            ; The requested taddr?
        BNE     STOP30          ; NO: Next task in queue please
        LDA     R1.1            ; Check MSB
        CPA     R2.1            ; The requested taddr?
        BNE     STOP30          ; NO: Next task in queue please
        ; Requested task found, de-link the task from task queue
        LDI     4               ; R1 = taddr.NEXT
        ADW     R1              ; :
        LDR     R1              ; prevL = taddr.NEXT
        STR     R3              ; :
        INW     R1              ; :
        INW     R3              ; :
        LDR     R1              ; :
        STR     R3              ; :
        LDI     0               ; taddr.NEXT = 0
        STR     R1              ; :
        DEW     R1              ; :
        LDI     0               ; :
        STR     R1              ; :
        JPA     NEXT            ; Done.
        ; Step to next task in queue
STOP30: LDI     4               ; R1 points to taddr.NEXT
        ADW     R1              ; :
        LDA     R1.0            ; R3 = R1
        STA     R3.0            ; :
        LDA     R1.1            ; :
        STA     R3.1            ; :
        JPA     STOP10          ; Go inspect next task in queue

