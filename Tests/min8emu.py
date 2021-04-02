#!/usr/bin/python

import os, time, sys, msvcrt

print('Welcome to min8emu v 0.1 by SlowCorners')

ram = []
eeprom = []

for i in range(2**15): ram.append(0xFF)

mnem = ['NOP', 'BNK', 'OUT', 'CLC', 'SEC', 'LSL', 'ROL', 'LSR', \
        'ROR', 'ASR', 'INP', 'NEG', 'INC', 'DEC', 'LDI', 'ADI', \
        'SBI', 'CPI', 'ACI', 'SCI', 'JPA', 'LDA', 'STA', 'ADA', \
        'SBA', 'CPA', 'ACA', 'SCA', 'JPR', 'LDR', 'STR', 'ADR', \
        'SBR', 'CPR', 'ACR', 'SCR', 'CLB', 'NEB', 'INB', 'DEB', \
        'ADB', 'SBB', 'ACB', 'SCB', 'CLW', 'NEW', 'INW', 'DEW', \
        'ADW', 'SBW', 'ACW', 'SCW', 'LDS', 'STS', 'PHS', 'PLS', \
        'JPS', 'RTS', 'BNE', 'BEQ', 'BCC', 'BCS', 'BPL', 'BMI']

UART_in = 0xFF
UART_out = 0xFF

PC  = 0
A   = 0
B   = 0
N   = False
C   = False
Z   = False

aIP = 0xFEE8
aSP = aIP + 4
aRP = aIP + 6
aUP = aIP + 8

aR1 = aIP + 10
aR2 = aIP + 14
aR3 = aIP + 18

aBT = aIP + 22

XSP = 0xF5B9
XRP = 0xF68D

IP = 0

stopHere = False
step = 0
stepCnt = 0
watchList = []
sourceCode = None
locoLines = []
breaks = []

def kbhit():
    return msvcrt.kbhit()

def getch():
    return msvcrt.getch()

def loadHexFile(fName):
    global sourceCode, locoLines
    sourceCode = None; locoLines = []; f = None
    try:
        hfName = fName + '.hex'
        f = open(hfName, 'r')
    except:
        pass
    if not f:
        print('Cannot find file %s.hex' % fName)
        return
    lines = f.readlines()
    f.close()
    loco = 0x8000
    cnt = 0
    for line in lines:
        ll = line.split()
        if ll[0][0] == ':':
            b = int(ll[0][1:], 16)
            ST8(loco, b); loco += 1
            cnt += 1
            for item in ll[1:]:
                b = int(item, 16)
                ST8(loco, b); loco += 1
                cnt += 1
        else:
            loco = int(ll[0], 16)
    print('Successfully loaded %d bytes from file %s.hex' % (cnt, fName))
    # Also try to load the source code if possible
    try:
        afName = fName + '.lst'
        f = open(afName, 'r')
    except:
        f = None
    if f:
        sourceCode = f.readlines()
        f.close()
        ln = 0; loco = 1
        for sLine in sourceCode:
            try:
                lo = int(sLine[0:4], 16)
                if lo >= loco:
                    locoLines.append((lo, ln))
                    loco = lo
            except:
                pass
            ln += 1
        locoLines.sort()
        print('Also loaded list file %s.lst' % fName)
    else:
        print('Cannot load list file %s.lst' % fName)

# ----------------------------------------------------------------------
# The Minimal-CPU emulator

def set_NZ():
    global N, Z
    if A > 127:
        N = True
    else:
        N = False
    if A == 0:
        Z = False
    else:
        Z = True

def LD8(a):
    if a in breaks: step = 0
    if a > 0x7FFF:
        return ram[a - 0x8000]
    else:
        return eeprom[B + a]

def ST8(a, b):
    global step
    if a in breaks: step = 0
    try:
        if a > 0x7FFF:
            ram[a - 0x8000] = b
        else:
            eeprom[B + a] = b
    except:
        step = 0

def LD16(a):
    res = LD8(a) + (LD8(a + 1) << 8)
    return res

def ST16(a, w):
    ST8(a, w & 0xFF)
    ST8(a + 1, w >> 8)

def LDI():
    global PC
    res = LD8(PC); PC += 1
    return res

def LDIW():
    global PC
    res =  LD16(PC); PC += 2
    return res

def LDA():
    return LD8(LDIW())

def STA():
    ST8(LDIW(), A)
    return A

def LDR():
    return LD8(LD16(LDIW()))

def STR():
    ST8(LD16(LDIW()), A)
    return A

def ADD(b):
    global A, C
    A += b
    if A > 255:
        A -= 256
        C = True
    else:
        C = False
    set_NZ()
    return A

def ADC(b):
    if C: ADD(1)
    ADD(b)
    return A

def SUB(b):
    ADD(256 - b)
    return A

def SBC(b):
    if not C: SUB(1)
    SUB(b)
    return A
    
def CMP(b):
    global A
    Asave = A; SUB(b); A = Asave

def CLR():
    global A, C
    A = 0; C = True; set_NZ()

def LSL():
    ADD(A)

def ROL():
    global A
    c = C
    ADD(A)
    if c: A |= 0x01

def LSR():
    global A
    A >>= 1; set_NZ()

def ROR():
    global A
    m = A & 0x01
    A >>= 1
    if C: A |= 0x80
    if m: C = True
    else: C = False
    set_NZ()

def ASR():
    global A
    m = A & 0x80
    A >>= 1
    if m: A |= 0x80
    set_NZ()

def NEG():
    global A
    A = 256 - A; ADD(0)
    return A

def INC():
    ADD(1)
    return A

def DEC():
    SUB(1)
    return A

def CPU_instruction():
    global mem, PC, A, B, N, C, Z, UART_in, UART_out, step, stepCnt
    ir = LDI(); stepCnt += 1
    if ir == 0:                                                 # NOP
        pass
    elif ir == 1:                                               # BNK
        B = (A & 0x0F) << 15
    elif ir == 2:                                               # OUT
        UART_out = A; N = True; C = False; Z = False
    elif ir == 3:                                               # CLC
        N = True; C = False; Z = False
    elif ir == 4:                                               # SEC
        N = False; C = True; Z = True
    elif ir == 5:                                               # LSL
        LSL()
    elif ir == 6:                                               # ROL
        ROL()
    elif ir == 7:                                               # LSR
        LSR()
    elif ir == 8:                                               # ROR
        ROR()
    elif ir == 9:                                               # ASR
        ASR()
    elif ir == 10:                                              # INP
        A = UART_in; UART_in = 0xFF
    elif ir == 11:                                              # NEG
        NEG()
    elif ir == 12:                                              # INC
        INC()
    elif ir == 13:                                              # DEC
        DEC()
    elif ir == 14:                                              # LDI
        A = LDI()
    elif ir == 15:                                              # ADI
        ADD(LDI())
    elif ir == 16:                                              # SBI
        SUB(LDI())
    elif ir == 17:                                              # CPI
        CMP(LDI())
    elif ir == 18:                                              # ACI
        ADC(LDI())
    elif ir == 19:                                              # SCI
        SBC(LDI())
    elif ir == 20:                                              # JPA
        PC = LDIW()
    elif ir == 21:                                              # LDA
        A = LDA()
    elif ir == 22:                                              # STA
        STA()
    elif ir == 23:                                              # ADA
        ADD(LDA())
    elif ir == 24:                                              # SBA
        SUB(LDA())
    elif ir == 25:                                              # CPA
        CMP(LDA())
    elif ir == 26:                                              # ACA
        ADC(LDA())
    elif ir == 27:                                              # SCA
        SBC(LDA())
    elif ir == 28:                                              # JPR
        PC = LD16(LDIW())
    elif ir == 29:                                              # LDR
        A = LDR()
    elif ir == 30:                                              # STR
        STR()
    elif ir == 31:                                              # ADR
        ADD(LDR())
    elif ir == 32:                                              # SBR
        SUB(LDR())
    elif ir == 33:                                              # CPR
        CMP(LDR())
    elif ir == 34:                                              # ACR
        ADC(LDR())
    elif ir == 35:                                              # SCR
        SBC(LDR())
    elif ir == 36:                                              # CLB
        a = LDIW(); ST8(a, 0)
        N = False; C = True; Z = False
    elif ir == 37:                                              # NEB
        a = LDIW(); A = LD8(a); NEG(); ST8(a, A)
    elif ir == 38:                                              # INB
        a = LDIW(); A = LD8(a); INC(); ST8(a, A)
    elif ir == 39:                                              # DEB
        a = LDIW(); A = LD8(a); DEC(); ST8(a, A)
    elif ir == 40:                                              # ADB
        Asave = A
        a = LDIW(); ADD(LD8(a)); ST8(a, A)
        A = Asave
    elif ir == 41:                                              # SBB
        Asave = A
        a = LDIW(); SUB(LD8(a)); ST8(a, A)
        A = Asave
    elif ir == 42:                                              # ACB
        Asave = A
        a = LDIW(); ADC(LD8(a)); ST8(a, A)
        A = Asave
    elif ir == 43:                                              # SCB
        Asave = A
        a = LDIW(); SBC(LD8(a)); ST8(a, A)
        A = Asave
    elif ir == 44:                                              # CLW
        a = LDIW(); ST16(a, 0)
        N = False; C = True; Z = False
    elif ir == 45:                                              # NEW
        a = LDIW()
        A = 0; SUB(LD8(a)); ST8(a, A)
        A = 0; SBC(LD8(a + 1)); ST8(a + 1, A)
    elif ir == 46:                                              # INW
        a = LDIW()
        A = LD8(a); INC(); ST8(a, A)
        A = LD8(a + 1); ADC(0); ST8(a + 1, A)
    elif ir == 47:                                              # DEW
        a = LDIW()
        A = LD8(a); DEC(); ST8(a, A)
        A = LD8(a + 1); SBC(0); ST8(a + 1, A)
    elif ir == 48:                                              # ADW
        a = LDIW()
        ADD(LD8(a)); ST8(a, A)
        A = LD8(a + 1)
        if C: INC()
        ST8(a + 1, A)
    elif ir == 49:                                              # SBW
        a = LDIW()
        SUB(LD8(a)); ST8(a, A)
        A = LD8(a + 1)
        if not C: DEC()
        ST8(a + 1, A)
    elif ir == 50:                                              # ACW
        a = LDIW()
        ADC(LD8(a)); ST8(a, A)
        A = LD8(a + 1)
        if C: INC()
        ST8(a + 1, A)
    elif ir == 51:                                              # SBW
        a = LDIW()
        SBC(LD8(a)); ST8(a, A)
        A = LD8(a + 1)
        if not C: DEC()
        ST8(a + 1, A)
    elif ir == 52:                                              # LDS
        i = LDI()
        a = (0xFFF0 + LD8(0xFFFF) + i) & 0xFFFF
        A = LD8(a)
    elif ir == 53:                                              # STS
        i = LDI()
        a = (0xFFF0 + LD8(0xFFFF) + i) & 0xFFFF
        ST8(a, A)
    elif ir == 54:                                              # PHS
        sp = LD8(0xFFFF) - 1
        ST8(0xFFF0 + sp, A)
        ST8(0xFFFF, sp)
    elif ir == 55:                                              # PLS
        sp = LD8(0xFFFF)
        A = LD8(0xFFF0 + sp)
        ST8(0xFFFF, sp + 1)
    elif ir == 56:                                              # JPS
        sp = LD8(0xFFFF)
        a = LDIW()
        ST8(0xFF00 + sp, PC >> 8);   sp -= 1
        ST8(0xFF00 + sp, PC & 0xFF); sp -= 1
        ST8(0xFFFF, sp)
        PC = a
    elif ir == 57:                                              # RTS
        sp = LD8(0xFFFF)
        PC = LD16(0xFF00 + sp + 1)
        ST8(0xFFFF, sp + 2)
    elif ir == 58:                                              # BNE
        a = LDIW()
        if Z: PC = a
    elif ir == 59:                                              # BEQ
        a = LDIW()
        if not Z: PC = a
    elif ir == 60:                                              # BCC
        a = LDIW()
        if not C: PC = a
    elif ir == 61:                                              # BCS
        a = LDIW()
        if C: PC = a
    elif ir == 62:                                              # BPL
        a = LDIW()
        if not N: PC = a
    elif ir == 63:                                              # BMI
        a = LDIW()
        if N: PC = a
    else:
        step = True

def dumpWatches():
    if len(watchList):
        print('WPs:', end = ' ')
        for w in watchList:
            print('%04.4X:%04.4X' % (w, LD16(w)), end = ' ')

def dumpBreaks():
    if len(breaks):
        print('BPs:', end = ' ')
        for w in breaks:
            print('%04.4X' % w, end = ' ')

def dr(a, n):
    for i in range(n):
        print('%02.2X' % LD8(a + i), end = ' ')
    print(((5 - n) * 3) * ' ', end = ' ')

def dumpRegs():
    print('IP SP RP UP    ', end = ' ')
    dr(aIP, 2); dr(aSP, 2); dr(aRP, 2); dr(aUP, 2);
    print()
    print('R1 R2 R3 B/T   ', end = ' ')
    dr(aR1, 4); dr(aR2, 4); dr(aR3, 4); dr(aBT, 2);
    print()

def dumpStack():
    print('          FFF0 ', end = '')
    sp = LD8(0xFFFF) + 0xFF00
    for a in range(0xFFF0, 0x10000):
        if a <= sp:
            print('..', end = ' ')
        else:
            print('%02.2X' % LD8(a), end = ' ')
    print()

def dumpHex(addr):
    print('%04.4X ' % addr, end = '')
    for i in range(addr, addr + 16):
        print('%02.2X ' % LD8(i), end = '')
    print()

def showSource():
    cl = None
    for loc in locoLines:
        if loc[0] >= PC:
            lo = loc[0]
            cl = loc[1]
            break
    if cl:
        print(80 * '-')
        for ln in range(cl - 2, cl + 3):
            try:
                print(sourceCode[ln][:-1], end = ' ')
                if ln == cl: print('      <-- PC (%04.4X)' % PC, end = '')
                print()
            except:
                pass

def showFORTH():
    cl = None; prev = (0, 0)
    IP = LD16(aIP)
    for loc in locoLines:
        if loc[0] == IP:
            lo = loc[0]
            cl = loc[1]
            break
        if loc[0] > IP:
            lo = prev[0]
            cl = prev[1]
            break
        prev = loc
    if cl:
        print(80 * '-')
        for ln in range(cl - 2, cl + 3):
            try:
                print(sourceCode[ln][:-1], end = ' ')
                if ln == cl: print('      <-- FORTH IP (%04.4X)' % IP, end = '')
                print()
            except:
                pass

def showFORTHstack(ptrAddr, sZero, name):
    ptr = LD16(ptrAddr)
    print(name, end = ' ')
    if abs(ptr - sZero) < 40 and ptr < sZero:
        wrk = sZero - 2
        while wrk >= ptr:
            print('%04.4X' % LD16(wrk), end = ' ')
            wrk -= 2
    print()

def mainMenu():
    global stopHere, PC, step, stepCnt, watchList, breaks
    prMenu = True
    while True:
        if prMenu:
            print('-------------------------------')
            print('L <fileName>    R <hexAddr>')
            print('D <hexAddr>     C:Continue')
            print('                W <hexAddr>')
            print('X <W|B>         N <steps>')
            print('B <breakpoint>  Q:Quit')
            prMenu = False
        print('min8emu> ', end = ''); sys.stdout.flush()
        try:
            cmd = input().split()
            cc = cmd[0].upper()
            if cc == 'L':
                loadHexFile(cmd[1])
            elif cc == 'R':
                PC = int(cmd[1], 16)
                stepCnt = 0
                print('PC set to %04.4X' % PC)
            elif cc == 'D':
                dumpHex(int(cmd[1], 16))
            elif cc == 'C':
                break
            elif cc == 'W':
                watchList.append(int(cmd[1], 16))
                dumpWatches(); print()
            elif cc == 'X':
                if cmd[1].upper() == 'W':
                    watchList = []
                    print('Watchlist cleared.')
                elif cmd[1].upper() == 'B':
                    breaks = []
                    print('Breakpoints cleared.')
            elif cc == 'N':
                step = int(cmd[1], 0)
                stepCnt = 0
                print('Step counter set to %d' % step)
            elif cc == 'B':
                breaks.append(int(cmd[1], 16))
                dumpBreaks(); print()                
            elif cc == 'Q':
                stopHere = True
                break
        except:
            pass

def sStep():
    global step, IP
    while not stopHere:
        print(80 * '=')
        print('%8d  ' % stepCnt, end = '')
        print('A:%02.2X B:%02.2X PC:%04.4X ' % (A, B, PC), end = '')
        print('N:%d C:%d Z:%d    ' % (N, C, Z), end = '')
        try:
            print('%02.2x(%s) ' % (LD8(PC), mnem[LD8(PC)]), end = '')
        except:
            print('%02.2x(???) ' % LD8(PC), end = '')
        for i in range(PC + 1, PC + 5):
            print('%02.2X ' % LD8(i), end = '')
        dumpWatches()
        dumpBreaks()
        print()
        dumpStack()
        showSource()
        print(80 * '-')
        showFORTHstack(aSP, XSP, 'DS:')
        showFORTHstack(aRP, XRP, 'RS:')
        print(80 * '-')
        dumpRegs()
        showFORTH()
        cc = getch()
        if ord(cc) == 0x1B:
            mainMenu()
        elif ord(cc) == 0x0D:
            break
        elif ord(cc) == 0x20:
            step = -1
            IP = LD16(aIP)
            break
        elif cc == b'?' or cc == b'H' or cc == b'h':
            print('\n<ESC>Menu <CR>Step <BL>FORTH word\n')

# ----------------------------------------------------------------------
# Read flash.bin

try:
    f = open('flash.bin', 'rb')
    while True:
        b = f.read(1)
        if b == b'': break
        eeprom.append(int.from_bytes(b, byteorder = 'big'))
except:
    print('WARNING: Could not read flash.bin')
finally:
    f.close()

print('Memory: RAM:%d, EEPROM:%d\n' % (len(ram), len(eeprom)))

# ----------------------------------------------------------------------
# "MAIN"

while not stopHere:

    # FORTH instruction?
    if IP:
        if abs(LD16(aIP) - IP) > 1:
            step = 0
            IP = 0

    # CPU instruction
    if step == 0: sStep()
    CPU_instruction()

    # Keyboard input
    if UART_in == 0xFF and kbhit():
        ch = getch()
        if ord(ch) == 0x1B:
            mainMenu()
        else:
            UART_in = ord(ch)

    # Screen output
    if UART_out != 0xFF:
        sys.stdout.write(chr(UART_out))
        if UART_out == 0x0D:
            sys.stdout.write(chr(0x0A))
        sys.stdout.flush()
        UART_out = 0xFF
    
    if step: step -= 1

print('min8emu done.')
