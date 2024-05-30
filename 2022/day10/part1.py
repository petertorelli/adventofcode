#!/usr/bin/env python3

import sys
import re

fn = sys.argv[1]

reg = 1
timeline = []

file = open(sys.argv[1])
for line in file:
    parts = re.split(r' ', line, 2)
    timeline.append(reg)
    if parts[0] == 'addx':
        timeline.append(reg)
        reg += int(parts[1])

sum = 0
for i in range(0, 6):
    idx = i * 40 + 20
    sum += timeline[idx - 1] * idx

print(sum)