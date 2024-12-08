#!/usr/bin/env python3
import sys
import numpy as np

input = np.loadtxt(sys.argv[1], dtype=int)

a, b = input[:, 0], input[:, 1]
print("Part 1:", sum(np.absolute(np.sort(a) - np.sort(b))))

dictb = dict(zip(*np.unique(b, return_counts=True)))
print("Part 2:", sum([i * dictb.get(i,0) for i in a ]))