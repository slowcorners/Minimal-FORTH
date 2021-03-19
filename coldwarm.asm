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



TEST:   DW      LIT 0x1122 LIT 0x3344 PLUS BRAN +TEST
        



WENT:   NOP

XDP:    DW      0 0 0 0 0 0 0 0
        DW      0 0 0 0 0 0 0 0
        DW      0 0 0 0 0 0 0 0
        DW      0 0 0 0 0 0 0 0
        DW      0 0 0 0 0 0 0 0
        DW      0 0 0 0 0 0 0 0
        DW      0 0 0 0 0 0 0 0
        DW      0 0 0 0 0 0 0 0
XSP:    DW      0 0 0 0 0 0 0 0
        DW      0 0 0 0 0 0 0 0
        DW      0 0 0 0 0 0 0 0
        DW      0 0 0 0 0 0 0 0
        DW      0 0 0 0 0 0 0 0
        DW      0 0 0 0 0 0 0 0
        DW      0 0 0 0 0 0 0 0
        DW      0 0 0 0 0 0 0 0
XRP:    DW      0
