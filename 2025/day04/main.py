#!/usr/bin/env python3
import sys
import numpy as np

def check(m, r, c, rx, cx):
    if (r >= 0 and c >= 0) and (r < rx and c < cx):
        return 1 if (m[r,c] == '@' or m[r,c] == 'x') else 0
    return 0

def tag(m, depth):
    rx, cx = np.shape(m)
    removed = 0
    for d in range(0, depth):
        for r in range(0, rx):
            for c in range(0, cx):
                if m[r, c] == '@' or m[r, c] == 'x':
                    i = 0
                    i += check(m, r-1, c-0, rx, cx)
                    i += check(m, r+1, c-0, rx, cx)
                    i += check(m, r-0, c-1, rx, cx)
                    i += check(m, r-0, c+1, rx, cx)
                    i += check(m, r-1, c-1, rx, cx)
                    i += check(m, r+1, c-1, rx, cx)
                    i += check(m, r+1, c+1, rx, cx)
                    i += check(m, r-1, c+1, rx, cx)
                    if i < 4:
                        m[r,c] = 'x'
        unique, counts = np.unique(m, return_counts=True)
        stuff = dict(zip(unique, counts))
        if 'x' in stuff:
            removed += stuff['x']
            m[m == 'x'] = '.'
        else:
            break
    return removed

m = np.genfromtxt(sys.argv[1], dtype='U1', delimiter=1, comments=None)
print("Part 1:", tag(m, 1))
m = np.genfromtxt(sys.argv[1], dtype='U1', delimiter=1, comments=None)
print("Part 2:", tag(m, 1000))