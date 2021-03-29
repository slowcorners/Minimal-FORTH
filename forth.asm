; ----------------------------------------------------------------------
; M i n i m a l - F O R T H
;
; A minimal FORTH for the Minimal-CPU.
;
; Date:         2021-03-24
; Version:      0.1
; Adaptation:   Nils "slowcorners" Kullberg
; License:      MIT Open Source Initiative
;
;
; FIG-FORTH WAS ORIGINALLY DEVELOPED BY:
; FORTH INTEREST GROUP / FORTH IMPLEMENTATION TEAM
; P.O.BOX 1105
; SAN CARLOS, CA. 94701
;
; THIS COMPILER EXISTS THANKS TO ALL THE WONDERFUL PEOPLE OF THE
; FORTH INTEREST GROUP. IT IS THEIR DEDICATION AND GENEROSITY WHICH
; STILL TODAY MAKES THESE NEW ADAPTATIONS POSSIBLE.
;
; MAY THIS COMPILER BE A SMALL TRIBUTE TO ALL THOSE INDIVIDUALS OF THE
; FORTH INTEREST GROUP AS WELL AS SLU4 WHOSE COUNTLESS HOURS AND
; INGENIOUS DETAILS HAVE MADE THE MINIMAL-CPU COME INTO EXISTENCE.
;
; NILS "SLOWCORNERS" KULLBERG
; LUND, SWEDEN
; MARCH 2021, IN THE MIDDLE OF THE COVID-19 PANDEMIC
;
; ----------------------------------------------------------------------

        ORG     0x8000
        
INCLUDE         defs.asm
INCLUDE         boot-table.asm
INCLUDE         helpers.asm
; INCLUDE         debug.asm
INCLUDE         inner.asm
INCLUDE         primaries.asm
INCLUDE         precompiled.asm
INCLUDE         coldwarm.asm
INCLUDE         math.asm
INCLUDE         diskio.asm
INCLUDE         misc.asm
INCLUDE         uppermem.asm
