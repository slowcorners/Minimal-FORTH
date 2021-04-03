
: .MOUNT    ( maddr -- )
  >R R NV@
  IF
    ." [" R NV@ 0 .R
    ." .." R 2+ NV@ 0 .R ." ]"
    ."  --> "
    R 4 + NV@ 0 .R ." :"
    ." [" R 6 + NV@ 0 .R
    ." .." R 2+ NV@ R NV@ -
    R 6 + NV@ + 0 .R ." ]" CR
  ENDIF
  R> DROP
;

: MOUNTS
  CR 1024 992
  DO
    I .MOUNT 8
  +LOOP
;
