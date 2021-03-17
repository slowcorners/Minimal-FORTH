AND:    LDI     8
        STA     counter
AND10:  LDA     regb
        LSL
        STA     regb
        LDA     rega
        BCC     AND20
        CPI     0
        BMI     AND20
        CLC
AND20:  ROL
        STA     rega
        DEB     counter
        BNE     AND10
        RTS
