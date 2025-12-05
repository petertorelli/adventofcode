#!/usr/bin/env python3

import sys

def merge_ranges(r1):
    while True:
        start = len(r1)
        r2 = []
        while len(r1) > 0:
            r = r1.pop(0)
            if len(r2) == 0:
                r2.append(r)
            else:
                merged = False
                for ri in r2:
                    if r[0] >= ri[0] and r[1] <= ri[1]:
                        merged = True
                    elif r[0] <= ri[0] and r[1] >= ri[1]:
                        ri[0] = r[0]
                        ri[1] = r[1]
                        merged = True
                    elif r[0] <= ri[0] and r[1] >= ri[0] and r[1] <= ri[1]:
                        ri[0] = r[0]
                        merged = True
                    elif r[1] >= ri[1] and r[0] <= ri[1] and r[0] >= ri[0]:
                        ri[1] = r[1]
                        merged = True
                    if merged:
                        break
                if merged is False:
                    r2.append(r)
        r1 = r2
        if start == len(r2):
            break
    c = 0
    for r in r1:
        c += (r[1] - r[0]) + 1
    return c

with open(sys.argv[1], 'r') as file:
    ranges = []
    for line in file:
        parts = line.strip().split('-')
        if len(parts) == 2:
            ranges.append([int(x) for x in parts])
        else:
            break
    c1 = 0
    for line in file:
        v = int(line)
        for parts in ranges:
            if v >= parts[0] and v <= parts[1]:
                c1 += 1
                break
    print("Part 1:", c1)
    print("Part 2:", merge_ranges(ranges))

    