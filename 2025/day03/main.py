#!/usr/bin/env python3

import sys

def calc(bats, n):
    total = ""
    for i in range(0, n):
        # bloopid indices... i swear this year...
        tail = (len(bats) - (n - i)) + 1
        [p, mx] = max(enumerate(bats[ : tail]), key=lambda x: x[1])
        bats = bats[p + 1 : ]
        total += str(mx)
    return int(total)

with open(sys.argv[1], 'r') as file:
    total1 = 0
    total2 = 0
    for line in file:
        line = line.strip()
        bats = [int(x) for x in list(line)]
        total1 += calc(bats, 2)
        total2 += calc(bats, 12)
    print("Part 1:", total1)
    print("Part 2:", total2)
