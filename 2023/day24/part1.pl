#!/usr/bin/env perl

use warnings;
use strict;

sub find_intersections {
    my ($lines, $c0, $c1) = @_;

    my @keys = keys %$lines;

    while (@keys) {
        my $l1 = shift @keys;
        foreach my $l2 (@keys) {
            
            my $m1 = $lines->{$l1}{m2d};
            my $m2 = $lines->{$l2}{m2d};
            
            # Parallel?
            if ($m1 == $m2) {
                print "$l1 and $l2 are parallel\n";
            }
            next if $m1 == $m2;

            my $b1 = $lines->{$l1}{b2d};
            my $b2 = $lines->{$l2}{b2d};
            my $x = ($b1 - $b2) / ($m2 - $m1);
            my $y = $m2 * $x +$b2;

            # Is new point behind l1 in time?
            next if $x > $lines->{$l1}{px} && $lines->{$l1}{vx} < 0;
            next if $x < $lines->{$l1}{px} && $lines->{$l1}{vx} > 0;
            next if $y > $lines->{$l1}{py} && $lines->{$l1}{vy} < 0;
            next if $y < $lines->{$l1}{py} && $lines->{$l1}{vy} > 0;

            # Is new point behind l2 in time?
            next if $x > $lines->{$l2}{px} && $lines->{$l2}{vx} < 0;
            next if $x < $lines->{$l2}{px} && $lines->{$l2}{vx} > 0;
            next if $y > $lines->{$l2}{py} && $lines->{$l2}{vy} < 0;
            next if $y < $lines->{$l2}{py} && $lines->{$l2}{vy} > 0;

            # Do the intersect in the region?
            my $inx = ($x >= $c0 && $x <= $c1);
            my $iny = ($y >= $c0 && $y <= $c1);

            if ($inx && $iny) {
                print "$l1 intersects $l2 at $x, $y\n";
            }
        }
    }
}

sub main {
    my %lines;
    while (<>) {
        s/\s//g;
        my ($pos, $vel) = split '@';
        my ($px, $py, $pz) = split ',', $pos;
        my ($vx, $vy, $vz) = split ',', $vel;
        # Assuming they all have non infinite slope in X/Y for part 1.
        my $m2d = $vy / $vx;
        my $b2d = $py - $m2d * $px;
        $lines{"$pos @ $vel"}{px} = $px;
        $lines{"$pos @ $vel"}{py} = $py;
        $lines{"$pos @ $vel"}{pz} = $pz;
        $lines{"$pos @ $vel"}{vx} = $vx;
        $lines{"$pos @ $vel"}{vy} = $vy;
        $lines{"$pos @ $vel"}{vz} = $vz;
        $lines{"$pos @ $vel"}{m2d} = $m2d;
        $lines{"$pos @ $vel"}{b2d} = $b2d;
    }

    # N * (N - 1) mpf;
    &find_intersections(\%lines, 7, 27);
#    &find_intersections(\%lines, 200000000000000, 400000000000000);
}

&main;



