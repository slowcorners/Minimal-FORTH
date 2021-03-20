; ----------------------------------------------------------------------
; COLD AND WARM START ENTRY POINTS

CENT:   LDI     0xFE            ; Initialize Minimal stack pointer
        STA     0xFFFF          ; :
        LDI     <XSP            ; Initialize FORTH SP
        STA     SP.0            ; :
        LDI     >XSP            ; :
        STA     SP.1            ; :
        LDI     <TEST           ; Initialize FORTH IP
        STA     IP.0            ; :
        LDI     >TEST           ; :
        STA     IP.1            ; :
        JPA     NEXT            ; ... and over to FORTH VM

TEST:   DW      LIT STRING LIT HPFIND PFIND LIT 0x3377 _HALT

WENT:   NOP

STRING: DB      7 "EXECITE"

        ORG     0x8600
INCLUDE         regs.asm

        ORG     0x8620
XDP:    DW      0 0 0 0 0 0 0 0    
XSP:    DW      0 0 0 0 0 0 0 0
XRP:    DW      0
