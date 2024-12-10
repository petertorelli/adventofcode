#!/usr/bin/env python3
import sys
import numpy as np

m = np.genfromtxt(sys.argv[1], dtype=int, delimiter=1, comments=None)
# Encode
q1, q2 = [], []
for i in range(len(m)): # create list of blocks as chars
    val = -1 if i & 1 else i//2
    q1 += [val] * m[i] # q1 = blocks
    q2.append((val, m[i])) # q2 = tuples (file or free chunk)
# Part 1: defrag by block (left to right)
for i in range(len(q1)):
    if i >= len(q1): # we're popping so end condition changes
        break
    if q1[i] == -1:
        while True: # swap the last block and pop until we hit an ID
            q1[i] = q1[-1]
            q1.pop()
            if i == len(q1) or q1[i] != -1: # ID, or went too far...
                break
# Score = sumproduct
print("Part 1:", sum(i * x for i, x in enumerate(q1)))
# Part 2: defrag by file (right to left)
for fid in range(len(q2) >> 1, 0, -1):
    j = len(q2) - next(x for x,y in enumerate(reversed(q2)) if y[0] == fid) - 1
    k = None
    for l in range(0, j): # find the first place we can stick q[j]
        if q2[l][0] < 0 and q2[l][1] >= q2[j][1]:
            k = l
            break
    if k: # swap, and add a new free chunk if we didn't use it all
        delta = q2[k][1] - q2[j][1] # compute before changing q[]!
        q2[k] = (fid, q2[j][1])
        q2[j] = (-1, q2[j][1])
        if delta > 0:
            q2.insert(k + 1, (-1, delta))
# Score = sumproduct of positions, but they're tuples
acc, pos = 0, 0
for e in q2:
    for f in range(e[1]):
        if e[0] >= 0:
            acc += pos * e[0]
        pos += 1
print("Part 2:", acc)
