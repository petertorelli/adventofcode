#!/usr/bin/env python3

import sys
import re

def part1():
    with open(sys.argv[1], 'r') as file:
        acc = 0
        for line in file:
            matches = re.findall(r"mul\((\d{1,3}),(\d{1,3})\)", line)
            for m in matches:
                acc += int(m[0]) * int(m[1])
        print("Part 1:", acc)

def part2():
    with open(sys.argv[1], 'r') as file:
        acc = 0
        skip = False
        for line in file:
            matches = re.findall(r"(mul\((\d{1,3}),(\d{1,3})\)|do\(\)|don't\(\))", line)
            for m in matches:
                if m[0] == 'do()':
                    skip = False
                elif m[0] == 'don\'t()':
                    skip = True
                else:
                    if skip == False:
                        acc += int(m[1]) * int(m[2])
        print("Part 2:", acc)

part1()
part2()
