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
SEMI:   DW      DOCOL QCSP COMP SEMIS SMUDG LBRAC SEMIS

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
DOUSE:  LDR     WA              ; Compute UP[index]
        ADA     UP.0            ; :
        STA     R1.0            ; :
        INW     WA              ; :
        LDR     WA              ; :
        ACA     UP.1            ; :
        STA     R1.1            ; :
        JPA     PUSH            ; Push address; NEXT

; ------------------------------
; PRECOMPILED CONSTANTS

HMONE:  DB      ^2 "-" ^'1'                             ; ***** -1
        DW      HUSER
MONE:   DW      DOCON -1

HZERO:  DB      ^1 ^'0'                                 ; ***** 0
        DW      HMONE
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
CL:     DW      DOCON 64

HBBUF:  DB      ^5 "B/BU" ^'F'                          ; ***** B/BUF
        DW      HCL
BBUF:   DW      DOCON 1024

HBSCR:  DB      ^5 "B/SC" ^'R'                          ; ***** B/SCR
        DW      HBBUF
BSCR:   DW      DOCON 1

HPORIG: DB      ^7 "+ORIGI" ^'N'                        ; ***** +ORIGIN
        DW      HBSCR
        ; speed++
PORIG:  DW      PORIG0 ; DOCOL LIT ORIGIN PLUS SEMIS
PORIG0: JPS     _POP2           ; R2 = offset
        JPS     _PORIG          ; R3 = &ORIGIN[R2]
        JPS     _PUSH3          ; Push result
        JPA     NEXT            ; Done

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

HBANK:  DB      ^4 "BAN" ^'K'                           ; ***** BANK
        DW      HPREV
BANK:   DW      DOUSE 62

; END OF USER VARIABLES
; ------------------------------

HRSHFT: DB      ^2 ">" ^'>'                             ; ***** >>
        DW      HBANK
RSHFT:  DW      RSHFT0
RSHFT0: JPS     _POP21
RSHF10: LDA     R1.1
        LSR
        STA     R1.1
        LDA     R1.0
        ROR
        STA     R1.0
        DEB     R2.0
        BNE     RSHF10
        JPA     PUSH

HLSHFT: DB      ^2 "<" ^'<'                             ; ***** <<
        DW      HRSHFT
LSHFT:  DW      LSHFT0
LSHFT0: JPS     _POP21
LSHF10: LDA     R1.0
        LSL
        STA     R1.0
        LDA     R1.1
        ROL
        STA     R1.1
        DEB     R2.0
        BNE     LSHF10
        JPA     PUSH

HONEP:  DB      ^2 "1" ^'+'                             ; ***** 1+
        DW      HLSHFT
ONEP:   DW      ONEP0
ONEP0:  JPS     _POP1
        INW     R1
        JPA     PUSH

HTWOP:  DB      ^2 "2" ^'+'                             ; ***** 2+
        DW      HONEP
TWOP:   DW      TWOP0
TWOP0:  JPS     _POP1
        LDI     2
        ADW     R1
        JPA     PUSH

HHERE:  DB      ^4 "HER" ^'E'                           ; ***** HERE
        DW      HTWOP
        ; speed++
HERE:   DW      HERE0 ; DOCOL DP AT SEMIS
HERE0:  JPS     _HERE
        JPA     NEXT
        ;
_HERE:  LDI     18              ; USER[18] (DP)
        STA     R2.0            ; :
        JPS     _USER           ; R3 = &USER[18]
        JPS     _LD16           ; R1 = USER[18]
        JPS     _PUSH1          ; -(SP) = Result
        RTS                     ; Done

HALLOT: DB      ^5 "ALLO" ^'T'                          ; ***** ALLOT
        DW      HHERE
        ; speed++
ALLOT:  DW      ALLOT0 ; DOCOL DP PSTOR SEMIS
ALLOT0: JPS     _ALLOT
        JPA     NEXT
        ;
_ALLOT: LDI     18              ; USER[18] (DP)
        STA     R2.0            ; :
        JPS     _USER           ; R3 = &USER[18]
        JPS     _LD16           ; R1 = USER[18]
        JPS     _POP2           ; Get increment
        LDA     R1.0            ; LSB
        ADA     R2.0            ; :
        STA     R1.0            ; :
        LDA     R1.1            ; MSB
        ACA     R2.1            ; :
        STA     R1.1            ; :
        JPS     _ST16           ; :
        RTS                     ; Done

HCOMMA: DB      ^1 ^','                                 ; ***** ,
        DW      HALLOT
        ; speed++
COMMA:  DW      COMMA0 ; DOCOL HERE STORE TWO ALLOT SEMIS
COMMA0: JPS     _COMMA
        JPA     NEXT
        ;
_COMMA: JPS     _HERE           ; HERE
        JPS     _STORE          ; STORE
        CLW     R1              ; 2 ALLOT
        LDI     2               ; :
        ADW     R1              ; :
        JPS     _PUSH1          ; :
        JPS     _ALLOT          ; :
        RTS                     ; Done

HSUB:   DB      ^1 ^'-'                                 ; ***** -
        DW      HCOMMA
        ; speed++
SUB:    DW      SUB0 ; DOCOL MINUS PLUS SEMIS
SUB0:   JPS     _SUB
        JPA     NEXT
        ;
_SUB:   JPS     _POP21          ; R1 = R1 - R2
        LDA     R1.0            ; LSB
        SBA     R2.0            ; :
        STA     R1.0            ; :
        LDA     R1.1            ; MSB
        SCA     R2.1            ; :
        STA     R1.1            ; :
        JPS     _PUSH1          ; Push result
        RTS                     ; Done

HEQUAL: DB      ^1 ^'='                                 ; ***** =
        DW      HSUB
        ; speed++
EQUAL:  DW      EQUAL0 ; DOCOL SUB ZEQU SEMIS
EQUAL0: JPS     _SUB
        JPS     _ZEQU
        JPA     NEXT

HLESS:  DB      ^1 ^'<'                                 ; ***** <
        DW      HEQUAL
        ; speed++
LESS:   DW      LESS0 ; DOCOL SUB ZLESS SEMIS
LESS0:  JPS     _SUB
        JPS     _ZLESS
        JPA     NEXT

HGREAT: DB      ^1 ^'>'                                 ; ***** >
        DW      HLESS
        ; speed++
GREAT:  DW      GREAT0 ; DOCOL SWAP LESS SEMIS
GREAT0: JPS     _SWAP
        JPA     LESS0

HROT:   DB      ^3 "RO" ^'T'                            ; ***** ROT
        DW      HGREAT
ROT:    DW      ROT0
ROT0:   JPS     _POP321
        JPS     _PUSH2
        JPS     _PUSH3
        JPA     PUSH

HSPACE: DB      ^5 "SPAC" ^'E'                          ; ***** SPACE
        DW      HROT
SPACE:  DW      SPACE0 ; DOCOL BL EMIT SEMIS
SPACE0: LDI     CH_BL
        STA     R1.0
        CLB     R1.1
        JPS     _PUSH1
        JPS     _EMIT
        JPA     NEXT

HDDUP:  DB      ^4 "-DU" ^'P'                           ; ***** -DUP
        DW      HSPACE
DDUP:   DW      DDUP0
DDUP0:  JPS     _DDUP
        JPA     NEXT
        ;
_DDUP:  JPS     _GET1
        LDA     R1.0
        CPI     0
        BNE     DDUP10
        LDA     R1.1
        CPI     0
        BNE     DDUP10
        RTS
DDUP10: JPS     _PUSH1
        RTS

HTRAV:  DB      ^8 "TRAVERS" ^'E'                       ; ***** TRAVERSE
        DW      HDDUP
TRAV:   DW      DOCOL SWAP
TRAV10: DW      OVER PLUS LIT 0x7F
        DW      OVER CAT LESS ZBRAN +TRAV10
        DW      SWAP DROP SEMIS

HLATES: DB      ^6 "LATES" ^'T'                         ; ***** LATEST
        DW      HTRAV
LATES:  DW      DOCOL CURR AT AT SEMIS

HLFA:   DB      ^3 "LF" ^'A'                            ; ***** LFA
        DW      HLATES
LFA:    DW      DOCOL LIT 4 SUB SEMIS

HCFA:   DB      ^3 "CF" ^'A'                            ; ***** CFA
        DW      HLFA
CFA:    DW      DOCOL TWO SUB SEMIS

HNFA:   DB      ^3 "NF" ^'A'                            ; ***** NFA
        DW      HCFA
NFA:    DW      DOCOL LIT 5 SUB LIT -1 TRAV SEMIS

HPFA:   DB      ^3 "PF" ^'A'                            ; ***** PFA
        DW      HNFA
PFA:    DW      DOCOL ONE TRAV LIT 5 PLUS SEMIS

; ------------------------------
; COMPILE TIME CHECKS

HSCSP:  DB      ^4 "!CS" ^'P'                           ; ***** !CSP
        DW      HPFA
SCSP:   DW      DOCOL SPAT CSP STORE SEMIS

HQERR:  DB      ^6 "?ERRO" ^'R'                         ; ***** ?ERROR
        DW      HSCSP
QERR:   DW      DOCOL SWAP ZBRAN +QERR10
        DW      ERROR BRAN +QERR20
QERR10: DW      DROP
QERR20: DW      SEMIS

HQCOMP: DB      ^5 "?COM" ^'P'                          ; ***** ?COMP
        DW      HQERR
QCOMP:  DW      DOCOL STATE AT ZEQU LIT 17 QERR SEMIS

HQEXEC: DB      ^5 "?EXE" ^'C'                          ; ***** ?EXEC
        DW      HQCOMP
QEXEC:  DW      DOCOL STATE AT LIT 18 QERR SEMIS

HQPAIR: DB      ^6 "?PAIR" ^'S'                         ; ***** ?PAIRS
        DW      HQEXEC
QPAIR:  DW      DOCOL SUB LIT 19 QERR SEMIS

HQCSP:  DB      ^4 "?CS" ^'P'                           ; ***** ?CSP
        DW      HQPAIR
QCSP:   DW      DOCOL SPAT CSP AT SUB
        DW      LIT 20 QERR SEMIS

HQLOAD: DB      ^8 "?LOADIN" ^'G'                       ; ***** ?LOADING
        DW      HQCSP
QLOAD:  DW      DOCOL BLK AT ZEQU LIT 22 QERR SEMIS

; ------------------------------
; COMPILER WORDS

HCOMP:  DB      ^7 "COMPIL" ^'E'                        ; ***** COMPILE
        DW      HQLOAD
COMP:   DW      DOCOL QCOMP FROMR DUP
        DW      TWOP TOR AT COMMA SEMIS

HLBRAC: DB      ^^1 ^'['                                ; ***** [
        DW      HCOMP
LBRAC:  DW      DOCOL ZERO STATE STORE SEMIS

HRBRAC: DB      ^1 ^']'                                 ; ***** ]
        DW      HLBRAC
RBRAC:  DW      DOCOL LIT 0xC0 STATE STORE SEMIS

HSMUDG: DB      ^6 "SMUDG" ^'E'                         ; ***** SMUDGE
        DW      HRBRAC
SMUDG:  DW      DOCOL LATES LIT 0x20 TOGGL SEMIS

HHEX:   DB      ^3 "HE" ^'X'                            ; ***** HEX
        DW      HSMUDG
HEX:    DW      DOCOL LIT 16 BASE STORE SEMIS

HDEC:   DB      ^7 "DECIMA" ^'L'                        ; ***** DECIMAL
        DW      HHEX
DEC:    DW      DOCOL LIT 10 BASE STORE SEMIS

HOCTAL: DB      ^5 "OCTA" ^'L'                          ; ***** OCTAL
        DW      HDEC
OCTAL:  DW      DOCOL LIT 8 BASE STORE SEMIS

HPSCOD: DB      ^7 "(;CODE" ^')'                        ; ***** (;CODE)
        DW      HOCTAL
PSCOD:  DW      DOCOL FROMR LATES PFA CFA STORE SEMIS

HBUILD: DB      ^7 "<BUILD" ^'S'                        ; ***** <BUILDS
        DW      HPSCOD
BUILD:  DW      DOCOL ZERO CON SEMIS

HDOES:  DB      ^5 "DOES" ^'>'                          ; ***** DOES>
        DW      HBUILD
DOES:   DW      DOCOL FROMR LATES PFA STORE PSCOD
DODOE:  DEW     RP              ; -(RP) = IP
        LDA     IP.1            ; :
        STR     RP              ; :
        DEW     RP              ; :
        LDA     IP.0            ; :
        STR     RP              ; :
        LDR     WA              ; IP = (WA)+
        STA     IP.0            ; :
        INW     WA              ; :
        LDR     WA              ; :
        STA     IP.1            ; :
        INW     WA              ; :
        DEW     SP              ; -(SP) = WA
        LDA     WA.1            ; :
        STR     SP              ; :
        DEW     SP              ; :
        LDA     WA.0            ; :
        STR     SP              ; :
        JPA     NEXT            ; Done

; ------------------------------
; MISC WORDS RELATED TO PRINTING

HCOUNT: DB      ^5 "COUN" ^'T'                          ; ***** COUNT
        DW      HDOES
COUNT:  DW      DOCOL DUP ONEP SWAP CAT SEMIS

HTYPE:  DB      ^4 "TYP" ^'E'                           ; ***** TYPE
        DW      HCOUNT
TYPE:   DW      DOCOL DDUP ZBRAN +TYPE20
        DW      OVER PLUS SWAP XDO
TYPE10: DW      I CAT EMIT XLOOP +TYPE10
        DW      BRAN +TYPE30
TYPE20: DW      DROP
TYPE30: DW      SEMIS

HDTRAI: DB      ^9 "-TRAILIN" ^'G'                      ; ***** -TRAILING
        DW      HTYPE
DTRAI:  DW      DOCOL DUP ZERO XDO
DTRA10: DW      OVER OVER PLUS ONE SUB
        DW      CAT BL SUB ZBRAN +DTRA20
        DW      LEAVE BRAN +DTRA30
DTRA20: DW      ONE SUB
DTRA30: DW      XLOOP +DTRA10
        DW      SEMIS

HPDOTQ: DB      ^4 "(." '"' ^')'                        ; ***** (.")
        DW      HDTRAI
PDOTQ:  DW      DOCOL R COUNT DUP ONEP
        DW      FROMR PLUS TOR TYPE SEMIS

HDOTQ:  DB      ^^2 "." ^'"'                            ; ***** ."
        DW      HPDOTQ
DOTQ:   DW      DOCOL LIT '"' STATE AT ZBRAN +DOTQ10
        DW      COMP PDOTQ WORD HERE CAT ONEP
        DW      ALLOT BRAN +DOTQ20
DOTQ10: DW      WORD HERE COUNT TYPE
DOTQ20: DW      SEMIS

; ------------------------------
; OUTER INTERPRETER

HEXPEC: DB      ^6 "EXPEC" ^'T'                         ; ***** EXPECT
        DW      HDOTQ
EXPEC:  DW      DOCOL OVER PLUS OVER XDO
EXPE10: DW      KEY DUP LIT 14 PORIG
        DW      AT EQUAL ZBRAN +EXPE20
        DW      DROP DUP I EQUAL DUP FROMR TWO SUB
        DW      PLUS TOR ZBRAN +EXPE60
        DW      LIT CH_BEL BRAN +EXPE70
EXPE60: DW      LIT CH_BSP
EXPE70: DW      BRAN +EXPE30
EXPE20: DW      DUP LIT 10 EQUAL ZBRAN +EXPE40
        DW      LEAVE DROP BL ZERO BRAN +EXPE50
EXPE40: DW      DUP
EXPE50: DW      I CSTOR ZERO I ONEP STORE
EXPE30: DW      EMIT XLOOP +EXPE10
        DW      DROP SEMIS

HQUERY: DB      ^5 "QUER" ^'Y'                          ; ***** QUERY
        DW      HEXPEC
QUERY:  DW      DOCOL TIB AT LIT 80 EXPEC
        DW      ZERO IN STORE SEMIS

HNULL:  DB      ^^1 ^0                                  ; ***** <the NULL word>
        DW      HQUERY
NULL:   DW      DOCOL BLK AT ZBRAN +NULL20
        DW      ONE BLK PSTOR ZERO IN STORE
        DW      BLK AT BSCR MOD ZEQU ZBRAN +NULL10
        DW      QEXEC FROMR DROP
NULL10: DW      BRAN +NULL30
NULL20: DW      FROMR DROP
NULL30: DW      SEMIS

HFILL:  DB      ^4 "FIL" ^'L'                           ; ***** FILL
        DW      HNULL
FILL:   DW      DOCOL SWAP TOR OVER CSTOR DUP
        DW      ONEP FROMR ONE SUB CMOVE SEMIS

HERASE: DB      ^5 "ERAS" ^'E'                          ; ***** ERASE
        DW      HFILL
ERASE:  DW      DOCOL ZERO FILL SEMIS

HBLANK: DB      ^6 "BLANK" ^'S'                         ; ***** BLANKS
        DW      HERASE
BLANK:  DW      DOCOL BL FILL SEMIS

HHOLD:  DB      ^4 "HOL" ^'D'                           ; ***** HOLD
        DW      HBLANK
HOLD:   DW      DOCOL LIT -1 HLD PSTOR
        DW      HLD AT CSTOR SEMIS

HPAD:   DB      ^3 "PA" ^'D'                            ; ***** PAD
        DW      HHOLD
PAD:    DW      DOCOL HERE LIT 84 PLUS SEMIS

HWORD:  DB      ^4 "WOR" ^'D'                           ; ***** WORD
        DW      HPAD
WORD:   DW      DOCOL BLK AT ZBRAN +WORD10
        DW      BLK AT BLOCK BRAN +WORD20
WORD10: DW      TIB AT
WORD20: DW      IN AT PLUS SWAP ENCL
        DW      HERE LIT 34 BLANK IN PSTOR
        DW      OVER SUB TOR R HERE CSTOR PLUS
        DW      HERE ONEP FROMR CMOVE SEMIS

HPNUMB: DB      ^8 "(NUMBER" ^')'                       ; ***** (NUMBER)
        DW      HWORD
PNUMB:  DW      DOCOL
PNUM10: DW      ONEP DUP TOR CAT
        DW      BASE AT DIGIT ZBRAN +PNUM30
        DW      SWAP BASE AT USTAR DROP ROT BASE AT
        DW      USTAR DPLUS DPL AT ONEP ZBRAN +PNUM20
        DW      ONE DPL PSTOR
PNUM20: DW      FROMR BRAN +PNUM10
PNUM30: DW      FROMR SEMIS

HNUMB:  DB      ^6 "NUMBE" ^'R'                         ; ***** NUMBER
        DW      HPNUMB
NUMB:   DW      DOCOL ZERO ZERO ROT DUP ONEP CAT
        DW      LIT '-' EQUAL DUP TOR SUB LIT -1
NUMB10: DW      DPL STORE PNUMB DUP
        DW      CAT BL SUB ZBRAN +NUMB20
        DW      DUP CAT LIT '.' SUB
        DW      ZERO QERR ZERO BRAN +NUMB10
NUMB20: DW      DROP FROMR ZBRAN +NUMB30
        DW      DMINU
NUMB30: DW      SEMIS

HDFIND: DB      ^5 "-FIN" ^'D'                          ; ***** -FIND
        DW      HNUMB
DFIND:  DW      DOCOL BL WORD HERE COUNT UPPER
        DW      HERE CONT AT AT PFIND
        DW      DUP ZEQU ZBRAN +DFIN10
        DW      DROP HERE LATES PFIND
DFIN10: DW      SEMIS

HUPPER: DB      ^5 "UPPE" ^'R'                          ; ***** UPPER
        DW      HDFIND
UPPER:  DW      DOCOL OVER PLUS SWAP XDO
UPPE10: DW      I CAT LIT 0x60 GREAT
        DW      I CAT LIT 0x7B LESS
        DW      AND ZBRAN +UPPE20
        DW      I LIT 0x20 TOGGL
UPPE20: DW      XLOOP +UPPE10
        DW      SEMIS

HPABOR: DB      ^7 "(ABORT" ^')'                        ; ***** (ABORT)
        DW      HUPPER
PABOR:  DW      DOCOL ABORT SEMIS

HERROR: DB      ^5 "ERRO" ^'R'                          ; ***** ERROR
        DW      HPABOR
ERROR:  DW      DOCOL WARN AT ZLESS ZBRAN +ERRO10
        DW      PABOR
ERRO10: DW      HERE COUNT TYPE PDOTQ
        DB      3 32 '?' 32
        DW      MESS SPSTO IN AT BLK AT QUIT SEMIS

HIDDOT: DB      ^3 "ID" ^'.'                            ; ***** ID.
        DW      HERROR
IDDOT:  DW      DOCOL PAD BL LIT 95 FILL
        DW      DUP PFA LFA OVER SUB PAD SWAP CMOVE
        DW      PAD COUNT LIT 31 AND
        DW      OVER OVER ONE SUB PLUS DUP CAT
        DW      LIT 0x7F AND SWAP CSTOR
        DW      TYPE SPACE SEMIS

HCREAT: DB      ^6 "CREAT" ^'E'                         ; ***** CREATE
        DW      HIDDOT
CREAT:  DW      DOCOL DFIND ZBRAN +CREA10
        DW      DROP NFA IDDOT LIT 4 MESS SPACE
CREA10: DW      HERE DUP CAT WIDTH AT MIN ONEP ALLOT
        DW      DUP LIT 0xA0 TOGGL HERE ONE SUB
        DW      LIT 0x80 TOGGL LATES COMMA CURR AT STORE
        DW      HERE TWOP COMMA SEMIS

HBCOMP: DB      ^^9 "[COMPILE" ^']'                     ; ***** [COMPILE]
        DW      HCREAT
BCOMP:  DW      DOCOL DFIND ZEQU ZERO QERR
        DW      DROP CFA COMMA SEMIS

HLITER: DB      ^^7 "LITERA" ^'L'                       ; ***** LITERAL
        DW      HBCOMP
LITER:  DW      DOCOL STATE AT ZBRAN +LITE10
        DW      COMP LIT COMMA
LITE10: DW      SEMIS

HDLITE: DB      ^^8 "DLITERA" ^'L'                      ; ***** DLITERAL
        DW      HLITER
DLITE:  DW      DOCOL STATE AT ZBRAN +DLIT10
        DW      SWAP LITER LITER
DLIT10: DW      SEMIS

HULESS: DB      ^2 "U" ^'<'                             ; ***** U<
        DW      HDLITE
ULESS:  DW      DOCOL OVER OVER XOR ZLESS ZBRAN +ULES10
        DW      DROP ZLESS ZEQU BRAN +ULES20
ULES10: DW      SUB ZLESS
ULES20: DW      SEMIS

HQSTAC: DB      ^6 "?STAC" ^'K'                         ; ***** ?STACK
        DW      HULESS
QSTAC:  DW      DOCOL SPAT SZERO AT SWAP ULESS
        DW      ONE QERR SPAT HERE LIT 128
        DW      PLUS ULESS TWO QERR SEMIS

HINTER: DB      ^9 "INTERPRE" ^'T'                      ; ***** INTERPRET
        DW      HQSTAC
INTER:  DW      DOCOL
INTE10: DW      DFIND ZBRAN +INTE40
        DW      STATE AT LESS ZBRAN +INTE20
        DW      CFA COMMA BRAN +INTE30
INTE20: DW      CFA EXEC
INTE30: DW      QSTAC BRAN +INTE70
INTE40: DW      HERE NUMB DPL AT ONEP ZBRAN +INTE50
        DW      DLITE BRAN +INTE60
INTE50: DW      DROP LITER
INTE60: DW      QSTAC
INTE70: DW      BRAN +INTE10

HIMMED: DB      ^9 "IMMEDIAT" ^'E'                      ; ***** IMMEDIATE
        DW      HINTER
IMMED:  DW      DOCOL LATES LIT 0x40 TOGGL SEMIS

HVOCAB: DB      ^10 "VOCABULAR" ^'Y'                    ; ***** VOCABULARY
        DW      HIMMED
VOCAB:  DW      DOCOL BUILD LIT 0xa081 COMMA
        DW      CURR AT CFA COMMA
        DW      HERE VOCL AT COMMA VOCL STORE DOES
DOVOC:  DW      TWOP CONT STORE SEMIS

HDEFIN: DB      ^11 "DEFINITION" ^'S'                   ; ***** DEFINITIONS
        DW      HVOCAB
DEFIN:  DW      DOCOL CONT AT CURR STORE SEMIS

HPAREN: DB      ^1 ^'('                                 ; ***** (
        DW      HDEFIN
PAREN:  DW      DOCOL LIT ')' WORD SEMIS

HQUIT:  DB      ^4 "QUI" ^'T'                           ; ***** QUIT
        DW      HPAREN
QUIT:   DW      DOCOL ZERO BLK STORE LBRAC
QUIT10: DW      RPSTO CR QUERY INTER STATE AT
        DW      ZEQU ZBRAN +QUIT20
        DW      PDOTQ
        DB      3 32 "ok"
QUIT20: DW      BRAN +QUIT10

HABORT: DB      ^5 "ABOR" ^'T'                          ; ***** ABORT
        DW      HQUIT
ABORT:  DW      DOCOL
ABOR10: DW      RPSTO SPSTO DEC SPACE
        DW      PAD AT LIT COLD_MAGIC SUB ZBRAN +ABOR20
        DW      ZERO PAD STORE CR PDOTQ
        DB      13 "Minimal-FORTH"
ABOR20: DW      FORTH DEFIN QUIT
