#!/usr/bin/env perl

use warnings;
use strict;

$_ = <>;
chomp;
my @directions = split("");

$_ = <>;

my %graph;
while (<>) {
    m/(...) = \((...), (...)\)/ or die "input format error";
    die "redefined node $1" if defined $graph{$1};
    $graph{$1}{'L'} = $2;
    $graph{$1}{'R'} = $3;
}

my $cur = "AAA";
my $next;
my $steps = 0;
while (1) {
    foreach (@directions) {
        ++$steps;
        $next = $graph{$cur}{$_};
        print "$steps: [$_] $cur -> $next\n";
        die "done $steps" if $next eq "ZZZ";
        $cur = $next;
    }
}
print "fail\n";