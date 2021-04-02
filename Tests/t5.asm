
        ORG     0x8000
        
        CLW     R1

        INW     R1
        INW     R1
        DEW     R1
        DEW     R1
        DEW     R1
        DEW     R1
        INW     R1
        INW     R1

        LDI     0xFE
        STA     R1

        INW     R1
        INW     R1
        DEW     R1
        DEW     R1
        DEW     R1
        DEW     R1
        INW     R1
        INW     R1

        LDA     R1
        CPI     0
        BNE     NOTZ
        LDA     R1a
        CPI     0
        BNE     NOTZ
        LDI     0
STOP:   JPA     STOP

NOTZ:   LDI     -1
NOTZ0:  JPA     NOTZ0

        ORG     0x8080

R1:     DB      0
R1a:    DB      0