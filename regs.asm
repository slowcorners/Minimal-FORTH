; ----------------------------------------------------------------------
; THE VIRTUAL FORTH MACHINE REGISTERS

        ORG     0x8800

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

        ORG     0x8810

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
