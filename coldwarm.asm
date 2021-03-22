; ----------------------------------------------------------------------
; COLD AND WARM START ENTRY POINTS

CENT:   LDI     0xFE            ; Initialize Minimal stack pointer
        STA     0xFFFF          ; :
        LDI     <XSP            ; Initialize FORTH SP
        STA     SP.0            ; :
        LDI     >XSP            ; :
        STA     SP.1            ; :
        LDI     <XRP            ; Initialize FORTH RP
        STA     RP.0            ; :
        LDI     >XRP            ; :
        STA     RP.1            ; :
        LDI     <TEST           ; Initialize FORTH IP
        STA     IP.0            ; :
        LDI     >TEST           ; :
        STA     IP.1            ; :
        JPA     NEXT            ; ... and over to FORTH VM

TEST:   DW      LIT 32
TEST10: DW      DUP EMIT ONEP
        DW      DUP LIT 128 LESS ZEQU ZBRAN +TEST10
        DW      _HALT

WENT:   NOP

STRING: DB      32 32 "TOKEN" 0 32 32 0

        ORG     0xD000
INCLUDE         regs.asm

        ORG     0xD020
XDP:    DW      0 0 0 0 0 0 0 0    
XSP:    DW      0 0 0 0 0 0 0 0
XRP:    DW      0
