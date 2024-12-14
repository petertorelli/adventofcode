#!/usr/bin/env python3
import sys
import numpy as np

NESW = np.array([[-1,0], [0,1], [1,0], [0,-1]])

def nextpos(m, r1, c1, d1, rx, cx):
    (r2, c2) = (r1, c1) + NESW[d1]
    if r2 < 0 or c2 < 0 or r2 >= rx or c2 >= cx:
        return False, []
    if m[r2, c2] == '#':
        d1 = (d1 + 1) % 4
    else:
        r1, c1 = r2, c2
    return True, [r1, c1, d1]

def loopcheck(m, r1, c1, d1, rx, cx):
    seen = set()
    while True:
        if (r1, c1, d1) in seen:
            return True
        seen.add((r1,c1,d1))
        go, pos = nextpos(m, r1, c1, d1, rx, cx)
        if go == False:
            break
        (r1, c1, d1) = pos

def part1(m, r1, c1, d1, rx, cx):
    seen = set()
    while True:
        seen.add((r1,c1))
        go, pos = nextpos(m, r1, c1, d1, rx, cx)
        if go == False:
            break
        (r1, c1, d1) = pos
    print("Part 1:", len(seen))

def part2(m, r1, c1, d1, rx, cx):
    loops = 0
    for v in np.column_stack(np.where(m == '.')):
        m[*v] = '#'
        if loopcheck(m, r1, c1, d1, rx, cx) is True:
            loops += 1
        m[*v] = '.'
    print("Part 2:", loops)

m = np.genfromtxt(sys.argv[1], dtype='U1', delimiter=1, comments=None)
rx, cx = np.shape(m)
start = np.array(np.where(m == '^')).T
(r1, c1), d1 = start[0], 0
part1(m, r1, c1, d1, rx, cx)
part2(m, r1, c1, d1, rx, cx)