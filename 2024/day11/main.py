#!/usr/bin/env python3
import sys

def decompose(number, seen, blinks):
    key = tuple([number, blinks]) # need to cache the level as well
    if key in seen:
        return seen[key]
    else:
        if blinks <= 0:
            return 1
        ns = str(number)
        n = len(ns)
        count = 0
        if number == 0:
            count += decompose(1, seen, blinks - 1)
        elif n & 1 == 0:
            chips = list(ns)
            left = ''.join(chips[0:n//2])
            right = ''.join(chips[n//2:])
            count += decompose(int(left), seen, blinks - 1)
            count += decompose(int(right), seen, blinks - 1)
        else:
            count += decompose(number * 2024, seen, blinks - 1)
        seen[key] = count
    return count

with open(sys.argv[1], 'r') as file:
    seen = {}
    for line in file:
        stones = [int(x) for x in line.split()]
        print("Part 1:", sum(decompose(stone, seen, 25) for stone in stones))
        print("Part 2:", sum(decompose(stone, seen, 75) for stone in stones))