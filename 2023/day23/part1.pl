#!/usr/bin/env perl
use warnings;
use strict;
use Data::Dumper;
use Storable 'dclone';

my @N = (  0, -1 );
my @S = (  0,  1 );
my @E = (  1,  0 );
my @W = ( -1,  0 );
my @DIRS = ( \@N, \@S, \@E, \@W );

my %quickd = (
    '>' => \@E,
    '<' => \@W,
    'v' => \@S,
    '^' => \@N, # didn't see any of these?
);

sub render {
    my ($seen, $map, $max) = @_;
    my $sum = 0;
    for (my $y=0; $y<$max->[1]; ++$y) {
        for (my $x=0; $x<$max->[0]; ++$x) {
            my $key = "$x,$y";
            my $c = $map->{$key};
            if (defined $c) {
                if (defined $seen->{$key}) {
                    $c = 'O';
                    ++$sum;
                }
            }
            print defined $c ? $c : '#';
        }
        print "\n";
    }
    print "Sum=$sum\n";
    return $sum;
}

sub count {
    my ($seen, $map, $max) = @_;
    my $sum = 0;
    for (my $y=0; $y<$max->[1]; ++$y) {
        for (my $x=0; $x<$max->[0]; ++$x) {
            my $key = "$x,$y";
            my $c = $map->{$key};
            if (defined $c) {
                if (defined $seen->{$key}) {
                    ++$sum;
                }
            }
        }
    }
    return $sum;
}

my @g_solutions;

sub traverse {
    my ($cur, $stop, $map, $lastseen, $max) = @_;
    my @todo;
    my %seen = %{ dclone $lastseen };

    my $key = join(',', @$cur);
    # Hmm... we might end up crossing a path if forced by slopes
    return if defined $seen{$key};
    $seen{$key} = 1;

    my @go;

    # Use @go = @DIRS for part 2.
    if ($map->{$key} eq '.') {
        @go = @DIRS;
    } else {
        push @go, $quickd{$map->{$key}};
    }

    foreach my $dir (@go) {
        my @next = ($cur->[0] + $dir->[0], $cur->[1] + $dir->[1]);
        $key = join(',', @next);
        push @todo, \@next if defined $map->{$key};
    }

    if (@todo > 0) {
        foreach my $next (@todo) {
            if (($next->[0] == $stop->[0]) && ($next->[1] == $stop->[1])) {
                #&render(\%seen, $map, $max);
                print "Found solution\n";
                push @g_solutions, \%seen;
#                my $total = &count(\%seen, $map, $max);
            } else {
                &traverse($next, $stop, $map, \%seen, $max);
            }
        }
    }
}

sub main {
    my $maxx = 0;
    my $maxy = 0;
    my %map;
    while (<>) {
        chomp;
        if (/^\s*$/) {
            # process
            print "Size [$maxx, $maxy]\n";
            my (@max) = ($maxx, $maxy);
            my (@start) = (1, 0);
            my (@stop) = ($maxx - 2, $maxy - 1);
            my %seen;
            &traverse(\@start, \@stop, \%map, \%seen, \@max);
            print "Found ".scalar @g_solutions." solutions\n";
            my $maxc = -1;
            my $maxseen;
            foreach my $path (@g_solutions) {
                my $c = &count($path, \%map, \@max);
                if ($c > $maxc) {
                    $maxc = $c;
                    $maxseen = $path;
                }
            }
            print "Longest path is $maxc\n";
            return;
        } else {
            my @spots = split '';
            $maxx = scalar @spots;
            for (my $x=0; $x < @spots; ++$x) {
                unless ($spots[$x] eq '#') {
                    $map{"$x,$maxy"} = $spots[$x];
                }
            }
            ++$maxy;
        }
    }
}

&main;
