#!/usr/bin/env python3
import sys
import numpy as np

DIR4 = [[-1,0], [0,1], [1,0], [0,-1]]
DIR8 = [[i,j] for i in range(-1, 2) for j in range(-1, 2) if i or j]
GARDEN = np.genfromtxt(sys.argv[1], dtype='U1', delimiter=1)
ROWS, COLS = np.shape(GARDEN)

def validloc(r, c):
    return (r in range(ROWS)) and (c in range(COLS))

def isme(r, c, me):
    return validloc(r, c) and (GARDEN[r][c] == me)

def getbedmetrics(r, c, me, bed, peri):
    bed.add((r, c))
    for d in DIR4:
        nr, nc = r + d[0], c + d[1]
        if isme(nr, nc, me):
            if (nr, nc) not in bed:
                peri = getbedmetrics(nr, nc, me, bed, peri)
        else:
            peri += 1
    return peri

def countcorners(bed, me):
    res = 0
    for ploc in bed:
        r, c = ploc
        nw, n, ne, w, e, sw, s, se = [isme(r + i, c + j, me) for i, j in DIR8]
        res += sum([
            # internal corners
            n and w and not nw,
            n and e and not ne,
            s and w and not sw,
            s and e and not se,
            # external corners
            not (n or w),
            not (n or e),
            not (s or w),
            not (s or e)
        ])
    return res

seen = set()
acc1, acc2 = 0, 0
for r in range(ROWS):
    for c in range(COLS):
        if (r, c) in seen:
            continue
        plant = GARDEN[r, c]
        bed = set()
        peri = getbedmetrics(r, c, plant, bed, 0)
        area = len(bed)
        acc1 += area * peri
        sides = countcorners(bed, plant)
        acc2 += area * sides
        seen |= bed

print("Part 1:", acc1)
print("Part 2:", acc2)