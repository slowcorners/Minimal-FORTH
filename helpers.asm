; ----------------------------------------------------------------------
; HELPER FUNCTIONS
;

; ------------------------------
;       R1 = (IP)+

_LIT:   LDR     IP
        STA     R1.0
        INW     IP
        LDR     IP
        STA     R1.1
        INW     IP
        RTS

; ------------------------------
;       IP = IP + (IP)+

_BRAN:  LDR     IP
        STA     R1.0
        INW     IP
        LDR     IP
        STA     R1.1
        DEW     IP
        LDA     R1.0
        ADB     IP.0
        LDA     R1.1
        ACB     IP.1
        RTS

; ------------------------------
;       R1 = (SP) "half function"

_GET1_: LDR     SP
        STA     R1.0
        INW     SP
        LDR     SP
        STA     R1.1
        RTS

; ------------------------------
;       R1 = (SP)

_GET1:  JPS     _GET1_
        DEW     SP
        RTS

; ------------------------------
;       R1 = (SP)+

_POP1:  JPS     _GET1_
        INW     SP
        RTS

; ------------------------------
;       R1X = (SP)+

_DPOP1: LDR     SP
        STA     R1.0
        INW     SP
        LDR     SP
        STA     R1.1
        INW     SP
        LDR     SP
        STA     R1.2
        INW     SP
        LDR     SP
        STA     R1.3
        INW     SP
        RTS

; ------------------------------
;       R2 = (SP) "half function"

_GET2_: LDR     SP
        STA     R2.0
        INW     SP
        LDR     SP
        STA     R2.1
        RTS

; ------------------------------
;       R2 = (SP)

_GET2:  JPS     _GET2_
        DEW     SP
        RTS

; ------------------------------
;       R1 = (SP)+

_POP2:  JPS     _GET2_
        INW     SP
        RTS

; ------------------------------
;       R2X = (SP)+

_DPOP2: LDR     SP
        STA     R2.0
        INW     SP
        LDR     SP
        STA     R2.1
        INW     SP
        LDR     SP
        STA     R2.2
        INW     SP
        LDR     SP
        STA     R2.3
        INW     SP
        RTS

; ------------------------------
;       R3 = (SP) "half function"

_GET3_: LDR     SP
        STA     R3.0
        INW     SP
        LDR     SP
        STA     R3.1
        RTS

; ------------------------------
;       R3 = (SP)

_GET3:  JPS     _GET3_
        DEW     SP
        RTS

; ------------------------------
;       R3 = (SP)+

_POP3:  JPS     _GET3_
        INW     SP
        RTS

; ------------------------------
;       R1 = (RP) "half function"

_RGET1_: LDR    RP
        STA     R1.0
        INW     RP
        LDR     RP
        STA     R1.1
        RTS

; ------------------------------
;       R1 = (RP)

_RGET1: JPS     _RGET1_
        DEW     RP
        RTS

; ------------------------------
;       R1 = (RP)+

_RPOP1: JPS     _RGET1_
        INW     RP
        RTS

; ------------------------------
;       R2 = (RP) "half function"

_RGET2_: LDR    RP
        STA     R2.0
        INW     RP
        LDR     RP
        STA     R2.1
        RTS

; ------------------------------
;       R2 = (RP)

_RGET2: JPS     _RGET2_
        DEW     RP
        RTS

; ------------------------------
;       R1 = (RP)

_RPOP2: JPS     _RGET2_
        INW     RP
        RTS

; ------------------------------
;       R3 = (RP) "half function"

_RGET3_: LDR    RP
        STA     R3.0
        INW     RP
        LDR     RP
        STA     R3.1
        RTS

; ------------------------------
;       R3 = (RP)

_RGET3: JPS     _RGET3_
        DEW     RP
        RTS

; ------------------------------
;       R3 = (RP)

_RPOP3: JPS     _RGET3_
        INW     RP
        RTS

; ------------------------------
;       (SP) = R1 "half function"

_PUT1_: LDA     R1.1
        STR     SP
        DEW     SP
        LDA     R1.0
        STR     SP
        RTS

; ------------------------------
;       (SP) = R1

_PUT1:  INW     SP
        JPS     _PUT1_
        RTS

; ------------------------------
;       -(SP) = R1

_PUSH1: DEW     SP
        JPS     _PUT1_
        RTS

; ------------------------------
;       (SP) = R2 "half function"

_PUT2_: LDA     R2.1
        STR     SP
        DEW     SP
        LDA     R2.0
        STR     SP
        RTS

; ------------------------------
;       (SP) = R2

_PUT2:  INW     SP
        JPS     _PUT2_
        RTS

; ------------------------------
;       -(SP) = R2

_PUSH2: DEW     SP
        JPS     _PUT2_
        RTS

; ------------------------------
;       (SP) = R3 "half function"

_PUT3_: LDA     R3.1
        STR     SP
        DEW     SP
        LDA     R3.0
        STR     SP
        RTS

; ------------------------------
;       (SP) = R3

_PUT3:  INW     SP
        JPS     _PUT3_
        RTS

; ------------------------------
;       -(SP) = R3

_PUSH3: DEW     SP
        JPS     _PUT3_
        RTS

; ------------------------------
;       (RP) = R1 "half function"

_RPUT1_: LDA    R1.1
        STR     RP
        DEW     RP
        LDA     R1.0
        STR     RP
        RTS

; ------------------------------
;       (RP) = R1

_RPUT1: INW     RP
        JPS     _RPUT1_
        RTS

; ------------------------------
;       -(RP) = R1

_RPUSH1: DEW    RP
        JPS     _PUT1_
        RTS

; ------------------------------
;       (RP) = R2 "half function"

_RPUT2_: LDA    R2.1
        STR     RP
        DEW     RP
        LDA     R2.0
        STR     RP
        RTS

; ------------------------------
;       (RP) = R2

_RPUT2: INW     RP
        JPS     _RPUT2_
        RTS

; ------------------------------
;       -(RP) = R2

_RPUSH2: DEW    RP
        JPS     _RPUT2_
        RTS

; ------------------------------
;       (RP) = R3 "half function"

_RPUT3_: LDA    R3.1
        STR     RP
        DEW     RP
        LDA     R3.0
        STR     RP
        RTS

; ------------------------------
;       (RP) = R3

_RPUT3: INW     RP
        JPS     _RPUT3_
        RTS

; ------------------------------
;       -(RP) = R3

_RPUSH3: DEW    RP
        JPS     _RPUT3_
        RTS

; ------------------------------
;       R1 = R1 + R2

_ADD16: LDA     R2.0
        ADB     R1.0
        LDA     R2.1
        ACB     R1.1
        RTS

; ------------------------------
;       R1X = R1X + R2X

_ADD32: LDA     R2.0
        ADB     R1.0
        LDA     R2.1
        ACB     R1.1
        LDA     R2.2
        ACB     R1.2
        LDA     R2.3
        ACB     R1.3
        RTS

; ------------------------------
;       R10 = R10 & R20

AND:    LDI     8               ; Load bit counter
        STA     R3              ; :
AND10:  LDA     R2              ; Load second operand
        LSL                     ; Shift 2b7 into C
        STA     R2              ; Store shifted second operand
        LDA     R1              ; Load first operand
        BCC     AND20           ; If C is clear: Shift in a zero
        ; 2b7 is set
        CPI     0               ; Is first operand < 0, i.e. is 1b7 set?
        BMI     AND20           ; N is set: 1b7 is set
        ; 1b7 is clear
        CLC                     ; 1b7 is clear: Clear C
AND20:  ROL                     ; Shift C into result
        STA     R1              ; Store first operand/result
        DEB     R3              ; All bits done?
        BNE     AND10           ;   NO: Do one more
        RTS                     ;   YES: All done

; ------------------------------
;       R10 = R10 | R20

OR:     LDI     8               ; Load bit counter
        STA     R3              ; :
OR10:   LDA     R2              ; Load second operand
        LSL                     ; Shift 2b7 into C
        STA     R2              ; Store shifted second operand
        LDA     R1              ; Load first operand
        BCS     OR20            ; If C is set, shift it into result
        ; 2b7 is clear
        CPI     0               ; Is first operand < 0, i.e. is 1b7 set?
        BMI     OR20            ; N is clear: 1b7 is clear
        ; 1b7 is clear
        CLC                     ; Neither bit is set: Clear C 
OR20:   ROL                     ; Shift C into result
        STA     R1              ; Store first operand/result
        DEB     R3              ; All bits done?
        BNE     OR10            ;   NO: Do one more
        RTS                     ;   YES: All done

; ------------------------------
;       R10 = R10 ^ R20

XOR:    LDI     8               ; Load bit counter
        STA     R3              ; :
XOR10:  LDA     R2              ; Get second operand
        LSL                     ; Shift b7 into C
        STA     R2              ; Store shifted second operand
        LDA     R1              ; Load first operand
        BCS     XOR20           ; C is set, check 1b7 for zero
        ; 2b7 is clear
        CPI     0               ; Is first operand < 0, i.e. is b7 set?
        BMI     XOR40           ; 1b7 is set and 2b7 is clear, shift in C which is set
        JPA     XOR30           ; 1b7 and 2b7 are both zero, clear C and shift in 
        ; 2b7 is set, check 1b7 for zero
XOR20:  CPI     0
        BPL     XOR40           ; If 1b7 is zero, shift in C which is set
XOR30:  CLC                     ; 1b7 and 2b7 are equal, shift in a zero
XOR40:  ROL                     ; Shift whatever is in C into result
        STA     R1              ; Store first operand/result
        DEB     R3              ; All bits done?
        BNE     XOR10           ;   NO: Do one more
        RTS                     ;   YES: All done

; ------------------------------
;       R1 = ~R1

_NOT32: LDA     R1.3            ; Negate MSB
        NEG                     ; Two-complement negation
        SBI     1               ; Adjust to bitwise not
        STA     R1.3            ; Store negated MSB
        LDA     R1.2            ; Negate byte2
        NEG                     ; Two-complement negation
        SBI     1               ; Adjust to bitwise not
        STA     R1.2            ; Store negated byte2
_NOT16: LDA     R1.1            ; Negate byte1
        NEG                     ; Two-complement negation
        SBI     1               ; Adjust to bitwise not
        STA     R1.1            ; Store negated byte1
        LDA     R1.0            ; Negate LSB
        NEG                     ; Two-complement negation
        SBI     1               ; Adjust to bitwise not
        STA     R1.0            ; Store negated LSB
        RTS                     ; Done

; ------------------------------
;       R1 = -R1

_NEG16: JPS     _NOT16          ; Bitwise NOT R1
        LDI     1               ; Add one to make it 2-complement
        ADB     R1.0            ; :
        LDI     0               ; :
        ACB     R1.1            ; :
        RTS                     ; Done

; ------------------------------
;       R1X = -R1X

_NEG32: JPS     _NOT32          ; Bitwise NOT R1X
        LDI     1               ; Add one to make it 2-complement
        ADB     R1.0            ; :
        DEC                     ; :
        ACB     R1.1            ; :
        ACB     R1.2            ; :
        ACB     R1.3            ; :
        RTS                     ; Done

; ------------------------------
;       R1 <-> R2

_XCH16: JPS     _PUSH1          ; Temp = R1
        LDA     R2.0            ; R1 = R2
        STA     R1.0            ; :
        LDA     R2.1            ; :
        STA     R1.1            ; :
        JPS     _POP2           ; R2 = Temp
        RTS                     ; Done

; ------------------------------
;       R1 = (R1)

_AT:    LDR     R1              ; Get LSB
        STA     R1.2            ; ... Store temp
        INW     R1              ; Bump
        LDR     R1              ; Get MSB
        STA     R1.3            ; ... Store temp
        LDA     R1.2            ; Get temp LSB
        STA     R1.0            ; ... Store
        LDA     R1.3            ; Get temp MSB
        STA     R1.1            ; ... Store
        RTS                     ; Done

; ------------------------------
;       "HALT"

_HALT:  DW      _HALT0
_HALT0: JPA     _HALT0

