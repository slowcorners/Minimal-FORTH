FORTH DEFINITIONS

VOCABULARY MULTI IMMEDIATE

: TASK
  <BUILDS
    0 ,                     \ Counter
    0 ,                     \ :CFA
    0 ,                     \ :NEXT
  DOES>
;

MULTI DEFINITIONS

0 VARIABLE TASKS

: :CFA    2+ ;              \ task-addr -- task-add:cfa
: :NEXT   4 + ;             \ task-addr -- task-add:next

: RUN   :CFA @ EXECUTE ;    \ task-addr --

\ Set baseline for delta ticks calculation
: TICKS!    #MILLIS ARDUINO 2DROP TICKS ! ;

\ Calculate number of ticks since last check
\ Also set current tick count as new baseline
: +TICKS                    \ -- ticksElapsed
  #MILLIS ARDUINO 2DROP     \ newTicks
  DUP TICKS @ -             \ newTicks ticksElapsed
  SWAP TICKS !              \ ticksElapsed
;

\ ----------------------------------------------------------------------
\ Subtract <ticks> from task at taddr and return "unused ticks" ...
\ ... as task counter is not decremented below zero
\ If all ticks "are used", then return 0 for ticks

: --COUNT                   \ taddr ticks -- taddr ticks'
  OVER @ - DUP 0<           \ taddr +-ticks' neg?
  IF
    OVER 0 SWAP !           \ taddr -ticks'
    MINUS                   \ taddr ticks'
  ELSE
    2DUP SWAP !             \ taddr ticks'
    DROP 0                  \ taddr 0
  ENDIF
;

\ Traverse the tasks in the waiting queue and distribute ticks passed
: --COUNTS                  \ ticks --
  TASKS @ SWAP              \ taddr ticks
  BEGIN
    OVER                    \ taddr ticks taddr!=0?
    IF                      \ YES: There is a task to be inspected
      --COUNT               \ taddr ticks'
    ENDIF
    OVER 0= OVER 0= OR      \ taddr ticks
  UNTIL
  2DROP                     \
;

\ Pop first task from the task queue
: POP                       \ -- taddr
  TASKS DUP @               \ TASKS taddr0
  SWAP OVER                 \ taddr0 TASKS taddr0
  :NEXT @                   \ taddr0 TASKS taddr1
  SWAP !                    \ taddr0
;

\ Is prevL at the end of the list?
: END?      @ 0= ;          \ prevL -- end-flag

\ Is prevL pointing to the task we are looking for?
: MATCH?    @ = ;           \ task-addr prevL -- flag

\ Do we need FIND also?
: FIND      ;               \ task-addr -- prevL|false

\ Subtract count of task pointed to by prevL from this task
: SUB                       \ task-addr prevL -- remaining-ticks
    OVER >R                 \ Save
    @ @ MINUS               \ task-addr -nextDelay
    SWAP +!                 \
    R @
;

\ Subtract (remaining) delay of current task from following task
: --NEXT                    \ task-addr --
    DUP @ MINUS             \ task-addr -delay
    SWAP :NEXT @ +!         \
;

\ Step to next task
: >>NEXT                    \ prevL -- prevL'
    @ :NEXT                 \ prevL'
;

\ Insert task at position pointed by prevL
: INSERT                    \ task-addr prevL --
    OVER :NEXT              \ task-addr prevL task-addr.next
    OVER @                  \ task-addr prevL task-addr.next *prevL
    SWAP !                  \ task-addr prevL
    !                       \
;

\ Dequeue task pointed to by prevL
\ : DEQUEUE                   \ prevL -- taddr
\    OVER :NEXT DUP >R @     \ task-addr prevL *task-addr.next
\    OVER !                  \ task-addr prevL
\    0 R> !                  \ task-addr prevL
\ ;

\ Is counter of this task lower than that of *prevL?
\ : HERE?                     \ task-addr prevL -- flag
\    SWAP @ SWAP             \ task-counter prevL
\    @ @ <                   \ flag
\ ;

\ Is the requested delay smaller than ...
\ ... that of the task pointed to by prevL?
: INSERT?                   \ task-addr prevL -- task-addr prevL flag
    OVER @                  \ task-addr prevL newDelay
    OVER @ @                \ task-addr prevL newDelay nextDelay
    <                       \ task-addr prevL flag
    OVER @ 0=               \ task-addr prevL delayFlag nextFlag
    OR                      \ delay < nextDelay OR next == 0 ?
    IF                      \ YES: Insert here
        2DUP INSERT         \ task-addr prevL
        OVER :NEXT @        \ task-addr prevL next
        IF
            OVER --NEXT     \ task-addr prevL
        ENDIF
        TRUE                \ task-addr prevL true
    ELSE                    \ NO: Step forward on caller level
        FALSE               \ task-addr prevL false
    ENDIF
;

\ Is this task currently in the task queue, i.e. is it waiting?
\ : QUEUED?                   \ task-addr -- prevL | false
\    MULTI TASKS @           \ task-addr queued-tasks?
\    IF                      \ YES: There are tasks in the queue
\        TASKS               \ task-addr prevL
\        BEGIN
\            DUP @           \ task-addr prevL *prevL
\            IF              \ Not end of list: Inspect
\                2DUP MATCH? \ task-addr prevL equal?
\                IF          \ Found: Stop here
\                    SWAP DROP FALSE    \ t-a prevL found-flag loop-flag
\                ELSE        \ Not found: Continue looping
\                    TRUE    \ task-addr prevL loop-on-flag
\                ENDIF
\            ELSE            \ End of list: No match
\                DROP FALSE FALSE \ notfound-flag stop-loop-flag
\            ENDIF
\        WHILE
\            >>NEXT          \ task-addr prevL'
\        REPEAT
\    ELSE
\        DROP FALSE          \ Nothing in task queue: Return FALSE
\    ENDIF
\ ;

\ : DEQUEUE?                  \ task-addr --
\    QUEUED? -DUP
\    IF
\        DEQUEUE
\    ENDIF
\ ;

: DISPATCH                  \ --
  +TICKS --COUNTS           \
  TASKS @ -DUP              \ taddr
  IF                        \ YES: taddr > 0
    @ 0=                    \ delay
    IF                      \ YES: delay == 0
      POP DUP RUN DROP      \
    ENDIF
  ENDIF
;

: <KEY>
    BEGIN
        (?TERMINAL) NOT
    WHILE
        DISPATCH
    REPEAT
    (KEY)
;

\ MAKE KEY <KEY>

FORTH DEFINITIONS

: RUNS      [COMPILE] ' CFA SWAP MULTI :CFA ! ;

: AFTER                     \ task-addr delay --
    MULTI
    OVER SWAP !             \ task-addr
    TASKS @                 \ Tasks in the list?
    IF                      \ YES:
        TASKS               \ task-addr prevL
        BEGIN
            INSERT? NOT     \ task-addr prevL flag
        WHILE
            --COUNT         \ task-addr prevL
            >>NEXT          \ task-addr prevL'
        REPEAT
        2DROP
    ELSE                    \ NO: Empty task list case
        TASKS !
    ENDIF
;

\ : NOW     0 AFTER ;
\ : URGENT  TASK @ ...

\ : STOP                      \ task-addr --
\    MULTI DEQUEUE? -DUP
\    IF
\        DEQUEUE
\    ENDIF
\ ;

\ MULTI DEFINITIONS

\ ------------------------------------------------------------
\ MULTI heartbeat: Blinks the LED once per second

\ TASK LED-ON
\ TASK LED-OFF

\ : +LED  32 1 #DIGITALWRITE ARDUINO DROP LED-OFF 25 AFTER ;
\ : -LED  32 0 #DIGITALWRITE ARDUINO DROP LED-ON 125 AFTER ;

\ LED-ON RUNS +LED
\ LED-OFF RUNS -LED

\ : BOOT  32 1 #PINMODE ARDUINO ;

\ LED-ON NOW

FORTH DEFINITIONS
