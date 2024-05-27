#!/usr/bin/env perl

use warnings;
use strict;

my @grid;

while (<>) {
    chomp;
    last if /^\s*$/;
    push @grid, [ split '' ];
}

my @transpose;

for (my $r=$#grid; $r >= 0; --$r) {
    my @row = @{$grid[$r]};
    for (my $c=0; $c <= $#row; ++$c) {
        unshift @{$transpose[$c]}, $row[$c];
    }
}

my $xmax = @transpose;
my $ymax = @grid;

my $outer = ($xmax * 2) + ($ymax * 2) - 4;
my $inner = 0;

for (my $y=1; $y<$ymax-1; ++$y) {
    for (my $x=1; $x<$xmax-1; ++$x) {
        my $val = $grid[$y][$x];
        my $nval;
        my $pass;
        
        $pass = 1;
        for (my $z=0; $z<$x; ++$z) {
            $nval = $grid[$y][$z];
            if ($nval >= $val) {
                $pass = 0;
                last;
            }
        }
        if ($pass == 1) {
            ++$inner;
            next;
        }
        
        $pass = 1;
        for (my $z=$x+1; $z<$xmax; ++$z) {
            $nval = $grid[$y][$z];
            if ($nval >= $val) {
                $pass = 0;
                last;
            }
        }
        if ($pass == 1) {
            ++$inner;
            next;
        }
        
        $pass = 1;
        for (my $z=0; $z<$y; ++$z) {
            $nval = $transpose[$x][$z];
            if ($nval >= $val) {
                $pass = 0;
                last;
            }
        }
        if ($pass == 1) {
            ++$inner;
            next;
        }

        $pass = 1;
        for (my $z=$y+1; $z<$ymax; ++$z) {
            $nval = $transpose[$x][$z];
            if ($nval >= $val) {
                $pass = 0;
                last;
            }
        }
        if ($pass == 1) {
            ++$inner;
            next;
        }
    }
}

print "".($outer+$inner)."\n";
