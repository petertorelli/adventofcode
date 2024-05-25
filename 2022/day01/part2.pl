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

my @sorted = sort {$b <=> $a} @elves;
my $top3 = 0;
$top3 += $_ for (@sorted[0..2]);

print "$top3\n";
