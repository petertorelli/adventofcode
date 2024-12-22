#!/usr/bin/env python3
import sys
import re
import numpy as np

def parse_input_file(fn):
    grid, cmds = '', ''
    with open(fn) as file:
        for line in file:
            m = re.match('#', line)
            if m:
                grid += line
            else:
                break
        for line in file:
            cmds += line.strip()
    return np.array([[c for c in r] for r in grid.splitlines()]), list(cmds)

def solve(grid, commands, char):
    NESW = { '^': (-1, 0), '>': (0, 1), 'v': (1,0), '<': (0, -1) }
    for cmd in commands:
        r0, c0 = np.column_stack(np.where(grid == '@'))[0]
        dr, dc = NESW[cmd]
        seen = dict()
        if can_move(grid, r0, c0, dr, dc, seen):
            for m in seen:
                grid[*m] = '.'
            for m in seen:
                grid[m[0] + dr, m[1] + dc] = seen[m]
    return score(grid, char)

def can_move(grid, r0, c0, dr, dc, seen):
    me = grid[r0, c0]
    if me == '#':
        return False
    if me == '.':
        return True
    seen[(r0, c0)] = me
    if me == '@' or me == 'O':
        return can_move(grid, r0 + dr, c0 + dc, dr, dc, seen)
    if me == '[':
        dx, seen[(r0, c0 + 1)] =  1, ']'
    elif me == ']':
        dx, seen[(r0, c0 - 1)] = -1, '['
    if dr == 0: # left/right skip ahead on same row
        return can_move(grid, r0, c0 + 2 * dc, dr, dc, seen)
    else: # up/down has to check self and paired bracket 'dx' away on col.
        a = can_move(grid, r0 + dr, c0 + dc, dr, dc, seen)
        b = can_move(grid, r0 + dr, c0 + dc + dx, dr, dc, seen)
        return a and b

def score(grid, char):
    spots = np.column_stack(np.where(grid == char))
    return sum([r * 100 + c for r, c in spots])

def expand_grid(grid):
    rows, cols = np.shape(grid)
    grid = np.hstack([grid, np.full([rows, cols], '.')])
    for r in range(rows):
        for c in reversed(range(cols)): # reverse to overwrite
            left, right = grid[r, c], grid[r, c]
            if grid[r, c] == '@':
                left, right = '@', '.'
            elif grid[r, c] == 'O':
                left, right = '[', ']'
            grid[r, c * 2 : c * 2 + 2] = [left, right]
    return grid

grid1, commands = parse_input_file(sys.argv[1])
grid2 = expand_grid(grid1)

print("Part 1:", solve(grid1, commands, 'O'))
print("Part 2:", solve(grid2, commands, '['))