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
