; ----------------------------------------------------------------------
; THE VIRTUAL FORTH MACHINE REGISTERS

IP:                             ; Instruction Pointer
IPlo:   DB      0
IPhi:   DB      0

WA:                             ; Word Address Register
WAlo:   DB      0
WAhi:   DB      0

RegBC:                          ; Working registers B and C
RegB:   DB      0
RegC:   DB      0

RegDE:                          ; Working registers D and E
RegD:   DB      0
RegE:   DB      0

SP:                             ; Data stack pointer
SPlo:   DB      0
SPhi:   DB      0

RP:                             ; Return stack pointer
RPlo:   DB      0
RPhi:   DB      0

UP:                             ; User area pointer
UPlo:   DB      0
UPhi:   DB      0

