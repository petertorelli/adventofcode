#!/usr/bin/env python3
import sys
import numpy as np
import operator
from itertools import combinations

def raytrace(m, p1, d, seen, n, func):
    rx, cx = np.shape(m)
    while n > 0:
        pn = func(p1, d)
        if pn[0] >= 0 and pn[1] >= 0 and pn[0] < rx and pn[1] < cx:
            seen.add((pn[0], pn[1]))
        else:
            return
        p1 = pn
        n -= 1

m = np.genfromtxt(sys.argv[1], dtype='U1', delimiter=1, comments=None)
seen1 = set()
seen2 = set()
seen2.update({tuple(x) for x in np.column_stack(np.where(m != '.'))})
for f in np.unique([x for x in m.flatten() if x != '.']):
    for c in combinations(np.column_stack(np.where(m == f)), 2):
        p1, p2 = c
        pd = p1 - p2
        raytrace(m, p1, pd, seen1, 1, operator.add)
        raytrace(m, p2, pd, seen1, 1, operator.sub)
        raytrace(m, p1, pd, seen2, 1000, operator.add)
        raytrace(m, p2, pd, seen2, 1000, operator.sub)

print("Part 1:", len(seen1))
print("Part 2:", len(seen2))