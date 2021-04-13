; ----------------------------------------------------------------------
; GLOBAL DEFINES
;

CH_BEL      EQU     7
CH_BSP      EQU     8
CH_LF       EQU     10
CH_CR       EQU     13
CH_ESC      EQU     27
CH_BL       EQU     32
CH_DQUOTE   EQU     34
CH_BSL      EQU     92
CH_DEL      EQU     127

MAGIC       EQU     0x205C      ; Magic cookie
                                ; : actually "\ " as an integer
                                ; : used by COLD and ABORT
