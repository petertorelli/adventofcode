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

use Data::Dumper;

print "$nrows x $ncols\n";

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

sub is_valid {
    my ($rr, $c0, $c1) = @_;
    my @row = @{$matrix[$rr]};
    # left
    if ($c0 > 0) {
        if ($row[$c0 - 1] !~ /[\.0-9]/) {
            return 1;
        }
    }
    # right
    if ($c1 < ($ncols - 1)) {
        if ($row[$c1 + 1] !~ /[\.0-9]/) {
            return 1;
        }
    }
    # top
    if ($rr > 0) {
        my $cc0 = $c0;
        my $cc1 = $c1;
        if ($c0 > 0) {
            $cc0 = $c0 - 1;
        }
        if ($c1 < ($ncols - 1)) {
            $cc1 = $c1 + 1;
        }
        @row = @{$matrix[$rr - 1]};
        for (my $c = $cc0; $c <= $cc1; ++$c) {
            my $val = $row[$c];
            if ($val !~ /[\.0-9]/) {
                return 1;
            }
        }
    }
    # bottom
    if ($rr < ($nrows - 1)) {
        my $cc0 = $c0;
        my $cc1 = $c1;
        if ($c0 > 0) {
            $cc0 = $c0 - 1;
        }
        if ($c1 < ($ncols - 1)) {
            $cc1 = $c1 + 1;
        }
        @row = @{$matrix[$rr + 1]};
        for (my $c = $cc0; $c <= $cc1; ++$c) {
            my $val = $row[$c];
            if ($val !~ /[\.0-9]/) {
                return 1;
            }
        }
    }
    return 0;
}

my $acc = 0;

for (my $r = 0; $r < $nrows; ++$r) {
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
    my ($a0, $a1, $part_number) = (0, 0, 0);
    my $start = 0;
    do {
        ($a0, $a1, $part_number) = get_row_markers($r, $start);  
        my $pass = 0;
        if ($a0 > 0 && $a1 > 0) {
            $pass = is_valid($r, $a0, $a1);
            if ($pass) {
                $acc += $part_number;        
            }
            printf("%3d %3d (%3d) $pass\n", $a0, $a1, $part_number);
            $start = $a1 + 1;
        }
    } while (($a0 >= 0) && ($a1 >= 0));
}

print "$acc\n";
