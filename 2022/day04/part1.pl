#!/usr/bin/env perl

use warnings;
use strict;

my $total = 0;

while (<>) {
    last if /^\s*$/;
    chomp;
    my ($a, $b) = split ',';
    my ($start_a, $end_a) = split '-', $a;
    my ($start_b, $end_b) = split '-', $b;
    my $ainb = ($start_a >= $start_b) && ($end_a <= $end_b);
    my $bina = ($start_b >= $start_a) && ($end_b <= $end_a);
    ++$total if $ainb || $bina;
}

print "$total\n";
