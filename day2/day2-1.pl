#!/usr/bin/env perl

use warnings;
use strict;

my %games;

while (<>) {
#    print "LINE $_";
    chomp;
    s/\s//g;
    s/^Game(\d+)://;
    my $gidx = $1;
    my @pulls = split(/;/);
    my $pidx = 0;
    foreach my $pull (@pulls) {
        my @cubestats = split(/,/, $pull);
        # prevent autovivification warnings
        $games{$gidx}{$pidx}{'red'} = 0;
        $games{$gidx}{$pidx}{'green'} = 0;
        $games{$gidx}{$pidx}{'blue'} = 0;
        foreach my $cubestat (@cubestats) {
            $cubestat =~ m/^(\d+)(.*)$/;
            my ($count, $color) = ($1, $2);
            $games{$gidx}{$pidx}{$color} = $count;
        }
        ++$pidx;
    }
}

my %bag = ( 'red' => 12, 'green' => 13, 'blue' => 14);

# Build this out since we'll probably modify the query later

my $acc = 0;

foreach my $gidx (sort {$a <=> $b} keys %games) {
    print "gidx: $gidx ... ";
    my $pass = 1;
    foreach my $pidx (sort {$a <=> $b} keys %{$games{$gidx}}) {
        my $pull = $games{$gidx}{$pidx};
        if (
            ($pull->{'red'} > $bag{'red'}) ||
            ($pull->{'green'} > $bag{'green'}) ||
            ($pull->{'blue'} > $bag{'blue'})
        ) {
            $pass = 0;
        }
    }
    if ($pass) {
        print "pass";
        $acc += $gidx;
    } else {
        print "fail";
    }
    print "\n";
}

print "Total $acc\n";
