FORTH DEFINITIONS

VOCABULARY MULTI IMMEDIATE

: TASK
  <BUILDS
    0 ,                     \ Delay
    ' NOOP CFA ,            \ :CFA
    0 ,                     \ :NEXT
  DOES>
;

MULTI DEFINITIONS

0 VARIABLE TASKS

: :CFA    2+ ;              \ task-addr -- task-add:cfa
: :NEXT   4 + ;             \ task-addr -- task-add:next

: RUN     :CFA @ EXECUTE ;  \ task-addr --

\ Is prevL at the end of the list?
: END?    @ 0= ;            \ prevL -- end-flag

\ Is prevL pointing to the task we are looking for?
: MATCH?  @ = ;             \ task-addr prevL -- flag

\ Calculate number of ticks since last check
\ Also set current tick count as new baseline
: +TICKS                    \ -- ticksElapsed
  #MILLIS SYSTEM DROP       \ newTicks
  DUP TICKS @ -             \ newTicks ticksElapsed
  SWAP TICKS !              \ ticksElapsed
;

\ ----------------------------------------------------------------------
\ Subtract <ticks> from task at taddr and return "unused ticks" ...
\ ... as task counter is not decremented below zero
\ If all ticks "are used", then return 0 for ticks

: --DELAY                   \ taddr ticks -- taddr ticks'
  OVER @ SWAP - DUP 0<      \ taddr +-ticks' neg?
  IF
    OVER 0 SWAP !           \ taddr -ticks'
    MINUS                   \ taddr ticks'
  ELSE
    2DUP SWAP !             \ taddr ticks'
    DROP 0                  \ taddr 0
  ENDIF
;

\ Traverse the tasks in the waiting queue and distribute ticks passed
: --DELAYS                  \ ticks --
  TASKS @ SWAP              \ taddr ticks
  BEGIN
    OVER                    \ taddr ticks taddr!=0?
    IF                      \ YES: There is a task to be inspected
      --DELAY               \ taddr ticks'
      SWAP :NEXT @ SWAP     \ taddr' ticks'
    ENDIF
    OVER 0= OVER 0= OR      \ taddr' ticks'
  UNTIL
  2DROP                     \
;

\ Pop first task from the task queue
: POP                       \ -- taddr
  TASKS DUP @               \ TASKS taddr0
  SWAP OVER                 \ taddr0 TASKS taddr0
  :NEXT @                   \ taddr0 TASKS taddr1
  SWAP !                    \ taddr0
  0 OVER :NEXT !            \ taddr0
;

\ Add delay of taddr to next task (if next task exists)
: +-NEXT                    \ taddr +-delay --
  OVER :NEXT @ -DUP         \ taddr +-delay nextL?
  IF                        \ YES: Add the delay
    +!                      \ taddr
  ELSE                      \ NO: No next, nothing to do
    DROP                    \ delay
  ENDIF
  DROP                      \
;

\ Add or subract taddr delay from next task
: ++NEXT  DUP @ +-NEXT ;        \ taddr --
: --NEXT  DUP @ MINUS +-NEXT ;  \ taddr --

\ Subtract *prevL delay from taddr delay
: DELAY--                   \ taddr prevL --
  @ @ MINUS SWAP +!         \
;

\ Step to next task
: >>NEXT                    \ prevL -- prevL'
  @ :NEXT                   \ prevL'
;

\ Insert task at position pointed by prevL
: +QUEUE                    \ taddr prevL --
    OVER :NEXT              \ taddr prevL taddr.next
    OVER @                  \ taddr prevL taddr.next *prevL
    SWAP !                  \ taddr prevL
    OVER --NEXT             \ taddr prevL
    !                       \
;

\ Remove task pointed to by prevL
: -QUEUE                    \ prevL -- taddr
  DUP @ ++NEXT              \ prevL
  DUP @ SWAP                \ taddr prevL
  OVER :NEXT @              \ taddr prevL nextL
  SWAP !                    \ taddr
  0 OVER :NEXT !            \ taddr
;

\ Is the requested delay smaller than ...
\ ... that of the task pointed to by prevL?
: QUEUE?                    \ task-addr prevL -- task-addr prevL flag
  DUP @ 0=                  \ prevL pointing to end of list?
  IF                        \ YES: End of list case. Insert!
    2DUP ! TRUE             \ task-addr prevL true
  ELSE                      \ NO: We are in middle of the list
    OVER @ OVER @ @ <       \ task-addr prevL new<next?
    IF                      \ YES: Insert here
      2DUP +QUEUE TRUE      \ task-addr prevL true
    ELSE                    \ NO: Step forward on caller level
      FALSE                 \ task-addr prevL false
    ENDIF
  ENDIF
;

\ Is this task currently in the task queue, i.e. is it waiting?
: QUEUED?                   \ taddr -- [prevL | false]
  TASKS                     \ taddr prevL
  BEGIN
    DUP END?                \ taddr prevL end?
    IF                      \ YES: Stop looping and return false
      2DROP FALSE FALSE     \ return-false loop-false
    ELSE
      2DUP MATCH?           \ taddr prevL match?
      IF                    \ YES: Stop looping and return prevL
        SWAP DROP FALSE     \ prevL loop-false
      ELSE                  \ Not found: Continue looping
        TRUE                \ task-addr prevL loop-true
      ENDIF
    ENDIF
  WHILE
    >>NEXT                  \ task-addr prevL'
  REPEAT
;                           \ [prevL | false]

: DISPATCH                  \ --
  +TICKS --DELAYS           \
  TASKS @ -DUP              \ taddr
  IF                        \ YES: taddr > 0
    @ 0=                    \ delay==0?
    IF                      \ YES: Run task
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

MAKE KEY <KEY>

FORTH DEFINITIONS

: RUNS      [COMPILE] ' CFA SWAP MULTI :CFA ! ;

: STOP                      \ taddr --
  MULTI QUEUED? -DUP        \ [prevL | false]
  IF                        \ YES: Task found
    -QUEUE DROP             \
  ENDIF                     \
;

: AFTER                     \ taddr delay --
  MULTI OVER !              \ taddr
  TASKS @                   \ Tasks in the list?
  IF                        \ YES:
    TASKS                   \ taddr prevL
    BEGIN
      QUEUE? NOT            \ taddr prevL done?
    WHILE
      2DUP DELAY--          \ taddr prevL
      >>NEXT                \ taddr prevL'
    REPEAT
    2DROP
  ELSE                      \ NO: Empty task list case
    TASKS !
  ENDIF
;

: NOW     0 AFTER ;

MULTI DEFINITIONS

\ ------------------------------------------------------------
\ MULTI heartbeat: Blinks the LED once per second

TASK LED-ON
TASK LED-OFF

: +LED  32 1 #DIGITALWRITE SYSTEM LED-OFF 25 AFTER ;
: -LED  32 0 #DIGITALWRITE SYSTEM LED-ON 125 AFTER ;

LED-ON RUNS +LED
LED-OFF RUNS -LED

: BOOT 32 1 #PINMODE SYSTEM ;

BOOT

LED-ON NOW

FORTH DEFINITIONS
