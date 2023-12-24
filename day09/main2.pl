#!/usr/bin/env perl
use warnings;
use strict;
use List::Util qw(reduce);

sub process_superset {
    my $superset = shift @_;
    # Did we reach the difference of zero vector yet?
    my @last = @{$superset->[-1]};
    my $zcount = 0;
    foreach (@last) {
        if ($_ != 0) {
            ++$zcount;
        }
    }
    if ($zcount == 0) {
        my $left = 0;
        my $right = 0;
        # Sum the last element of each subset
        foreach my $set (@$superset) {
            $right += $set->[-1];
        }
        foreach my $set (reverse @$superset) {
            $left = $set->[0] - $left;
            print join(",", @$set). " $left\n";
        }
        return ($left, $right);
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

my $suml = 0;
my $sumr = 0;
my $ln = 0;
while (<>) {
    ++$ln;
    my @set = map { int($_) } split;
    my @superset = (\@set);
    my ($left, $right) = process_superset(\@superset);
    $suml += $left;
    $sumr += $right;
    printf "Line %5d: Left(%10d -> %10d) Right(%10d -> %10d)\n", $ln, 
        $left, $suml,
        $right, $sumr;
}
