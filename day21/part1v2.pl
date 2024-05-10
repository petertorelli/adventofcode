#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;

my $input_steps = 26501365;
$input_steps = 131 + 65;

my @N = (  0, -1 );
my @S = (  0,  1 );
my @E = (  1,  0 );
my @W = ( -1,  0 );
my @DIRS = ( \@N, \@S, \@E, \@W );

sub render {
    my ($size, $stones, $seen) = @_;
    my $o = 0;
    print "Render ".scalar(keys %$seen)."\n";
    for (my $y=0; $y<$size; ++$y) {
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

sub calchalfos {
    my ($step, $seen) = @_;
    my $c = 0;
    # "%seen" contains all of the O's, but we only need half of
    # them depending on the parity of the step we're at and the
    # parity of the coordinate sum.
    foreach my $pt (keys %$seen) {
        my ($x, $y) = split ' ', $pt;
        if (($x + $y) % 2 == ($step & 1)) {
            ++$c;
        }
    }
    return $c;
}

sub walk {
    my ($start, $steps, $stones, $size) = @_;
    my %seen;
    my @todo;
    my $curstep;
    my @cycles;

    push @todo, [ 0, $start ];
    my $laststep = 0;

    while (@todo) {
        my $next = shift @todo;
        my ($curstep, $start) = @$next;
        my ($x, $y) = @$start;

        if ($curstep != $laststep) {
            if ($laststep == $steps) {
                &render($size, $stones, \%seen);
                print "Total = ".&calchalfos($laststep, \%seen)."\n";
                return;
            }
            $laststep = $curstep;
        }

        my $seenkey = "$x $y";
        next if $seen{$seenkey};
        $seen{$seenkey} = 1;

        foreach my $dir (@DIRS) {
            my $nx = $x + $dir->[0];
            my $ny = $y + $dir->[1];
            next if $seen{"$nx $ny"};
            my $snx = $nx % $size;
            my $sny = $ny % $size;
            next if $stones->{"$snx $sny"};
            push @todo, [ $curstep + 1, [ $nx, $ny ] ];
        }
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
            die if $XMAX != $YMAX;
            my $size = $XMAX;
            &walk(\@start, $input_steps, \%stones, $size);
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