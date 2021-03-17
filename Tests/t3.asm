        ORG     0x8000

        JPA     START
        
RegA:   DB      0xFE
        
START:  LDA     RegA
        NEG
        SBI     1
        
STOP:   NOP
        JPA     STOP
