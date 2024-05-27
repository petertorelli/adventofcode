#!/usr/bin/env perl

use warnings;
use strict;

use constant X => 0;
use constant Y => 1;

my %dirs = (
    'U' => [  0,  1 ],
    'D' => [  0, -1 ],
    'R' => [  1,  0 ],
    'L' => [ -1,  0 ]
);

my ($dx, $dy);

my %visited;
my @snake = (
    [0,0], # head
    [0,0],
    [0,0],
    [0,0],
    [0,0],
    [0,0],
    [0,0],
    [0,0],
    [0,0],
    [0,0],
);

sub printx {
    foreach my $py (-80 ... 80) {
        my $y =  - $py;
        foreach my $x (-80 ... 80) {
            my $c = '.';
            foreach my $z (1 ... 9) {
                my $g = (9 - ($z - 1));
                if ($snake[$g][X] == $x && $snake[$g][Y] == $y) {
                    $c = $g;
                }
            }
            if ($snake[0][X] == $x && $snake[0][Y] == $y) {
                $c = 'H';
            }
            if ($c eq '.') {
                if (defined $visited{"$x,$y"}) {
                    print '#';
                } else {
                    print '.';
                }
            } else {
                print $c;
            }
        }
        print "\n";
    }
    print "\n";
}

while (<>) {
    last unless m/^([UDLR]) (\d+)/;
    for (1 .. $2) {
        $snake[0][X] += @{$dirs{$1}}[X];
        $snake[0][Y] += @{$dirs{$1}}[Y];
        for my $seg (1 .. 9) {
            my ($hx, $hy) = @{$snake[$seg - 1]};
            my ($tx, $ty) = @{$snake[$seg]};
            ($dx, $dy) = ($hx - $tx, $hy - $ty);
            if (abs($dx) > 1 || abs($dy) > 1) {
                if ($hy == $ty) {
                    $tx += $dx > 0 ? 1 : -1;
                } elsif ($hx == $tx) {
                    $ty += $dy > 0 ? 1 : -1;
                } else {
                    if (abs($dx) > 1 && abs($dy) > 1) {
                        # new case!
                        $tx += $dx > 0 ? 1 : -1;
                        $ty += $dy > 0 ? 1 : -1;
                    } elsif (abs($dx) > 1) {
                        $ty = $hy;
                        $tx += $dx > 0 ? 1 : -1;
                    } else {
                        $tx = $hx;
                        $ty += $dy > 0 ? 1 : -1;
                    }
                }
            }
            @{$snake[$seg]} = ($tx, $ty);
        }
        my ($hx, $hy) = @{$snake[0]};
        my ($tx, $ty) = @{$snake[-1]};
        $visited{"$tx,$ty"} = 1;
    }
    #printx;
}

print scalar keys %visited, "\n";
