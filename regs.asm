; ----------------------------------------------------------------------
; THE VIRTUAL FORTH MACHINE REGISTERS

IP:                             ; Instruction Pointer
IPlo:   DB      0
IPhi:   DB      0

WA:                             ; Word Address Register
WAlo:   DB      0
WAhi:   DB      0

R1:                             ; Working register R1
R1lo:   DB      0
R1hi:   DB      0

R2:                             ; Working register R2
R2lo:   DB      0
R2hi:   DB      0

SP:                             ; Data stack pointer
SPlo:   DB      0
SPhi:   DB      0

RP:                             ; Return stack pointer
RPlo:   DB      0
RPhi:   DB      0

UP:                             ; User area pointer
UPlo:   DB      0
UPhi:   DB      0

