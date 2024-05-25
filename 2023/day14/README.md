# Notes

Brute force was feeling REALLY slow in PERL. In fact, just reading each
element in the array, nothing else, was taking too long.

Tried to build a tree of the Os to see what things were like from their
perspective, maybe just by computing the O freedoms it would be faster, but
every tilt requires a sort, which is costly.


Switch to C, and GCC -O2 on a macbook pro M1 doing nothing but a test and
increment takes 8.08 seconds to do 10,000,000 iterations, or 800 sec for 1e9.
And that's with very little math going on, and linear access to each row.

Somethings up.

Started looking at the north weight after each title cycle of four and noticed
repeats. Created a serialized lookup of seen patterns and discovered they
start to repeat. Which means we can just do a mod lookup rather than do
one billion iterations.

Sneaky. Very sneaky.


## Test Data Cycle
```
Cycle 1 was NOT seen -- score = 87
Cycle 2 was NOT seen -- score = 69
Cycle 3 was NOT seen -- score = 69
Cycle 4 was NOT seen -- score = 69
Cycle 5 was NOT seen -- score = 65
Cycle 6 was NOT seen -- score = 64
Cycle 7 was NOT seen -- score = 65
Cycle 8 was NOT seen -- score = 63
Cycle 9 was NOT seen -- score = 68
Cycle 10 was NOT seen -- score = 69
Cycle 11 was seen before at cycle 4 -- score = 69
Cycle 12 was seen before at cycle 5 -- score = 65
Cycle 13 was seen before at cycle 6 -- score = 64
Cycle 14 was seen before at cycle 7 -- score = 65
Cycle 15 was seen before at cycle 8 -- score = 63
Cycle 16 was seen before at cycle 9 -- score = 68
Cycle 17 was seen before at cycle 10 -- score = 69
Cycle 18 was seen before at cycle 4 -- score = 69
Cycle 19 was seen before at cycle 5 -- score = 65


4 + ((N - 11) % 7) = lookup for test
N=1e9 --> 6 --> 64
```
## Input Data Cycle
```
Cycle 1 was NOT seen -- score = 97447
Cycle 2 was NOT seen -- score = 97467
:
:
Cycle 110 was NOT seen -- score = 91270
Cycle 111 was NOT seen -- score = 91278
Cycle 112 was NOT seen -- score = 91295
Cycle 113 was NOT seen -- score = 91317
Cycle 114 was NOT seen -- score = 91333
Cycle 115 was NOT seen -- score = 91332
Cycle 116 was NOT seen -- score = 91320
Cycle 117 was NOT seen -- score = 91306
Cycle 118 was NOT seen -- score = 91286
Cycle 119 was NOT seen -- score = 91270
Cycle 120 was seen before at cycle 111 -- score = 91278
Cycle 121 was seen before at cycle 112 -- score = 91295
Cycle 122 was seen before at cycle 113 -- score = 91317
Cycle 123 was seen before at cycle 114 -- score = 91333
Cycle 124 was seen before at cycle 115 -- score = 91332
Cycle 125 was seen before at cycle 116 -- score = 91320
Cycle 126 was seen before at cycle 117 -- score = 91306
Cycle 127 was seen before at cycle 118 -- score = 91286
Cycle 128 was seen before at cycle 119 -- score = 91270
Cycle 129 was seen before at cycle 111 -- score = 91278
Cycle 130 was seen before at cycle 112 -- score = 91295
Cycle 131 was seen before at cycle 113 -- score = 91317
Cycle 132 was seen before at cycle 114 -- score = 91333
Cycle 133 was seen before at cycle 115 -- score = 91332
Cycle 134 was seen before at cycle 116 -- score = 91320

111 + ((N - 120) % 9) = Lookup

N=1,000,000,000 --> 118
```



