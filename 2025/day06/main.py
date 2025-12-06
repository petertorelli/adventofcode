#!/usr/bin/env python3
import sys
import numpy as np
import operator
from functools import reduce

part1 = 0
m = np.genfromtxt(sys.argv[1], dtype='str')
# convert operands to actual functions to avoid conditionals
ops, m = m[-1], m[:-1]
ops = list(map(lambda x: operator.add if x == '+' else operator.mul, ops))
m = np.transpose(m)
for k in range(0, len(m)):
    part1 += reduce(ops[k], [int(x) for x in m[k]])
print(part1)

part2 = 0
# such a great function!
m = np.genfromtxt(sys.argv[1], dtype='str', delimiter=1)
m = m[:-1]
m = np.rot90(m)
n = []
for k in range(0, len(m)):
    a = ''.join(m[k]).strip()
    if a.isdigit():
        n.append(int(a))
    # whoops, don't forget end-condition cleanup...
    if (not a.isdigit()) or (k == len(m) - 1):
        op, ops = ops[-1], ops[:-1]
        part2 += reduce(op, n)
        n = []
print(part2)
