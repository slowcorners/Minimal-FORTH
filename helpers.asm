; ----------------------------------------------------------------------
; HELPER FUNCTIONS
;

; ------------------------------
;       RegDE = (IP)+

_LIT:   LDR     IP
        STA     RegE
        INW     IP
        LDR     IP
        STA     RegD
        INW     IP
        RTS

; ------------------------------
;       IP = IP + (IP)+

_BRAN:  LDR     IP
        STA     RegE
        INW     IP
        LDR     IP
        STA     RegD
        DEW     IP
        LDA     RegE
        ADB     IPlo
        LDA     RegD
        ACB     IPhi
        RTS

; ------------------------------
;       RegD = RegE & RegD

AND:    LDI     8               ; Load bit counter
        STA     RegC            ; :
AND10:  LDA     RegE            ; Load second operand
        LSL                     ; Shift 2b7 into C
        STA     RegE            ; Store shifted second operand
        LDA     RegD            ; Load first operand
        BCC     AND20           ; If C is clear: Shift in a zero
        ; 2b7 is set
        CPI     0               ; Is first operand < 0, i.e. is 1b7 set?
        BMI     AND20           ; N is set: 1b7 is set
        ; 1b7 is clear
        CLC                     ; 1b7 is clear: Clear C
AND20:  ROL                     ; Shift C into result
        STA     RegD            ; Store first operand/result
        DEB     RegC            ; All bits done?
        BNE     AND10           ;   NO: Do one more
        RTS                     ;   YES: All done

; ------------------------------
;       RegD = RegE | RegD

OR:     LDI     8               ; Load bit counter
        STA     RegC            ; :
OR10:   LDA     RegE            ; Load second operand
        LSL                     ; Shift 2b7 into C
        STA     RegE            ; Store shifted second operand
        LDA     RegD            ; Load first operand
        BCS     OR20            ; If C is set, shift it into result
        ; 2b7 is clear
        CPI     0               ; Is first operand < 0, i.e. is 1b7 set?
        BMI     OR20            ; N is clear: 1b7 is clear
        ; 1b7 is clear
        CLC                     ; Neither bit is set: Clear C 
OR20:   ROL                     ; Shift C into result
        STA     RegD            ; Store first operand/result
        DEB     RegC            ; All bits done?
        BNE     OR10            ;   NO: Do one more
        RTS                     ;   YES: All done

; ------------------------------
;       RegD = RegE ^ RegD

XOR:    LDI     8               ; Load bit counter
        STA     RegC            ; :
XOR10:  LDA     RegE            ; Get second operand
        LSL                     ; Shift b7 into C
        STA     RegE            ; Store shifted second operand
        LDA     RegD            ; Load first operand
        BCS     XOR20           ; C is set, check 1b7 for zero
        ; 2b7 is clear
        CPI     0               ; Is first operand < 0, i.e. is b7 set?
        BMI     XOR90           ; 1b7 is set and 2b7 is clear, shift in C which is set
        JPA     XOR30           ; 1b7 and 2b7 are both zero, clear C and shift in 
        ; 2b7 is set, check 1b7 for zero
XOR20:  CPI     0
        BPL     XOR40           ; If 1b7 is zero, shift in C which is set
XOR30:  CLC                     ; 1b7 and 2b7 are equal, shift in a zero
XOR40:  ROL                     ; Shift whatever is in C into result
        STA     RegD            ; Store first operand/result
        DEB     RegC            ; All bits done?
        BNE     XOR10           ;   NO: Do one more
        RTS                     ;   YES: All done

; ------------------------------
;       RegD = ~RegD

NOT:    LDA     RegD            ; Load operand
        NEG                     ; Two-complement negation
        SBI     1               ; Adjust to become bitwise not
        STA     RegD            ; Store result
        RTS                     ; Done
