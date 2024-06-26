## Part 1

Easy but does not bode well for the future.

## Part 2

### First thoughts

Ffffffffuuuuuu.....

### Second thoughts

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

### Third thoughts

If we project everything in to the X/Y plane like in part one, find all
the intersections, and then draw a bounding box around each intersection,
that area should go to zero when looking head-on from the solution.

So now I twist through the Y axis from 0 pi rads, then rotate around the
X axis from 0 pi rads. I start at 0.1 increments and rotate all the points.
Then I project into Z and compute the bounding box of the intersections.

I sort on the lowest area, and then zoom in by 10x. So my next range is

* Rotate around Y in [ theta - epsilon, theta + epsilon ]
* Rotate around X in [ phi - epsilon, phi + epsilon ]
* Pick the lowest area, set theta to new theta, same for phi
* Epsilon = increment
* Increment /= 10
* repeat, until apparenlty I run out of precision...

Looks like I found something but then I ran out of precision because
the next iteration didn't complete:

```
petertorelli@Hipparchus day24 % time ./planewobble.pl input1.txt
area=42689466694521172791605965357056.0000000000 theta=0.840000000000000079936057773011 phi=0.050000000000000009714451465470
area=21929695813511488349891723264.0000000000 theta=0.842000000000000081712414612412 phi=0.043000000000000010436096431476
area=20637619988605634270151573504.0000000000 theta=0.841999999999999970690112149896 phi=0.042800000000000032462921240040
area=61114061108588621395394560.0000000000 theta=0.842019999999999435580377848964 phi=0.042850000000000075528472365249
area=731724945175127250698240.0000000000 theta=0.842017999999999711135956204089 phi=0.042847000000000079467099567410
area=10703343045045903163392.0000000000 theta=0.842017699999999313931198230421 phi=0.042846700000000098595975828175
area=101977677130480484352.0000000000 theta=0.842017740000000070033081556176 phi=0.042846660000000105772421932215
area=643300118422939904.0000000000 theta=0.842017743999999623838448314928 phi=0.042846656000000100938951419494
area=162348517004245.5000000000 theta=0.842017744399999767956899177079 phi=0.042846655900000113481596031306
area=47305756168768.5000000000 theta=0.842017744409999768784302887070 phi=0.042846655900000120420489935213
area=452007779354.2500000000 theta=0.842017744406999613104858326551 phi=0.042846655899000107847740537181
area=754549546.4062500000 theta=0.842017744406699852888209534285 phi=0.042846655899200149220096278668
area=22299363.2812500000 theta=0.842017744406689749858685445361 phi=0.042846655899210134288424001170
area=3530428.6250000000 theta= 0.842017744406688750657963282720 phi=0.042846655899213124951696585185
area=868806.9843750000 theta=  0.842017744406688861680265745235 phi=0.042846655899213097196120969556
```

Hmm... been 25 years since precision was a problem! (Good ol' 3D days.)

I removed the floating point conditionals to avoid precision bounds errors
and replaced them with finite increments, now I don't hit infinte loops, but
the solution bottoms out due to precision:

```
petertorelli@Hipparchus day24 % time ./planewobble2.pl input1.txt
area=42689466694463436644383075598336.0000000000 theta=0.839999999999999968913755310496 phi=0.050000000000000002775557561563
area=21929695813405684544974094336.0000000000 theta=0.841999999999999970690112149896 phi=0.043000000000000003497202527569
area=20637619988654065558331850752.0000000000 theta=0.841999999999999970690112149896 phi=0.042800000000000004707345624411
area=61114061122460987804352512.0000000000 theta=0.842019999999999990691890161543 phi=0.042849999999999999200639422270
area=731724946425926148685824.0000000000 theta=0.842018000000000044202863591636 phi=0.042846999999999996200372720523
area=10703342526381485457408.0000000000 theta=0.842017699999999980065013005515 phi=0.042846699999999994512567269567
area=101977655352377999360.0000000000 theta=0.842017740000000070033081556176 phi=0.042846659999999994750119469700
area=643300628783904768.0000000000 theta=0.842017744000000067927658164990 phi=0.042846655999999989916648956978
area=162287892109103.5625000000 theta=0.842017744400000101023806564626 phi=0.042846655899999988581505760976
area=47307233981224.4531250000 theta=0.842017744410000101851210274617 phi=0.042846655899999988581505760976
area=452441386430.7500000000 theta=0.842017744407000057194068176614 phi=0.042846655898999989886544170758
area=747735485.0000000000 theta=0.842017744406700074932814459316 phi=0.042846655899199989625536488802
area=22443106.3750000000 theta=0.842017744406690082925592832908 phi=0.042846655899209988571652019118
area=3763496.8437500000 theta=0.842017744406688084524148507626 phi=0.042846655899212986173818507041
area=868806.9843750000 theta=0.842017744406688861680265745235 phi=0.042846655899213090257227065649
area=665156.6250000000 theta=0.842017744406688861680265745235 phi=0.042846655899213145768378296907
area=665156.6250000000 theta=0.842017744406688861680265745235 phi=0.042846655899213138829484393000
area=665156.6250000000 theta=0.842017744406688861680265745235 phi=0.042846655899213138829484393000
./planewobble2.pl input1.txt  237.37s user 0.08s system 99% cpu 3:58.11 total
```

IEEE 754 64b is ~16 digits of precision so there ya go...

I guess could use Math::BigFloat...

Or maybe I guess I'll try building some vectors at:

* theta = 0.842017744406688
* phi   = 0.042846655899213

I can make a 3D vector out of this that will be the veclocity, then pick
a point in any one of the lines, and hopefully rounding error will get me
to the right time? Let's see how it goes...

Guess I rotate [0,0,1] -phi around [1,0,0], and then by -theta around [0,1,0]? 

[0,0.7459883726,0.6659589687]

Vel = [-0.0285253849,0.7459883726,0.6653477665] ???

359781776524153, 312705660279075, 236728636905923 @ -44, -125, 18

Pos = [ 359781776524153, 312705660279075, 236728636905923 ] ???

Does it hit this line?

276481733510955, 270867065789660, 273768862611813 @ 35, 20, 33


... Switched to Perl Math::BigFloat with accuracy of 25 and only looked at 5 stones:

petertorelli@Hipparchus day24 % head -5 input1.txt > 5.txt
petertorelli@Hipparchus day24 % ./okfine.pl 5.txt 
3.141592653589793238462643 3.141592653589793238462643
Start
area=74740431415331219293863936.000000000000000000000000000000 theta=0.800000000000000044408920985006 phi=0.100000000000000005551115123126
area=747114019971690680811520.000000000000000000000000000000 theta=0.839999999999999968913755310496 phi=0.070000000000000006661338147751
area=2134299680045671907328.000000000000000000000000000000 theta=0.840999999999999969801933730196 phi=0.064000000000000001332267629550
area=15709797494322452480.000000000000000000000000000000 theta=0.840999999999999969801933730196 phi=0.064299999999999996047606032334
area=23300316136805668.000000000000000000000000000000 theta=0.840990000000000015312195955630 phi=0.064289999999999999924504834325
area=3903917252929731.500000000000000000000000000000 theta=0.840990000000000015312195955630 phi=0.064288999999999998924415933743
area=99378248096823.609375000000000000000000000000 theta=0.840990299999999968427744079236 phi=0.064288899999999996048849482122
area=685794599714.470214843750000000000000000000 theta=0.840990270000000039729570744385 phi=0.064288960000000006100862037783
area=6871196019.653600692749023437500000000000 theta=0.840990267000000013553062672145 phi=0.064288966000000002942726951005
area=72500472.062682121992111206054687500000 theta=0.840990267100000021827099772054 phi=0.064288965500000003205904874903
area=297889.228626540629193186759948730469 theta=0.840990267110000022654503482045 phi=0.064288965439999998241482614958
area=2184.736245897812295879703015089035 theta=0.840990267110000022654503482045 phi=0.064288965443000001265261289518
area=62.852732579608677099258784437552 theta=0.840990267110000022654503482045 phi=0.064288965443299997404302814630
area=0.230727728040974577883304164061 theta=0.840990267110029998676168361271 phi=0.064288965443249995734831259142
area=0.006590955463655039613113384434 theta=0.840990267110028999475446198630 phi=0.064288965443247997333386933860
area=0.000014037225093720360347008050 theta=0.840990267110029443564656048693 phi=0.064288965443247803044357624458
area=0.000001179741193149999940639316 theta=0.840990267110029332542353586177 phi=0.064288965443247816922145432272
area=0.000000007002115370619999644956 theta=0.840990267110029332542353586177 phi=0.064288965443247803044357624458
area=0.000000000052637825999999997371 theta=0.840990267110029332542353586177 phi=0.064288965443247803044357624458

Screw this... i'm fussing with precision which is not the right way, at least
compared to the other 23 problems that all had a neat solution.

### Fourth thoughts

I know that there is a camera vector where if we look down it we see the
area of the bounding box around the intesections is zero in the plane that
is normal to the camera vector at the camera eye.

This will be the line that hits all the hailstones.

Is there a minimum # of hailstones we need to solve this camera orientation?

I'm guessing 3 lines is sufficient to anchor the camera point. I can think
of cases where three isn't enough, but if there is definitely a solution, then
there should be three that lock it down?

Normally there is no solution to the general problem, but since we KNOW there
is a solution can we find some shortcuts in the dataset...?

Let's look through the data...

### Fifth Solution

Ok, done with this camera thing... Let's just play with the vectors and
see if I can convert this into a set of N variables and N equations and then
see if there's a linear equation sol'n in there. THere's like a dozen variables.

...

Looks like we can reduce this because we know there are intersection points
because there IS a solution to the puzzle. So the fact that all the 
equations share the thrown rock values is probably the reduciton.

Writing this out is killing me, we've got Rock & Hailstone's Position XYZ,
Velocity XYZ, and t. We know t and the position of the rock will be the
same for each hailstone when they hit but still so many variables.

Annoying-ass notation:

* HI for the Ith hailstone
* R for the rock
* P for position
* V for velocity
* t for ... t

After half a pad of engineering paper this makes it look easy...

```
RP + t * RV = HIP + t * HIV

t = (RP - HIP) / (HIV - RV)
```
or

```
t = (RPx - HIPx) / (HIVx - RVx)
t = (RPy - HIPy) / (HIVy - RVy)
t = (RPz - HIPz) / (HIVz - RVz)
```

We have a lot of this data, let's take them as pairs...

For X & Y...

```
(RPx - HIPx) / (HIVx - RVx) = (RPy - HIPy) / (HIVy - RVy)

->

(RPx - HIPx) * (HIVy - RVy) = (RPy - HIPy) * (HIVx - RVx)

->

(RPx * HIVy) - (HIPx * HIVy) - (RPx * RVy) + (HIPx * RVy) = 
(RPy * HIVx) - (HIPy * HIVx) - (RPy * RVx) + (HIPy * RVx)
```

Let drag the rock parts to the left since every hailstone collision shares them.


```
  (RPy * RVx) - (RPx * RVy)  <--- call this guy "W"
=
  (RPy * HIVx) - (HIPy * HIVx) + (HIPy * RVx)
- (RPx * HIVy) + (HIPx * HIVy) - (HIPx * RVy)

```

W is a defining property of the rock we are throwing, so it never changes. It
is the same for all hailstones. Whcih means if we replace 'I' with 1 and 2...


```
W
= 
  (RPy * H1Vx) - (H1Py * H1Vx) + (H1Py * RVx)
- (RPx * H1Vy) + (H1Px * H1Vy) - (H1Px * RVy)
=
  (RPy * H2Vx) - (H2Py * H2Vx) + (H2Py * RVx)
- (RPx * H2Vy) + (H2Px * H2Vy) - (H2Px * RVy)

collecting terms to keep track of signs...

  (RPy * H1Vx) - (H1Py * H1Vx) + (H1Py * RVx)
- (RPx * H1Vy) + (H1Px * H1Vy) - (H1Px * RVy)
- (RPy * H2Vx) + (H2Py * H2Vx) - (H2Py * RVx)
+ (RPx * H2Vy) - (H2Px * H2Vy) + (H2Px * RVy)

= 0

```

So by grinding and grinding and grinding and checking and re-checking
eventually you can solve a 4x5 equation and derive RPx, RPy, RVx, RVy by
simply putting this into a gauss-jordan elimination sovler. Since you need
four rows, just take the first five rocks in pairs and run the above equation
through it (edit: I had a bunch of signs wrong but didn't feel like fixing
it, just look at the code...).

Once you've solved for these four variables, there are still two left. This
time you only need two pairs of stones, and the equations are exactly the
same as the manipulation above. Except this time around it is a 2x3 matrix
solving for RPz, RVz.

Really annoyed I didn't start this way first. Not sure why I was so bent
on manipulating a plane and fussing with precision. Probably because 
precision is fascinating.
