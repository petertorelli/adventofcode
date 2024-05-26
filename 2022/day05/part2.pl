#!/usr/bin/env perl

use warnings;
use strict;

my @matrix;

while (<>) {
    last if /^\s*$/;
    chomp;
    # munge munge munge...
    s/[\[\]]/ /g;
    s/ /x/g;
    s/^x//;
    s/x$//;
    s/x{3}/./g;
    s/\.//g;
    s/x/ /g;
    my @cols = split '';
    next if $cols[0] eq '1';
    push @matrix, \@cols;
}

my @transpose;

for (my $r=$#matrix; $r >= 0; --$r) {
    my @row = @{$matrix[$r]};
    for (my $c=0; $c <= $#row; ++$c) {
        push @{$transpose[$c]}, $row[$c] unless $row[$c] eq ' ';
    }
}

while (<>) {
    next unless m/move (\d+) from (\d+) to (\d+)/;
    my ($q, $from, $to) = ($1, $2 - 1, $3 - 1);
    push @{$transpose[$to]}, splice(@{$transpose[$from]}, -$q, $q);
}

foreach my $row (@transpose) {
    print @$row[-1];
}
print "\n";
