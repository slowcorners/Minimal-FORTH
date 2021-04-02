        ORG     0x8000
        
        LDA     P1lo
        SBA     P2lo
        STA     P1lo
        LDA     P1hi
        SCA     P2hi
        STA     P1hi

STOP:   JPA     STOP

        ORG     0x8080

P1lo:   DB      4
P1hi:   DB      1
P2lo:   DB      100
P2hi:   DB      0
