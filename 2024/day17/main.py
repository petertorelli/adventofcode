#!/usr/bin/env python3
import sys
import re
import copy

def combo(operand, state):
    if operand < 4:
        return operand
    elif operand == 4:
        return state['A']
    elif operand == 5:
        return state['B']
    elif operand == 6:
        return state['C']
 
instruction_rom = {
    0: lambda operand, state:
        state.update({'A': state['A'] // (2 ** combo(operand, state)), 'PC': state['PC'] + 2}),
    1: lambda operand, state:
        state.update({'B': state['B'] ^ operand, 'PC': state['PC'] + 2}),
    2: lambda operand, state:
        state.update({'B': combo(operand, state) % 8, 'PC': state['PC'] + 2}),
    3: lambda operand, state:
        (state['A'] == 0 and (state.update({'PC': state['PC'] + 2}) or 1)) or state.update({'PC': operand}),
    4: lambda operand, state:
        state.update({'B': state['B'] ^ state['C'], 'PC': state['PC'] + 2}),
    5: lambda operand, state:
        state['out'].append(combo(operand, state) % 8) or state.update({'PC': state['PC'] + 2}),
    6: lambda operand, state:
        state.update({'B': state['A'] // (2 ** combo(operand, state)), 'PC': state['PC'] + 2}),
    7: lambda operand, state:
        state.update({'C': state['A'] // (2 ** combo(operand, state)), 'PC': state['PC'] + 2}),
}

machine_state = {
    'A': 0,
    'B': 0,
    'C': 0,
    'PC': 0,
    'out': [],
}

with open(sys.argv[1]) as file:
    for line in file:
        m = re.match(r"Register (\S): (\d+)", line)
        if m:
            machine_state[m[1]] = int(m[2])
            continue
        m = re.match(r"Program: (\S+)", line)
        if m:
            program = list(map(int, m[1].split(',')))

def run(prog, state, a = None):
    pc = 0
    if a is not None:
        state['A'] = a
    while pc < len(prog):
        opcode, operand = prog[pc:pc+2]
        instruction_rom[opcode](operand, state)
        pc = state['PC']

temp = copy.deepcopy(machine_state)
run(program, temp)
print("Part 1:", ','.join(map(str, temp['out'])))

intprogram = list(map(int, program))
go = True
got = 0
ngot = 0
shift = 0
while go:
    print("Loop: got=", got, "shift=", shift)
    for i in range(1, 1 << 20):
        a = (i << shift) | got
        #print("a = ", a, bin(a))
        temp = copy.deepcopy(machine_state)
        run(program, temp, a)
        n = len(temp['out'])
        target = intprogram[0:n]
        if target == temp['out']:
            ngot = a
            print(a, target, bin(ngot))
            if n == len(program):
                print("Done")
                go = False
                break
    got = ngot
    shift = got.bit_length()



intprogram = list(map(int, program))
for i in range(8*8*8*8*8*8*8):
    # found this by successively grepping bigger solution starting points
    acc = 0b10011101011111010111010011110000001111
    a = (i << 38) | acc
    temp = copy.deepcopy(machine_state)
    run(program, temp, a)
    if intprogram == temp['out']:
        print("Part 2:", a, temp['out'], bin(a))
        break


sys.exit(1)

# this was an attempt to recreate what I did with grep, but I kept finding
# wrong starting points. I must have just been lucky on the cli?
intprogram = list(map(int, program))
last_good = 0
shifter = 0
r = 8*8*8*8
while True:
    print("Restart", last_good, last_good.bit_length())
    for i in range(r):
        temp = copy.deepcopy(machine_state)
        acc = (i << shifter.bit_length()) | shifter
        run(program, temp, acc)
        n = len(temp['out'])
        target = intprogram[0:n]
        if temp['out'] == target and n < len(program):
            print(acc, temp['out'], bin(acc))
            last_good = acc
    shifter = last_good
    r = r * 8

sys.exit(1)
