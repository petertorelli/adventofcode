#!/usr/bin/env perl

# 1. Brute force method #1 w/o combinatorics worked fine
# 2. Brute force method #2 w/ combinatorics is still to big for Part 2
# 3. Need to write an engine that doesn't brute force

use warnings;
use strict;
use Math::Combinatorics qw/combine/;
use List::Util qw/reduce/;

$| = 1;
my $BS = chr(0x08);

sub validate {
    $_ = shift;
    my @counts = @$_;
    $_ = shift;
    my @qpat = @$_;

    my @found;
    my $in = 0;
    my $z = 0;

    # Score it
    #print "\t";
    foreach my $q (@qpat) {
        #print "\t$q ";
        if ($q eq '.') {
            if ($in) {
                push @found, $z;
                $in = 0;
                $z = 0;
                #print "a ($z, $in)\n";
            } else {
                #print "b ($z, $in)\n";
            }
        }
        else {
            $in = 1;
            ++$z;
            #print "c ($z, $in)\n";
        }
        #print "$q";
    }
    #print "\n";
    push @found, $z if $z;
    #print " --- ";
    #print join(", ", @counts)." > ";
    #print join("; ", @found);
    #print "\n";

    return 0 if scalar @counts != scalar @found;
    foreach (0 .. $#counts) {
        return 0 if $counts[$_] != $found[$_];
    }
    print "-- SOLUTION: ".join("", @qpat)."\n";
    return 1;
}

sub lsum {
    my $sum = 0;
    foreach (@_) {
        $sum += $_;
    }
    return $sum;
}

sub kbits {
    my ($n, $k, $func) = @_;
    my @base = split('', '0' x $n);
    my @s;
    my $bit;
    my $combinat = Math::Combinatorics->new(
        count => $k,
        data => [(0 .. ($n - 1))]
    );
    while (my @combo = $combinat->next_combination) {
        @s = @base;
        foreach $bit (@combo) {
            $s[$bit] = '1'
        }
        $func->(@s);
    }
}

sub analyze {
    $_ = shift;
    my @pattern = @$_;
    $_ = shift;
    my @counts = @$_;

    # 1. find the indices of the wildcards, we will replace them
    my @qlocs = grep { $pattern[$_] =~ /[?]/ } 0..$#pattern;
    # 2. How many wildcards are there
    my $num_qs = scalar @qlocs;
    # 3. How many hashes are already determined?
    my $num_existing_hashes = grep { $_ eq '#'} @pattern;
    # 4. What is the total number of hashes we need per pattern?
    my $target_hashes = lsum(@counts);
    # 5. How many new hashes do we have to rearrange to find answers?
    my $num_new_hashes = $target_hashes - $num_existing_hashes;
    # 6. How big is the search space?
    my $nf = reduce { $a * $b } 1 .. $num_qs;
    my $kf = reduce { $a * $b } 1 .. $num_new_hashes;
    my $nmkf = reduce { $a * $b } 1 .. ($num_qs - $num_new_hashes);
    my $combos = ($nf) / ($nmkf * $kf);

    print "\tnum_qs              : $num_qs\n";
    print "\tnum_existing_hashes : $num_existing_hashes\n";
    print "\ttarget_hashes       : $target_hashes\n";
    print "\tnum_new_hashes      : $num_new_hashes\n";
    print "\tn = $num_qs, k = $num_new_hashes\n";
    print "\tCombinations        : $combos\n";

    my $iterations = 0;
    my $ticker = 10000;
    my $found = 0;

    # Prime the ticker
   # printf("%7.3f %%", 0);
    # ...aaaaaand go!
    kbits($num_qs, $num_new_hashes, sub {
        my @new = @pattern;
        my @v = @_;
        foreach my $i (0 .. $#v) {
            $new[$qlocs[$i]] = $v[$i] == '1' ? '#' : '.';
        }
        $found += validate(\@counts, \@new);
        ++$iterations;
        if ($iterations % $ticker == 0) {
            #printf("%s%7.3f %%", ($BS x 9), ($iterations / $combos) * 100);
        }
    });
    #printf("%s%7.3f %%\n", ($BS x 9), ($iterations / $combos) * 100);
    return $found;
}


my $sum = 0;

while (<>) {
    chomp;
    my ($pattern, $rule) = split;
    
    # Part 2
    my $mag = 0;
    $pattern = ("$pattern?" x $mag) . $pattern;
    $rule = ("$rule," x $mag) . $rule;
    
    my @counts = split(/,/, $rule);
    my @qpat = split("", $pattern);
    print '@qpat     : '.join("", @qpat)."\n";
    print '@counts   : '.join(",", @counts)."\n";
    my $solutions = analyze(\@qpat, \@counts);
    print "solutions : $solutions\n";
    $sum += $solutions;
    print "\n";
}

print "\nSum: $sum\n";
