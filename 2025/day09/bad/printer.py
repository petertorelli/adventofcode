#!/usr/bin/env python3

import sys
import itertools
import numpy as np

pts = np.genfromtxt(sys.argv[1], delimiter=',', dtype="int")

x = max(pts[:, 0]) + 1
y = max(pts[:, 1]) + 1

print(x, y)
print(pts)

grid = np.full((x, y), '.')
grid[pts[:, 0], pts[:, 1]] = '#'

grid = np.transpose(grid)

for row in grid:
    print(''.join(row))


