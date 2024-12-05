#!/usr/bin/env python3

import sys
import re
import numpy as np

def analyze(m, lookup):
    for i in range(m.size):
        if m[i] in lookup:
            r = lookup[m[i]]
            for j in range(m.size):
                if i > j:
                    w = np.where(r == m[j])[0]
                    if w.size > 0:
                        a = m[i]
                        m = np.delete(m, i)
                        m = np.insert(m, j, a)
                        return m
    return np.array([])

with open(sys.argv[1], 'r') as file:
    acc1, acc2 = 0, 0
    lookup = dict()
    for line in file:
        m = re.match(r"(\d+)\|(\d+)", line)
        if m:
            a, b = int(m[1]), int(m[2])
            if a in lookup:
                lookup[a] = np.append(lookup[a], b)
            else:
                lookup[a] = np.array([b])
        m = re.match(r".*,.*", line)
        if m:
            org = np.array(line.split(r','), dtype=int)
            result = analyze(org, lookup)
            if result.size == 0:
                acc1 += org[org.size // 2]
            else:
                org = result
                while 1:
                    result = analyze(org, lookup)
                    if result.size > 0:
                        org = result
                    else:
                        break
                acc2 += org[org.size // 2]
    print("Part 1:", acc1)
    print("Part 2:", acc2)
