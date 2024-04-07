#!/usr/bin/env perl

use warnings;
use strict;

sub process {
    my ($_springs, $_records, $expand) = @_;
    if ($expand > 1) {
        $_springs = ($_springs . '?') x ($expand - 1) . $_springs;
        $_records = ($_records . ',') x ($expand - 1) . $_records;
    }
    my @springs = split('', $_springs);
    my @records = split(',', $_records);

    # The solver attempts to build each record from the left to right by
    # sliding that record size from left to right through the springs. Each
    # time it finds a place where the record can fit, it accumulates the 
    # number of solutions already seen. It uses an array of solution counts
    # and modifies it each pass. The array is seeded with a "fake" solution
    # at the end that the first pattern tries to capture. This solution's
    # position in the vector let's us know when the next record can "start",
    # meaning: the next record can't start until it has passed the previous
    # record's solution positions.

    # Seed the starting solution counts with a "fake" solution one position
    # after the end (since you need a ".#" to be a solution). The first record
    # "steals" this and sets it to zero. If the first record doesn't find a
    # position where it fits, it doesn't store the '1' so no other records
    # will have a chance to start matching.

    my @prev_solns = split('', (0 x ($#springs + 2)) . 1);

    # First, fit each record from right to left, start where we see the last
    # "..., 0, n", which in the first-pass is +2 past the end.
    foreach my $rlen (reverse @records) {
        # remember the array has the end "telomere"
        my @curr_solns = split('', (0 x ($#springs + 2)) . 0);

        # The accumulated solutions to the right of a valid solution
        my $acc = 0;
        # The current size of the (?|#) pattern we've built.
        my $build = 0;

        # Now slide that record backwards and see how many places it fits...
        foreach my $spos (reverse 0 ... $#springs) {

            # If the proposed pattern fits, this is the next rightmost pos.
            my $stop = $spos + $rlen;
            
            # Step 1. Check to see if we're in a valid check position, and
            #         if any solutions have come before this one (i.e. to the
            #         right of this solution).

            # 1a. If it fits in the remaining spaces, but there's a '#' at
            #     the next space, it's an automatic fail.
            if (($stop <= $#springs) && ($springs[$stop] eq '#')) {
                $acc = 0;
            }
            # 1b. It fits, but this only counts if we've already passed a
            #     previous count. If there's no previous count, the previous
            #     record didn't fit the pattern! If it did fit the pattern,
            #     accumulate the number of solutions to the right.
            else {
                my $telomere_pos = $stop + 1;
                if ($telomere_pos <= $#prev_solns) {
                    # Accumulate the solutions we've seen to the right...
                    $acc += $prev_solns[$telomere_pos];
                } else {
                    $acc = 0;
                }
            }

            # Step 2. See if the record can actually fit the spring pattern
            my $pass = 0;

            # 2a. A "good" spring resets the build string
            if ($springs[$spos] eq '.') {
                $build = 0;
            }
            # 2b. Otherwise check if it can fit the pattern
            else {
                $build += 1;
                # Did we meet the objective size (or exceed it??)
                my $met_size_goal = $build >= $rlen;
                # Check the left-hand side of the built pattern
                # Look one to the left: don't touch a bad spring
                my $at_beginning = $spos == 0;
                my $lhs_ok = $at_beginning || ($springs[$spos - 1] ne '#');
                # Check the right-hand side of the built pattern
                # Did the pattern stop at the end of the spring string?
                my $at_end = $stop == scalar(@springs);
                # Look to the right: don't touch a bad spring - check to make
                # sure the stop position fits the array before referencing it.
                my $rhs = (($stop <= $#springs) && ($springs[$stop] ne '#'));
                my $rhs_ok = $at_end || $rhs;
                # Is it a solution?
                if ($met_size_goal && $lhs_ok && $rhs_ok) {
                    $pass = 1;
                }
            }
            # If the build checker passes, store the accumulated solutions.
            $curr_solns[$spos] = $pass ? $acc : 0;
        }
        @prev_solns = @curr_solns;
    }

    my $total = 0;
    # Here's the tricky bit: the total # of solutions is the sum from left
    # to right, but if a solution is on a known-bad spring, then no more
    # solutions are valid.
    foreach (0 .. $#springs) {
        $total += $prev_solns[$_];
        if ($springs[$_] eq '#') {
            last;
        }
    }
    return $total;
}

sub parse {
    my ($expand) = @_;
    my $fn = $ARGV[0];
    die "Plese specify the test data\n" unless $fn and -f $fn;
    my $fp;
    open ($fp, "<", $fn) or die "Failed to opern file\n";
    my $acc = 0;
    while (<$fp>) {
        my ($springs, $records) = split();
        $acc += &process($springs, $records, $expand);
    }
    close $fp;
    print "Sum: $acc\n";
}

&parse(1);
&parse(5);
