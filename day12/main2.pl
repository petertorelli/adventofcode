#!/usr/bin/env perl
use warnings;
use strict;

my @solutions = ();

# Attempt #2.
# Guess we gotta think about this a little more deeply.
# Let's pretend to be a regex engine... choo choo...
# How many patterns of W can yoy find from the starting point and shifting
# to the right? This includes FIXED '#' characters, which will for an end
# to the W search. 

# Fancy printer with cursor so we can stay sane...
sub pcursor {
    my ($i, @pattern) = @_;
    print "\t".join('', @pattern)."\n";
    print "\t".(' ' x $i)."^\n";
}

# Start at a point in pattern, and try to build a string 'width' long
# return 1 if you can, 0 if you cannot. Note that the found string must 
# either terminate at the end of the pattern, or terminate at a '?' or '.'.
sub analyze3 {
    my ($start, $width, @pattern) = @_;
    my $i = $start;
    my $count = 0;
    my $valid = 0;

    for (; $i <= $#pattern; ++$i) {
#        &pcursor($i, @pattern);
        last if $pattern[$i] eq '.';
        last if $count == $width;
        if ($pattern[$i] eq '?') {
            $pattern[$i] = '#';
            ++$count;
        }
        elsif ($pattern[$i] eq '#') {
            ++$count;
        }
    }
    #&pcursor($i, @pattern) if $i >= $start;
#    print "Exited i=$i; start=$start; #pattern=$#pattern; c=$count, w=$width\n";
    if ($count == $width) {
        if ($i > $#pattern) {
            # We're at the end
            $valid = 1;
        }
        elsif ($pattern[$i] eq '#') {
            # We stopped on a '#', which increases count by 1.
#            print "*** Stopped on a #, fail\n";
            $valid = 0;
        }
        elsif ($pattern[$i] eq '?') {
            $pattern[$i] = '.';
#            &pcursor($i, @pattern); # print this so we can see the update
            $valid = 1;
        }
        elsif ($pattern[$i] eq '.') {
            $valid = 1;
        }
        else {
            die "Should never get here!";
        }
    }
    else {
        $valid = 0;
    }
    return ($valid, $i + 1, @pattern);
}

sub lsum {
    my $sum = 0;
    foreach (@_) {
        $sum += $_;
    }
    return $sum;
}

sub chase {
    my $start = shift;
    $_ = shift; my @pattern = @$_;
    my @counts = @_;
    if (@counts == 0) {
#        print "\t\t\tThat was the last count\n";
        while ($start <= $#pattern) {
#            print "\t\t\tcheck $pattern[$start]\n";
            if ($pattern[$start] eq '#') {
#                print "\t\t\tfail due to trailing #\n";
                return ;
            }
            ++$start;
        }
#        print "\t\tDone with counts, is ".join("", @pattern)." OK?\n";
        push @solutions, join('', @pattern);
        return;
    }
    my $count = shift @counts;
    my $p = 0;
    my $i = $start;
    for (; ($i <= ($#pattern + 1 - $count)); ++$i) {
#        print "COUNT $count, starting at $i\n";
        # Set all "?" to "." from the start
        for (my $j = 0; $j < $i; ++$j) {
            $pattern[$j] = '.' if $pattern[$j] eq '?';
        }
        if (($i > 0) && ($pattern[$i - 1] eq '#')) {
#            &pcursor($i, @pattern);
#            print "*** previous # prevents start here\n";
            last;
        }
        else {
            my ($valid, $stop, @np) = &analyze3($i, $count, @pattern);
            #print ">> Valid [$i, ".($stop - 1)."]\n" if $valid;
            if ($valid) {
                &chase($stop, \@np, @counts);
            }
        }
    }
    return 1;
}

my $sum = 0;
while (<>) {
    print "OK: $_";
    my ($xpattern, $xcounts) = split;
    
    # Part 2
    my $mag = 0;
    $xpattern = ("$xpattern?" x $mag) . $xpattern;
    $xcounts = ("$xcounts," x $mag) . $xcounts;
    
    my @pattern = split("", $xpattern);
    my @counts = split(/,/, $xcounts);
    print '@pattern  : '.join("", @pattern)."\n";
    print '@counts   : '.join(",", @counts)."\n";

    my $num_qs = grep { $_ eq '?'} @pattern;
    my $num_existing_hashes = grep { $_ eq '#'} @pattern;
    my $target_hashes = lsum(@counts);
    # 5. How many new hashes do we have to rearrange to find answers?
    my $num_new_hashes = $target_hashes - $num_existing_hashes;

    print "\tnum_qs              : $num_qs\n";
    print "\tnum_existing_hashes : $num_existing_hashes\n";
    print "\ttarget_hashes       : $target_hashes\n";
    print "\tnum_new_hashes      : $num_new_hashes\n";
    print "\n";

    &chase(0, \@pattern, @counts);
    print "RESULTS : $xpattern = ".scalar(@solutions)."\n";
    print "\n";
    print "\n";
    $sum += scalar(@solutions);
    @solutions = ();
}
print "RESULTS TOTAL $sum\n";
