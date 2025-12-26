#!/usr/bin/env python3

import sys
import itertools

pts = [tuple(map(int, line.split(','))) for line in open(sys.argv[1])]

# Key = point, vert = its vertical partner, horz = its horz partner
vert = dict()
horz = dict()

# Examine each segment on the hull (pre-ordered)
for i in range(len(pts)):
    
    # Roll over to the starting point at the end
    if i == len(pts) - 1:
        p1, p2 = pts[i], pts[0]
    else:
        p1, p2 = pts[i], pts[i+1]
    
    # I know from analysis that there are only two points on
    # the line defining the segment, so skip the checks.

    # If the x coords are the same, its a vertical segment
    if p1[0] == p2[0]:
        vert[p1] = p2
        vert[p2] = p1
    # ... otherwise it is a horizontal segment
    else:
        horz[p1] = p2
        horz[p2] = p1

# Now make all possible rectangles
combos = itertools.combinations(pts, 2)

# For each pair of points defining a rectangle, we have to construct
# the missing mirror points from the the starting points. If the
# constructed points do not fall within the segment, it fails. Because
# the hull is already defined (e.g., no interior points), we should be
# safe. Let's see...

def houtside(p, lhs, rhs):
    if lhs[0] > rhs[0]:
        lhs, rhs = rhs, lhs
    return True if p[0] > rhs[0] else False

def voutside(p, lhs, rhs):
    if lhs[1] > rhs[1]:
        lhs, rhs = rhs, lhs
    return True if p[1] > rhs[1] else False

def area(p1, p2):
    dx = abs(p2[0] - p1[0]) + 1
    dy = abs(p2[1] - p1[1]) + 1
    return dx * dy

for p1, p3 in combos:
    fail = False
    p2 = (p3[0], p1[1])
    p4 = (p1[0], p3[1])
    hp1, vp1 = horz[p1], vert[p1]
    hp3, vp3 = horz[p3], vert[p3]
    if houtside(p2, p1, hp1) or houtside(p4, p3, hp3):
        fail = True
    if voutside(p2, p3, vp3) or voutside(p4, p1, vp1):
        fail = True
    if fail:
        pass
    else:
        print(p1, p3, area(p1, p3))
    

# Nope. This misses the fact that the mirrored point
# can still be inside the hull. We need to construct the
# longest possible segment for each line.