#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;

my @commands;
my @pts;

sub part2 {
    my ($color) = @_;
    $color =~ s/[\(\)\#]//g;
    $color =~ m/^(.{5})(.)$/;
    my $dst = hex($1);
    my $dir = $2;
    if    ($dir == 0) { $dir = 'R' }
    elsif ($dir == 1) { $dir = 'D' }
    elsif ($dir == 2) { $dir = 'L' }
    elsif ($dir == 3) { $dir = 'U' }
    return ($dir, $dst);
}

sub trace {
    my ($x, $y) = (0, 0);
    foreach my $cmd (@commands) {
        my ($dir, $dst, $color) = @$cmd;
        ($dir, $dst) = &part2($color);
        if ($dir eq 'R') {
            $x += $dst;
        } elsif ($dir eq 'L') {
            $x -= $dst;
        } elsif ($dir eq 'U') {
            $y -= $dst;
        } elsif ($dir eq 'D') {
            $y += $dst;
        }
        push @pts, [ $x, $y ];
    }
}

sub green {
    my $pt0 = $pts[-1];
    my $area = 0;
    my $perimeter = 0;

    for (my $i=0; $i<@pts; ++$i) {
        my $j = ($i + 1) % @pts;
        my ($x0, $y0) = @{$pts[$i]};
        my ($x1, $y1) = @{$pts[$j]};
        $area += $x0 * $y1;
        $area -= $y0 * $x1;
        # And perimeter of segment
        my ($dx, $dy) = ($x0 - $x1, $y0 - $y1);
        my $dst = sqrt($dx * $dx + $dy * $dy);
        $perimeter += $dst;
    }
    $area *= 0.5;
    $perimeter += 2;
    $perimeter *= 0.5;
    my $total = $area + $perimeter;
    print "Area $area, Perimeter $perimeter, Total $total\n";
}

sub main {
    while (<>) {
        if (/^\s*$/) {
            &trace;
            &green;
        } else {
            push @commands, [ (split) ];
        }
    }
}

&main;