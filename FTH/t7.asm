        ORG     0x8000

        LDI     7
        CPI     7
        BPL     TRUE
        LDI     0
STOP:   JPA     STOP

TRUE:   LDI     -1
        JPA     STOP

        