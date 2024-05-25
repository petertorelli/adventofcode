#!/usr/bin/env perl

use warnings;
use strict;

# Since the ranges are huge we can just make a map, instead we
# need to turn the entries into a map and than work on the results
# with a translation function.

# also probably need list of functions to process in order..

my @mapnames = (   
    'seed-to-soil',
    'soil-to-fertilizer',
    'fertilizer-to-water',
    'water-to-light',
    'light-to-temperature',
    'temperature-to-humidity',
    'humidity-to-location'
);

# not being fancy about the file parser
$_ = <>;
s/^seeds: //;
my @seeds = split;

# now get maps
my $key;
my %maps;
while (<>) {
    chomp;
    my @tok = split;
    next unless $#tok > 0;
    if ($tok[0] =~ /^\d/) {
        if (!defined $key || $key eq "") {
            die "Range with no key";
        }
        if ($#tok != 2) {
            die "Too few elements in map";
        }
        push(@{$maps{$key}}, \@tok);
    } else {
        $key = $tok[0];
    }
}

sub remap {
    my ($id, $key) = @_;
    # assume no remapping
    my $result = $id;
    foreach my $submap (@{$maps{$key}}) {
        my ($d0, $s0, $rng) = @{$submap};
        die unless defined $s0 && defined $d0 && defined $rng;
        my $s1 = $s0 + ($rng - 1);
        #print "[$s0 $id $s1] : $d0 : $key\n";
        if ($id >= $s0 && $id <= $s1) {
            $result = $d0 + ($id - $s0);
        }
    }
    return $result;
}

my $lowest = 1e100;

foreach my $id (@seeds) {
    print "SEED -- $id\n";
    foreach my $map (@mapnames) {
        my $nid = remap($id, $map);
        print "$id -> $nid ($map)\n";
        $id = $nid;
    }
    $lowest = $lowest < $id ? $lowest : $id;
}

print "Lowest: $lowest\n";


