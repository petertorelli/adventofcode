#!/usr/bin/env perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw(reduce);

my $GAP_FACTOR = 1000000;

sub mprint {
    my ($src) = @_;
    for my $row (0..@$src-1) {
        printf "%5d ".join("", @{$src->[$row]})."\n", $row;
    }
}

sub transpose {
    my ($src, $dst) = @_;
    @$dst = ();
    for my $row (0..@$src-1) {
        for my $col (0..@{$src->[$row]}-1) {
            $dst->[$col][$row] = $src->[$row][$col];
        }
    }
}

sub finderows {
    my ($src) = @_;
    my %todo;
    for my $row (0 .. @$src-1) {
        my $not_empty = reduce { $a += $b eq '.' ? 0 : 1 } 0, @{$src->[$row]};
        unless ($not_empty) {
            $todo{$row} = 1;
        }
    }
    return %todo;
}

sub findpoints {
    my ($src) = @_;
    my @todo;
    for my $row (0..@$src-1) {
        for my $col (0..@{$src->[$row]}-1) {
            if ($src->[$row][$col] eq '#') {
                push @todo, [$col, $row];
            }
        }
    }
    return @todo;
}

sub main {
    my @data;
    my @tmp;
    
    while (<>) {
        chomp;
        push @data, [ split("") ];
    }

    mprint(\@data);

    my %erows;
    my %ecols;

    # Store the indices of empty rows and columns    
    %erows = finderows(\@data);
    transpose(\@data, \@tmp);
    %ecols = finderows(\@tmp);

    sub computelineardist {
        my ($n0, $n1, $gaps) = @_;
        my $dst = 0;
        ($n0, $n1) = ($n0 > $n1) ? ($n1, $n0) : ($n0, $n1);
        for my $n ($n0 + 1 .. $n1) {
            if (defined $gaps->{$n}) {
                $dst += $GAP_FACTOR;
            } else {
                $dst += 1;
            }
        }
        return $dst;
    }

    # Find manhattan distance between all unique pairs and sum
    my @pts = findpoints(\@data);
    my $total = 0;
    while (@pts) {
        my $pt1 = shift @pts;
        foreach my $pt2 (@pts) {
            my ($dr, $dc);
            $dr = computelineardist($pt1->[1], $pt2->[1], \%erows);
            $dc = computelineardist($pt1->[0], $pt2->[0], \%ecols);
            $total += $dr + $dc;
        }
    }
    print "$total\n";
}
main();