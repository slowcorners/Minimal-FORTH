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
        STA     R1.2
        INW     SP
        LDR     SP
        STA     R1.3
        INW     SP
        LDR     SP
        STA     R1.0
        INW     SP
        LDR     SP
        STA     R1.1
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
        STA     R2.2
        INW     SP
        LDR     SP
        STA     R2.3
        INW     SP
        LDR     SP
        STA     R2.0
        INW     SP
        LDR     SP
        STA     R2.1
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
;       R3 = (SP)+
;       R2 = (SP)+
;       R1 = (SP)+

_POP321: JPS    _POP3
_POP21: JPS     _POP2
        JPS     _POP1
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
        JPS     _RPUT1_
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

_ADD16: LDA     R1.0
        ADA     R2.0
        STA     R1.0
        LDA     R1.1
        ACA     R2.1
        STA     R1.1
        RTS

; ------------------------------
;       R1X = R1X + R2X

_ADD32: LDA     R1.0
        ADA     R2.0
        STA     R1.0
        LDA     R1.1
        ACA     R2.1
        STA     R1.1
        LDA     R1.2
        ACA     R2.2
        STA     R1.2
        LDA     R1.3
        ACA     R2.3
        STA     R1.3
        RTS

; ------------------------------
;       R1 = (R1)

_ATR1:  LDR     R1              ; Get LSB
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
;       R1 = (R3)

_LD16:  LDR     R3
        STA     R1.0
        INW     R3
        LDR     R3
        STA     R1.1
        DEW     R3
        RTS

; ------------------------------
;       (R3) = R1

_ST16:  LDA     R1.0
        STR     R3
        INW     R3
        LDA     R1.1
        STR     R3
        DEW     R3
        RTS

; ------------------------------
;       R1.0 = R1.0 & R2.0

_AND8:  LDI     8               ; Load bit counter
        STA     BC              ; :
_AND81: LDA     R2.0            ; Load second operand
        LSL                     ; Shift 2b7 into C
        STA     R2.0            ; Store shifted second operand
        LDA     R1.0            ; Load first operand
        BCC     _AND82          ; If C is clear: Shift in a zero
        ; 2b7 is set
        CPI     0               ; Is first operand < 0, i.e. is 1b7 set?
        BMI     _AND82           ; N is set: 1b7 is set
        ; 1b7 is clear
        CLC                     ; 1b7 is clear: Clear C
_AND82: ROL                     ; Shift C into result
        STA     R1.0            ; Store first operand/result
        DEB     BC              ; All bits done?
        BNE     _AND81          ;   NO: Do one more
        RTS                     ;   YES: All done

; ------------------------------
;       R1.0 = R1.0 | R2.0

_OR8:   LDI     8               ; Load bit counter
        STA     BC              ; :
_OR810: LDA     R2.0            ; Load second operand
        LSL                     ; Shift 2b7 into C
        STA     R2.0            ; Store shifted second operand
        LDA     R1.0            ; Load first operand
        BCS     _OR820          ; If C is set, shift it into result
        ; 2b7 is clear
        CPI     0               ; Is first operand < 0, i.e. is 1b7 set?
        BMI     _OR820          ; N is clear: 1b7 is clear
        ; 1b7 is clear
        CLC                     ; Neither bit is set: Clear C 
_OR820: ROL                     ; Shift C into result
        STA     R1.0            ; Store first operand/result
        DEB     BC              ; All bits done?
        BNE     _OR810          ;   NO: Do one more
        RTS                     ;   YES: All done

; ------------------------------
;       R1.0 = R1.0 ^ R2.0

_XOR8:  LDI     8               ; Load bit counter
        STA     BC              ; :
_XOR81: LDA     R2.0            ; Get second operand
        LSL                     ; Shift b7 into C
        STA     R2.0            ; Store shifted second operand
        LDA     R1.0            ; Load first operand
        BCS     _XOR82          ; C is set, check 1b7 for zero
        ; 2b7 is clear
        CPI     0               ; Is first operand < 0, i.e. is b7 set?
        BMI     _XOR84          ; 1b7 is set and 2b7 is clear, shift in C which is set
        JPA     _XOR83          ; 1b7 and 2b7 are both zero, clear C and shift in 
        ; 2b7 is set, check 1b7 for zero
_XOR82: CPI     0
        BPL     _XOR84          ; If 1b7 is zero, shift in C which is set
_XOR83: CLC                     ; 1b7 and 2b7 are equal, shift in a zero
_XOR84: ROL                     ; Shift whatever is in C into result
        STA     R1.0            ; Store first operand/result
        DEB     BC              ; All bits done?
        BNE     _XOR81          ;   NO: Do one more
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
        LDA     R1.0            ; Add one to make it 2-complement
        ADI     1               ; :
        STA     R1.0            ; :
        LDA     R1.1            ; :
        ACI     0               ; :
        STA     R1.1            ; :
        RTS                     ; Done

; ------------------------------
;       R1X = -R1X

_NEG32: JPS     _NOT32          ; Bitwise NOT R1X
        LDA     R1.0            ; Add one to make it 2-complement
        ADI     1               ; :
        STA     R1.0            ; :
        LDA     R1.1            ; :
        ACI     0               ; :
        STA     R1.1            ; :
        LDA     R1.2            ; :
        ACI     0               ; :
        STA     R1.2            ; :
        LDA     R1.3            ; :
        ACI     0               ; :
        STA     R1.3            ; :
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
;       _USER
; NOTE: Index number in R2

_USER:  LDA     UP.0            ; R3 = UP
        STA     R3.0            ; :
        LDA     UP.1            ; :
        STA     R3.1            ; :
        LDA     R2.0            ; Get index number
        ADW     R3              ; Compute addr
        RTS                     ; Done

; ------------------------------
;       __PICK
; NOTE: Index number on Minimal stack

__PICK: LDA     SP.0            ; R3 = SP
        STA     R3.0            ; :
        LDA     SP.1            ; :
        STA     R3.1            ; :
        LDS     3               ; Get index number
        LSL                     ; : word index --> byte index
        ADW     R3              ; Compute addr
        JPS     _LD16           ; Get the n:th word from stack
        RTS                     ; Done

; ------------------------------
;       _ROLL
; NOTE: Index number on Minimal stack

__ROLL: LDS     3               ; Get index number
        STA     R3.3            ; Prepare loop counter
        PHS                     ; Push as parameter for _PICK
        JPS     __PICK          ; Pick n:th element in R1
        PLS                     ; Cleanup stack
        ; Set up source pointer (R2) for move
        LDA     R3.0            ; :
        STA     R2.0            ; :
        LDA     R3.1            ; :
        STA     R2.1            ; :
        DEW     R2              ; :
        DEW     R2              ; :
        ; All moved already?
_ROL10: LDA     R3.3            ; Get loop counter
        CPI     0               ; Zero?
        BEQ     _ROL99          ; YES: We are done
        ; Move one word down in the stack
        LDR     R2              ; Move word
        STR     R3              ; :
        INW     R2              ; :
        INW     R3              ; :
        LDR     R2              ; :
        STR     R3              ; :
        ; Bump pointers upwards in the stack
        LDI     3               ; :
        SBW     R2              ; :
        LDI     3               ; :
        SBW     R3              ; :
        ; Decrement counter
        DEB     R3.3            ; Decrement loop counter
        JPA     _ROL10          ; Go for another round
        ; All done
_ROL99: JPS     _PUT1           ; Replace top of stack with R1
        RTS                     ; :

; ------------------------------
;       _SWAP8
; Swaps R1.1 <-> R1.0
;       R2.1 <-> R2.0

_SWAP8: LDA     R1.0
        STA     TMP
        LDA     R1.1
        STA     R1.0
        LDA     TMP
        STA     R1.1
        LDA     R2.0
        STA     TMP
        LDA     R2.1
        STA     R2.0
        LDA     TMP
        STA     R2.1
        RTS

; ------------------------------
;       R1 = R1 & R2

_AND16: JPS     _AND8
        JPS     _SWAP8
        JPS     _AND8
        JPS     _SWAP8
        RTS

; ------------------------------
;       R1 = R1 | R2

_OR16:  JPS     _OR8
        JPS     _SWAP8
        JPS     _OR8
        JPS     _SWAP8
        RTS

; ------------------------------
;       R1 = R1 ^ R2

_XOR16: JPS     _XOR8
        JPS     _SWAP8
        JPS     _XOR8
        JPS     _SWAP8
        RTS

; ------------------------------
;       R3X = R1X * R2X

_UMULT: LDI     16              ; Set bit counter
        STA     BC
        LDI     0               ; R3X = 0
        STA     R3.0            ; :
        STA     R3.1            ; :
        STA     R3.2            ; :
        STA     R3.3            ; :
        STA     R1.2            ; R1H = 0
        STA     R1.3            ; :
_UMU10: LDA     R2.1            ; R2 >> 1
        LSR                     ; :
        STA     R2.1            ; :
        LDA     R2.0            ; :
        ROR                     ; :
        STA     R2.0            ; :
        BCC     _UMU20          ; No carry, no add
        LDA     R3.0            ; R3X = R3X + R1X
        ADA     R1.0            ; :
        STA     R3.0            ; :
        LDA     R3.1            ; :
        ACA     R1.1            ; :
        STA     R3.1            ; :
        LDA     R3.2            ; :
        ACA     R1.2            ; :
        STA     R3.2            ; :
        LDA     R3.3            ; :
        ACA     R1.3            ; :
        STA     R3.3            ; :
_UMU20: LDA     R1.0            ; R1X << 1
        LSL                     ; :
        STA     R1.0            ; :
        LDA     R1.1            ; :
        ROL                     ; :
        STA     R1.1            ; :
        LDA     R1.2            ; :
        ROL                     ; :
        STA     R1.2            ; :
        LDA     R1.3            ; :
        ROL                     ; :
        STA     R1.3            ; :
        DEB     BC              ; Decrement bit counter
        BNE     _UMU10          ; Not zero, more bits to go
        RTS

; ------------------------------
;       R1X / R2L
;       R1H: Quotient
;       R1L: Remainder

_UDIV:  LDI     16              ; Set bit counter
        STA     BC              ; :
        
_UDI10: LDA     R1.0            ; R1X = R1X << 1
        LSL                     ; :
        STA     R1.0            ; :
        LDA     R1.1            ; :
        ROL                     ; :
        STA     R1.1            ; :
        LDA     R1.2            ; :
        ROL                     ; :
        STA     R1.2            ; :
        LDA     R1.3            ; :
        ROL                     ; :
        STA     R1.3            ; :

        LDA     R1.2            ; R3H = R1H
        STA     R3.2            ; :
        LDA     R1.3            ; :
        STA     R3.3            ; :
        
        LDA     R3.2            ; R3H = R3H - R2L
        SBA     R2.0            ; :
        STA     R3.2            ; :
        LDA     R3.3            ; :
        SCA     R2.1            ; :
        STA     R3.3            ; :
        
        BCC     _UDI20
        
        LDA     R3.2            ; R1H = R3H
        STA     R1.2            ; :
        LDA     R3.3            ; :
        STA     R1.3            ; :
        
        INW     R1.0            ; R1L++
        
_UDI20: DEB     BC              ; All bits done?
        BNE     _UDI10          ; NO: Loop again
        
        RTS
