#!/usr/bin/env python3

import sys
import numpy as np

def evaluate_report_p1(a):
    test1 = (a == np.sort(a)).all()
    test2 = (a == np.flip(np.sort(a))).all()
    if test1 == False and test2 == False:
        return False
    diff = np.absolute(np.diff(a))
    test = np.where((diff >= 1) & (diff <= 3))
    if len(test[0]) != len(diff):
        return False
    return True

def evaluate_report_p2(a):
    if evaluate_report_p1(a) == True:
        return True
    for i in range(0, len(a)):
        b = np.delete(a, i)
        if evaluate_report_p1(b) == True:
            return True
    return False

with open(sys.argv[1], 'r') as file:
    count1 = 0
    count2 = 0
    for line in file:
        a = np.array(line.split(), dtype=int)
        if evaluate_report_p1(a) == True:
            count1 += 1
        if evaluate_report_p2(a) == True:
            count2 += 1
    print("Part 1:", count1)
    print("Part 2:", count2)