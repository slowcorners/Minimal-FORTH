; ----------------------------------------------------------------------
; EXTRAS (added by SlowCorners)

HNOOP:  DB      ^4 "NOO" ^'P'                           ; ***** NOOP
        DW      HARROW
NOOP:   DW      DOCOL
NOO10:  DW      SEMIS

HASCII: DB      ^^5 "ASCI" ^'I'                         ; ***** ASCII
        DW      HNOOP
ASCII:  DW      DOCOL BL WORD HERE ONEP
        DW      CAT STATE AT ZBRAN +ASCI10
        DW      LITER
ASCI10: DW      SEMIS

HBSLAS: DB      ^^1 ^'\'                                ; ***** \
        DW      HASCII
BSLAS:  DW      DOCOL BLK AT ZBRAN +BSLA10
        DW      IN AT DUP CL MOD CL SWAP
        DW      SUB PLUS IN STORE BRAN +BSLA20
BSLA10: DW      ONE WORD
BSLA20: DW      SEMIS

HTASK:  DB      ^4 "TAS" ^'K'                           ; ***** TASK
        DW      HBSLAS
TASK:   DW      DOCOL BUILD ZERO COMMA
        DW      LIT NOOP COMMA ZERO COMMA DOES
DOTAS:  DW      SEMIS

HRUNS:  DB      ^4 "RUN" ^'S'                           ; ***** RUNS
        DW      HTASK
RUNS:   DW      DOCOL TICK CFA SWAP TWOP STORE SEMIS

; To be added as primaries: STOP AFTER NOW

HRQUIR: DB      ^7 "REQUIR" ^'E'                        ; ***** REQUIRE
        DW      HRUNS
RQUIR:  DW      DOCOL DFIND BRAN +RQUI10
        DW      TDROP BRAN +RQUI20
RQUI10: DW      LIT 34 ERROR
RQUI20: DW      SEMIS

HBOUND: DB      ^2 ">" ^'<'                             ; ***** ><
        DW      HRQUIR
BOUND:  DW      DOCOL TOR MAX FROMR MIN SEMIS

HDOER:  DB      ^4 "DOE" ^'R'                           ; ***** DOER
        DW      HBOUND
DOER:   DW      DOCOL BUILD LIT NOO10 COMMA DOES
DODOR:  DW      AT TOR SEMIS

HMAKE:  DB      ^4 "MAK" ^'E'                           ; ***** MAKE
        DW      HDOER
MAKE:   DW      DOCOL DFIND ZEQU ZERO QERR DROP TWOP DFIND
        DW      ZEQU ZERO QERR DROP STATE AT ZBRAN +MAKE10
        DW      LITER LITER COMP STORE BRAN +MAKE20
MAKE10: DW      SWAP STORE
MAKE20: DW      SEMIS

HPTRUE: DB      ^6 "(TRUE" ^')'                         ; ***** (TRUE)
        DW      HMAKE
PTRUE:  DW      DOCOL
PTR10:  DW      MONE SEMIS

HTRUE:  DB      ^4 "TRU" ^'E'                           ; ***** TRUE
        DW      HPTRUE
TRUE:   DW      DODOE DODOR PTR10

HFALSE: DB      ^5 "FALS" ^'E'                          ; ***** FALSE
        DW      HTRUE
FALSE:  DW      DOCON 0

HPEMIT: DB      ^6 "(EMIT" ^')'                         ; ***** (EMIT)
        DW      HFALSE
PEMIT:  DW      DOCOL
PEM10:  DW      XEMIT ONE OUT PSTOR SEMIS
        ;
XEMIT:  DW      XEMIT0
XEMIT0: JPS     _POP1           ; Get character
        LDA     R1.0            ; Send char to terminal
        OUT                     ; :
        JPA     NEXT            ; Done

HEMIT:  DB      ^4 "EMI" ^'T'                           ; ***** EMIT
        DW      HPEMIT
EMIT:   DW      DODOE DODOR PEM10

HPKEY:  DB      ^5 "(KEY" ^')'                          ; ***** (KEY)
        DW      HEMIT
PKEY:   DW      DOCOL
PKE10:  DW      PQTER ZBRAN +PKEY20
        DW      XKEY SEMIS
PKEY20: DW      DISPA
PKEY30: DB      <NOOP           ; This word is the task vector ...
PKEY31: DB      >NOOP           ; ... updated by DISPATCH
        DW      BRAN +PKE10
        ;
XKEY:   DW      XKEY0
XKEY0:  CLB     R1.1            ; Clear MSB of result
        LDA     CHIN            ; Any character buffered?
        CPI     0xFF            ; :
        BNE     XKEY10          ; YES: We use the buffered character
        INP                     ; NO: Read whatever is on the input port
XKEY10: STA     R1.0            ; YES: This is in any case the result
        LDI     0xFF            ; Mark input buffer as available
        STA     CHIN            ; :
        JPA     PUSH            ; Done

HKEY:   DB      ^3 "KE" ^'Y'                            ; ***** KEY
        DW      HPKEY
KEY:    DW      DODOE DODOR PKE10

HPQTER: DB      ^11 "(?TERMINAL" ^')'                    ; ***** (?TERMINAL)
        DW      HKEY
PQTER:  DW      DOCOL
PQT10:  DW      XQTER SEMIS
        ;
XQTER:  DW      XQTER0
XQTER0: CLW     R1              ; Default FALSE to return
        INP                     ; Get char from terminal
        CPI     0xFF            ; Did we get a character?
        BEQ     QTER10          ; NO: Return FALSE
        STA     CHIN            ; YES: Put into buffer
        DEW     R1              ; Make default FALSE into TRUE
QTER10: JPA     PUSH            ; Push R1; NEXT

HQTERM: DB      ^9 "?TERMINA" ^'L'                      ; ***** ?TERMINAL
        DW      HPQTER
QTERM:  DW      DODOE DODOR PQT10

HCR:    DB      ^2 "C" ^'R'                             ; ***** CR
        DW      HQTERM
CR:     DW      DOCOL LIT 13 EMIT LIT 10 EMIT SEMIS

; ----------------------------------------------------------------------
; FORTH MULTITASKER
;
; The headerless word DISPATCH is the central point of the small
; multitasker. It decrements the delay timer of the first task in the
; task queue (and maybe following task timers as well, if needed).
; If the task timer of the first task has expired (counted down to zero),
; the task is delinked from the task queue and the corresponding
; FORTH word is executed.

; ------------------------------
;       GETCL
; OUT:  R1     = (current tick count - LSTCLK)
; OUT:  LSTCLK =  updated with current tick count

_GETCL: LDA     LSTCLK          ; R1.1 = LSTCLK
        STA     R1.1            ; :
        LDA     CLK1            ; LSTCLK = current tick count
        STA     LSTCLK          ; :
        SBA     R1.1
        STA     R1.0            ; R1 = newticks - prevticks
        CLB     R1.1            ; Clear MSB of R1
        RTS

; ------------------------------
;       DECTI
;       In:     R1 = delta tick count
;       Out:    Nothing

        ; GET TASKS POINTER
_DECTI: LDA     XTASK0          ; R3 = Addr of first task
        STA     R3.0            ; :
        LDA     XTASK1          ; :
        STA     R3.1            ; :
        ; IS TASK ADDR ZERO? (I.E. END OF QUEUE)
DECT10: LDA     R3.1            ; Check task addr MSB
        CPI     0               ; MSB zero? (i.e. end of queue)
        BNE     DECT20          ; NO: Go decrement task timer(s)
        LDA     R3.0            ; MSB is zero, check LSB
        CPI     0               ; LSB zero?
        BNE     DECT20          ; NO: Go decrement task timer(s)
        ; END OF QUEUE
        RTS                     ; Done
        ; WE HAVE A TASK, GET TASK TIMER
DECT20: LDR     R3              ; R2 = task timer
        STA     R2.0            ; :
        INW     R3              ; :
        LDR     R3              ; :
        STA     R2.1            ; :
        DEW     R3              ; :
        ; TASK TIMER ZERO?
DECT30: LDA     R2.0            ; Is task timer already zero?
        CPI     0               ; LSB zero?
        BNE     DECT40          ; NO: Decrement timer
        LDA     R2.1            ; LSB is zero, check MSB
        CPI     0               ; MSB zero?
        BNE     DECT40          ; NO: Decrement timer
        ; TASK TIMER IS ZERO, STEP TO NEXT TASK
        LDA     R2.0            ; Save task tick counter back to task
        STR     R3              ; :
        INW     R3              ; :
        LDA     R2.1            ; :
        STR     R3              ; :
        LDI     3               ; Bump task pointer to link field
        ADW     R3              ; :
        JPS     _LD16           ; R1 = addr of next task
        LDA     R1.0            ; R3 = R1
        STA     R3.0            ; :
        LDA     R1.1            ; :
        STA     R3.1            ; :
        JPA     DECT10          ; Go inspect this next task
        ; DECREMENT TASK TIMER AND DELTA TICK COUNT
DECT40: DEW     R2              ; Decrement task timer
        DEW     R1              ; Also "consume" tick
        ; DELTA TICK COUNT ZERO?
        LDA     R1.0            ; Is delta tick count zero?
        CPI     0               ; LSB zero?
        BNE     DECT30          ; NO: Go check task timer for zero
        LDA     R1.1            ; LSB is zero, check MSB
        CPI     0               ; MSB zero?
        BNE     DECT30          ; NO: Go check task timer for zero
        ; OUT OF DELTA TICKS, SAVE TASK TIMER AND EXIT
        LDA     R2.0            ; Save task tick counter back to task
        STR     R3              ; :
        INW     R3              ; :
        LDA     R2.1            ; :
        STR     R3              ; :
        RTS                     ; Done

; ------------------------------
;       RUNTA
;       If task timer of first task
;       is zero, delink task from 
;       task queue and run its word.

_RUNTA: LDI     <NOOP           ; Put NOOP as the default vector for (KEY)
        STA     PKEY30          ; :
        LDI     >NOOP           ; :
        STA     PKEY31          ; :
        ; Is there at least one task in the queue?
        LDA     XTASK0          ; Get addr of first task into R3
        STA     R3.0            ; :
        LDA     XTASK1          ; :
        STA     R3.1            ; :
        CPI     0               ; Is there a first task?
        BNE     RUNT10          ; YES: Look at its timer
        LDA     R3.0            ; MSB is zero, look at LSB
        CPI     0               ; :
        BNE     RUNT10          ; YES: Look at its timer
        RTS                     ; No task in queue, we are done
        ; Is the timer of the first task zero?
RUNT10: LDR     R3              ; Check timer LSB for zero
        CPI     0               ; LSB zero?
        BNE     RUNT99          ; NO: Nothing more to do
        INW     R3              ; YES: LSB is zero, also check MSB
        LDR     R3              ; :
        CPI     0               ; MSB zero?
        BNE     RUNT99          ; NO: Nothing more to do
        ; Timer zero case, set code vector for (KEY)
        INW     R3              ; Step to CFA field
        LDR     R3              ; Put CFA of word as the vector for (KEY)
        STA     PKEY30          ; :
        INW     R3              ; :
        LDR     R3              ; :
        STA     PKEY31          ; :
        ; De-link task from task queue
        INW     R3              ; Step to task NEXT field
        LDR     R3              ; TASKS = taddr.NEXT
        STA     XTASK0          ; :
        INW     R3              ; :
        LDR     R3              ; :
        STA     XTASK1          ; :
        LDI     0               ; Set task's NEXT field to zero
        STR     R3              ; :
        DEW     R3              ; :
        LDI     0               ; :
        STR     R3              ; :
RUNT99: RTS                     ; Done

; ------------------------------
;       DISPATCH

DISPA:  DW      DISPA0        
DISPA0: JPS     _GETCL          ; R1 = task tick delta count
        LDA     R1.0            ; Check tick delta
        CPI     0               ; Do we have delta ticks?
        BNE     DISP10          ; YES: Handle update tasks
        JPA     DISP20          ; NO: Skip decrement of timer(s)
        ; Decrement task timer(s)
DISP10: JPS     _DECTI          ; Decrement task timer(s)
DISP20: JPS     _RUNTA          ; See if the first task needs to be run
        JPA     NEXT            ; Done

; END OF FORTH MULTITASKER
; ----------------------------------------------------------------------

HPQUOT: DB      ^3 '(' '"' ^')'                         ; ***** (")
        DW      HCR
PQUOT:  DW      DOCOL R DUP CAT ONEP
        DW      FROMR PLUS TOR SEMIS

HQUOTE: DB      ^^1 ^'"'                                ; ***** "
        DW      HPQUOT
QUOTE:  DW      DOCOL LIT CH_DQUOTE STATE AT ZBRAN +QUOT10
        DW      COMP PQUOT WORD HERE
        DW      CAT ONEP ALLOT BRAN +QUOT20
QUOT10: DW      WORD HERE PAD OVER CAT ONEP CMOVE PAD
QUOT20: DW      SEMIS

