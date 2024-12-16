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

wide = 11
tall = 7
if len(plan) > 12:
    wide = 101
    tall = 103
xm = tall // 2
ym = wide // 2

fig, ax = plt.subplots()
m = np.zeros((tall, wide), dtype=int)
im = ax.imshow(m, animated=True)
plt.colorbar(im)

def dump(r):
    for i in range(len(r)):
        print(f"p={r[i][0]},{r[i][1]} v={r[i][2]},{r[i][3]}")
    sys.exit(1)

f = 0
def update(frame):
    global m, plan, f
    f+=1
    m = np.zeros((tall, wide), dtype=int)
    for r in range(len(plan)):
        plan[r][PX] = (plan[r][PX] + plan[r][VX]) % tall
        plan[r][PY] = (plan[r][PY] + plan[r][VY]) % wide
        m[plan[r][PX], plan[r][PY]] += 1
    im.set_array(m)
    if f % 1000 == 0:
        print("Frames", f)
    if f > (7500 + 500 + 270):
        print(f-1)
        input()
        sys.exit(1)
        #dump(plan)
    return [im]

anim = FuncAnimation(fig, update, frames=100, interval=1, blit=True)
plt.show()
print('frames', f)
q1 = np.sum(m[0:xm,0:ym])
q2 = np.sum(m[0:xm,ym+1:wide])
q3 = np.sum(m[xm+1:tall,0:ym])
q4 = np.sum(m[xm+1:tall,ym+1:wide])
print(np.sum(m[:,xm:xm+1]))
print("Part 1:", q1 * q2 * q3 * q4)
