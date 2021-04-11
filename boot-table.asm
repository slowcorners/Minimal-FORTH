; ----------------------------------------------------------------------
; BOOT TABLE

ORIGIN: JPA     CENT            ;  0: COLD start
        NOP
        JPA     WENT            ;  4: WARM start
        NOP
        DW      29168           ;  8: Processor type "MI8" in radix 36
        DW      1               ; 10: Revision
        DW      HFORTH          ; 12: Pointer to latest word defined
        DW      CH_BSP          ; 14: Backspace character
        DW      XUP             ; 16: Pointer to initial user area
        DW      XSP             ; 18: Initial data stack pointer
        DW      XRP             ; 20: Initial return stack pointer
        DW      XTIB            ; 22: Pointer to terminal input buffer
        DW      31              ; 24: Maximum FORTH word name length
        DW      0               ; 26: Initial WARNING mode
        DW      XDP             ; 28: Initial FENCE
        DW      XDP             ; 30: Initial HERE
        DW      XXVOC           ; 32: Pointer to initial VOC-LINK
        DW      DSKBF           ; 34: Initial FIRST
        DW      ENDBF           ; 36: Initial LIMIT
        DW      0               ; 38: unused
        DW      0               ; 40: unused
