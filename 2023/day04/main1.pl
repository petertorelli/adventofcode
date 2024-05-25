#!/usr/bin/env perl

use warnings;
use strict;

my $acc = 0;
my @stack = ();

# sluuurp
my @deck = <>;

my @todo = ();

# Start with the normal deck
@todo = (0 ... $#deck);

sub get_num_matches {
    my ($idx) = (@_);
    $_ = $deck[$idx];
    # preprocessing
    chomp;
    s/Card.*(\d+):\s*//;
    my $card = $1;
    s/\s+\|\s+/:/;
    my @first_split = split(/:/);
    my @winning = split(/\s+/, $first_split[0]);
    my @mine = split(/\s+/, $first_split[1]);
    # linear of linear? sure.
    my $matches = 0;
    for (my $i=0; $i<=$#winning; ++$i) {
        for (my $j=0; $j<=$#mine; ++$j) {
            if ($winning[$i] == $mine[$j]) {
                ++$matches;
            }
        }
    }
    return $matches;
}

foreach my $idx (@todo) {
    my $nmatch = get_num_matches($idx);
    if ($nmatch > 0) {
        $acc += 2 ** ($nmatch - 1);
    }
}

print $acc . "\n";