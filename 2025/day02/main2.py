#!/usr/bin/env python3

import sys

count = 0

def expand(strx, poss, repeat, upper):
    mx = int('9' * len(strx))
    for i in range(int(strx), mx + 1):
        qq = f'{i}' * repeat
        qqi = int(qq)
        if qqi <= upper:
            poss.add(qqi)

def get_poss(x, upper):
    poss = set()
    parts = list(x)
    # compute all integer fractions from 1 ... len(n)
    for q in range(1, len(parts)):
        if len(parts) % q == 0:
            repeat = len(parts) // q
            for qq in range(1, repeat + 1):
                lhs = (qq - 1) * q
                rhs = qq * q
                expand(''.join(parts[lhs : rhs]), poss, repeat, upper)
    return poss

def step1(strx, lower, upper, found):
    posses = get_poss(strx, upper)
    for poss in posses:
        if poss >= lower and poss <= upper:
            found.add(poss)

with open(sys.argv[1], 'r') as file:
    line = file.readline().strip()
    entries = line.split(',')
    for entry in entries:
        found = set()
        print("----------Entry", entry)
        (a, b) = entry.split('-')
        ia = int(a)
        ib = int(b)
        if (len(b) - len(a)) > 1:
            print("Nope!")
            sys.exit()
        step1(a, ia, ib, found)
        step1(b, ia, ib, found)
        for x in found:
            count += int(x)
    print(count)
