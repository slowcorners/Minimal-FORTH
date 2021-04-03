TASK HUGO
TASK EETU

: HW   ." Hugo " ;
: EW   ." Eetu " ;

HUGO RUNS HW
EETU RUNS EW

: T
  TASKS @
  BEGIN
    -DUP
  WHILE
    DUP @ .
    4 + @
  REPEAT
;

1000 HUGO AFTER

1200 EETU AFTER

