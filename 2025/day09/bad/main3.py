#!/usr/bin/env python3

import sys
import itertools

[N, S, E, W] = [(0, -1), (0, 1), (1, 0), (-1, 0)]
names = { N: "N", S: "S", E: "E", W: "W" }
class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y
    def __repr__(self):
        return f"({self.x},{self.y})"
    def __add__(self, pts):
        return Point(self.x + pts[0], self.y + pts[1])
    def __eq__(self, other):
        if not isinstance(other, Point):
            return NotImplemented
        return self.x == other.x and self.y == other.y
    def __hash__(self):
        return hash((self.x, self.y))

def get_dir(p1, p2):
    if p1.x == p2.x: # vertical
        # visuall, row 0 is on top of the CLI picture
        return [0, 1] if p2.y > p1.y else [0, -1]
    else: # horizontal
        return [1, 0] if p2.x > p1.x else [-1, 0]

def patch_area(p1, p3):
    dx = abs(p3.x - p1.x) + 1
    dy = abs(p3.y - p1.y) + 1
    return dx * dy

import math

def sort_rectangle_points(points):
    # 1. centroid
    cx = sum(p.x for p in points) / 4
    cy = sum(p.y for p in points) / 4

    # 2. sort clockwise around center
    points_sorted = sorted(
        points,
        key=lambda p: math.atan2(cy - p.y, p.x - cx),
        reverse=True
    )

    # 3. find smallest (closest to origin)
    start = min(points_sorted, key=lambda p: p.x*p.x + p.y*p.y)
    start_index = points_sorted.index(start)

    # 4. rotate list
    return points_sorted[start_index:] + points_sorted[:start_index]

#NOPE THIS IS TOO SLOW! CAN'T WALK!

pts = [Point(*map(int, line.split(','))) for line in open(sys.argv[1])]
ptsset = { point: ordinal for ordinal, point in enumerate(pts) }
xs = dict()
ys = dict()
for p in pts:
    if not p.y in ys:
        ys[p.y] = set()
    ys[p.y].add(p)
    if not p.x in xs:
        xs[p.x] = set()
    xs[p.x].add(p)

def get_next_dir(pts, ptsset, j):
    idx = ptsset[p]
    idx += 1
    if idx == len(pts):
        idx = 0
    k = pts[idx]
    #print("    interloper", p, k)
    return get_dir(p, k)
    
areas = dict()

# do we always go ESWN?
for i in range(len(pts) - 1):
    print(pts[i], pts[i+1], names[tuple(get_dir(pts[i], pts[i+1]))])

sys.exit(1)


#### WELP... loks like it gotta look for line intersections

#for combo in [(pts[0], pts[2])]:
for combo in [(pts[64], pts[314])]:
#for combo in itertools.combinations(pts, 2):
    print("NEW COMBO", combo)
    p1, p3 = combo
    p2, p4 = Point(p3.x, p1.y), Point(p1.x, p3.y)
    # Always have L/D/R/U! or E/S/W/N
    points = sort_rectangle_points([p1, p2, p3, p4])
    print("--", points)
    
    bad = False
    [p1, p2, p3, p4] = points
    for j in ys[p1.y]:
        if p1 == j or p2 == j:
            pass # were ok
        else:
            print("First ray", p1, p2, "hits an interloper", j)
            if j.x > p1.x and j.x < p2.x:
                print("- interloper in range")
                if get_next_dir(pts, ptsset, j) != N:
                    print("Abort!")
                    bad = True
                    break

    if bad:
        continue
    
    for j in xs[p2.x]:
        if p2 == j or p3 == j:
            pass # were ok
        else:
            print("Second ray", p2, p3, "hits an interloper", j)
            if j.y > p2.y and j.y < p3.y:
                print("- interloper in range")
                if get_next_dir(pts, ptsset, j) != E:
                    print("Abort!")
                    bad = True
                    break

    if bad:
        continue

    for j in ys[p3.y]:
        if p3 == j or p4 == j:
            pass # were ok
        else:
            print("Third ray", p3, p4, "hits an interloper", j)
            if j.x > p4.x and j.x < p3.x:
                print("- interloper in range")
                if get_next_dir(pts, ptsset, j) != S:
                    print("Abort!")
                    bad = True
                    break

    if bad:
        continue

    for j in xs[p4.x]:
        if p4 == j or p1 == j:
            pass # were ok
        else:
            print("4th ray", p4, p1, "hits an interloper", j)
            if j.y > p1.y and j.y < p4.y:
                print("- interloper in range")
                if get_next_dir(pts, ptsset, j) != W:
                    print("Abort!")
                    bad = True
                    break

    if bad:
        continue

    area = patch_area(*combo)
    areas[area] = combo
    print("PASSED WITH AREA", combo, area)

biggest = sorted(areas, reverse=True)[0]
combo = areas[biggest]
print(biggest, combo, ptsset[combo[0]], ptsset[combo[1]])

# 4657817632 wrong
    

# We are going clockwise around a hull, therefore only the following
# states are valid if our patch is convex!
# ES->SW->WN->NE->ES...
# if we construct a patch and follow its points, and if track that
# path on the edge, these are the only valid 