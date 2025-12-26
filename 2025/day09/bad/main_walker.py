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


#NOPE THIS IS TOO SLOW! CAN'T WALK!

pts = [Point(*map(int, line.split(','))) for line in open(sys.argv[1])]
ptsset = { point: ordinal for ordinal, point in enumerate(pts) }
print(ptsset)
combos = itertools.combinations(pts, 2)
for combo in combos:
    print("NEW COMBO", combo)
    p1, p3 = combo
    p2, p4 = Point(p3.x, p1.y), Point(p1.x, p3.y)
    #print("-- BOX", p1,p2,p3,p4)


    corners = [p1, p2, p3, p4, p1]
    direction = get_dir(p1, p2)
    start = corners[0]
    cursor = corners.pop(0)
    stop = corners[0]
    last_dir = None
    while True:
        #print(cursor, "heading to", stop)
        if cursor == stop:
            #print("Hit a corner,", corner, len(corners), "left")
            if len(corners) > 1:
                #print("\tTurning")
                start = corners[0]
                cursor = corners.pop(0)
                stop = corners[0]
                last_dir = direction
                direction = get_dir(cursor, stop)
                #print("new", cursor, corner, direction, corners)
                continue
            elif len(corners) > 0:
                #print("Closed the box")
                break
        elif cursor in ptsset and cursor != start:
            #print("Current location is another corner not in our box", last_dir, direction)
            idx = ptsset[cursor]
            branch_pt = pts[idx]
            idx += 1
            if idx == len(pts):
                idx = 0
            next_pt = pts[idx]
            branch_dir = get_dir(branch_pt, next_pt)
            #print("--- branch go", names.get(tuple(branch_dir)), branch_pt, next_pt, branch_dir)
        cursor += direction


    

# We are going clockwise around a hull, therefore only the following
# states are valid if our patch is convex!
# ES->SW->WN->NE->ES...
# if we construct a patch and follow its points, and if track that
# path on the edge, these are the only valid 