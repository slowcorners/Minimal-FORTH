; ----------------------------------------------------------------------
; M i n i m a l - F O R T H
;
; A minimal FORTH for the Minimal-CPU.
;
; Date:         2021-03-18
; Version:      0.1
; Author:       Nils "slowcorners" Kullberg
; License:      MIT Open Source Initiative
; ----------------------------------------------------------------------


        ORG     0x8000
        
INCLUDE         defs.asm
INCLUDE         boot-table.asm
; INCLUDE         regs.asm
INCLUDE         helpers.asm
INCLUDE         inner.asm
INCLUDE         primaries.asm
INCLUDE         precompiled.asm
INCLUDE         coldwarm.asm
