: (")   R DUP C@ 1+ R> + >R ;

: "
  ASCII " STATE @
  IF
    COMPILE (") WORD HERE
  ELSE
    WORD HERE DUP
  ENDIF
  C@ 1+ ALLOT
; IMMEDIATE
