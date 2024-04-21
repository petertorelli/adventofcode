#!/usr/bin/env perl

use warnings;
use strict;

$_ = <>;

my @chunks = split ',';


my $sum = 0;

foreach my $chunk (@chunks) {
    my $total = 0;
    foreach my $c (split '', $chunk) {
        $total += ord($c);
        $total *= 17;
        $total %= 256;
    }
    print "\t$chunk = $total\n";
    $sum += $total;
    $total = 0;
}

print "sum = $sum\n";

