#!/usr/bin/env python3

import sys
import itertools

def area(p1, p2):
    dx = abs(p2[0] - p1[0]) + 1
    dy = abs(p2[1] - p1[1]) + 1
    return dx * dy

# Given a list of ordered 1D intervals, add segment (a,b)
def add_interval(intervals, a, b):
    if a > b:
        a,b = b,a
    merged = []
    placed = False
    for i,j in intervals:
        if j < a - 1:
            merged.append((i,j))
        elif i > b + 1:
            if not placed:
                merged.append((a, b))
                placed = True
            merged.append((i,j))
        else:
            a = min(a,i)
            b = max(b,j)
    if not placed:
        merged.append((a,b))
    return merged

# Given a list of ordered 1D intervals, remove segment (a,b)
def remove_interval(intervals, a, b):
    if a > b:
        a,b = b,a
    result = []
    for i, j in intervals:
        if j < a or i > b:
            result.append((i,j))
            continue
        if i < a:
            result.append((i,a))
        if j > b:
            result.append((b,j))
    return result

def are_both_points_in_seg(intervals, i, j):
    if i > j:
        i,j = j,i
    for (a, b) in intervals:
        if i >= a and i <= b and j >=a and j <= b:
            return True
    return False

pts = [tuple(map(int, line.split(','))) for line in open(sys.argv[1])]

areas = { area(*list(c)) for c in itertools.combinations(pts, 2) }
print("Part 1", max(areas))

# create a dictionary of all vertical and horizontal edges (segments), indexed
# by the point pair's correspending x or y (whichever they share)
# we know from analysis that there are ony two points on every horizontal segment
vert = dict()
horz = dict()
for i in range(len(pts)):
    # wrap
    if i == len(pts) - 1:
        p1, p2 = pts[i], pts[0]
    else:
        p1, p2 = pts[i], pts[i+1]
    # store
    if p1[0] == p2[0]:
        x = p1[0]
        vert[x] = (p1[1], p2[1])
    else:
        y = p1[1]
        horz[y] = (p1[0], p2[0])

# Sort the edges and create ordered sets of "slices" (aka valid intervals)
# by adding or subtracting  (order of segment points indicates add or sub)

vsegs = dict()
hsegs = dict()

intervals = []
for h in sorted(horz.keys()):
    (a,b) = horz[h]
    row = h
    if b > a:
        intervals = add_interval(intervals, *horz[h])
    else:
        hsegs[row] = intervals
        intervals = remove_interval(intervals, *horz[h])
        row += 1
    hsegs[row] = intervals

intervals = []
for v in sorted(vert.keys()):
    (a,b) = vert[v]
    col = v
    if a > b:
        intervals = add_interval(intervals, *vert[v])
    else:
        vsegs[col] = intervals
        intervals = remove_interval(intervals, *vert[v])
        col += 1
    vsegs[col] = intervals

areas = set()
for c in itertools.combinations(pts, 2):
    (p1, p3) = sorted(c)
    p2 = (p1[0], p3[1])
    p4 = (p3[0], p1[1])
    if are_both_points_in_seg(vsegs[p1[0]], p1[1], p2[1]) is False:
        continue
    if are_both_points_in_seg(vsegs[p3[0]], p3[1], p4[1]) is False:
        continue
    if are_both_points_in_seg(hsegs[p1[1]], p1[0], p2[0]) is False:
        continue
    if are_both_points_in_seg(hsegs[p3[1]], p3[0], p4[0]) is False:
        continue
    areas.add(area(p1,p3))

print("Part 2", max(areas))
