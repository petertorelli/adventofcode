#!/usr/bin/env perl

use warnings;
use strict;

my $SCALE = -1e13;

while (<>) {
    s/\s//g;
    my ($pos, $vel) = split '@';
    my ($px, $py, $pz) = split ',', $pos;
    my ($vx, $vy, $vz) = split ',', $vel;
    $px = $px - $vx * $SCALE;
    $py = $py - $vy * $SCALE;
    $pz = $pz - $vz * $SCALE;

    print "$px, $py, $pz @ $vx, $vy, $vz\n";

}