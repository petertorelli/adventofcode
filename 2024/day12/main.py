#!/usr/bin/env python3
import sys
import numpy as np

NESW = [[-1,0], [0,1], [1,0], [0,-1]]
DIRS = [[i,j] for i in range(-1, 2) for j in range(-1, 2) if i or j]

m = np.genfromtxt(sys.argv[1], dtype='U1', delimiter=1)
rows, cols = np.shape(m)

def validloc(r, c):
    return (r in range(rows)) and (c in range(cols))

def isme(r, c, me):
    return validloc(r, c) and (m[r][c] == me)

def getbedarea(r, c, me, bed, peri):
    bed.add((r, c))
    for d in NESW:
        nr, nc = r + d[0], c + d[1]
        if not validloc(nr, nc) or m[nr, nc] != me:
            peri += 1
        if isme(nr, nc, me):
            if (nr, nc) not in bed:
                peri = getbedarea(nr, nc, me, bed, peri)
    return peri

def countcorners(bed, me):
    res = 0
    for ploc in bed:
        r, c = ploc
        NW, N, NE, W, E, SW, S, SE = [isme(r + i, c + j, me) for i, j in DIRS]
        res += sum([
            # internal corners
            N and W and not NW, 
            N and E and not NE, 
            S and W and not SW, 
            S and E and not SE,
            # external corners
            not (N or W),
            not (N or E),
            not (S or W),
            not (S or E)
        ])
    return res

seen = set()
acc1, acc2 = 0, 0
for r in range(rows):
    for c in range(cols):
        if (r, c) in seen:
            continue
        plant = m[r, c]
        bed = set()
        peri = getbedarea(r, c, plant, bed, 0)
        area = len(bed)
        acc1 += area * peri
        sides = countcorners(bed, plant)
        acc2 += area * sides
        seen |= bed

print("Part 1:", acc1)
print("Part 2:", acc2)