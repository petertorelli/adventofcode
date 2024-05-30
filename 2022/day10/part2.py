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

for s in range(0, 240):
    p = s % 40
    if (p >= (timeline[s] - 1)) and (p <= (timeline[s] + 1)):
        print('#', end="")
    else:
        print('.', end="")
    if (s + 1) % 40 == 0:
        print("")
