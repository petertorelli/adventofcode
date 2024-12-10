#!/usr/bin/env python3
import sys
import numpy as np

m = np.genfromtxt(sys.argv[1], dtype=object, delimiter=1, comments=None)

q = []
# encode blocks
for i in range(len(m)):
    if i & 1:
        q += ['.'] * int(m[i])
    else:
        q += [str(i//2)] * int(m[i])
# defrag by block
for i in range(len(q)):
    if i >= len(q):
        break
    if q[i] == '.':
        while True:
            q[i] = q[-1]
            q.pop()
            if i == len(q) or q[i] != '.':
                break
# Score = sumproduct
print("Part 1:", sum(i * int(x) for i, x in enumerate(q)))

q = []
# encode as tuples
for i in range(len(m)):
    if i & 1:
        q.append((-1, int(m[i])))
    else:
        q.append((i//2, int(m[i])))
# defrag by file
for i in range(len(q) >> 1, 0, -1):
    j = len(q) - next(x for x,y in enumerate(reversed(q)) if y[0] == i) - 1
    k = None
    for l in range(0, j):
        if q[l][0] < 0 and q[l][1] >= q[j][1]:
            k = l
            break
    if k:
        delta = q[k][1] - q[j][1]
        q[k] = (i, q[j][1])
        q[j] = (-1, q[j][1])
        if delta > 0:
            q.insert(k+1, (-1, delta))
# Score = sumproduct of positions
acc = 0
pos = 0
for e in q:
    for f in range(e[1]):
        if e[0] >= 0:
            acc += pos * e[0]
        pos += 1
print("Part 2:", acc)
