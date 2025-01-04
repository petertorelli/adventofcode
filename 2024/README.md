Notes for this year. Doing all Python. Need to learn how to transition from thinking in PERL (after 30 years!) to thinking in Python.

| Day |Comments |
| --- |-------- |
| 1   |Vector math; numpy |
| 2   |More vector math; numpy |
| 3   |Basic regex |
| 4   |More numpy matrix stuff (started with regex but then part2 required a restart) |
| 5   |More array play with a dictionary. Brute force is still viable this early |
| 6   |Started with fancy ray-trace on corners, then tried obstacles in front of each nextpos, but then went with brute force with all possible obstacles on all voids and a set. |
| 7   |Python's combinatorial tools are kinda cheating. |
| 8   |Line walking with dictionaries and combinatorials. |
| 9   |Misread the directions, was coalescing unused space and running multiple passes. Just needed one pass in part 2 and leave unused space as-is. |
| 10  |Deja vu. DFS pathfinding w/dictionary. |
| 11  |Deja vu, again. Cycle time, end of brute-force. *Sniff* |
| 12  |Made a stupid hard algorithm then realized the logic trick. I was counting turns while walking the perimeter, and then looking for containment relationships. Instead, any corner indicates a side, internal or external. No need for relationships between regions.|
| 13  |Learned about Diophantine equations, Bezout, and the Extended Euclidean algorithm. Didn't expect to have to this much research so soon, but after Day 12 things always go sideways. |
| 14  |Huh, visualization was actually required for this one. Most of the time was spent watch the image until I saw a tree. I didn't know what to search for so there was no algorithmic approach, just refining the window and slowing the interval (also used save/restore of positions). |
| 15  |Kinda boring. Recursive 2D collision detection.|
| 16  |Finding all paths in A* with the same score.|
| 17  |Virtual machine, but self-similar code. Found the answer accidentally while looking at bit patterns and cycles. But attempting to recreate my command-line analysis in code is failing due to false positives as the set grows with A. See readme in day17.|
| 18  |Another A* search. That's weird, brute force shouldn't be an option on day 18, but here we are.|
| 19  |Hard. Spent too much time trying to fuse together partion solutions, rather than accumulating the # of solutions that fit at each point in the pattern.|
| 20  |Funny Day 20 was so much easier than Day 19. Actually got the idea from a 3b1b video I saw a few weeks ago about topology.|
