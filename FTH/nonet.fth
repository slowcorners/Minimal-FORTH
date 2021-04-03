
FORTH DEFINITIONS
REQUIRE MULTI
VOCABULARY NONET IMMEDIATE
NONET DEFINITIONS

TASK STATE-RCVE-DEST
TASK STATE-RCVE-SOURCE
TASK STATE-RCVE-DATA
TASK STATE-PASS-SOURCE
TASK STATE-PASS-DATA
TASK STATE-XMIT-PACKET

0 VARIABLE RCVE
0 VARIABLE MXIT

: [?TERMINAL]   #SER1-AVAILABLE SYSTEM ;
: [KEY]         #SER1-READ SYSTEM ;
: [EMIT]        #SER1-WRITE SYSTEM ;
: [INIT]        48 #SER1-BEGIN SYSTEM ;   \ 57600 baud

: GET-DEST
  [?TERMINAL]
  IF
    [KEY] DUP NODE @ =
    IF
      DROP STATE-GET-SOURCE NOW
    ELSE
      [EMIT]
      STATE-PASS-SOURCE NOW
    ENDIF
  ELSE
    OUTBYTE @ HEX 8000 AND
    IF
      STATE-XMIT-PACKET NOW
    ELSE
      STATE-GET-DEST NOW
    ENDIF
  ENDIF
;

: GET-SOURCE
  [?TERMINAL]
  IF
    [KEY] REMOTE !
    STATE-GET-BYTE NOW
  ELSE
    STATE-GET-SOURCE NOW
  ENDIF
;

: GET-DATA
  [?TERMINAL]
  IF
    [KEY] RCVE !
    STATE-GET-DEST NOW
  ELSE
    STATE-GET-DATA NOW
  ENDIF
;

: PASS-SOURCE
  [?TERMINAL]
  IF
    [KEY] [EMIT]
    STATE-PASS-DATA NOW
  ELSE
    STATE-PASS-SOURCE NOW
  ENDIF
;

: PASS-DATA
  [?TERMINAL]
  IF
    [KEY] [EMIT]
    STATE-GET-DEST NOW
  ELSE
    STATE-PASS-DATA NOW
  ENDIF
;

: XMIT-PACKET
  REMOTE @ [EMIT]
  NODE @ [EMIT]
  XMIT @ [EMIT]
  STATE-RCVE-DEST NOW
;

STATE-RCVE-DEST     RUNS  RCVE-DEST
STATE-RCVE-SOURCE   RUNS  RCVE-SOURCE
STATE-RCVE-DATA     RUNS  RCVE-DATA
STATE-PASS-SOURCE   RUNS  PASS-SOURCE
STATE-PASS-DATA     RUNS  PASS-DATA
STATE-XMIT-PACKET   RUNS  XMIT-PACKET

: {KEY} ;

: {EMIT}  8000 OR XMIT ! ;
