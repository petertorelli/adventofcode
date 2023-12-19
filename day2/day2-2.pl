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


sub max {
    my ($a, $b) = @_;
    return ($a > $b ? $a : $b);
}

my $acc = 0;

foreach my $gidx (sort {$a <=> $b} keys %games) {
    my %mins = ( 'red' => 0, 'green' => 0, 'blue' => 0);
    foreach my $pidx (sort {$a <=> $b} keys %{$games{$gidx}}) {
        my $pull = $games{$gidx}{$pidx};
        foreach my $color ('red', 'green', 'blue') {
            $mins{$color} = max($mins{$color}, $pull->{$color})
        }
    }
    my $power = $mins{'red'} * $mins{'green'} * $mins{'blue'};
    $acc += $power;
}

print "Total $acc\n";
