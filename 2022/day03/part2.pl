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
my @lines = <>;

while (@lines) {
    $_ = shift @lines;
    chomp;
    my @a = split '';
    $_ = shift @lines;
    chomp;
    my @b = split '';
    $_ = shift @lines;
    chomp;
    my @c = split '';

    my @int = &uintersect(\@a, \@b);
    my ($i) = (&uintersect(\@int, \@c));

    if ($i gt 'Z') {
        $total += (ord($i) - ord('a')) + 1;
    } else {
        $total += (ord($i) - ord('A')) + 27;
    }
}

print "$total\n";
