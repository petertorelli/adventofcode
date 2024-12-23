#!/usr/bin/env python3
import sys
import numpy as np
from heapq import heappop, heappush

NESW = np.array([[-1,0], [0,1], [1,0], [0,-1]])

def part1(grid):
    spos = np.column_stack(np.where(grid == 'S'))[0]
    start = (*spos, 1) # facing east
    gscore = { start: 0 }
    openset = [(0, start)]
    cost = 0
    while len(openset) > 0:
        cost, state = heappop(openset)
        r, c, d = state
        if grid[r, c] == 'E':
            break
        nr, nc = r + NESW[d][0], c + NESW[d][1]
        if grid[nr, nc] != '#': # Forward
            tentative = cost + 1
            ntup = (nr, nc, d)
            if tentative < gscore.get(ntup, np.inf):
                gscore[ntup] = tentative
                heappush(openset, (tentative, ntup))
        for m in [1, 3]: # Left and Right turns w/o advancing
            nd = (m + d) % 4
            tentative = cost + 1000
            ntup = (r, c, nd)
            if tentative < gscore.get(ntup, np.inf):
                gscore[ntup] = tentative
                heappush(openset, (tentative, ntup))
    return int(cost)

def part2(grid):
    spos = np.column_stack(np.where(grid == 'S'))[0]
    epos = np.column_stack(np.where(grid == 'E'))[0]
    start = (*spos, 1) # facing east
    gscore = { start: 0 }
    openset = [(0, start)]
    cost = 0
    while len(openset) > 0:
        cost, state = heappop(openset)
        r, c, d = state
        #if grid[r, c] == 'E':
        #    break
        nr, nc = r + NESW[d][0], c + NESW[d][1]
        if grid[nr, nc] != '#': # Forward
            tentative = cost + 1
            ntup = (nr, nc, d)
            if tentative < gscore.get(ntup, np.inf):
                gscore[ntup] = tentative
                heappush(openset, (tentative, ntup))
        for m in [1, 3]: # Left and Right turns w/o advancing
            nd = (m + d) % 4
            tentative = cost + 1000
            ntup = (r, c, nd)
            if tentative < gscore.get(ntup, np.inf):
                gscore[ntup] = tentative
                heappush(openset, (tentative, ntup))

    best = min([gscore[(epos[0],epos[1],d)] for d in range(4)])
    todo = []
    for k, v in gscore.items():
        r, c, d = k
        if v == best and r == epos[0] and c == epos[1]:
            todo.append(k)
    seen = set(todo)
    seats = set()

    while len(todo) > 0:
        r, c, d = todo.pop(0)
        seats.add((r,c))
        cost = gscore[(r,c,d)]
        nr, nc = r - NESW[d][0], c - NESW[d][1]
        if grid[nr, nc] != '#': # Forward
            ntup = (nr, nc, d)
            if gscore[ntup] == cost - 1 and ntup not in seen:
                seen.add(ntup)
                todo.append(ntup)
        for m in [1, 3]: # Left and Right turns w/o advancing
            nd = (m + d) % 4
            ntup = (r, c, nd)
            if gscore[ntup] == cost - 1000 and ntup not in seen:
                seen.add(ntup)
                todo.append(ntup)
    
    return len(seats)

grid = np.genfromtxt(sys.argv[1], dtype='U1', delimiter=1, comments=None)

print("Part 1:", part1(grid))
print("Part 2:", part2(grid))