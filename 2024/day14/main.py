#!/usr/bin/env python3
import sys
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation


# r/c is opposite x/y
PY, PX, VY, VX = range(4)

rid = 0
plan = []

with open(sys.argv[1], 'r') as file:
    for line in file:
        px, py = line.split()[0].split('=')[1].split(',')
        vx, vy = line.split()[1].split('=')[1].split(',')
        plan.append(list(map(int, [px, py, vx, vy])))
        rid += 1


def render(m):
    print('\033[2J')
    rows, cols = np.shape(m)
    for r in range(rows):
        for c in range(cols):
            print('.' if m[r,c] == 0 else 'X', end='')
        print()

wide = 11
tall = 7
if len(plan) > 12:
    wide = 101
    tall = 103
xm = tall // 2
ym = wide // 2

print(plan)
m = np.zeros((tall,wide), dtype=int)
for r in range(len(plan)):
    m[plan[r][PX], plan[r][PY]] += 1
render(m)

for i in range(100000):
    m = np.zeros((tall,wide), dtype=int)
    for r in range(len(plan)):
        plan[r][PX] = (plan[r][PX] + plan[r][VX]) % tall
        plan[r][PY] = (plan[r][PY] + plan[r][VY]) % wide
        m[plan[r][PX], plan[r][PY]] += 1
    render(m)
    input()

q1 = np.sum(m[0:xm,0:ym])
q2 = np.sum(m[0:xm,ym+1:wide])
q3 = np.sum(m[xm+1:tall,0:ym])
q4 = np.sum(m[xm+1:tall,ym+1:wide])
print(np.sum(m[:,xm:xm+1]))
print("Part 1:", q1 * q2 * q3 * q4)

