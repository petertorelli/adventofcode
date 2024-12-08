#!/usr/bin/env python3
import sys
from itertools import product, zip_longest, chain

def permute(total, numbers, operators):
    n = len(numbers) - 1
    comb = list(product(operators, repeat=n))
    for c in comb:
        expr = chain(*zip_longest(numbers,c))
        expr = [x for x in expr if x is not None]
        acc = expr.pop(0)
        for i in range(len(expr)):
            op, i = expr[i], i + 1
            if op == '+':
                acc += expr[i]
            elif op == '*':
                acc *= expr[i]
            elif op == '||':
                acc = int(f'{acc}{expr[i]}')
        if acc == total:
            return True
    return False

with open(sys.argv[1], 'r') as file:
    acc1, acc2 = 0, 0
    for line in file:
        numbers = line.replace(':', '').split()
        numbers = list(map(int, numbers))
        total = numbers.pop(0)
        if permute(total, numbers, ['+', '*']):
            acc1 += total
        if permute(total, numbers, ['+', '*', '||']):
            acc2 += total
    print("Part 1:", acc1)
    print("Part 2:", acc2)