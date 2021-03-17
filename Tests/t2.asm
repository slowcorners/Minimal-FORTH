        ORG     0x8000

N0      EQU     0b00001111
N1      EQU     0b01010101

START:  JPA     MAIN

RegA:   DB      0
RegB:   DB      0
RegC:   DB      0
RegD:   DB      0
RegE:   DB      0

; ------------------------------
;       XOR     RegE, RegD

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
        JPA     XOR80           ; 1b7 and 2b7 are both zero, clear C and shift in 
        ; 2b7 is set, check 1b7 for zero
XOR20:  CPI     0
        BPL     XOR90           ; If 1b7 is zero, shift in C which is set
XOR80:  CLC                     ; 1b7 and 2b7 are equal, shift in a zero
XOR90:  ROL                     ; Shift whatever is in C into result
        STA     RegD            ; Store first operand/result
        DEB     RegC            ; All bits done?
        BNE     XOR10           ;   NO: Do one more
        RTS                     ;   YES: All done

MAIN:
        LDI     N0
        STA     RegD
        LDI     N1
        STA     RegE
        JPS     XOR
        LDA     RegD
        STA     RegA
STOP:   NOP
        JPA     STOP
