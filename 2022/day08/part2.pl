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
my @scores;

for (my $y=1; $y<$ymax-1; ++$y) {
    for (my $x=1; $x<$xmax-1; ++$x) {
        my $val = $grid[$y][$x];
        my $nval;
        my $total = 1;
        my $score = 0;

        $score = 0;
        for (my $z=$x-1; $z>=0; --$z) {
            ++$score;
            $nval = $grid[$y][$z];
            if ($nval >= $val) {
                last;
            }
        }
        $total *= $score;
        
        $score = 0;
        for (my $z=$x+1; $z<$xmax; ++$z) {
            ++$score;
            $nval = $grid[$y][$z];
            if ($nval >= $val) {
                last;
            }
        }
        $total *= $score;
        
        $score = 0;
        for (my $z=$y-1; $z>=0; --$z) {
            ++$score;
            $nval = $transpose[$x][$z];
            if ($nval >= $val) {
                last;
            };
        }
        $total *= $score;

        $score = 0;
        for (my $z=$y+1; $z<$ymax; ++$z) {
            ++$score;
            $nval = $transpose[$x][$z];
            if ($nval >= $val) {
                last;
            }
        }
        $total *= $score;

        push @scores, $total;
    }
}

@scores = sort { $a <=> $b } @scores;

print "$scores[-1]\n";
