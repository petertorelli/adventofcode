#!/usr/bin/env python3
import sys

def creep_counts(pattern, towells):
    n = len(pattern)
    accs = [0] * (n + 1)
    accs[0] = 1
    for i in range(1, n + 1):
        for towel in towells:
            m = len(towel)
            if i >= m and pattern[i-m:i] == towel:
                accs[i] += accs[i-m]
    return accs[n]

with open(sys.argv[1]) as file:
    towells = set()
    valid = 0
    acc = 0
    for line in file:
        line = line.strip()
        tokens = line.split(', ') if line != "" else []
        if len(tokens) == 1:
            count = creep_counts(tokens[0], towells)
            if count > 0:
                valid += 1
                acc += count
        elif len(tokens) > 1:
            for towel in tokens:
                towells.add(towel)
    print("Part 1:", valid)
    print("Part 2:", acc)
