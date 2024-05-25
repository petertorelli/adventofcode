#!/usr/bin/env perl

use warnings;
use strict;

my @matrix;
my $nrows = 0;
my $ncols = 0;

while (<>) {
    chomp;
    my @row = split("");
    $ncols = scalar @row;
    push(@{$matrix[$nrows]}, @row);
    ++$nrows;
}

sub get_row_markers {
    my ($rr, $cc) = @_;
    my $start = -1;
    my $stop = -1;
    my $part_number = "";
    my @row = @{$matrix[$rr]};
    for (my $c = $cc; $c < $ncols; ++$c) {
        my $val = $row[$c];
        if ($start <= 0) {
            if ($val =~ /[0-9]/) {
                $start = $c;
                $part_number .= $val;
            }
        }
        elsif ($stop <= 0) {
            if ($val !~ /[0-9]/) {
                $stop = $c - 1;
                return ($start, $stop, $part_number);
            }
            $part_number .= $val;
        }
    }
    if ($start >= 0) {
        return ($start, 139, $part_number);
    }
    return (-1, -1, -1);
}

sub check_adj_gears {
    my ($r, $c) = @_;
    my ($a0, $a1, $part_number) = (0, 0, 0);
    my $start = 0;
    my @pns;
    do {
        ($a0, $a1, $part_number) = get_row_markers($r, $start);  
        my $pass = 0;
        if ($a0 > 0 && $a1 > 0) {
            if (($c >= ($a0 - 1)) && ($c <= ($a1 + 1))) {
                print "Gear $part_number\n";
                push @pns, $part_number;
            }
            $start = $a1 + 1;
        }
    } while (($a0 >= 0) && ($a1 >= 0));
    return @pns;
}

my $acc = 0;

for (my $r = 0; $r < $nrows; ++$r) {
    # debug
    print "\nRow $r\n";
    if ($r > 0) {
        print "UPR: ".join("", @{$matrix[$r - 1]})."\n";
    }
    {
        print "Row: ".join("", @{$matrix[$r]})."\n";
    }
    if ($r < ($nrows - 1)) {
        print "LWR: ".join("", @{$matrix[$r + 1]})."\n";
    }
    my @row = @{$matrix[$r]};
    for (my $c = 0; $c < $ncols; ++$c) {
        my $val = $row[$c];
        if ($val eq '*') {
            my @pns;
            print "HUB >> $c <<\n";
            # above
            if ($r > 0) {
                my @res = check_adj_gears($r - 1, $c);
                @pns = (@pns, @res);
            }
            # below
            if ($r < ($nrows - 1)) {
                my @res = check_adj_gears($r + 1, $c);
                @pns = (@pns, @res);
            }
            # inline
            {
                my @res = check_adj_gears($r, $c);
                @pns = (@pns, @res);
            }
            if (scalar @pns != 2) {
                print "-- BAD GEARS\n";
            } else {
                my $ratio = $pns[0] * $pns[1];
                $acc += $ratio;
            }
        }
    }
}

print "$acc\n";
# 84584891