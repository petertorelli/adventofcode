## Part 1

Easy but does not bode well for the future.

## Part 2

Ffffffffuuuuuu.....

Since there IS a solution, and 1000 lines, it feels like there should be a
minimum number of lines that intersect to define the unqiue trajectory. E.g.,
if there's only one hailstone, there's an infinite # of trajectories. If there
are two hailstones, again, an infinite number, but those are bounded by the
fact they have to pass through two lines. But with three hailstones, is there
just one solution? And aren't we working in a field, rather than a continuous
space? E.g. Each line is a number of integral multiples of the velocity
vector, does this make it easier?

What is the closet point between every pair of lines?

None of this worked, but thinking about it, we should be able to orient all
of the rendered lines so that the all coincide at one point. This point
would be like staring down the solution line that hits all the trajectories.

If we project everything in to the X/Y plane like in part one, find all
the intersections, and then draw a bounding box around each intersection,
that area should go to zero when looking head-on from the solution.

Try wobbling around the x and y axis and find a theta in x and y rotation
that minimizes the projected area of the bounding box.

This works! But now how do I reconstruct the line at the two thetas when
the area goes to zero? and how do I quantize these coordinates to integers?

Oh crap, I forgot about commuitivity of matrices, I need a quaternion.

To be continued...
