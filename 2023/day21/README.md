## Part 1

Took the simple approach and created a set of visited spots seen every 
iteration.

## Part 1 v2

Part 1 didn't work on the part 2 updates to test1.txt.

Found a faster way to count the Os than undefining a set every time the
count changes:

```
Total = 16733044
./part1v2.pl test1.txt  132.70s user 2.97s system 99% cpu 2:16.69 total
```

`part1.pl` didn't finish after 20 minutes.

## Part 2

Yeah, no.

Probably another repetition check. The diamond has no blockers in the cardinal
directions, the edges, and the short diagonals. Unlike the test input. This
is probably a clue since every n=65 or 131 steps we are guaranteed to spill
into another tile. And the number of steps minus 65 is exactly a multiple
of 131.

### Analytic (cheating?)

Maybe we can just sum up all of the visited spots in mega tile of N many
steps.

```
    26,501,365 - 65 / 131 = 202,300 tiles in any direction
    (plus the center tile)
```

But the perimeter is all chopped up. Let's forget about the perimeter for now.
Focus on the full tiles.

In any direction:

```
    Center Tile -> 202,299 tiles -> Fractional tile
```

Looking at just full tiles, we can add up the plus sign in the middle, and
then the wedges that repeat in all four corners of the plus

```
    Center tile : 1
    Arms : 202,299 * 4
    Wedges : sum of 1..N formula where N=202,298 ... times 4
    Total tiles : 81,850,175,401
``` 

That will be the same parity as the the input of (65 + 131) - 1 steps. I used my
brute force part1.pl:

```
    o=7,558
    :
    Total O's = 618,623,625,680,758
```

Well that's the lowerbound. Now we've got a bunch of fractional tiles to add up.

Ugh.

```
    4 cardinal tiles
    A bunch of tiles with a corner missing 
    A bunch of corner tiles (this should be one more tile than above per edge)
```

I guess for every tile with a corner missing there is a matching corner on
the other side, plus one extra (at least according to drawing on graph paper).

Let's add those tiny corners later.

Above where we summed up 1..N for N-2, that was to account for corner-missing
tiles. Which means there are exactly N-1 corner-missing tiles per quadrant.

Paired with their missing corners means we can count fill tiles. If you look
at the results, the corners are exactly one less step than the corner-missing
tiles.

```
    Corner missing tiles + their corner : 202,299 * 4 full tiles
    Adds 6,115,903,368 O's

```

Now there are exactly 4 corner tiles. To find this I subtracted the total
number of Os to the edge + 1 from 7,558.

```
    Corner tile O's. = 7558 - 3929 = 3629 * 4 = 14516
```

Ironcially, 2 x the corner tile O's are what is subracted from the cardinal
tiles.

Cardinal tiles = ...

```
    Full tile * 4 - Corner Tile O's * 2 =
    (7558 * 4) - (3629 * 2) = 22,974 Extra O's 
```

And there's the answer: 618,629,741,621,616

Wrong. Crap.

I just realized the tiles alternate between A=7558 and B=7623 O's depending
on their parity, so I have to figure out which tiles are A and which are B.

Since the total # of steps is odd, the center tile is odd, so we can re-work
the results. After dinner.


### Correct cheating

Thinking about this I had the parities all wrong. The paritiy of the full
tiles is set because the number of steps in the example always reaches the
edges. That is, if we head east from the origin, after we leave the center
tile and reach the far edge of the next tile, that pentagon will always have
dots in the four corners. This sets the parity of the tile to it's west (if
heading east). Following this back we can compute the center tile based on
N = (steps - 65) / 131. If N is even then the center tile is always the same
parity as the cardinal pentagons, and if odd, it is the opposite. This sets
the parity for all the other corner cases: the arms, the wedges, the corners,
and the dog-eared pages. The cardinal pentagons also determine how many steps
each corner and dog-eared page takes. Since the cardinal pentagons cordinate
65 on either axis is always an O, that means the corners have to reach one
above or below 64 with an O. Corners must have an "O" in the innermost corner,
and dog-eared pages must have a dot.

So with all this in mind we can build each piece by setting the starting 
coordinates and using `part1.pl`.

The trick is counting.
```
  Center tile = IF(isodd(N), 7623, 7558) ... x 1
  Cardinal pentagons = 4
  Corners = N x 4
  Dog-eared pages = (N - 1) x 4
  Arm dot parity = FLOOR(N/2) if N > 1, else 0 ... x 4
  Arm O pairty = (N - arm dot parity) if N > 2, else 0 ... x 4
  Wedge Dot Corners = FLOOR((N-2)*(N-2)*0.5) if N > 4, else 0 ... x 4
  Wedge O Corners = (Wedge Dot Corners - ((N-2)*(N-2+1)/2)) if N > 4, else 0 x 4
```

In `part1b.pl` I list out all of the starting points needed to compute these
values to get the answer: 621,289,922,886,149.

## Afterwards

I'd really like to understand how to programmatically derive this. I know
there's a way because that's the entire point of this game. Some kind of 
repeating cycles log that I'm missing.
