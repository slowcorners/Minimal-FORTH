; ----------------------------------------------------------------------
; PRECOMPILED FORTH WORDS
;

HCOLON: DB      ^^1 ^':'                                ; ***** :
        DW      HCSTOR
COLON:  DW      DOCOL QEXEC SCSP CURR AT CONT STORE
        DW      CREAT RBRAC PSCOD
DOCOL:  DEW     RP              ; -(RP) = IP
        LDA     IP.1            ; :
        STR     RP              ; :
        DEW     RP              ; :
        LDA     IP.0            ; :
        STR     RP              ; :
        LDA     WA.0            ; IP = WA
        STA     IP.0            ; :
        LDA     WA.1            ; :
        STA     IP.1            ; :
        JPA     NEXT

HSEMI:  DB      ^^1 ^';'                                ; ***** ;
        DW      HCOLON
SEMI:   DW      QCSP COMP SEMIS SMUDG LBRAC SEMIS

HCON:   DB      ^8 "CONSTAN" ^'T'                       ; ***** CONSTANT
        DW      HSEMI
CON:    DW      DOCOL CREAT SMUDG COMMA PSCOD
DOCON:  LDR     WA              ; -(SP) = (WA)
        STA     R1.0            ; :
        INW     WA              ; :
        LDR     WA              ; :
        STA     R1.1            ; :
        DEW     WA              ; :
        JPA     PUSH            ; Done

HVAR:   DB      ^8 "VARIABL" ^'E'                       ; ***** VARIABLE
        DW      HCON
VAR:    DW      DOCOL CON PSCOD
DOVAR:  DEW     SP              ; -(SP) = WA
        LDA     WA.1            ; :
        STR     SP              ; :
        DEW     SP              ; :
        LDA     WA.0            ; :
        STR     SP              ; :
        JPA     NEXT            ; Done

HUSER:  DB      ^4 "USE" ^'R'                           ; ***** USER
        DW      HVAR
USER:   DW      DOCOL CON PSCOD
DOUSE:  JPS     _POP1           ; Get index
        LDA     R1.0            ; Compute UP[index]
        ADA     UP.0            ; :
        STA     R1.0            ; :
        LDA     R1.1            ; :
        ACA     UP.1            ; :
        STA     R1.1            ; :
        JPA     PUSH            ; Push address; NEXT

; ------------------------------
; PRECOMPILED CONSTANTS

HZERO:  DB      ^1 ^'0'                                 ; ***** 0
        DW      HUSER
ZERO:   DW      DOCON 0

HONE:   DB      ^1 ^'1'                                 ; ***** 1
        DW      HZERO
ONE:    DW      DOCON 1

HTWO:   DB      ^1 ^'2'                                 ; ***** 2
        DW      HONE
TWO:    DW      DOCON 2

HTHREE: DB      ^1 ^'3'                                 ; ***** 3
        DW      HTWO
THREE:  DW      DOCON 3

HBL:    DB      ^2 "B" ^'L'                             ; ***** BL
        DW      HTHREE
BL:     DW      DOCON 32

HCL:    DB      ^3 "C/" ^'L'                            ; ***** C/L
        DW      HBL
CL:     DW      DOCON 80

HBBUF:  DB      ^5 "B/BU" ^'F'                          ; ***** B/BUF
        DW      HCL
BBUF:   DW      DOCON 1024

HBSCR:  DB      ^5 "B/SC" ^'R'                          ; ***** B/SCR
        DW      HBBUF
BSCR:   DW      DOCON 1

HPORIG: DB      ^7 "+ORIGI" ^'N'                        ; ***** +ORIGIN
        DW      HBSCR
PORIG:  DW      DOCOL LIT ORIGIN PLUS SEMIS

; ------------------------------
; USER VARIABLES

HSZERO: DB      ^2 "S" ^'0'                             ; ***** S0
        DW      HPORIG
SZERO:  DW      DOUSE 6

HRZERO: DB      ^2 "R" ^'0'                             ; ***** R0
        DW      HSZERO
RZERO:  DW      DOUSE 8

HTIB:   DB      ^3 "TI" ^'B'                            ; ***** TIB
        DW      HRZERO
TIB:    DW      DOUSE 10

HWIDTH: DB      ^5 "WIDT" ^'H'                          ; ***** WIDTH
        DW      HTIB
WIDTH:  DW      DOUSE 12

HWARN:  DB      ^7 "WARNIN" ^'G'                        ; ***** WARNING
        DW      HWIDTH
WARN:   DW      DOUSE 14

HFENCE: DB      ^5 "FENC" ^'E'                          ; ***** FENCE
        DW      HWARN
FENCE:  DW      DOUSE 16

HDP:    DB      ^2 "D" ^'P'                             ; ***** DP
        DW      HFENCE
DP:     DW      DOUSE 18

HVOCL:  DB      ^8 "VOC-LIN" ^'K'                       ; ***** VOC-LINK
        DW      HDP
VOCL:   DW      DOUSE 20

HFIRST: DB      ^5 "FIRS" ^'T'                          ; ***** FIRST
        DW      HVOCL
FIRST:  DW      DOUSE 22

HLIMIT: DB      ^5 "LIMI" ^'T'                          ; ***** LIMIT
        DW      HFIRST
LIMIT:  DW      DOUSE 24

HBLK:   DB      ^3 "BL" ^'K'                            ; ***** BLK
        DW      HLIMIT
BLK:    DW      DOUSE 30

HIN:    DB      ^2 "I" ^'I'                             ; ***** IN
        DW      HBLK
IN:     DW      DOUSE 32

HOUT:   DB      ^3 "OU" ^'T'                            ; ***** OUT
        DW      HIN
OUT:    DW      DOUSE 34

HSCR:   DB      ^3 "SC" ^'R'                            ; ***** SCR
        DW      HOUT
SCR:    DW      DOUSE 36

HOFFSE: DB      ^6 "OFFSE" ^'T'                         ; ***** OFFSET
        DW      HSCR
OFFSE:  DW      DOUSE 38

HCONT:  DB      ^7 "CONTEX" ^'T'                        ; ***** CONTEXT
        DW      HOFFSE
CONT:   DW      DOUSE 40

HCURR:  DB      ^7 "CURREN" ^'T'                        ; ***** CURRENT
        DW      HCONT
CURR:   DW      DOUSE 42

HSTATE: DB      ^5 "STAT" ^'E'                          ; ***** STATE
        DW      HCURR
STATE:  DW      DOUSE 44

HBASE:  DB      ^4 "BAS" ^'E'                           ; ***** BASE
        DW      HSTATE
BASE:   DW      DOUSE 46

HDPL:   DB      ^3 "DP" ^'L'                            ; ***** DPL
        DW      HBASE
DPL:    DW      DOUSE 50

HFLD:   DB      ^3 "FL" ^'D'                            ; ***** FLD
        DW      HDPL
FLD:    DW      DOUSE 52

HCSP:   DB      ^3 "CS" ^'P'                            ; ***** CSP
        DW      HFLD
CSP:    DW      DOUSE 52

HRNUM:  DB      ^2 "R" ^'#'                             ; ***** R#
        DW      HCSP
RNUM:   DW      DOUSE 54

HHLD:   DB      ^3 "HL" ^'D'                            ; ***** HLD
        DW      HRNUM
HLD:    DW      DOUSE 56

HUSE:   DB      ^3 "US" ^'E'                            ; ***** USE
        DW      HHLD
USE:    DW      DOUSE 58

HPREV:  DB      ^4 "PRE" ^'V'                           ; ***** PREV
        DW      HUSE
PREV:   DW      DOUSE 60

; END OF USER VARIABLES
; ------------------------------

HONEP:  DB      ^2 "1" ^'+'                             ; ***** 1+
        DW      HPREV
ONEP:   DW      DOCOL ONE PLUS SEMIS

HTWOP:  DB      ^2 "2" ^'+'                             ; ***** 2+
        DW      HPREV
TWOP:   DW      DOCOL TWO PLUS SEMIS

HHERE:  DB      ^4 "HER" ^'E'                           ; ***** HERE
        DW      HTWOP
HERE:   DW      DOCOL DP AT SEMIS

HALLOT: DB      ^5 "ALLO" ^'T'                          ; ***** ALLOT
        DW      HHERE
ALLOT:  DW      DOCOL DP PSTOR SEMIS

HCOMMA: DB      ^1 ^','                                 ; ***** ,
        DW      HALLOT
COMMA:  DW      DOCOL HERE STORE TWO ALLOT SEMIS

HSUB:   DB      ^1 ^'-'                                 ; ***** -
        DW      HCOMMA
SUB:    DW      DOCOL MINUS PLUS SEMIS

HEQUAL: DB      ^1 ^'='                                 ; ***** =
        DW      HSUB
EQUAL:  DW      DOCOL SUB ZEQU SEMIS

HLESS:  DB      ^1 ^'<'                                 ; ***** <
        DW      HEQUAL
LESS:   DW      DOCOL SUB ZLESS SEMIS

HGREAT: DB      ^1 ^'>'                                 ; ***** >
        DW      HLESS
GREAT:  DW      DOCOL SWAP LESS SEMIS

HROT:   DB      ^3 "RO" ^'T'                            ; ***** ROT
        DW      HGREAT
ROT:    DW      DOCOL TOR SWAP FROMR SWAP SEMIS

HSPACE: DB      ^5 "SPAC" ^'E'                          ; ***** SPACE
        DW      HROT
SPACE:  DW      DOCOL BL EMIT SEMIS

HDDUP:  DB      ^4 "-DU" ^'P'                           ; ***** -DUP
        DW      HSPACE
DDUP:   DW      DOCOL DUP ZBRAN +DDU10
        DW      DUP
DDU10:  DW      SEMIS

