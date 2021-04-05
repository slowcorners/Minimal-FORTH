; ----------------------------------------------------------------------
; UPPER MEMORY AREA

        ORG     0xF5B4

XSP:    DB      0
XTIB:   DB      0
        DS      210             ; TIB:      84
XRP:    DB      0               ; RSTACK:  128
        ; 40 user variables
XUP:    DW      0 0 0 0 0 0 0 0 ;  0
        DW      0 0 0 0 0 0 0 0 ; 16
        DW      0 0 0 0 0 0 0 0 ; 32
        DW      0 0 0 0 0 0 0 0 ; 48
XTASKS:
XTASK0: DB      0               ; USER[64] is TASKS
XTASK1: DB      0               ; :
        DW      0 0 0 0 0 0 0   ; 66

DSKBF:  DB      0
        DS      2055            ; 2 * 1028 bytes
ENDBF:  DB      0

; ----------------------------------------------------------------------
; THE VIRTUAL FORTH MACHINE REGISTERS

IP:                             ; Instruction Pointer
IP.0:   DB      0
IP.1:   DB      0

WA:                             ; Word Address Register
WA.0:   DB      0
WA.1:   DB      0

SP:                             ; Data stack pointer
SP.0:   DB      0
SP.1:   DB      0

RP:                             ; Return stack pointer
RP.0:   DB      0
RP.1:   DB      0

UP:                             ; User area pointer
UP.0:   DB      0
UP.1:   DB      0

R1:                             ; Working register R1
R1.0:   DB      0
R1.1:   DB      0
R1H:
R1.2:   DB      0
R1.3:   DB      0

R2:                             ; Working register R2
R2.0:   DB      0
R2.1:   DB      0
R2H:
R2.2:   DB      0
R2.3:   DB      0

R3:                             ; Working register R3
R3.0:   DB      0
R3.1:   DB      0
R3H:
R3.2:   DB      0
R3.3:   DB      0

BC:     DB      0               ; "Hidden" registers
TMP:    DB      0               ; (used by _AND8 _OR8 _XOR8)
CHIN:   DB      0               ; Used by (?TERMINAL) and (KEY)
CLK0:   DB      0               ; 32-bit fake clock tick counter
CLK1:   DB      0               ; :
CLK2:   DB      0               ; :
CLK3:   DB      0               ; :

; LSTCLK is used by th4 FORTH multitasker in order to keep track
; of "delta ticks" since last DISPATCH run
LSTCLK: DB      0               ; Last clock tick count LSB

MEMEND: DS      0
     