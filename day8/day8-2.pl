#!/usr/bin/env perl

use warnings;
use strict;
use Math::Utils qw(:utility);

$_ = <>;
chomp;
my @directions = split("");

$_ = <>;

my @nodes = ();
my %graph;
while (<>) {
    m/(...) = \((...), (...)\)/ or die "input format error";
    my ($node, $l, $r) = ($1, $2, $3);
    die "redefined node $1" if defined $graph{$1};
    $graph{$1}{'L'} = $2;
    $graph{$1}{'R'} = $3;
    push @nodes, $node if $node =~ /..A$/;
    
}

# Find how many steps it takes to get from each @cur to $end,
# then find the LCM of the results
my @counts = ();

foreach my $node (@nodes) {
    my $cur = $node;
    my $count = 0;
    while (1) {
        foreach my $dir (@directions) {
            ++$count;
            $cur = $graph{$cur}{$dir};
            last if $cur =~ /^..Z$/;
        }
        last if $cur =~ /^..Z$/;
    }
    push @counts, $count;
    print "$node ended at $cur in $count steps\n";
}

print "Total iterations (LCM) is ".lcm(@counts);
