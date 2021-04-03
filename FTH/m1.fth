FORTH DEFINITIONS

VOCABULARY MULTI IMMEDIATE

: TASK
    <BUILDS
        0 ,     \ Counter
        0 ,     \ CFA
        0 ,     \ :NEXT
    DOES>
;

: :CFA      2+ ;            \ task-addr -- task-add:cfa
: :NEXT     4 + ;           \ task-addr -- task-add:next

MULTI DEFINITIONS

0 VARIABLE TICKS
0 VARIABLE TASKS

\ Set baseline for delta ticks calculation
: TICKS!    #MILLIS ARDUINO 2DROP TICKS ! ;

\ Calculate number of ticks since last check
: +TICKS                    \ -- ticksElapsed
    #MILLIS ARDUINO 2DROP   \ newTicks
    DUP TICKS @ -           \ newTicks ticksElapsed
    SWAP TICKS !            \ ticksElapsed
;

\ Decrement task delay counter and return "unused" ticks
: --COUNT   \ task-addr delta-ticks -- task-addr delta-ticks'
    OVER @ SWAP             \ task-addr task-counter delta-ticks
    - DUP 0<                \ task-addr tick-diff tick-diff<0?
    IF
        OVER 0 SWAP ! MINUS \ task-addr delta-ticks'
    ELSE
        2DUP SWAP ! DROP 0  \ task-addr delta-ticks'
    ENDIF
;

: RUN   :CFA @ EXECUTE ;    \ task-addr --

: DISPATCH                  \ --
    +TICKS -DUP
    IF                      \ delta-ticks
        TASKS @ SWAP        \ task-addr delta-ticks
        BEGIN
            2DUP 0= NOT     \ task-addr delta-ticks task-addr flag
            SWAP 0= NOT AND \ task-addr delta-ticks flag
        WHILE
            --COUNT             \ task-addr delta-ticks'
            SWAP :NEXT @ SWAP   \ task-addr' delta-ticks'
        REPEAT
        2DROP TASKS @ -DUP  \ 1st-task
        IF                  \ 1st-task
            DUP @ 0=        \ 1st-task counter=0?
            IF              \ It is time to run first task in list
                DUP :NEXT @ TASKS ! \ Remove task from queue
                0 OVER :NEXT !      \ :
                DUP RUN     \ Execute word: task-addr -- task-addr
            ENDIF
            DROP
        ENDIF
    ENDIF
;

\ Subtract (remaining) delay of current task from following task
: --NEXT                    \ task-addr --
    DUP @ MINUS             \ task-addr -delay
    SWAP :NEXT @ +!
;

\ Insert task at position pointed by prevL
: INSERT                    \ task-addr prevL --
    OVER :NEXT              \ task-addr prevL task-addr.next
    OVER @                  \ task-addr prevL task-addr.next *prevL
    SWAP !                  \ task-addr prevL
    !                       \
;

\ Remove task at position pointed by prevL
: REMOVE                    \ task-addr prevL
    OVER :NEXT DUP >R @     \ task-addr prevL *task-addr.next
    OVER !                  \ task-addr prevL
    0 R> !                  \ task-addr prevL
;

\ Is prevL at the end of the list?
: END?      DUP @ 0= ;      \ task-addr prevL -- task-addr prevL flag

\ Is prevL pointing to the task we are looking for?
: FOUND?    2DUP @ = ;      \ task-addr prevL -- task-addr prevL flag

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
        1                   \ task-addr prevL ff
    ELSE                    \ NO: Step forward on caller level
        0                   \ task-addr prevL tf
    ENDIF
;

\ Is this task currently in the task queue, i.e. is it waiting?
: WAITING?                  \ task-addr -- flag
    MULTI TASKS @
    IF
        TASKS               \ task-addr prevL
        BEGIN
            DUP @           \ task-addr prevL *prevL
            IF              \ Not en of list: Inspect
                FOUND?      \ task-addr prevL equal?
                IF          \ Found: Stop here
                    2DROP TRUE FALSE    \ found-flag stop-loop-flag
                ELSE        \ Not found: Continue looping
                    TRUE    \ task-addr prevL loop-on-flag
                ENDIF
            ELSE            \ End of list: No match
                DROP FALSE FALSE \ notfound-flag stop-loop-flag
            ENDIF
        WHILE
            >>NEXT          \ task-addr prevL'
        REPEAT
    ELSE
        DROP FALSE          \ Nothing in task queue: Return FALSE
    ENDIF
;

\ Step to next task in queue
: >>NEXT                    \ task-addr prevL -- task-addr prevL'
    2DUP @ @ MINUS          \ task-addr prevL task-addr -nextDelay
    SWAP +!                 \ task-addr prevL
    @ :NEXT                 \ task-addr prevL'
;

FORTH DEFINITIONS

: RUNS      [COMPILE] ' CFA SWAP :CFA ! ;

: AFTER                     \ task-addr delay --
    OVER !                  \ task-addr
    MULTI TASKS @           \ Already tasks in the list?
    IF                      \ YES:
        TASKS               \ task-addr prevL
        BEGIN
            INSERT? NOT     \ task-addr prevL' flag
        WHILE
            >>NEXT          \ task-addr prevL'
        REPEAT
        2DROP
    ELSE                    \ NO: Empty task list case
        TASKS !
    ENDIF
;

: NOW   0 AFTER ;

: STOP                      \ task-addr --
    MULTI TASKS @
    IF
        TASKS               \ task-addr prevL
        BEGIN
            FOUND?          \ task-addr prevL flag
            IF
                REMOVE FALSE \ task-addr prevL stop-flag
            ELSE
                TRUE        \ task-addr prevL continue-flag
            ENDIF
        WHILE
            >>NEXT          \ task-addr prevL'
        REPEAT
        2DROP
    ENDIF
;

MULTI DEFINITIONS

: <KEY>
    BEGIN
        (?TERMINAL) NOT
    WHILE
        DISPATCH
    REPEAT
    (KEY)
;

MAKE KEY <KEY>

\ ------------------------------------------------------------
\ MULTI heartbeat: Blinks the LED once per second

TASK LED-ON
TASK LED-OFF

: +LED  32 1 #DIGITALWRITE ARDUINO DROP LED-OFF 25 AFTER ;
: -LED  32 0 #DIGITALWRITE ARDUINO DROP LED-ON 125 AFTER ;

LED-ON RUNS +LED
LED-OFF RUNS -LED

: BOOT  32 1 #PINMODE ARDUINO ;

LED-ON NOW

FORTH DEFINITIONS
