#!/usr/bin/env perl
use warnings;
use strict;
use List::Util qw(reduce);

sub process_superset {
    my $superset = shift @_;
    # Did we reach the difference of zero vector yet?
    my @last = @{$superset->[-1]};
# BUG! I was summing the elements to detect zero! doh!!!
# BUG!    my $lsum = reduce { $a + $b } @last;
    my $zcount = 0;
    foreach (@last) {
        if ($_ != 0) {
            ++$zcount;
        }
    }
# BUG!    if ($lsum == 0)
    if ($zcount == 0) {
        my $extrapolation = 0;
        # Sum the last element of each subset
        foreach my $set (@$superset) {
            $extrapolation += $set->[-1];   
        }
        return $extrapolation;
    }
    die "single nonzero element" if scalar(@last) == 1;
    # Construct a new set of differences
    my @newset = ();
    for (my $i = 0; $i < $#last; ++$i) {
        push @newset, $last[$i + 1] - $last[$i];
    }
    push @$superset, \@newset;
    return process_superset($superset);
}

my $sum = 0;
my $ln = 0;
while (<>) {
    ++$ln;
    my @set = map { int($_) } split;
    my @superset = (\@set);
    my $next = process_superset(\@superset);
    $sum += $next;
    printf "Line %5d = next = %15d , sum = %15d\n", $ln, $next, $sum;
}
