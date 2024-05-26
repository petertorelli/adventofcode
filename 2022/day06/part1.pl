#!/usr/bin/env perl

use warnings;
use strict;

LINE: while (<>) {
    last if /^\s*$/;
    my @marker;
    my $i = 0;
    foreach my $c (split '') {
        if (@marker >= 4) {
            my %seen;
            my $pass = 1;
            foreach (@marker) {
                if ($seen{$_}) {
                    $pass = 0;
                }
                $seen{$_} = 1;
            }
            if ($pass) {
                print "marker: @marker @ $i\n";
                next LINE;
            }
            shift @marker;
        }
        push @marker, $c;
        ++$i;
    }
}
