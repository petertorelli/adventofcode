#!/usr/bin/env python3
import sys
import numpy as np

def walk(m, s, e):
    seen = set()
    distances = []
    steps = 0
    todo = [tuple(s)]
    while todo:
        cur = todo.pop(0)
        if cur in seen:
            continue
        seen.add(cur)
        steps += 1
        distances.append((cur, steps))
        if cur[0] == e[0] and cur[1] == e[1]:
            break
        for dr, dc in [(-1,0), (0,1), (1,0), (0,-1)]:
            nr, nc = cur[0] + dr, cur[1] + dc
            if m[nr, nc] != '#':
                todo.append((nr, nc))
    return distances

def extract_paths(distances, savings, cheatsize):
    n = len(distances)
    total = 0
    for i in range(0, n):
        for j in range(i + 1, n):
            ti, tj = distances[i], distances[j]
            loci, locj = ti[0], tj[0]
            manhat = abs(loci[0] - locj[0]) + abs(loci[1] - locj[1])
            # heh: forgot to subtract cheat steps from total steps!
            dsteps = abs(ti[1] - tj[1]) - manhat
            if dsteps >= savings and manhat <= cheatsize:
                total += 1
    return total

maze = np.genfromtxt(sys.argv[1], dtype='U1', delimiter=1, comments=None)
start = np.column_stack(np.where(maze == 'S'))[0]
end = np.column_stack(np.where(maze == 'E'))[0]

distances = walk(maze, start, end)

print("Part 1:", extract_paths(distances, 100, 2))
print("Part 2:", extract_paths(distances, 100, 20))
