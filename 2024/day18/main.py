#!/usr/bin/env python3
import sys
from heapq import heappush, heappop

NESW = [(-1,0), (0,1), (1,0), (0,-1)]

def astar(m):
    global NESW, maxr, maxc
    start = (0,0)
    gscore = { start: 0 }
    openset = [(0, start)]
    cost = None
    success = False
    while openset:
        cost, state = heappop(openset)
        r, c = state
        if r == maxr and c == maxc:
            success = True
            break
        for dr, dc in NESW:
            nr, nc = r + dr, c + dc
            if nr < 0 or nc < 0 or nr > maxr or nc > maxc:
                continue
            if m[nr][nc] != '#':
                tentative = cost + 1
                ntup = (nr, nc)
                if tentative < gscore.get(ntup, float('inf')):
                    gscore[ntup] = tentative
                    heappush(openset, (tentative, ntup))
    return success, cost

fn = sys.argv[1]
limit = int(sys.argv[2])

maxr, maxc = 0, 0
events = []
with open(fn) as file:
    for line in file:
        coords = list(map(int, line.strip().split(',')))
        maxr, maxc = max(maxr, coords[1]), max(maxr, coords[0])
        events.append(tuple(reversed(coords)))

grid = [['.'] * (maxc + 1) for _ in range((maxr + 1))]

for i in range(limit):
    r, c = events[i]
    grid[r][c] = '#'

success, cost = astar(grid)
print("Part 1:", cost)

# brute force?!?! on day18?!?!
for i in range(limit, len(events)):
    r, c = events[i]
    grid[r][c] = '#'
    success, cost = astar(grid)
    if success == False:
        print(f"Part 2: %d,%d" % (c, r)) # coords are X,Y in input!
        break
