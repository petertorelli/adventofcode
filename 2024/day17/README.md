```
Register A: 22817223
Register B: 0
Register C: 0

Program: 2,4,1,2,7,5,4,5,0,3,1,7,5,5,3,0

0: 2,4
B = A mod 8

2: 1,2
B = B xor 2

4: 7,5
C = A idiv 2 ** B

6: 4,5
B = B xor C

8: 0,3
A = A idiv 8

10: 1,7
B = B xor 7

12: 5,5
out <-- B mod 8

14: 3,0
goto 0 until A = 0

so go backwards, how do you get a 0 as the last digit?

12 ... outputs 0 so B is a multiple of 8

10 ... for B to be a multiple of 8 after xor 7, it must end with 0b111 before

08 ... A is zero this round because we are ending so it has to be > 8

06 ... B xor C, B has to come out with 0b111 so C must end in 0b111 and B must end in 0b000

04 ... A is > 8 and < 0 (otherwise it would have stopped last cycle), hence C must be .. hmmm...

02 ... we know from 06 b has to end in 0b000 so for xor2 to do this B must end with 0b010

00 ... A > 8, so A mod 8 must end in 0b010 so A has to be ... 2?

...
A=2

B = 2 mod 8 = 2
B = 2 xor 2 = 0
C = 2 // pow(2,0) = 2
B = 0 xor 2 = 2
A = A // 8 = 0
B = 2 xor 7 = 5

7 [2] 0b111
15 [2, 4] 0b1111




    0 = B mod 8 means b is a multiple of 8
    B xor 7 means it has 0b111 as the last three bits before this step
    so B before 1,7 is 0b???????111
    B = 0b????????111

    4,5 is B xor C ahhhh shit.
    7,5 -->
    C is A // 2^B but B ends with 0b111...
    A is [8 ** 15, 8 ** 16 - 1] but 2 ** 0b111111 is bigger than max(A) by a lot, so C = 0 if that big
    
    seems like B would only be 0b??111 which is 4 numbers


16 digits, currently at 9
A is divided by 8 every time

Backwards

B mod 8
(B xor 7) mod 8
((B xor C) xor 7) mod 8
((B xor (A / pow(2, B))) xor 7) mod 8
(((B xor 2) xor (A / pow(2, (B xor 2)))) xor 7) mod 8
(
    (
        (
            (A mod 8) xor 2
        ) xor 
            (
                A / pow(2, ((A mod 8) xor 2))
            )
    )
    xor 7
) mod 8


range....
>>> 8 ** 15
35184372088832
>>> 8 ** 16 - 1
281474976710655
>>> (8 ** 16 - 1) - (8 ** 15)
246290604621823


playing on the CLI and noticing similarities in the value if A as more
digits in the sequence are found.

well this is weird... these three #s are the iterative values of A from 1..n
that produced the increaseing string of numbers.... wonder if we can just
work out 8 * 16 triplets?

not really sure what I did here but by re-using the bottom bits when I found a
subset of the program I was able to build the number.

Program:         2, 4, 1, 2, 7, 5, 4, 5, 0, 3, 1, 7, 5, 5, 3, 0

 15375          [2, 4, 1, 2, 7]                                                                    0b11110000001111
 80911          [2, 4, 1, 2, 7, 5]                                                              0b10011110000001111
343055          [2, 4, 1, 2, 7, 5, 4]                                                         0b1010011110000001111
... when trying to do this w/code i get false starts ... ???
       89144335 [2, 4, 1, 2, 7, 5, 4, 5, 0]                                           0b101010100000011110000001111 ??? wrong?
      894516239 [2, 4, 1, 2, 7, 5, 4, 5, 0, 3]                                     0b110101010100010011110000001111 ??? wrong?
   169103670287 [2, 4, 1, 2, 7, 5, 4, 5, 0, 3, 1, 7, 5]                    0b10011101011111010111010011110000001111
 27656894364687 [2, 4, 1, 2, 7, 5, 4, 5, 0, 3, 1, 7, 5, 5, 3]       0b110010010011101011111010111010011110000001111 ??? wrong?
190384615275535 [2, 4, 1, 2, 7, 5, 4, 5, 0, 3, 1, 7, 5, 5, 3, 0] 0b101011010010011101011111010111010011110000001111
```
