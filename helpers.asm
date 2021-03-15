; ----------------------------------------------------------------------
; BITWISE LOGICAL OPERATIONS
;
; ------------------------------
;       R2H = R1H & R1L

AND:    CLB     R2hi            ; Zero result
        LDI     8               ; Init bit counter
        STA     R2lo            ; :
        ; Inspect first operand
AND00:  LDA     R1lo            ; Get first operand
        ROL                     ; Look at highest bit (i.e. sign flag)
        STA     R1lo            ; Store updated first operand
        BPL     AND10
        ; First is TRUE, inspect second operand
        LDA     R1hi            ; Get second operand
        ROL                     ; Look at highest bit (i.e. sign flag)
        STA     R1hi            ; Store updated second operand
        BPL     AND20
        ; Both are TRUE, set corresponding bit in result
        LDA     R2hi            ; Get result
        ROL                     ; Rotate as operands above
        ADI     0x80            ; Set highest bit
        STA     R2hi            ; Store result
        JPA     AND30           ; Go to end of loop
        ; First was FALSE, no need to look further
AND10:  LDA     R1hi            ; Get second operand
        ROL                     ; Just rotate
        STA     R1hi            ; Store updated second operand
AND20:  LDA     R2hi            ; Get result
        ROL                     ; Just rotate
        STA     R2hi            ; Store result
        ; Check for remaining iterations
AND30:  DEB     R2lo            ; Decrement bit counter
        BNE     AND00           ; Not zero: Next iteration
        RTS                     ; All eight bits done

; ------------------------------
;       R2H = R1H | R1L

OR:     CLB     R2hi            ; Zero result
        LDI     8               ; Init bit counter
        STA     R2lo            ; :
        ; Inspect first operand
OR00:   LDA     R1lo            ; Get first operand
        ROL                     ; Look at highest bit (i.e. sign flag)
        STA     R1lo            ; Store updated first operand
        BMI     OR10
        ; First is FALSE, inspect second operand
        LDA     R1hi            ; Get second operand
        ROL                     ; Look at highest bit (i.e. sign flag)
        STA     R1hi            ; Store updated second operand
        BMI     OR20
        ; Both are FALSE, rotate without setting bit in result
        LDA     R2hi            ; Get result
        ROL                     ; Rotate as operands above
        STA     R2hi            ; Store result
        JPA     OR30            ; Go to end of loop
        ; First was TRUE, no need to look further
OR10:   LDA     R1hi            ; Get second operand
        ROL                     ; Dummy shift
        STA     R1hi            ; Store updated second operand
        ; At least one was TRUE, rotate and set bit
OR20:   LDA     R2hi            ; Get result
        ROL                     ; Rotate as operands
        ADI     0x80            ; Set highest bit
        STA     R2hi            ; Store result
        ; Check for remaining iterations
OR30:   DEB     R2lo            ; Decrement bit counter
        BNE     OR00            ; Not zero: Next iteration
        RTS                     ; All eight bits done

; ------------------------------
;       R2H = R1H ^ R1L

XOR:    CLB     R2hi            ; Zero result
        LDI     8               ; Init bit counter
        STA     R2lo            ; :
        ; Inspect first operand
XOR00:  LDA     R1lo            ; Get first operand
        ROL                     ; Look at highest bit (i.e. sign flag)
        STA     R1lo            ; Store updated first operand
        BMI     XOR10
        ; First is FALSE, inspect second operand for TRUE
        LDA     R1hi            ; Get second operand
        ROL                     ; Look at highest bit (i.e. sign flag)
        STA     R1hi            ; Store updated second operand
        BMI     XOR30           ; Second is TRUE, set bit in result
        JPA     XOR20           ; Both operand bits are false
        ; First is TRUE, inspect second operand for FALSE
XOR10:  LDA     R1hi            ; Get second operand
        ROL                     ; Look at highest bit (i.e. sign flag)
        STA     R1hi            ; Store updated second operand
        BPL     XOR30           ; Second is FALSE, set bit in result
        ; FALSE case, just rotate result
XOR20:  LDA     R2hi            ; Get second operand
        ROL                     ; Dummy shift
        STA     R2hi            ; Store updated second operand
        JPA     XOR40
        ; TRUE case, rotate and set bit
XOR30:  LDA     R2hi            ; Get result
        ROL                     ; Rotate as operands
        ADI     0x80            ; Set highest bit
        STA     R2hi            ; Store result
        ; Check for remaining iterations
XOR40:  DEB     R2lo            ; Decrement bit counter
        BNE     XOR00           ; Not zero: Next iteration
        RTS                     ; All eight bits done

