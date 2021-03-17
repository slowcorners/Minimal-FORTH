; Slu4 synthesized bitwise AND

        ORG     0x8000

        JPS     And
halt:   JPA     halt

rega:   DB      0xf0
regb:   DB      0x55
count:  DB      0

        ; rega = rega & regb
And:    LDI     8
        STA     count
loop:   LDA     regb
        LSL
        STA     regb            ; shift bit of b into C
        LDA     rega
        BCC     rollthisin
        CPI     0
        BMI     rollthisin      ; check bit a, branch if N=1 (C will be 1, too)
        CLC                     ; clear C so it will be shifted back in
rollthisin:
        ROL
        STA     rega            ; roll C back in
        DEB     count
        BNE     loop
        RTS
