TASK CHIMER
TASK WATCHER

: CHIME     ." Ding! " CHIMER 97 AFTER ;

: WATCH
    S0 @ SP@ - 12 >
    IF
        CR ." Note: Several items on the stack" CR
    ENDIF
    WATCHER 300 AFTER
;

CHIMER RUNS CHIME
WATCHER RUNS WATCH

CHIMER 50 AFTER
WATCHER 7 AFTER
