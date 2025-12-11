#!/usr/bin/env python3

import sys

m = []
with open(sys.argv[1]) as file:
    for line in file:
        row = list(line.strip())
        m.append(row)

root = (0, m[0].index('S'))
splits = 0
counts = { root: 1 }
current = { root }
for r in range(2, len(m), 2):
    todo = set()
    for node in current:
        rr, rc = node
        ccount = counts[node]
        if m[r][rc] == '^':
            splits += 1
            left, right = (r+2, rc-1), (r+2, rc+1)
            todo.add(left)
            todo.add(right)
            counts[left] = counts.get(left, 0) + ccount
            counts[right] = counts.get(right, 0) + ccount
        else:
            carry = (r+2, rc)
            todo.add(carry)
            counts[carry] = counts.get(carry, 0) + ccount
    current = todo

q = sum([count for (r, c), count in counts.items() if r == len(m)])

print('Part 1:', splits)
print("Part 2:", q)
