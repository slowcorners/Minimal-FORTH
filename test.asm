		ORG     0
		
START:  BNE     LAB10
        ROL
LAB10:  DB      77
        DW      0 0 0 0
        DW      +LAB10
        DW      0
        DW      +LAB20
        DW      0x3377
LAB20:  DW      0x1122
        DW      0
        DW      +LAB20
