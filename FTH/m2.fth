FORTH DEFINITIONS

VOCABULARY MULTI IMMEDIATE

: TASK
  <BUILDS
    0 ,                     \ Counter
    ' NOOP CFA ,            \ :CFA
    0 ,                     \ :NEXT
  DOES>
;

MULTI DEFINITIONS

0 VARIABLE TASKS

: :CFA    2+ ;              \ task-addr -- task-add:cfa
: :NEXT   4 + ;             \ task-addr -- task-add:next

: RUN   :CFA @ EXECUTE ;    \ task-addr --

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
: --COUNTS                  \ ticks --
  TASKS @ SWAP              \ taddr ticks
  BEGIN
    OVER                    \ taddr ticks taddr!=0?
    IF                      \ YES: There is a task to be inspected
      --COUNT               \ taddr ticks'
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
;

\ Is prevL at the end of the list?
: END?      @ 0= ;          \ prevL -- end-flag

\ Is prevL pointing to the task we are looking for?
: MATCH?    @ = ;           \ task-addr prevL -- flag

\ Subtract count of task pointed to by prevL from this task
: SUB                       \ task-addr prevL -- remaining-ticks
    OVER >R                 \ Save
    @ @ MINUS               \ task-addr -nextDelay
    SWAP +!                 \
    R @                     \ Oops! n+++
;

\ Add delay to next task (if next task exists)
: ++NEXT                    \ taddr delay --
  SWAP :NEXT @ -DUP         \ taddr nextExists?
  IF                        \ taddr delay nextL
    +!                      \
  ELSE                      \ NO: No next, nothing to do
    DROP                    \ taddr
  ENDIF
;

\ Subtract *prevL:cnt from taddr:cnt and step to next task
: >>NEXT                    \ taddr prevL -- taddr prevL'
  2DUP @ @ MINUS SWAP +!    \ Subtract *prevL:cnt from taddr:cnt
  @ :NEXT                   \ taddr prevL'
;

\ Insert task at position pointed by prevL
: INSERT                    \ task-addr prevL --
    OVER :NEXT              \ task-addr prevL task-addr.next
    OVER @                  \ task-addr prevL task-addr.next *prevL
    SWAP !                  \ task-addr prevL
    !                       \
;

\ Dequeue task pointed to by prevL
: DEQUEUE                   \ prevL --
  DUP @ DUP @ ++NEXT
  DUP @ SWAP                \ taddr prevL
  OVER :NEXT @              \ taddr prevL nextL
  SWAP !                    \ taddr
  0 SWAP :NEXT !            \
;

\ Is the requested delay smaller than ...
\ ... that of the task pointed to by prevL?
: INSERT?                   \ task-addr prevL -- task-addr prevL flag
  DUP @ 0=                  \ prevL pointing to end of list?
  IF                        \ YES: End of list case. Insert!
    2DUP !                  \ task-addr prevL
    TRUE                    \ task-addr prevL true
  ELSE                      \ NO: We are in middle of the list
    OVER @                  \ task-addr prevL newDelay
    OVER @ @                \ task-addr prevL newDelay nextDelay
    <                       \ task-addr prevL new<next?
    IF                      \ YES: Insert here
      2DUP INSERT           \ task-addr prevL
      OVER :NEXT @          \ task-addr prevL next?
      IF                    \ YES: Decrement timeout of next task in list
        OVER DUP @ MINUS ++NEXT \ task-addr prevL
      ENDIF
      TRUE                  \ task-addr prevL true
    ELSE                    \ NO: Step forward on caller level
      FALSE                 \ task-addr prevL false
    ENDIF
  ENDIF
;

\ Is this task currently in the task queue, i.e. is it waiting?
: QUEUED?                   \ task-addr -- prevL | false
  TASKS                     \ task-addr prevL
  BEGIN
    DUP END?                \ End of list?
    IF                      \ YES: Stop looping and return false
      2DROP FALSE FALSE     \ return-false loop-false
    ELSE
      2DUP MATCH?           \ task-addr prevL match?
      IF                    \ YES: Stop looping and return prevL
        SWAP DROP FALSE     \ prevL loop-false
      ELSE                  \ Not found: Continue looping
        TRUE                \ task-addr prevL loop-on-flag
      ENDIF
    ENDIF
  WHILE
    @ :NEXT                 \ task-addr prevL'
  REPEAT
;                           \ [prevL | false]

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

MAKE KEY <KEY>

FORTH DEFINITIONS

: RUNS      [COMPILE] ' CFA SWAP MULTI :CFA ! ;

: STOP                      \ taddr --
  MULTI QUEUED? -DUP        \ [prevL | false]
  IF                        \ YES: Task found
    DEQUEUE                 \
  ENDIF                     \
;

: AFTER                     \ task-addr delay --
  MULTI
\  OVER STOP
  OVER !                  \ task-addr
  TASKS @                 \ Tasks in the list?
  IF                      \ YES:
    TASKS               \ task-addr prevL
    BEGIN
      INSERT? NOT     \ task-addr prevL flag
    WHILE
      >>NEXT          \ task-addr prevL'
    REPEAT
    2DROP
  ELSE                    \ NO: Empty task list case
    TASKS !
  ENDIF
;

: NOW     0 AFTER ;

MULTI DEFINITIONS

\ ------------------------------------------------------------
\ MULTI heartbeat: Blinks the LED once per second

TASK LED-ON
TASK LED-OFF

: +LED  32 1 #DIGITALWRITE ARDUINO DROP LED-OFF 25 AFTER ;
: -LED  32 0 #DIGITALWRITE ARDUINO DROP LED-ON 125 AFTER ;

LED-ON RUNS +LED
LED-OFF RUNS -LED

: BOOT 32 1 #PINMODE ARDUINO DROP ;

BOOT

LED-ON NOW

FORTH DEFINITIONS
