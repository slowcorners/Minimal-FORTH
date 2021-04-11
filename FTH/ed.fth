
27 CONSTANT ESC

: CSI   ESC EMIT ASCII [ EMIT ;

: CUU   CSI ASCII A EMIT ;
: CUD   CSI ASCII B EMIT ;
: CUF   CSI ASCII C EMIT ;
: CUB   CSI ASCII D EMIT ;

: CLS
    CSI ASCII H EMIT
    CSI ASCII J EMIT
;

: RULER
    CR 61 1
    DO
        I 10 MOD 0=
        IF
            I 10 / 0 .R
        ELSE
            I 5 - 10 MOD 0=
            IF
                ASCII + EMIT
            ELSE
                ASCII - EMIT
            ENDIF
        ENDIF
    LOOP
    CR
;
