#!/usr/bin/env python3

import sys
import math

limit = int(sys.argv[2])
jb = [tuple(map(int, line.split(','))) for line in open(sys.argv[1])]

dist = dict()
for i, a in enumerate(jb):
    for b in jb[i+1:]:
        dist[math.dist(a, b)] = (a, b)

# i got hung up on the wording, i thought "already connected" meant
# skip that connection (e.g., don't count it toward total connected)

ckts = {}
cktnum = 0
for d in sorted(dist):
    a, b = dist[d]
    if a in ckts and b in ckts:
        if ckts[a] == ckts[b]:
            pass
        else:
            ca, cb = ckts[a], ckts[b]
            for c in ckts:
                if ckts[c] == cb:
                    ckts[c] = ca
    elif a in ckts:
        ckts[b] = ckts[a]
    elif b in ckts:
        ckts[a] = ckts[b]
    else:
        ckts[a] = cktnum
        ckts[b] = cktnum
        cktnum += 1

    # ... sort | uniq -c
    glist = list(ckts.values())
    gset = set(glist)
    top3 = sorted([glist.count(x) for x in gset], reverse=True)[:3]
    
    if len(ckts) == len(jb) and len(gset) == 1:
        print("Part 2:", a[0] * b[0])
        break

    limit -= 1
    if limit == 0:
        print("Part 1:", top3[0] * top3[1] * top3[2])
