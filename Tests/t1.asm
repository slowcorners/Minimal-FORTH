        ORG     0
HSWAP:  DB      ^4 "SWA" ^'P'
        DW      0
SWAP:   DW      SWAP0
SWAP0:  LDA     20
        INW     20
DOCOL:  DW      0
DOC10:  DW      0
DUP:    DW      0
DROP:   DW      0
OVER:   DW      0
BRAN:   DW      0
        DW      DOCOL DUP OVER SWAP DUP OVER SWAP OVER
        DW      BRAN +DOC10
        DW      DOCOL DUP OVER SWAP
        DW      BRAN +DOC10 DOCOL DUP
        DW      OVER SWAP BRAN +DOC10
        DW      DOCOL DUP OVER SWAP
        DW      BRAN +DOC10 DOCOL DUP
        DW      OVER SWAP BRAN +DOC10
        DW      BRAN +DOC10
