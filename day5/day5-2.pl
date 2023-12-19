#!/usr/bin/env perl

use warnings;
use strict;

$|=0;

# can't brute force 5.2, well, you can, but why wait.
# I think since we know ranges can be mapped in chunks just
# by knowing where they overlap, that instead of creating a 
# single megaset of (n ... m) we can have multiple blocks and
# operate on those implicitly.


my @mapnames = (   
    'seed-to-soil',
    'soil-to-fertilizer',
    'fertilizer-to-water',
    'water-to-light',
    'light-to-temperature',
    'temperature-to-humidity',
    'humidity-to-location'
);

# not being fancy about the file parser
$_ = <>;
s/^seeds: //;
my @seeds = split;

# now get maps
my $key;
my %maps;
while (<>) {
    chomp;
    my @tok = split;
    next unless $#tok > 0;
    if ($tok[0] =~ /^\d/) {
        if (!defined $key || $key eq "") {
            die "Range with no key";
        }
        if ($#tok != 2) {
            die "Too few elements in map";
        }
        push(@{$maps{$key}}, \@tok);
    } else {
        $key = $tok[0];
    }
}

use Data::Dumper;

# First make seed ranges

my @seed_ranges;
while (@seeds) {
    my $start = shift @seeds;
    my $range = shift @seeds;
    push @seed_ranges, [ $start, $start + $range];
}

#die Dumper(\@seed_ranges);

my @s2s = @{$maps{'seed-to-soil'}};
#print Dumper(\@s2s);

sub print_tuples {
    my @tuples = @_;
    foreach my $tuple (@tuples) {
        print "[$tuple->[0], $tuple->[1]] ";
    }
    print "\n";
}

sub fracture_set {
    my ($tuple, $map) = @_;
    my $xs = @$tuple[0];
    my $xe = @$tuple[1];
    my $ln = ($xe - $xs);
    my @mapped;
    my @natural;
    my $ds = @$map[0];
    my $ss = @$map[1];
    my $r  = @$map[2];
    my $se = ($ss + $r - 1);
    my $de = ($ds + $r - 1);
    my $print_table = 0;
    if ($xs >= $ss && $xs <= $se) {
        if ($xe <= $se) {
            my $off = $xs - $ss;
            print " *********** Falls completely in range\n";
            $print_table = 1;
            push @mapped, [$ds + $off, $ds + $off + $ln];
        } else {
            my $off = $xs - $ss;
            print " *********** Falls partially in range (start) -> [REMAP,NAT]\n";
            $print_table = 1;
            push @mapped, [$ds + $off, $de];
            push @natural, [$se + 1, $xe];
        }
    }
    elsif ($xe >= $ss && $xe <= $se) {
        if ($xs < $ss) {
            print " *********** Falls partially in range (end) -> [NAT,REMAP]\n";
            $print_table = 1;
            push @natural, [$xs, $ss - 1];
            push @mapped, [$ds, $ds + ($ln - ($ss - $xs))];
        }
    }
    elsif ($xs < $ss && $xe > $se) {
            $print_table = 1;
        print " *********** Surrounds map [NAT,REMAP,NAT]\n";
        push @natural, [$xs, $ss - 1];
        push @natural, [$se + 1, $xe];
        push @mapped,  [$ds, $de];
    }
    else {
        push @natural, [$xs, $xe];
    }
    if ($print_table) {
        printf("Start : %15d %15d  sz %15d\n", $xs, $xe, $xe - $xs);
        printf("  Src : %15d %15d  sz %15d -->\n", $ss, $se, $se - $ss);
        printf("  Dst : %15d %15d  sz %15d\n", $ds, $de, $de - $ds);
        print "xNatural : "; print_tuples(@natural);
        print "xMapped  : "; print_tuples(@mapped);
        print "\n";
    }
    return ( \@natural, \@mapped );
}



sub process_sets {
    my ($_sets, $maps) = @_;
    my @sets = @$_sets;
    my @mapped;
    my @unmapped;
    foreach my $map (@$maps) {
        @unmapped = ();
        for (my $ii = 0; $ii <= $#sets; ++$ii) {
            #print "Set $ii -> "; print_tuples(@sets[$ii]);
            my ($u, $m) = fracture_set($sets[$ii], $map);
            push(@unmapped, @$u);
            push(@mapped, @$m);
        }
        @sets = @unmapped;
        #print_tuples(@sets);
    }
    return (@unmapped, @mapped);
}

my $lowest = 1e15;

foreach (@seed_ranges) {
    my @sets = ( $_ );
    print "Seeds "; print_tuples(@sets);
    my @results;
    foreach my $mapk (@mapnames) {
        my $maps = $maps{$mapk};
        
        #print "APPLYING MAP $mapk\n";
        @results = process_sets(\@sets, $maps);
        @sets = @results;
    }
    print "Finished Seed Range, Final soil ranges:\n";
    foreach my $tuple (@results) {
        printf("\t%15d %15d\n", $tuple->[0], $tuple->[1]);
        $lowest = $lowest < $tuple->[0] ? $lowest : $tuple->[0];
    }
}

print "Lowest $lowest\n";