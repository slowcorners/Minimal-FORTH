: MASTER
  BL WORD HERE NUMBER DROP
  DUP 127 < OVER 0< NOT AND
  IF
    REMOTE !
    BEGIN
      [?TERMINAL]
      IF
        [KEY] (EMIT)
      ENDIF
      (?TERMINAL)
      IF
        (KEY) DUP
        IF
          [EMIT] FALSE
        ELSE
          DROP TRUE
        ENDIF
      ENDIF
    UNTIL
;
