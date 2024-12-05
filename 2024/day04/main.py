#!/usr/bin/env python3

import sys
import numpy as np
import re

# hitting issues when diagonal slice goes negative, hence this mess:
def check(m, target, i0, i1, ix, j0, j1, jx):
    n = len(target)
    # Not sure why diagonal checks hate negative numbers?
    if i1 < 0:
        i1 = None
    if j1 < 0:
        j1 = None
    if i0 == i1:
        res = m[i0, j0:j1:jx]
    elif j0 == j1:
        res = m[i0:i1:ix, j0]
    else:
        res = m[i0:i1:ix, j0:j1:jx].diagonal()
    return 1 if len(res) == n and (res == target).all() else 0

def xmas(m, i, j):
    if m[i][j] != 'X':
        return False
    target = ['X', 'M', 'A', 'S']
    n = len(target)
    acc = 0
    acc += check(m, target, i, i-n, -1, j, j  ,  1)
    acc += check(m, target, i, i+n,  1, j, j  ,  1)
    acc += check(m, target, i, i  ,  1, j, j+n,  1)
    acc += check(m, target, i, i  ,  1, j, j-n, -1)
    acc += check(m, target, i, i+n,  1, j, j+n,  1)
    acc += check(m, target, i, i-n, -1, j, j+n,  1)
    acc += check(m, target, i, i+n,  1, j, j-n, -1)
    acc += check(m, target, i, i-n, -1, j, j-n, -1)
    return acc

def masx(m, i, j):
    if m[i][j] != 'A':
        return 0
    target = ['M', 'A', 'S']
    n = len(target)
    acc = 0
    acc += check(m, target, i-1, i-1+n,  1, j-1, j-1+n,  1)
    acc += check(m, target, i+1, i+1-n, -1, j+1, j+1-n, -1)
    acc += check(m, target, i-1, i-1+n,  1, j+1, j+1-n, -1)
    acc += check(m, target, i+1, i+1-n, -1, j-1, j-1+n,  1)
    return 1 if acc == 2 else 0

def looper(m, func):
    # probably a numpy reduce function for this...
    rows, cols = m.shape
    acc = 0
    for i in range(rows):
        for j in range(cols):
            acc += func(m, i, j)
    return acc

a = np.loadtxt(sys.argv[1], dtype=str)
b = np.array(list(map(list, a)))
print("Part 1:", looper(b, xmas))
print("Part 2:", looper(b, masx))
