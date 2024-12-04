#!/usr/bin/env perl

use warnings;
use strict;

sub part1 {
    my @lines = @_;
    my $sum = 0;
    foreach (@lines) {
        while (/mul\((\d{1,3}),(\d{1,3})\)/gc) {
            $sum += $1 * $2;
        }
    }
    print "Part 1: $sum\n";
}

sub part2 {
    my @lines = @_;
    my $sum = 0;
    my $skip = 1;
    foreach (@lines) {
        while (/(mul\((\d{1,3}),(\d{1,3})\)|do\(\)|don't\(\))/gc) {
            my ($opa, $opb, $opc) = ($1, $2, $3);
            if ($opa =~ /^mul/) {
                $sum += $opb * $opc * $skip;
            } elsif ($opa =~ /^don/) {
                $skip = 0;
            } elsif ($opa =~ /^do/) {
                $skip = 1;
            }
        }
    }
    print "Part 2: $sum\n";
}

my @input = <>;
&part1(@input);
&part2(@input);