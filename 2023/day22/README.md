## Part 1

Got the test case working in about 20 minutes, but took 2 hrs to build a
renderer to debug why the input wasn't working.

Was just a small bug in how `$disintigrate` flag was set (needed to clear it
rather than set it; reverse logic!).

Found it by using an online `Babylon.JS` viewer. See `writebabs` code.

This viewer worked ok with lots of awkward cutting and pasting. Need to
alter the upperRadiusLimit of the camera to 1000+ to zoom out all the way
though. By coloring the bricks I was lucky to identify a problem in the first
15 rows and zeroed in on the bad brick, which led to the conditional bug
discovery. Clunky, but it worked.

https://playground.babylonjs.com/#SRZRWV#1917

## Part 2

Really easy: Just save/restore the main structures, remove a brick, and run
the relaxation function.

