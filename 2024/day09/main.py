#!/usr/bin/env python3
import sys
import numpy as np

m = np.genfromtxt(sys.argv[1], dtype=object, delimiter=1, comments=None)

q = []
# encode blocks
for i in range(len(m)): # create list of blocks as chars
    if i & 1:
        q += ['.'] * int(m[i])
    else:
        q += [str(i//2)] * int(m[i])
# defrag by block
for i in range(len(q)):
    if i >= len(q): # we're popping so end condition changes
        break
    if q[i] == '.':
        while True: # swap the last block and pop until we hit an ID
            q[i] = q[-1]
            q.pop()
            if i == len(q) or q[i] != '.': # ID or went too far...
                break
# Score = sumproduct
print("Part 1:", sum(i * int(x) for i, x in enumerate(q)))

q = []
# encode as tuples
for i in range(len(m)): # create list of tuples of files or free chunks
    if i & 1:
        q.append((-1, int(m[i])))
    else:
        q.append((i//2, int(m[i])))
# defrag by file (right to left)
for fid in range(len(q) >> 1, 0, -1):
    j = len(q) - next(x for x,y in enumerate(reversed(q)) if y[0] == fid) - 1
    k = None
    for l in range(0, j): # find the first place we can stick q[j]
        if q[l][0] < 0 and q[l][1] >= q[j][1]:
            k = l
            break
    if k: # swap, and add a new free chunk if we didn't use it all
        delta = q[k][1] - q[j][1] # compute before changing q[]!
        q[k] = (fid, q[j][1])
        q[j] = (-1, q[j][1])
        if delta > 0:
            q.insert(k + 1, (-1, delta))
# Score = sumproduct of positions, but they're tuples
acc, pos = 0, 0
for e in q:
    for f in range(e[1]):
        if e[0] >= 0:
            acc += pos * e[0]
        pos += 1
print("Part 2:", acc)
