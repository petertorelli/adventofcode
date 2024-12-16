#!/usr/bin/env python3
import sys
import re
import math

# https://en.wikipedia.org/wiki/Diophantine_equation
# https://en.wikipedia.org/wiki/B%C3%A9zout's_identity
# https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm

def decomp(a, b):
    # original brute-force algorithm caught this case!
    if b != 0 and a % b == 0:
        return 0, 1
    if a != 0 and b % a == 0:
        return 1, 0
    quotients = []
    while b != 0:
        q, r = a // b, a % b
        quotients.append(q)
        a, b = b, r
    i = len(quotients) - 2
    ca, cb = 1, -1 * quotients[i]
    while i > 0:
        i -= 1
        ca, cb = cb, ca - cb * quotients[i]
    return ca, cb

def findpresses(ax, ay, bx, by, tx, ty, translate):
    tx += translate
    ty += translate
    # is it diophantine?
    gcdx = math.gcd(ax, bx)
    gcdy = math.gcd(ay, by)
    if (tx % gcdx != 0) or (ty % gcdy != 0):
        return None, None
    # get the bezout coefficients
    ax2, bx2, tx2 = ax // gcdx, bx // gcdx, tx // gcdx
    cax, cbx = decomp(ax2, bx2)
    ax0, bx0 = cax * tx2, cbx * tx2
    ay2, by2, ty2 = ay // gcdy, by // gcdy, ty // gcdy
    cay, cby = decomp(ay2, by2)
    ay0, by0 = cay * ty2, cby * ty2
    # construct the bezout equation forms (x + vt, y - ut)
    # where v = b/d, u = a/d, and d=gcd(a,b)
    # ax(sx) = ax0 + bx2 * sx
    # bx(sx) = bx0 - ax2 * sx
    # ay(sy) = ay0 + by2 * sy
    # by(sy) = by0 - ay2 * sy
    # A's must be same, B's must be same ... Rearranging
    # solve for sx & sy
    # ax0 + bx2 * sx = ay0 + by2 * sy
    # bx0 - ax2 * sx = by0 - ay2 * sy
    # ... or ...
    #   (sx)     (sy)   (total)
    #    bx2    -by2    (ay0 - ax0)
    #   -ax2     ay2    (by0 - bx0)
    (i1, i3) = ( bx2 *  ay2, (ay0 - ax0) *  ay2)
    (j1, j3) = (-ax2 * -by2, (by0 - bx0) * -by2)
    p1 = i1 - j1
    p3 = i3 - j3
    if p3 % p1 == 0:
        sx = p3 // p1
        (i1, i2, i3) = (-ax2 * sx, ay2, by0 - bx0)
        if (i3 - i1) % i2 == 0:
            return ax0 + bx2 * sx, bx0 - ax2 * sx
    return None, None

acc1 = 0
acc2 = 0
with open(sys.argv[1], 'r') as file:
    ax, ay, bx, by, tx, ty = [0] * 6
    for line in file:
        m = re.search(r'Button (.): X([\-\+\d]+), Y([\-\+\d]+)', line)
        if m:
            if m[1] == 'A':
                ax, ay = int(m[2]), int(m[3])
            else:
                bx, by = int(m[2]), int(m[3])
        m = re.search(r'Prize: X=(\d+), Y=(\d+)', line)
        if m:
            tx, ty = int(m[1]), int(m[2])
            p1, p2 = findpresses(ax, ay, bx, by, tx, ty, 0)
            if (p1, p2) != (None, None):
                acc1 += p1 * 3 + p2
            p1, p2 = findpresses(ax, ay, bx, by, tx, ty, 10000000000000)
            if (p1, p2) != (None, None):
                acc2 += p1 * 3 + p2

print("Part 1:", acc1)
print("Part 2:", acc2)
