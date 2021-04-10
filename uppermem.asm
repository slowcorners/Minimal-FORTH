; ----------------------------------------------------------------------
; UPPER MEMORY AREA

        ORG     0xF5B0

XSP:    DB      0
XTIB:   DB      0
        DS      210             ; TIB:      84
XRP:    DW      0 0             ; RSTACK:  128

; ------------------------------
; USER AREA (NON-MOVABLE!)

XUP:
_EOL:   DW      0x000A          ;  0: EOL       Default UNIX settings
_ENTER: DW      0x0A            ;  2: ENTER     :
_DEL:   DW      0x08            ;  4: DEL       :
_S0:    DW      0               ;  6: S0
_R0:    DW      0               ;  8: R0
_TIB:   DW      0               ; 10: TIB
_WIDTH: DW      0               ; 12: WIDTH
_WARN:  DW      0               ; 14: WARNING
_FENCE: DW      0               ; 16: FENCE
_DP:    DW      0               ; 18: DP
_VOCL:  DW      0               ; 20: VOC-LINK
_FIRST: DW      0               ; 22: FIRST
_LIMIT: DW      0               ; 24: LIMIT
        DW      0               ; -- unused --
        DW      0               ; -- unused --
_BLK:   DW      0               ; 30: BLK
_IN:    DW      0               ; 32: IN
_OUT:   DW      0               ; 34: OUT
_SCR:   DW      0               ; 36: SCR
_OFFSE: DW      0               ; 38: OFFSET
_CONT:  DW      0               ; 40: CONTEXT
_CURR:  DW      0               ; 42: CURRENT
_STATE: DW      0               ; 44: STATE
_BASE:  DW      0               ; 46: BASE
_DPL:   DW      0               ; 48: DPL
_FLD:   DW      0               ; 50: FLD
_CSP:   DW      0               ; 52: CSP
_RNUM:  DW      0               ; 54: R#
_HLD:   DW      0               ; 56: HLD
_USE:   DW      0               ; 58: USE
_PREV:  DW      0               ; 60: PREV
_BANK:  DW      0               ; 62: BANK
CLK0:   DB      0               ; 64: 32-bit fake clock tick counter
CLK1:   DB      0               ; :
CLK2:   DB      0               ; :
CLK3:   DB      0               ; :
        DW      0 0 0 0 0 0     ; 68: -- unused

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

; LSTCLK is used by th4 FORTH multitasker in order to keep track
; of "delta ticks" since last DISPATCH run
LSTCLK: DB      0               ; Last clock tick count LSB

MEMEND: DS      0
