#!/usr/bin/env perl
use warnings;
use strict;

use Data::Dumper;

my $debug = 0;

# Fancy printer with cursor so we can stay sane...
sub pcursor {
    my ($i, @pattern) = @_;
    print "\t".join('', @pattern)."\n";
    print "\t".(' ' x $i)."^\n";
}

sub look_both_ways {
    my ($pos, $target, @pattern);

    my $total = 0;

    if ($pattern[$pos] eq '#') {
        ++$total;
    }

    # Go right
    my $i = $pos + 1;
    while ($i <= $#pattern) {
        if ($pattern[$i] eq '?') {
            $pattern[$i] = '#';
            ++$total;
        }
        elsif ($pattern[$i] eq '#') {
            ++$total;
        }
    }

    
}

sub build_at {
    my ($start, $goal, @pattern) = @_;
    print("build_at(start=$start goal=$goal ".join("", @pattern).")\n");
    my $found;
    my $tally;
    my $i;

    $i = $start;
    $tally = 0;
    $found = 0;

    LOOP1: while (1) {
        &pcursor($i, @pattern);
        print "tally=$tally\n";
        if ($tally != $goal) {
            if ($i > $#pattern) {
                print "   build_at: Fail because we missed goal and are at end\n";
                last LOOP1;
            }
        }
        else {
            if ($i > $#pattern) {
                print "   build_at: Pass because $i is >= $#pattern\n";
                $found = 1;
            }
            elsif ($pattern[$i] eq '#') {
                print "   build_at: Fail because value at i=$i is '#'\n";
            }
            else {
                print "   build_at: Pass because value at i=$i is '?'\n";
                $pattern[$i] = '.';
                $found = 1;
            }
            last LOOP1;
        }

        my $c = $pattern[$i];

        if ($c eq '.') {
            last LOOP1;
        }
        elsif ($c eq '?') {
            $pattern[$i] = '#';
            ++$tally;
        }
        elsif ($c eq '#') {
            ++$tally;
        }
        else {
            last LOOP1;
        }
        ++$i;
    }
    return ($found, $i+1, @pattern);
}

sub slide_build {
    my ($start, $lcounts, $lisland) = @_;

    while ($start < scalar(@$lisland)) {
        my $island = @$lisland;
        my ($ret, $next, @nisland) = &build_at($start, $lcounts->[0], @$lisland);
        if ($ret) {
            print "  .. found @nisland\n";
        }
        ++$start;
    }
}


sub walk_island {
    my ($start_cidx, $xisland, @counts) = @_;
    print("walk_island(start_cidx=$start_cidx, $xisland, @counts)\n");
    my @island = split("", $xisland);
    my $pos = 0;
    my $cidx = $start_cidx;
    LCOUNT: for ( ; $cidx <= $#counts; ++$cidx) {
        print " walking: got a new count: $counts[$cidx]\n";
        print " walking: pos=$pos\n";
        &slide_build($pos, [@counts[$cidx .. $#counts]], [@island]);
#        my ($ret, $next, @nisland) = &build_at($pos, $counts[$cidx], @island);
    }
    return $cidx + 1;
}

sub analyze {
    my ($xpattern, $xcounts) = @_;
    my @counts = @$xcounts;
    my @pattern = split("", $xpattern);

    $xpattern =~ s/^\.//;
    my @islands = split(/\.+/, $xpattern);

    # How many sequential groups can we make out of each island?
    # Can we then arrange those groups into solutions?
    print "@islands\n";
    my $cidx = 0;
    ISLAND_LOOP: foreach my $xisland (@islands) {
        print "Island $xisland cidx=$cidx = $counts[$cidx]\n";
        my $progress = &walk_island($cidx, $xisland, @counts);
        printf("... found $progress counts in this island\n");
        $cidx = $progress;
    }

}


while (<>) {
    print;

    my ($xpattern, $xcounts) = (split);
    my @pattern = split("", $xpattern);
    my @counts = split(",", $xcounts);

    &analyze($xpattern, \@counts);
}