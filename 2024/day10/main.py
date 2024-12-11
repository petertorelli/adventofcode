#!/usr/bin/env python3
import sys
import numpy as np

def dfs(m, p0, seen, head, scoreboard):
    ts = tuple(p0)
    if ts in seen:
        return
    seen[ts] = 1
    v = m[*p0]
    if v == 9:
        key = ','.join([str(x) for x in [*head, *p0]])
        scoreboard[key] = scoreboard.get(key, 0) + 1
        return
    mr, mc = np.shape(m)
    for d in NESW:
        nr, nc = p0 + d
        if (nr >= 0 and nc >= 0) and (nr < mr and nc < mc):
            nv = m[nr][nc]
            if nv - v == 1:
                dfs(m, [nr, nc], {}, head, scoreboard)

NESW = np.array([[-1,0], [0,1], [1,0], [0,-1]])
m = np.genfromtxt(sys.argv[1], dtype=int, delimiter=1, comments=None)

scoreboard = {}
for head in np.column_stack(np.where(m == 0)):
    dfs(m, head, {}, head, scoreboard)

print("Part 1:", len(scoreboard))
print("Part 2:", sum(c for q,c in scoreboard.items()))