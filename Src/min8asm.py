#!/usr/bin/python
'''
File: min8asm.py
----------------------------------------------------------------------
m i n 8 a s m

A minimal assembler for the Minimal-CPU.

Date:       2021-03-28
Version:    0.1
Author:     Nils "slowcorners" Kullberg
License:    MIT Open Source Initiative
----------------------------------------------------------------------
'''

import sys

# ----------------------------------------
# Minimal v 2.0 OPCODE definitions

opcodes = {
    'NOP': (0, 0),  'BNK': (1, 0),  'OUT': (2, 0),  'CLC': (3, 0),
    'SEC': (4, 0),  'LSL': (5, 0),  'ROL': (6, 0),  'LSR': (7, 0),
    'ROR': (8, 0),  'ASR': (9, 0),  'INP': (10, 0), 'NEG': (11, 0),
    'INC': (12, 0), 'DEC': (13, 0), 'LDI': (14, 1), 'ADI': (15, 1),
    'SBI': (16, 1), 'CPI': (17, 1), 'ACI': (18, 1), 'SCI': (19, 1),
    'JPA': (20, 2), 'LDA': (21, 2), 'STA': (22, 2), 'ADA': (23, 2),
    'SBA': (24, 2), 'CPA': (25, 2), 'ACA': (26, 2), 'SCA': (27, 2),
    'JPR': (28, 2), 'LDR': (29, 2), 'STR': (30, 2), 'ADR': (31, 2),
    'SBR': (32, 2), 'CPR': (33, 2), 'ACR': (34, 2), 'SCR': (35, 2),
    'CLB': (36, 2), 'NEB': (37, 2), 'INB': (38, 2), 'DEB': (39, 2),
    'ADB': (40, 2), 'SBB': (41, 2), 'ACB': (42, 2), 'SCB': (43, 2),
    'CLW': (44, 2), 'NEW': (45, 2), 'INW': (46, 2), 'DEW': (47, 2),
    'ADW': (48, 2), 'SBW': (49, 2), 'ACW': (50, 2), 'SCW': (51, 2),
    'LDS': (52, 1), 'STS': (53, 1), 'PHS': (54, 0), 'PLS': (55, 0),
    'JPS': (56, 2), 'RTS': (57, 0), 'BNE': (58, 2), 'BEQ': (59, 2),
    'BCC': (60, 2), 'BCS': (61, 2), 'BPL': (62, 2), 'BMI': (63, 2)
}

# ----------------------------------------
# Global Definitions and Variables

WORD = 2
BYTE = 1

symtab = {}
sourceCode = []
loco = 0
objectCode = {}
lineno = -1
listFile = []
symUsed = {}

if len(sys.argv) != 2:
    print('usage: min8asm.py <sourcefile>')
    sys.exit(1)

# ----------------------------------------
# Write error message with source line

def error(txt):
    print('%s on line %d' % (txt, lineno))
    print(sourceCode[lineno])

# ----------------------------------------
# Read source file(s) into sourceCode

def readSource(fn):
    global sourceCode
    f = open(fn, 'r')
    while True:
        line = f.readline()
        if line == '': break
        llist = line.split()
        if len(llist):
            if llist[0] == 'INCLUDE':
                sourceCode.append('')
                sourceCode.append('; ' + line[:-1])
                sourceCode.append('')
                readSource(llist[1])
            else:
                sourceCode.append(line[:-1])
        else:
            sourceCode.append(line[:-1])
    f.close()

# ----------------------------------------
# Deposit various items into objectCode

def db(b):
    global loco, objectCode, listFile
    objectCode[loco] = b
    listFile.append((loco, lineno))
    loco += 1

def dw(w):
    db(w & 0xFF); db((w >> 8) & 0xFF)

def dv(v, size):
    if size == 2: dw(v)
    else: db(v)

def ds(n):
    global loco
    loco += n

# ----------------------------------------
# Symbol Table Operations

def findSym(name, offsFlag, nsb):
    global symtab
    try:
        symDefined = symtab[name][0]
    except:
        symtab[name] = [False]
        symDefined = False
    if symDefined:
        if offsFlag:
            symValue = symtab[name][1] - loco
        else:
            symValue = symtab[name][1]
    else:
        symtab[name].append((loco, offsFlag, nsb))
        symValue = None
    symUsed[name] = True
    return symValue

def defineSym(name, value = loco):
    global symtab, objectCode, symUsed
    symUsed[name] = False
    try:
        resolved = symtab[name][0]
        if resolved:
            error('Symbol %s redefined' % name)
    except:
        symtab[name] = [True, value]
        resolved = True
    if not resolved:
        forwards = symtab[name][1:]
        if len(forwards): symUsed[name] = True
        while len(forwards):
            forward = forwards[0]
            if forward[1]:
                if forward[2] == 'MSB':
                    objectCode[forward[0]] = (value - forward[0]) >> 8
                else:
                    objectCode[forward[0]] = (value - forward[0]) & 0xFF
                if forward[2] == None:
                    objectCode[forward[0] + 1] = (value - forward[0]) >> 8
            else:
                if forward[2] == 'MSB':
                    objectCode[forward[0]] = value >> 8
                else:
                    objectCode[forward[0]] = value & 0xFF
                if forward[2] == None:
                    objectCode[forward[0] + 1] = value >> 8
            forwards = forwards[1:]
        symtab[name] = [True, value]

# ----------------------------------------
# Object Code Operations

def depositValue(txt, size):
    highbit = 0x00
    nsb = None
    neg = False
    if txt[0] == '<':
        nsb = 'LSB'
        txt = txt[1:]
    if txt[0] == '>':
        nsb = 'MSB'
        txt = txt[1:]
    if txt[0] == '^':
        highbit |= 0x80
        txt = txt[1:]
    if txt[0] == '^':
        highbit |= 0x40
        txt = txt[1:]
    if txt[0] == '-':
        neg = True
        txt = txt[1:]
    if txt[0] == "'":
        value = ord(txt[1])
        dv(value | highbit, size)
    # Allow for decimal, hex, octal and binary constants
    elif txt[0:2] == '0x' or txt[0:2] == '0o' or txt[0:2] == '0b' or txt.isnumeric():
        if neg:
            val = int(txt, 0)
            if size == WORD: val = (0x10000 - val) & 0xFFFF
            if size == BYTE: val = (0x100 - val) & 0xFF
            dv(val | highbit, size)
        else:
            dv(int(txt, 0) | highbit, size)
    elif txt[0] == '"':
        txt = txt[1:-1]
        while len(txt):
            dv(ord(txt[0]), 1); txt = txt[1:]
    else:
        offset = False
        if txt[0] == '+':
            offset = True
            txt = txt[1:]
        value = findSym(txt, offset, nsb)
        if value:
            if nsb == 'MSB':
                dv(value >> 8, size)
            elif nsb == 'LSB':
                dv(value & 0xFF, size)
            else:
                dv(value, size)
        else:
            dv(0, size)

def depositValues(llist, size):
    while len(llist):
        depositValue(llist[0], size)
        llist = llist[1:]

def handleOpcode(llist):
    try:
        opcode = opcodes[llist[0]]
    except:
        error('Unknown opcode: %s' % llist[0])
        opcode = (0xFF, 0)
    db(opcode[0])
    llist = llist[1:]
    if opcode[1] == 2:
        depositValue(llist[0], WORD); llist = llist[1:]
    elif opcode[1] == 1:
        depositValue(llist[0], BYTE); llist = llist[1:]
    if opcode[0] != 0xFF and len(llist):
        error("Extra text after instruction")

# ----------------------------------------
# Higher level operations

def parseLine(llist):
    global loco
    # Label
    if llist[0][-1] == ':':
        defineSym(llist[0][:-1], loco)
        llist = llist[1:]
    # Pseudo opcode
    if len(llist) > 1 and llist[1] == 'EQU':
        defineSym(llist[0], int(llist[2], 0))
    elif len(llist):
        if llist[0] == 'ORG':
            loco = int(llist[1], 0)
        elif llist[0] == 'DB':
            depositValues(llist[1:], BYTE)
        elif llist[0] == 'DW':
            depositValues(llist[1:], WORD)
        elif llist[0] == 'DS':
            ds(int(llist[1]))
        else:
    # Opcode
            handleOpcode(llist)

def assemble():
    global lineno
    for line in sourceCode:
        lineno += 1
        llist = line.split()
        try:
            llist = llist[:llist.index(';')]
        except ValueError:
            pass
        if len(llist):
            parseLine(llist)

def checkForErrors():
    heading_ok = False
    for sym in sorted(symtab.items()):
        if not sym[1][0]:
            if not heading_ok:
                print('Undefined symbol(s):')
                heading_ok = True
            print('  %s' % sym[0], end = '')
    if heading_ok:
        print()

def writeOutputfile(outfileName):
    f = open(outfileName, 'w')
    outc = 0
    lastAddr = -2
    for addr in range(65536):
        try:
            dataByte = True
            byte = objectCode[addr]
        except:
            dataByte = False
        if dataByte:
            if addr > lastAddr + 1:
                if outc: f.write('\n')
                f.write('%04.4x' % addr)
                outc = 16
            if outc > 15:
                f.write('\n')
                f.write(':')
                outc = 0
            f.write('%02.2x ' % byte); outc += 1
            lastAddr = addr
    f.write('\n')
    f.close()

def writeListfile(listfileName):
    f = open(listfileName, 'w')
    lineno = 0
    newline = True
    outc = 0
    for listItem in listFile:
        while lineno < listItem[1]:
            f.write((54 - outc) * ' ')
            f.write('%s\n' % sourceCode[lineno])
            lineno += 1
            outc = 0
            newline = True
        if newline:
            f.write('%04.4X ' % listItem[0]); outc += 5
            newline = False
        f.write('%02.2X ' % objectCode[listItem[0]]); outc += 3
        if outc > 52:
            if lineno == listItem[1]:
                f.write((54 - outc) * ' ')
                f.write('%s\n' % sourceCode[lineno])
                lineno += 1
            else:
                f.write('\n')
            outc = 0
            newline = True
    f.write((54 - outc) * ' ')
    f.write('%s\n' % sourceCode[lineno])
    f.close()

# ----------------------------------------
# "MAIN"

readSource(sys.argv[1])
assemble()
checkForErrors()
writeOutputfile(sys.argv[1].split('.')[0] + '.hex')
writeListfile(sys.argv[1].split('.')[0] + '.lst')
'''
print('Symbols defined but not used:')
for key in symUsed.keys():
    if symUsed[key] == False:
        print('%s ' % key, end = '')
'''
print('\n%d lines done.' % len(sourceCode))

# End of file: min8asm.py
# ----------------------------------------------------------------------
