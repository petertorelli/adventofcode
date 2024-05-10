#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;

my @N = (  0, -1 );
my @S = (  0,  1 );
my @E = (  1,  0 );
my @W = ( -1,  0 );
my @DIRS = ( \@N, \@S, \@E, \@W );

sub render {
    my ($size, $stones, $seen) = @_;
    my $o = 0;
    for (my $y=0; $y<$size; ++$y) {
        printf "%03d: ", $y;
        for (my $x=0; $x<$size; ++$x) {
            if (defined $stones->{"$x $y"}) {
                print "#";
            } elsif (defined $seen->{"$x $y"}) {
                ++$o;
                print "O";
            } else {
                print ".";
            }
        }
        print "\n";
    }
    print "o=$o\n";
}

sub walk {
    my ($start, $steps, $stones, $size) = @_;
    my %seen;
    my @todo;
    my $curstep;

    push @todo, [ 0, $start ];
    my $laststep = 0;

    while (@todo) {
        my $next = shift @todo;
        my ($curstep, $start) = @$next;
        if ($laststep != $curstep) {
            print "$curstep ".scalar(@todo)."\n";
        }
        my $key = $start->[0] . ' ' . $start->[1];
        if ($curstep > $steps) {
            &render($size, $stones, \%seen);
            return;
        }
        if ($curstep != $laststep) {
            undef %seen;
        }
        if ($seen{$key}) {
            next;
        }
        $seen{$key} = 1;
        foreach my $dir (@DIRS) {
            my $nx = $start->[0] + $dir->[0];
            my $ny = $start->[1] + $dir->[1];
            my $stonekey = "$nx $ny";
            if (defined $stones->{$stonekey}) {

            } else {
                push @todo, [ $curstep + 1, [$nx, $ny ] ];
            }
        }
        $laststep = $curstep;
    }
}

sub main {
    my @start;
    my $XMAX = 0;
    my $YMAX = 0;
    my %stones;
    my $size;

    while (<>) {
        if (/^\s*$/) {
            die "xmax $XMAX ymax $YMAX" if $XMAX != $YMAX;
            my $size = $XMAX;
            &walk(\@start, 64, \%stones, $size);
            return;
        } else {
            chomp;
            my @parts = split '';
            $XMAX = @parts;
            my $x = 0;
            my $y = 0;
            foreach (@parts) {
                if ($_ eq '#') {
                    $stones{"$x $YMAX"} = 1;
                } elsif ($_ eq 'S') {
                    @start = ( $x, $YMAX );
                }
                ++$x;
            }
            ++$YMAX;
        }
    }
}

&main;