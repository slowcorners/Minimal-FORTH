; ----------------------------------------------------------------------
; FORTH PRIMARIES
;

HLIT:   DB      ^3 "LI" ^'T'                            ; ***** LIT
        DW      0
LIT:    DW      LIT0
LIT0:   JPS     _LIT            ; R1 = (IP)+
        JPA     PUSH            ; -(SP) = R1; NEXT

HEXEC:  DB      ^7 "EXECUT" ^'E'                        ; ***** EXECUTE
        DW      HLIT
EXEC:   DW      EXEC0
EXEC0:  LDR     SP              ; WA = (SP)+
        STA     WA.0
        INW     SP
        LDR     SP
        STA     WA.1
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
        JPA     BRAN0           ; IP = IP + (IP); NEXT
ZBRA10: INW     SP
ZBRA20: INW     SP
        INW     IP              ; Just skip jump offset
        INW     IP
        JPA     NEXT

HXPLOO: DB      ^7 "(+LOOP" ^')'                        ; ***** (+LOOP)
        DW      HZBRAN
XPLOO:  DW      XPLOO0
XPLOO0: JPS     _GET2           ; R2 = (SP) [only copying increment]
        JPS     _RPOP1          ; R1 = (RP)+
        JPS     _ADD16          ; R1 = counter'
        JPS     _RGET2          ; R2 = limit
        JPS     _RPUSH1         ; -(RP) = R1'
        JPS     _POP3           ; R3 = (SP)+ [now popping incr]
        LDA     R3.1            ; Is increment negative?
        CPI     0               ; :
        BPL     XPLO10
        ; Handle negative increment
        JPS     _XCH16          ; R1 <-> R2
        ; Compare counter to limit
XPLO10: LDA     R1.1            ; Compare MSB
        CPA     R2.1            ; :
        BMI     BRAN0           ; R2 is greater, continue looping
        BEQ     XPLO20          ; MSBs are equal, check LSBs
        JPA     XPLO30          ; R1 is greater, stop looping
        ; MSBs are equal
XPLO20: LDA     R1.0            ; Compare LSB
        CPA     R2.0            
        BMI     BRAN0           ; R2 is greater, continue looping
        ; Limit reached, cleanup rstack and stop looping
XPLO30: LDI     4               ; Drop loop counter ...
        ADW     RP              ; ... and loop limit
        LDI     2               ; Skip branch offset
        ADW     IP              ; :
        JPA     NEXT

HXLOOP: DB      ^6 "(LOOP" ^')'                         ; ***** (LOOP)
        DW      HXPLOO
XLOOP:  DW      XLOOP0
XLOOP0: CLW     R1              ; Push a one
        INW     R1              ; :
        JPS     _PUSH1          ; :
        JPA     XPLOO0          ; (+LOOP)

HXDO:   DB      ^4 "(DO" ^')'                           ; ***** (DO)
        DW      HXLOOP
XDO:    DW      XDO0
XDO0:   JPS     _POP1           ; Loop counter
        JPS     _POP2           ; Limit
        JPS     _RPUSH2         ; Push limit onto rstack
        JPS     _RPUSH1         ; Push loop counter onto rstack
        JPA     NEXT

HI:     DB      ^1 ^'I'                                 ; ***** I
        DW      HXDO
I:      DW      I0
I0:     JPS     _RGET1          ; Get loop counter
        JPS     _PUSH1          ; Push it onto dstack
        JPA     NEXT

HDIGIT: DB      ^5 "DIGI" ^'T'                          ; ***** DIGIT
        DW      HI
DIGIT:  DW      DIGIT0
DIGIT0: JPS     _POP2           ; Get base into R2.0
        JPS     _POP1           ; Get character into R1.0
        LDA     R1.0            ; Get character into A
        SBI     '0'             ; Assume '0' - '9'
        BMI     DIGI88          ; Oops! Negative
        CPI     10              ; Greater than 9?
        BMI     DIGI10          ; No, it is 0 - 9
        ; 'A' - 'Z' case
        SBI     7               ; ch -= ('A' - '0') + 10
DIGI10: CPA     R2.0            ; Greater than base?
        BMI     DIGI77
        JPA     DIGI88
DIGI77: STA     R1.0            ; Store binary value
        JPS     _PUSH1          ; Push the value
        JPA     PUSHT           ; Push TRUE; NEXT
DIGI88: JPA     PUSHF           ; Push FALSE; NEXT

HPFIND: DB      ^6 "(FIND" ^')'                         ; ***** (FIND)
        DW      HDIGIT
PFIND:  DW      PFIND0
PFIND0: JPS     _POP1           ; NFA
        JPS     _POP3           ; String address
PFIN10: LDA     R3.0            ; R2 = R3 (string address)
        STA     R2.0            ; :
        LDA     R3.1            ; :
        STA     R2.1            ; :
        ; Fast comparison of length bytes
        LDR     R1              ; Get lByte
        STA     R1.2            ; ... Store as potential result
        LSL                     ; lByte &= 0x3F
        LSL                     ; :
        LSR                     ; :
        LSR                     ; :
        STA     R2.2            ; R2.2 is counter for string match
        CPR     R2              ; lByte == string length?
        BNE     PFIN25
        ; Length bytes match, check names
PFIN20: INW     R1              ; Bump pointers
        INW     R2              ; :
        LDR     R1              ; Get char from dictionary
        LSL                     ; char &= 0x7F
        LSR
        CPR     R2              ; Is it a match with search string?
        BNE     PFIN30          ; NO: Look at next header in dictionary
        DEB     R2.2            ; Decrement character counter
        CPI     0               ; :
        BEQ     PFIN77          ; YES: This is the word we are looking for
        JPA     PFIN20          ; Match so far, try next char
        ; Step to next header in dictionary
PFIN25: INW     R1              ; Bump NFA pointer to actual characters
PFIN30: INW     R1              ; Bump NFA pointer
        DEB     R2.2            ; Decrement character counter
        CPI     0               ; End of name field?
        BNE     PFIN30          ; NO: Step to next char
        JPS     _AT             ; R1 = (R1)
        LDA     R1.1            ; At end of dictionary?
        CPI     0               ; :
        BNE     PFIN10          ; NO: Try this word for match
        LDA     R1.0            ; :
        CPI     0               ; :
        BNE     PFIN10          ; NO: Try this word for match
        ; Word not found, return a single FALSE
PFIN88: JPA     PUSHF           ; Done
        ; Word found, return PFA, lByte, TRUE
PFIN77: LDI     5               ; Bump ptr to PFA
        ADW     R1              ; :
        JPS     _PUSH1          ; Push PFA
        LDA     R1.2            ; Get stored length byte
        STA     R1.0            ; :
        CLB     R1.1            ; Clear MSB
        JPS     _PUSH1          ; Push length byte
        JPA     PUSHT           ; Done
        
HPLUS:  DB      ^1 ^'+'                                 ; ***** +
        DW      0
PLUS:   DW      PLUS0
PLUS0:  JPS     _POP2           ; Get second operand
        JPS     _POP1           ; Get first operand
        JPS     _ADD16          ; R1 = R1 + R2
        JPA     PUSH            ; -(SP) = R1; NEXT

HDPLU:  DB      ^2 "D" ^'+'                             ; ***** D+
        DW      0
DPLUS:  DW      DPLUS0
DPLUS0: JPS     _DPOP2          ; Get second operand
        JPS     _DPOP1          ; Get first operand
        JPS     _ADD32          ; R1X = R1X + R2X
        JPA     DPUSH           ; -(SP) = R1X; NEXT

HMINUS: DB      ^5 "MINU" ^'S'                          ; ***** MINUS
        DW      0
MINUS:  DW      MINUS0
MINUS0: JPS     _POP1           ; Get operand
        JPS     _NEG16          ; Negate
        JPA     PUSH

HDMINU: DB      ^6 "DMINU" ^'S'                         ; ***** DMINUS
        DW      0
DMINU:  DW      DMINU0
DMINU0: JPS     _DPOP1          ; Get operand
        JPS     _NEG32          ; Negate
        JPA     DPUSH

