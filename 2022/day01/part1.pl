#!/usr/bin/perl

use warnings;
use strict;

my @elves;

my $acc = 0;
while (<>) {
    chomp;
    if (/^\s*$/) {
        push @elves, $acc;
        $acc = 0;
    } else {
        $acc += $_;
    }
}
push @elves, $acc if $acc > 0;

my $max = (sort {$a <=> $b} @elves)[-1];

print "$max\n";
