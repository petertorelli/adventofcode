#!/usr/bin/env python3

import sys
import re

with open(sys.argv[1], 'r') as file:
    at = 50
    p1 = 0
    p2 = 0
    for line in file:
        line = line.strip()
        m = re.split(r'^([RL])(\d+)', line)
        inc = 1 if m[1] == 'R' else -1

        qat = at + (inc * int(m[2]))
        qatm = qat % 100
        delta = abs(qat - at)
        sn = delta // 100
        if at != 0 and (qat < 0 or qat > 100):
            sn += 1
        print(line, ": went from", at, "to", qat, "aka", qatm, 'delta', delta, "sn", sn, end="")

        # i got tired twiddling mod bound tests
        snoop = 0
        for i in range(int(m[2])):
            at = (at + inc) % 100
            if at == 0:
                snoop += 1
        print(" -- snoops", snoop)
        p2 += snoop
        if at == 0:
            p1 += 1
    print("p1", p1)
    print("p2", p2)
