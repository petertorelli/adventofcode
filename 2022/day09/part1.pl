#!/usr/bin/env perl

use warnings;
use strict;

my %dirs = (
    'U' => [  0,  1 ],
    'D' => [  0, -1 ],
    'R' => [  1,  0 ],
    'L' => [ -1,  0 ]
);

my ($hx, $hy) = (0, 0);
my ($tx, $ty) = (0, 0);
my ($dx, $dy);

my %visited;

while (<>) {
    last unless m/^([UDLR]) (\d+)/;
    for (1 .. $2) {
        $hx += @{$dirs{$1}}[0];
        $hy += @{$dirs{$1}}[1];
        ($dx, $dy) = ($hx - $tx, $hy - $ty);
        if (abs($dx) > 1 || abs($dy) > 1) {
            if ($hy == $ty) {
                $tx += $dx > 0 ? 1 : -1;
            } elsif ($hx == $tx) {
                $ty += $dy > 0 ? 1 : -1;
            } else {
                if (abs($dx) > 1) {
                    $ty = $hy;
                    $tx += $dx > 0 ? 1 : -1;
                } else {
                    $tx = $hx;
                    $ty += $dy > 0 ? 1 : -1;
                }
            }
        }
        $visited{"$tx,$ty"} = 1;
    }
}

print scalar keys %visited, "\n";
