## Part 1

Ah jeez, another pathfinding challenge.

Without the slopes it finds 12 paths. With the slopes it finds 6.

Attempt #1, basic brute force with DFS and a seen history. Found the answer
in about 2 minutes out of 252 solutions.

## Part 2

Well this is just part one without the test. I can see this will take a while
using brute force, so maybe I can speed it up using a decision graph instead
of rendering every single step. Encode each of the decision as a node and
then compute the number of fixed steps between each decision, then sum those
up using DFS.

Implemented a graph... Running brute-force now... expecting 500+ paths and
each solution takes about 5x as long so I guess I'll check back in 30 minutes.

Huh. Brute force only took 10 minutes and got the right answer after ~1.2e6
solutions. I expected that to take longer. I think if I didn't do it
recursively it would have been faster. 35 nodes = ~1.2M paths.

TODO: Clean up yer code.
