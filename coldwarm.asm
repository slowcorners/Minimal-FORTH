; ----------------------------------------------------------------------
; COLD AND WARM START ENTRY POINTS

CENT:   LDI     0xFE            ; Initialize Minimal stack pointer
        STA     0xFFFF          ; :
        LDI     <COLD10         ; Start by executing COLD
        STA     IP.0            ; :
        LDI     >COLD10         ; :
        STA     IP.1            ; :
        JPA     NEXT            ; ... and over to FORTH VM

WENT:   LDI     0xFE            ; Initialize Minimal stack pointer
        STA     0xFFFF          ; :
        LDI     <ABOR10         ; Start by executing ABORT
        STA     IP.0            ; :
        LDI     >ABOR10         ; :
        STA     IP.1            ; :
        JPA     NEXT            ; ... and over to FORTH VM

HCOLD:  DB      ^4 "COL" ^'D'                           ; ***** COLD
        DW      HABORT
COLD:   DW      DOCOL
COLD10: ; Init FORTH registers
        DW      RPSTO SPSTO UPSTO
        ; Set FORTH vocabulary
        DW      LIT 12 PORIG AT
        DW      LIT 6 LIT FORTH PLUS STORE
        DW      _HALT
        ; Init 12 items (24 bytes) in user area ...
        ; ... with values from boot table
        DW      LIT 18 PORIG
        DW      LIT 16 PORIG AT LIT 6 PLUS
        DW      LIT 24 CMOVE
        ; Erase disk buffers
        DW      LIT 34 PORIG AT LIT 36 PORIG AT
        DW      OVER SUB ERASE
        ; Initialize some of the user variables
        DW      ZERO OUT STORE
        DW      FIRST AT USE STORE
        DW      FIRST AT PREV STORE
        ; Continue via ABORT
        DW      ABORT


