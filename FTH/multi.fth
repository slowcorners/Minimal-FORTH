FORTH DEFINITIONS

VOCABULARY MULTI IMMEDIATE

MULTI DEFINITIONS

: :CFA      2+ ;            \ taddr -- taddr:CFA
: :NEXT     4 + ;           \ taddr -- taddr:NEXT
: NEXT@     :NEXT @ ;       \ prevL -- prevL'
: @NEXT     @ :NEXT ;       \ prevl -- prevL'

\ Add or subtract current task delay from next task delay
: +-NEXT    SWAP :NEXT @ +! ;       \ taddr delay --
: --NEXT    DUP @ MINUS +-NEXT ;    \ taddr --
: ++NEXT    DUP @ +-NEXT ;          \ taddr --

\ Calculate delay diff between task at taddr
\ and task under inspection
: DELAY-DIFF                \ taddr prevL -- taddr prevL diff
    OVER @ OVER @ @ -
;

\ Insert task at position pointed by prevL
: INSERT                    \ taddr prevL --
    OVER :NEXT              \ taddr prevL taddr.NEXT
    OVER @                  \ taddr prevL taddr.NEXT *prevL
    SWAP !                  \ taddr prevL
    OVER --NEXT             \ Also adjust next task's delay
    !
;

\ De-queue task at position pointed by prevL
: DE-QUEUE                  \ taddr prevL --
    OVER ++NEXT             \ Add this task's delay to next task
    OVER :NEXT @            \ taddr prevL *taddr.NEXT
    SWAP !                  \ taddr
    :NEXT 0 SWAP !          \
;

\ Is prevL at the end of the list?
: END?      0= ;            \ prevL -- flag

\ Is prevL pointing to taddr?
: MATCH?                    \ taddr prevL -- flag
    -DUP                    \ At end of list? (i.e. prevL == 0)
    IF                      \ Not at end, compare and leave flag
        @ =                 \ flag
    ELSE                    \ At end of list, leave false flag
        DROP FALSE          \ false
    ENDIF
;

\ Find position where to insert task into queue
: FIND-POS                  \ taddr prevL -- taddr prevL'
    BEGIN
        DUP @               \ taddr prevL {end-flag}
    WHILE
        DELAY-DIFF DUP 0<   \ taddr prevL diff {flag}
        IF                  \ Task delay smaller case
            OVER TASKS =    \ Inserting as first?
            IF              \ YES: Just drop the diff
                DROP        \ taddr prevL
            ELSE
                MINUS 2 PICK ! \ Update task's delay
            ENDIF
            [COMPILE] ;S    \ Right position found, stop here
        ENDIF
        DUP 0=
        IF                  \ Delays equal case
            2 PICK !        \ Set task delay to zero
            @NEXT           \ Inser after this task
            [COMPILE] ;S    \ taddr prevL' (stop here)
        ENDIF               \ Task delay greater, go forward
        2 PICK !            \ Adjust task delay
        @NEXT               \ taddr prevL'
    REPEAT                  \ taddr prevL'
;

\ Is task at taddr queued for execution?
: QUEUED?                   \ taddr -- <prevl | false>
    TASKS
    BEGIN
        DUP @               \ taddr prevL {end-flag}
    WHILE
        2DUP MATCH?         \ taddr prevL {match?}
        IF                  \ We have a match!
            SWAP DROP       \ Stop here and leave prevL only
            [COMPILE] ;S    \ prevL
        ENDIF
        @NEXT               \ taddr prevL' {prevl'==0}
    REPEAT
    2DROP FALSE             \ At end of list, leave a false flag
;

FORTH DEFINITIONS

\ --------------------------------------------------------
\ If task is queued for execution, de-queue the task
\ otherwise do nothing

: STOP                      \ taddr --
    MULTI                   \ Select context (compile time)
    DUP QUEUED? -DUP        \ taddr <prevL | false>
    IF                      \ taddr prevL
        DE-QUEUE            \
    ELSE                    \ taddr
        DROP                \
    ENDIF
;

\ --------------------------------------------------------
\ Set task's delay and queue it for later execution

: AFTER                     \ taddr delay --
    MULTI                   \ Select context (compile time)
    OVER STOP               \ Dequeue task if already queued
    OVER !                  \ Set requested delay
    TASKS FIND-POS INSERT   \
;


\ --------------------------------------------------------
\ Run task now :-)

: NOW   0 AFTER ;

