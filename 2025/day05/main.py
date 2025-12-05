#!/usr/bin/env python3

import sys

def merge_ranges(ranges):
    ranges = sorted(ranges, key=lambda r: r[0])

    merged = []
    cur_start, cur_end = ranges[0]

    for start, end in ranges[1:]:
        # eat the next range if it overlaps
        if start <= cur_end + 1:
            cur_end = max(cur_end, end)
        # if not it is its own range, this becomes our new compare
        else:
            merged.append((cur_start, cur_end))
            cur_start, cur_end = start, end

    # if the last range ate everything still need to append it
    merged.append((cur_start, cur_end))

    return sum((end - start + 1) for start, end in merged)

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

    