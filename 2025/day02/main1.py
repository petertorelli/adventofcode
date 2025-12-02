#!/usr/bin/env python3

import sys

count = 0

def expand(strx, poss, upper):
    mx = int('9' * len(strx))
    for i in range(int(strx), mx + 1):
        qq = f'{i}' * 2
        qqi = int(qq)
        if len(qq) & 1 == 0 and qqi <= upper:
            poss.add(qqi)

def get_poss(x, upper):
    poss = set()
    parts = list(x)
    if len(parts) & 1 == 0:
        half = len(x) // 2
        aa = ''.join(parts[0 : half])
        ab = ''.join(parts[half : len(x)])
        expand(aa, poss, upper)
        expand(ab, poss, upper)
    return poss

def step1(strx, lower, upper, found):
    if (len(strx) & 1) == 1:
        return
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
        a_odd = len(a) & 1
        b_odd = len(b) & 1
        if a_odd and len(a) == len(b):
            print("Both values are odd and the same length, no invalid values")
            continue
        if (len(b) - len(a)) > 1:
            print("Nope!")
            sys.exit()
        step1(a, ia, ib, found)
        step1(b, ia, ib, found)
        for x in found:
            count += int(x)
    print(count)        

        
