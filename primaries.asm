; ----------------------------------------------------------------------
; FORTH PRIMARIES
;

HLIT:   DB      ^3 "LI" ^'T'                            ; ***** LIT
        DW      0
LIT:    DW      LIT0
LIT0:   JPS     _LIT            ; R1 = (IP)+
        JPA     PUSH            ; -(SP) = R1; NEXT

HEXEC:  DB      ^7 "EXECUT" ^'E'                        ; ***** EXECUTE
        DW      HLIT
EXEC:   DW      EXEC0
EXEC0:  LDR     SP              ; WA = (SP)+
        STA     WA.0
        INW     SP
        LDR     SP
        STA     WA.1
        INW     SP
        JPA     NEXT10          ; jump @(WA)+

HBRAN:  DB      ^6 "BRANC" ^'H'                         ; ***** BRANCH
        DW      HEXEC
BRAN:   DW      BRAN0
BRAN0:  JPS     _BRAN           ; IP = IP + (IP)
        JPA     NEXT

HZBRAN: DB      ^7 "0BRANC" ^'H'                        ; ***** 0BRANCH
        DW      HBRAN
ZBRAN:  DW      ZBRAN0
ZBRAN0: LDR     SP
        CPI     0               ; Low byte non-zero?
        BNE     ZBRA10          ; YES: Do not branch
        INW     SP
        LDR     SP
        CPI     0               ; High byte non-zero?
        BNE     ZBRA20          ; YES: Do not branch
        INW     SP
        JPA     BRAN0           ; IP = IP + (IP); NEXT
ZBRA10: INW     SP
ZBRA20: INW     SP
        INW     IP              ; Just skip jump offset
        INW     IP
        JPA     NEXT

HXPLOO: DB      ^7 "(+LOOP" ^')'                        ; ***** (+LOOP)
        DW      HZBRAN
XPLOO:  DW      XPLOO0
XPLOO0: JPS     _GET2           ; R2 = (SP) [only copying increment]
        JPS     _RPOP1          ; R1 = (RP)+
        JPS     _ADD16          ; R1 = counter'
        JPS     _RGET2          ; R2 = limit
        JPS     _RPUSH1         ; -(RP) = R1'
        JPS     _POP3           ; R3 = (SP)+ [now popping incr]
        LDA     R3.1            ; Is increment negative?
        CPI     0               ; :
        BPL     XPLO10
        ; Handle negative increment
        JPS     _XCH16          ; R1 <-> R2
        ; Compare counter to limit
XPLO10: LDA     R1.1            ; Compare MSB
        CPA     R2.1            ; :
        BMI     BRAN0           ; R2 is greater, continue looping
        BEQ     XPLO20          ; MSBs are equal, check LSBs
        JPA     XPLO30          ; R1 is greater, stop looping
        ; MSBs are equal
XPLO20: LDA     R1.0            ; Compare LSB
        CPA     R2.0            
        BMI     BRAN0           ; R2 is greater, continue looping
        ; Limit reached, cleanup rstack and stop looping
XPLO30: LDI     4               ; Drop loop counter ...
        ADW     RP              ; ... and loop limit
        LDI     2               ; Skip branch offset
        ADW     IP              ; :
        JPA     NEXT

HXLOOP: DB      ^6 "(LOOP" ^')'                         ; ***** (LOOP)
        DW      HXPLOO
XLOOP:  DW      XLOOP0
XLOOP0: CLW     R1              ; Push a one
        INW     R1              ; :
        JPS     _PUSH1          ; :
        JPA     XPLOO0          ; (+LOOP)

HXDO:   DB      ^4 "(DO" ^')'                           ; ***** (DO)
        DW      HXLOOP
XDO:    DW      XDO0
XDO0:   JPS     _POP21          ; Loop counter, limit
        JPS     _RPUSH1         ; Push limit onto rstack
        JPS     _RPUSH2         ; Push loop counter onto rstack
        JPA     NEXT

HI:     DB      ^1 ^'I'                                 ; ***** I
        DW      HXDO
I:      DW      I0
I0:     JPS     _RGET1          ; Get loop counter
        JPA     PUSH            ; Push it onto dstack

HDIGIT: DB      ^5 "DIGI" ^'T'                          ; ***** DIGIT
        DW      HI
DIGIT:  DW      DIGIT0
DIGIT0: JPS     _POP21          ; R2 = base, R1 = char
        LDA     R1.0            ; Get character into A
        CPI     'A'             ; Greater or equal to 'A'?
        BMI     DIGI10          ; NO: Then it has to be '0' - '9'
        CPI     '['             ; Less than '[' (i.e. 'A' - 'Z')?
        BPL     DIGI88          ; NO: Not a digit
        SBI     55              ; A becomes 10
        JPA     DIGI20          ; Go check against base
        ; '0' - '9' case
DIGI10: SBI     '0'             ; Assume '0' - '9'
        BMI     DIGI88          ; Oops! Negative, not a digit
        CPI     10              ; Greater than 9?
        BPL     DIGI88          ; YES: Not a digit
        ; Check result against base
DIGI20: CPA     R2.0            ; Less than base?
        BMI     DIGI77          ; YES: Conversion done
        JPA     DIGI88          ; NO: Not a digit
        ; Conversion successful
DIGI77: STA     R1.0            ; Store binary value
        JPS     _PUSH1          ; Push the value
        JPA     PUSHT           ; Push TRUE; NEXT
        ; Not a digit
DIGI88: JPA     PUSHF           ; Push FALSE; NEXT

HPFIND: DB      ^6 "(FIND" ^')'                         ; ***** (FIND)
        DW      HDIGIT
PFIND:  DW      PFIND0
PFIND0: JPS     _POP1           ; NFA
        JPS     _POP3           ; String address
PFIN10: LDA     R3.0            ; R2 = R3 (string address)
        STA     R2.0            ; :
        LDA     R3.1            ; :
        STA     R2.1            ; :
        ; Fast comparison of length bytes
        LDR     R1              ; Get lByte
        STA     R1.2            ; ... Store as potential result
        LSL                     ; lByte &= 0x3F
        LSL                     ; :
        LSR                     ; :
        LSR                     ; :
        STA     R2.2            ; R2.2 is counter for string match
        CPR     R2              ; lByte == string length?
        BNE     PFIN25          ; NO: Move over to next header
        ; Length bytes match, check names
PFIN20: INW     R1              ; Bump pointers
        INW     R2              ; :
        LDR     R1              ; Get char from dictionary
        LSL                     ; char &= 0x7F
        LSR                     ; :
        CPR     R2              ; Is it a match with search string?
        BNE     PFIN30          ; NO: Look at next header in dictionary
        DEB     R2.2            ; YES: Decrement character counter
        CPI     0               ; At end of string?
        BEQ     PFIN77          ; YES: This is the word we are looking for
        JPA     PFIN20          ; Match so far, try next char
        ; Step to next header in dictionary
PFIN25: LSL                     ; Eliminate potential smudge bit
        LSL                     ; A = A & 0x1F
        LSL                     ; lByte consists of [^ISnnnnn]
        LSR                     ; :
        LSR                     ; :
        LSR                     ; :
        STA     R2.2            ; : also update char counter
        INW     R1              ; Bump NFA pointer to actual characters
PFIN30: INW     R1              ; Bump NFA pointer
        DEB     R2.2            ; Decrement character counter
        CPI     0               ; End of name field?
        BNE     PFIN30          ; NO: Step to next char
        JPS     _ATR1           ; YES: R1 = (R1)
        LDA     R1.1            ; At end of dictionary?
        CPI     0               ; :
        BNE     PFIN10          ; NO: Try this word for match
        LDA     R1.0            ; :
        CPI     0               ; :
        BNE     PFIN10          ; NO: Try this word for match
        ; Word not found, return a single FALSE
PFIN88: JPA     PUSHF           ; Done
        ; Word found, return PFA, lByte, TRUE
PFIN77: LDI     5               ; Bump ptr to PFA
        ADW     R1              ; :
        JPS     _PUSH1          ; Push PFA
        LDA     R1.2            ; Get stored length byte
        STA     R1.0            ; :
        CLB     R1.1            ; Clear MSB
        JPS     _PUSH1          ; Push length byte
        JPA     PUSHT           ; Done

HENCL:  DB      ^7 "ENCLOS" ^'E'                        ; ***** ENCLOSE
        DW      HPFIND
ENCL:   DW      ENCL0
ENCL0:  JPS     _POP3           ; Get delimiter char
        JPS     _GET1           ; Get addr of input
        CLW     R2              ; Initialize char index
        ; Scan preceeding delimiters
ENCL10: LDR     R1              ; Get char from input
        CPI     0               ; Is it <NUL>?
        BEQ     ENCL50          ; YES: <NUL> before first non-delimiter
        CPA     R3.0            ; Is it a delimiter?
        BNE     ENCL20          ; NO: We have the start of next token
        INW     R1              ; Bump to next char ...
        INW     R2              ; ... also increase index
        JPA     ENCL10          ; Go back to look at next char
        ; Start of token
ENCL20: JPS     _PUSH2          ; Push result n1 (first char of token)
ENCL30: LDR     R1              ; Get char from input
        CPI     0               ; Is it <NUL>?
        BEQ     ENCL60          ; YES: <NUL> found
        CPA     R3.0            ; Is it a delimiter?
        BEQ     ENCL40          ; YES: We have the end of the token
        INW     R1              ; Bump to next char ...
        INW     R2              ; ... also increase index
        JPA     ENCL30          ; Go back to look at next char
        ; End of token
ENCL40: JPS     _PUSH2          ; Push result n2 (ending delimiter)
        INW     R2              ; Also push n3 ...
        JPS     _PUSH2          ; : ... (index to first non-scanned char)
        JPA     NEXT            ; Done
        ; <NUL> word found
ENCL50: JPS     _PUSH2          ; Push i (index to <NUL>)
        INW     R2              ; Push i + 1 (a null is one character long)
        ; Token ends with a <NUL>
ENCL60: JPS     _PUSH2          ; :
        JPS     _PUSH2          ; :
        JPA     NEXT            ; Done

; NOTE: EMIT, KEY, ?TERMINAL and CR moved to "extras" as they have been
;       implemented as vectored functions in Minimal-FORTH

HCMOVE: DB      ^5 "CMOV" ^'E'                          ; ***** CMOVE
        DW      HENCL
CMOVE:  DW      CMOVE0
CMOVE0: JPS     _POP321         ; R3 = count, R2 = dst, R1 = src
CMOV10: LDR     R1              ; Get byte from source
        STR     R2              ; Store to destination
        INW     R1              ; Bump source pointer
        INW     R2              ; Bump destination pointer
        DEW     R3              ; Decrement count
        LDA     R3.0            ; Low byte zero?
        CPI     0               ; :
        BNE     CMOV10          ; NO: One more byte
        LDA     R3.1            ; High byte zero?
        CPI     0               ; :
        BNE     CMOV10          ; NO: One more byte
        JPA     NEXT            ; YES: Count zero. Done.

HUSTAR: DB      ^2 "U" ^'*'                             ; ***** U*
        DW      HCMOVE
USTAR:  DW      USTAR0
USTAR0: JPS     _POP21          ; R2 = oper2, R1 = oper1
        JPS     _UMULT          ; u32 = u16 * u16
        DEW     SP              ; -(SP) = R3X
        LDA     R3.1            ; :
        STR     SP              ; :
        DEW     SP              ; :
        LDA     R3.0            ; :
        STR     SP              ; :
        DEW     SP              ; :
        LDA     R3.3            ; :
        STR     SP              ; :
        DEW     SP              ; :
        LDA     R3.2            ; :
        STR     SP              ; :
        JPA     NEXT            ; Done

HUSLAS: DB      ^2 "U" ^'/'                             ; ***** U/
        DW      HUSTAR
USLAS:  DW      USLAS0
USLAS0: JPS     _POP21          ; R2 = divisor, R1 = dividend-hi
        LDA     R1.0            ; Move high part to R1.2 and R1.3
        STA     R1.2            ; :
        LDA     R1.1            ; :
        STA     R1.3            ; :
        JPS     _POP1           ; dividend, low 16b
        JPS     _UDIV           ; u32 / u16 --> quot_u16, rem_u16
        JPA     IPUSH           ; Push R1H; Push R1L; NEXT

HAND:   DB      ^3 "AN" ^'D'                            ; ***** AND
        DW      HUSLAS
AND:    DW      AND0
AND0:   JPS     _POP21          ; R2 = oper2, R1 = oper1
        JPS     _AND16          ; R1 = R1 & R2
        JPA     PUSH            ; Done

HOR:    DB      ^2 "O" ^'R'                             ; ***** OR
        DW      HAND
OR:     DW      OR0
OR0:    JPS     _POP21          ; R2 = oper2, R1 = oper1
        JPS     _OR16           ; R1 = R1 | R2
        JPA     PUSH            ; Done

HXOR:   DB      ^3 "XO" ^'R'                            ; ***** XOR
        DW      HOR
XOR:    DW      XOR0
XOR0:   JPS     _POP21          ; R2 = oper2, R1 = oper1
        JPS     _XOR16          ; R1 = R1 ^ R2
        JPA     PUSH            ; Done

HNOT:   DB      ^3 "NO" ^'T'                            ; ***** NOT
        DW      HXOR
NOT:    DW      ZEQU

HSPAT:  DB      ^3 "SP" ^'@'                            ; ***** SP@
        DW      HNOT
SPAT:   DW      SPAT0
SPAT0:  LDA     SP.0            ; Get stack pointer
        STA     R1.0            ; : into R1
        LDA     SP.1            ; :
        STA     R1.1            ; :
        JPA     PUSH            ; Push R1; NEXT

HSPSTO: DB      ^3 "SP" ^'!'                            ; ***** SP!
        DW      HSPAT
SPSTO:  DW      SPSTO0
SPSTO0: LDI     18              ; Index of SP0
        STA     R2.0            ; : in boot table
        JPS     _PORIG          ; R3 = &bootTable[R2]
        JPS     _LD16           ; R1 = XSP
        LDA     R1.0            ; SP = R1
        STA     SP.0            ; :
        LDA     R1.1            ; :
        STA     SP.1            ; :
        JPA     NEXT            ; Done

HRPSTO: DB      ^3 "RP" ^'!'                            ; ***** RP!
        DW      HSPSTO
RPSTO:  DW      RPSTO0
RPSTO0: LDI     20              ; Index of SP0
        STA     R2.0            ; : in boot table
        JPS     _PORIG          ; R3 = &bootTable[R2]
        JPS     _LD16           ; R1 = XRP
        LDA     R1.0            ; SP = R1
        STA     RP.0            ; :
        LDA     R1.1            ; :
        STA     RP.1            ; :
        JPA     NEXT            ; Done

HUPSTO: DB      ^3 "UP" ^'!'                            ; ***** UP!
        DW      HRPSTO
UPSTO:  DW      UPSTO0
UPSTO0: LDI     16              ; Index of UP0
        STA     R2.0            ; : in boot table
        JPS     _PORIG          ; R3 = &bootTable[R2]
        JPS     _LD16           ; R1 = XUP
        LDA     R1.0            ; UP = R1
        STA     UP.0            ; :
        LDA     R1.1            ; :
        STA     UP.1            ; :
        JPA     NEXT            ; Done

HSEMIS: DB      ^2 ";" ^'S'                             ; ***** ;S
        DW      HRPSTO
SEMIS:  DW      SEMIS0
SEMIS0: LDR     RP              ; IP = (RP)+
        STA     IP.0            ; :
        INW     RP              ; :
        LDR     RP              ; :
        STA     IP.1            ; :
        INW     RP              ; :
        JPA     NEXT            ; Done

HLEAVE: DB      ^5 "LEAV" ^'E'                          ; ***** LEAVE
        DW      HSEMIS
LEAVE:  DW      LEAVE0
LEAVE0: JPS     _RPOP1          ; 2(RP) = (RP)
        JPS     _RPUT1          ; :
        JPS     _RPUSH1         ; :
        JPA     NEXT

HTOR:   DB      ^2 ">" ^'R'                             ; ***** >R
        DW      HLEAVE
TOR:    DW      TOR0
TOR0:   JPS     _POP1           ; -(RP) = (SP)+
        JPS     _RPUSH1         ; :
        JPA     NEXT

HFROMR: DB      ^2 "R" ^'>'                             ; ***** R>
        DW      HTOR
FROMR:  DW      FROMR0
FROMR0: JPS     _RPOP1          ; -(SP) = (RP)+
        JPA     PUSH            ; :

HR:     DB      ^1 ^'R'                                 ; ***** R
        DW      HFROMR
R:      DW      R0
R0:     JPS     _RGET1          ; -(SP) = (RP)
        JPA     PUSH            ; :

HZEQU:  DB      ^2 "0" ^'='                             ; ***** 0=
        DW      HR
ZEQU:   DW      ZEQU0
ZEQU0:  JPS     _POP1
        JPS     _ZEQU
        JPA     PUSH
        ;
_ZEQU:  LDA     R1.0            ; Get LSB
        CPI     0               ; Is it zero?
        BNE     _ZEQ10          ; NO: Return false flag
        LDA     R1.1            ; Get MSB
        CPI     0               ; Is it zero?
        BNE     _ZEQ10          ; NO: Return false flag
        ; Zero case
        CLW     R1              ; True flag
        DEW     R1              ; :
        RTS                     ; Done
        ; Non-zero case
_ZEQ10: CLW     R1              ; False flag
        RTS                     ; Done

HZLESS: DB      ^2 "0" ^'<'                             ; ***** 0<
        DW      HZEQU
ZLESS:  DW      ZLESS0
ZLESS0: JPS     _POP1
        JPS     _ZLESS
        JPA     PUSH
        ;
_ZLESS: LDA     R1.1            ; Get MSB
        CPI     0               ; Is it negative?
        BMI     _ZLE10          ; YES: Return true flag
        ; Zero or positive case
        CLW     R1              ; NO: Return false flag
        RTS                     ; Done
        ; Negative case
_ZLE10: CLW     R1              ; True flag
        DEW     R1              ; :
        RTS                     ; Done

HPLUS:  DB      ^1 ^'+'                                 ; ***** +
        DW      HZLESS
PLUS:   DW      PLUS0
PLUS0:  JPS     _POP21          ; R2 = oper2, R1 = oper1
        JPS     _ADD16          ; R1 = R1 + R2
        JPA     PUSH            ; -(SP) = R1; NEXT

HDPLUS: DB      ^2 "D" ^'+'                             ; ***** D+
        DW      HPLUS
DPLUS:  DW      DPLUS0
DPLUS0: JPS     _DPOP2          ; Get second operand
        JPS     _DPOP1          ; Get first operand
        JPS     _ADD32          ; R1X = R1X + R2X
        JPA     DPUSH           ; -(SP) = R1X; NEXT

HMINUS: DB      ^5 "MINU" ^'S'                          ; ***** MINUS
        DW      HDPLUS
MINUS:  DW      MINUS0
MINUS0: JPS     _POP1           ; Get operand
        JPS     _NEG16          ; Negate
        JPA     PUSH

HDMINU: DB      ^6 "DMINU" ^'S'                         ; ***** DMINUS
        DW      HMINUS
DMINU:  DW      DMINU0
DMINU0: JPS     _DPOP1          ; Get operand
        JPS     _NEG32          ; Negate
        JPA     DPUSH

HPICK:  DB      ^4 "PIC" ^'K'                           ; ***** PICK
        DW      HDMINU
PICK:   DW      PICK0
PICK0:  JPS     _PICK
        JPA     NEXT
        ;
_PICK:  JPS     _POP1           ; Get index number
        LDA     R1.0            ; Push onto Minimal stack
        PHS                     ; :
        JPS     __PICK          ; R1 = n(SP)
        PLS                     ; Remove index number
        JPS     _PUSH1          ; -(SP) = R1
        RTS                     ; Done

HROLL:  DB      ^4 "ROL" ^'L'                           ; ***** ROLL
        DW      HPICK
ROLL:   DW      ROLL0
ROLL0:  JPS     _ROLL
        JPA     NEXT
        ;
_ROLL:  JPS     _POP1           ; Get index number
        LDA     R1.0            ; Push onto Minimal stack
        PHS                     ; :
        JPS     __ROLL          ; R1 = n(SP)
        PLS                     ; Remove index number
        RTS                     ; Done

HOVER:  DB      ^4 "OVE" ^'R'                           ; ***** OVER
        DW      HROLL
OVER:   DW      OVER0
OVER0:  JPS     _OVER
        JPA     NEXT
        ;
_OVER:  JPS     _POP2           ; n1 n2 -- n1 n2 n1
        JPS     _GET1           ; :
        JPS     _PUSH2          ; :
        JPS     _PUSH1          ; :
        RTS

HDROP:  DB      ^4 "DRO" ^'P'                           ; **** DROP
        DW      HOVER
DROP:   DW      DROP0
DROP0:  JPS     _DROP
        JPA     NEXT
        ;
_DROP:  LDI     2               ; n1 --
        ADW     SP              ; :
        RTS                     ; Done

HSWAP:  DB      ^4 "SWA" ^'P'                           ; **** SWAP
        DW      HDROP
SWAP:   DW      SWAP0
SWAP0:  JPS     _SWAP
        JPA     NEXT
        ;
_SWAP:  JPS     _POP21          ; n1 n2 -- n2 n1
        JPS     _PUSH2          ; :
        JPS     _PUSH1          ; :
        RTS                     ; Done

HDUP:   DB      ^3 "DU" ^'P'                            ; **** DUP
        DW      HSWAP
DUP:    DW      DUP0
DUP0:   JPS     _DUP
        JPA     NEXT
        ;
_DUP:   JPS     _GET1           ; n1 -- n1 n1
        JPS     _PUSH1          ; :
        RTS

HTOVER: DB      ^5 "2OVE" ^'R'                          ; ***** 2OVER
        DW      HDUP
TOVER:  DW      TOVER0
TOVER0: LDI     3
        PHS
        JPS     _PICK           ; 3 PICK
        JPS     _PUSH1
        JPS     _PICK           ; 3 PICK
        PLS
        JPA     PUSH

HTDROP: DB      ^5 "2DRO" ^'P'                          ; ***** 2DROP
        DW      HTOVER
TDROP:  DW      TDROP0
TDROP0: LDI     4
        ADW     SP
        JPA     NEXT

HTSWAP: DB      ^5 "2SWA" ^'P'                          ; ***** 2SWAP
        DW      HTDROP
TSWAP:  DW      TSWAP0
TSWAP0: LDI     3
        PHS
        JPS     _ROLL           ; 3 ROLL
        JPS     _ROLL           ; 3 ROLL
        PLS
        JPA     NEXT

HTDUP:  DB      ^4 "2DU" ^'P'                           ; ***** 2DUP
        DW      HTSWAP
TDUP:   DW      TDUP0
TDUP0:  JPS     _POP2           ; OVER
        JPS     _GET1           ; :
        JPS     _PUSH2          ; :
        JPS     _PUSH1          ; :
        JPS     _POP2           ; OVER
        JPS     _GET1           ; :
        JPS     _PUSH2          ; :
        JPA     PUSH            ; :


HPSTOR: DB      ^2 "+" ^'!'                             ; ***** +!
        DW      HTDUP
PSTOR:  DW      PSTOR0
PSTOR0: JPS     _PSTOR
        JPA     NEXT
        ;
_PSTOR: JPS     _POP3           ; R3 = addr
        JPS     _POP2           ; R2 = incr
        JPS     _LD16           ; R1 = (R3)
        JPS     _ADD16          ; R1 = R1 + R2
        JPS     _ST16           ; (R3) = R1
        RTS                     ; Done

HTOGGL: DB      ^6 "TOGGL" ^'E'                         ; ***** TOGGLE
        DW      HPSTOR
TOGGL:  DW      TOGGL0
TOGGL0: JPS     _POP2           ; R2 = bit mask
        JPS     _GET3           ; R3 = addr (leave copy on stack)
        LDR     R3              ; Get the byte
        STA     R1.0            ; :
        JPS     _XOR8           ; R1.0 = R1.0 ^ R2.0
        JPS     _POP3           ; R3 = addr
        LDA     R1.0            ; Update the byte
        STR     R3              ; :
        JPA     NEXT            ; Done

HTBANK: DB      ^5 ">BAN" ^'K'                          ; >BANK
        DW      HTOGGL
TBANK:  DW      TBANK0
TBANK0: JPS     _POP1           ; Get bank number from data stack into R1
        LDI     62              ; Get index to user variable BANK
        STA     R2.0            ; : into R2.0
        JPS     _USER           ; R3 now contains absolute address of BANK
        JPS     _ST16           ; Save the bank number in user variable BANK
        LDA     R1.0            ; Do the actual bank switch
        BNK                     ; :
        JPA     NEXT
        
HAT:    DB      ^1 ^'@'                                 ; ***** @
        DW      HTBANK
AT:     DW      AT0
AT0:    JPS     _AT
        JPA     NEXT
        ;
_AT:    JPS     _POP3           ; R3 = addr
        JPS     _LD16           ; R1 = (R3)
        JPS     _PUSH1           ; -(SP) = R1
        RTS

HCAT:   DB      ^2 "C" ^'@'                             ; ***** C@
        DW      HAT
CAT:    DW      CAT0
CAT0:   CLW     R1              ; R1 = 0
        JPS     _POP3           ; R3 = addr
        LDR     R3              ; A = (R3)
        STA     R1.0            ; R1 = A
        JPA     PUSH            ; -(SP) = R1; NEXT

HSTORE: DB      ^1 ^'!'                                 ; ***** !
        DW      HCAT
STORE:  DW      STORE0
STORE0: JPS     _STORE
        JPA     NEXT
        ;
_STORE: JPS     _POP3           ; R3 = addr
        JPS     _POP1           ; R1 = data
        JPS     _ST16           ; (R3) = R1
        RTS                     ; Done

HCSTOR: DB      ^2 "C" ^'!'                             ; ***** C!
        DW      HSTORE
CSTOR:  DW      CSTOR0
CSTOR0: JPS     _POP21          ; R2 = addr, R1 = data
        LDA     R1.0            ; A = R1.0
        STR     R2              ; (R3) = A
        JPA     NEXT            ; Done
