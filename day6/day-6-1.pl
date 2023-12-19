#!/usr/bin/env perl

use warnings;
use strict;
use POSIX;

$_ = <>;
my @times = split;
shift @times;

$_ = <>;
my @dists = split;
shift @dists;

print join(",", @times)."\n";
print join(",", @dists)."\n";

my $total = 1;

while (@times) {
    my $tt = shift @times;
    my $dr = shift @dists;

    # Only need one solution
    my $h1 = (($tt * -1) + (sqrt(($tt * $tt) - (4 * -1 * -$dr)))) / (2 * -1);

    # Integer speeds
    $h1 = ceil($h1);
    my $h2 = $tt - $h1;
    print "Hodl Times: [ $h1, $h2 ]\n";

    # Did we win or tie?
    my $d1 = $h1 * ($tt - $h1);
    my $d2 = $h2 * ($tt - $h2);
    print "     D  : $d1 $d2\n";

    if ($d1 == $dr) {
        print "  --------- $h1 tied, fixup:\n";
        ++$h1;
        $d1 = $h1 * ($tt - $h1);
        print "    Int : $h1 $h2\n";
        print "     D  : $d1 $d2\n";
    } 
    if ($d2 == $dr) {
        print "  --------- $h2 tied, fixup:\n";
        --$h2;
        $d2 = $h2 * ($tt - $h2);
        print "    Int : $h1 $h2\n";
        print "     D  : $d1 $d2\n";
    }
    
    # sanity checks
    die "something wrong $h1 > $h2" if ($h1 > $h2);
    die "didn't win" if (($dr > $d1) || ($dr > $d2));
    
    my $num = ($h2 - $h1) + 1;
    print "  Wins this round: $num\n";
    $total *= $num;
}

print "Total : $total\n";

__DATA__

For each time, there is a graph of hold time vs distance

    Total Time = Hold Time + Travel Time
    Travel Time = Total Time - Hold Time

    Speed = Hold Time * 1 mm/ms

    Distance = Speed * Travel Time

    Distance = Hold Time * 1 mm/ms * (Total Time - Hold Time);

Therefore,

    d(Th) = Th * (Tt - Th);
    d(Th) = Th*Tt - Th^2;

The optimial distance is the inflection point; first derivative = 0;

    d' = Tt - 2*Th = 0
    Th = Tt / 2

However, we just need to beat the current record, so what are the bounds of
Th so that d > record. This is upside down parabola with zeros at t=0 and t=Tt,
so it is already bounded.

There are two solutions for d

    (-b +/- sqrt(b^2 - 4ac)) / 2a

    dr = ht * tt - ht ^ 2

or

    -(ht ^ 2) + tt * ht - dr = 0;

    a = -1
    b = tt
    c = -dr

    d1 = (-tt + sqrt(tt ^ 2 - (4 * -1 * -dr))) / (2 * -1)
    d2 = (-tt - sqrt(tt ^ 2 - (4 * -1 * -dr))) / (2 * -1)

    or just d2 = tt - d1

This interval on the integer number line is the solution (w/o ties)

    [d1, d2]

Answer:

    # wins = (d2 - d1) + 1


