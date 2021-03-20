        ORG     0x8000
        
        LDI     7
        SBI     8
        BMI     MINUS
        BEQ     ZERO
        BPL     PLUS
        LDI     0xAA
        JPA     STOP
MINUS:  LDI     0xFF
        JPA     STOP
ZERO:   LDI     0x88
        JPA     STOP
PLUS:   LDI     0x01
        
STOP:   JPA     STOP
