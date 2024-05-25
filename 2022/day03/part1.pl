#!/usr/bin/env perl

use warnings;
use strict;

sub uintersect {
    my ($seta, $setb) = @_;
    my %uniq;
    foreach my $a (@$seta) {
        foreach my $b (@$setb) {
            $uniq{$a} = 1 if $a eq $b;
        }
    }
    return keys %uniq;
}

my $total = 0;

while (<>) {
    chomp;
    last if /^\s*$/;
    my @elements = split '';
    my @a = @elements[0 .. $#elements / 2];
    my @b = @elements[$#elements / 2 + 1 .. $#elements];
    my ($i) = (&uintersect(\@a, \@b));
    if ($i gt 'Z') {
        $total += (ord($i) - ord('a')) + 1;
    } else {
        $total += (ord($i) - ord('A')) + 27;
    }
}

print "$total\n";
