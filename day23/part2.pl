#!/usr/bin/env perl
#use warnings;
use strict;
use Data::Dumper;
use Storable 'dclone';

my @N = (  0, -1 );
my @S = (  0,  1 );
my @E = (  1,  0 );
my @W = ( -1,  0 );
my @DIRS = ( \@N, \@S, \@E, \@W );

sub render {
    my ($seen, $map, $max) = @_;
    my $sum = 0;
    print "    ";
    for (my $x=0; $x<$max->[0]; ++$x) {
        print $x % 10;
    }
    print "\n";
    print "    ";
    for (my $x=0; $x<$max->[0]; ++$x) {
        print int($x / 10) % 10;
    }
    print "\n";
    print "    ";
    for (my $x=0; $x<$max->[0]; ++$x) {
        print int($x / 100) % 10;
    }
    print "\n";
    print "    ";
    for (my $x=0; $x<$max->[0]; ++$x) {
        print "|";
    }
    print "\n";

    for (my $y=0; $y<$max->[1]; ++$y) {
        printf "%03d-", $y;
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

# Find all the coordinates in the graph where the path splits; these will
# be the vertices of the graph. This is just a set.
sub findchoices {
    my ($map, $max, $cnodes) = @_;
    for (my $y=0; $y<$max->[1]; ++$y) {
        for (my $x=0; $x<$max->[0]; ++$x) {
            my $parent = "$x,$y";
            my $c = $map->{$parent};
            if (defined $c) {
                my $choices = 0;
                foreach my $dir (@DIRS) {
                    my @next = ($x + $dir->[0], $y + $dir->[1]);
                    my $nkey = join(',', @next);
                    ++$choices if defined $map->{$nkey};
                }
                if ($choices > 2) {
                    die "Slope at decision at $parent" if $c ne '.';
                    $cnodes->{$parent} = 1;
                }
            }
        }
    }
    #&render($cnodes, $map, $max);
}

# Find the edge distances to all the child vertices from a parent.
sub measure {
    my ($start, $stop, $map, $lastseen, $cnodes, $found, $depth) = @_;
    my %seen = %{dclone $lastseen};

    if (defined $seen{$start}) {
        return;
    }
    $seen{$start} = 1;

    if (defined $cnodes->{$start} && $depth > 0) {
        push @$found, [ $start, $depth ];
        return;
    }

    if ($start eq $stop) {
        push @$found, [ $start, $depth ];
        return;
    }

    my ($x, $y) = split ',', $start;

    foreach my $dir (@DIRS) {
        my @next = ($x + $dir->[0], $y + $dir->[1]);
        my $nkey = "$next[0],$next[1]";
        if (defined $map->{$nkey}) {
            &measure($nkey, $stop, $map, \%seen, $cnodes, $found, $depth + 1);
        }
    }
}

my $scount = 0;
my @solutions;

# DFS walk of all solutions...
sub walk {
    my ($start, $stop, $graph, $lastseen, $dist) = @_;
    my %seen = %{dclone $lastseen};

    if (defined $seen{$start}) {
        return;
    }
    $seen{$start} = 1;
    
    if ($start eq $stop) {
        #print "Solution: ".join(' - ', @path)."\n";
        push @solutions, $dist;
        ++$scount;
        print "$scount\n" if $scount % 100 == 0;
        return;
    }

    my @children = keys %{$graph->{$start}};

    foreach my $child (@children) {
        &walk($child, $stop, $graph, \%seen, $dist + $graph->{$start}{$child});
    }

}

sub main {
    my $maxx = 0;
    my $maxy = 0;
    my %map;
    my %cnodes;
    my %graph;
    while (<>) {
        chomp;
        if (/^\s*$/) {
            # process
            #print "Size [$maxx, $maxy]\n";
            my (@max) = ($maxx, $maxy);
            my (@start) = (1, 0);
            my $startkey = join ',', @start;
            my (@stop) = ($maxx - 2, $maxy - 1);
            my $stopkey = join ',', @stop;
            my %seen;
            my @found;

            # Find all the verticies
            &findchoices(\%map, \@max, \%cnodes);
            # Find all the edges and construct a graph
            &measure($startkey, $stopkey, \%map, \%seen, \%cnodes, \@found, 0);
            foreach my $tuple (@found) {
                my ($node, $depth) = @$tuple;
                $graph{$startkey}{$node} = $depth;
                #print "\t\"$startkey\" -> \"$node\" [ label = \"$depth\" ];\n";
            }
            foreach my $choice (keys %cnodes) {
                my @found;
                &measure($choice, $stopkey, \%map, \%seen, \%cnodes, \@found, 0);
                foreach my $tuple (@found) {
                    my ($node, $depth) = @$tuple;
                    $graph{$choice}{$node} = $depth;
                    #print "\t\"$choice\" -> \"$node\" [ label = \"$depth\" ]; \n";
                }
            }
            #print Dumper \%graph;
            #print "Nodes = ".scalar(keys %graph)."\n";
            # Walk the graph
            my %nseen;
            &walk($startkey, $stopkey, \%graph, \%nseen, 0);
            print "Max = ".(sort {$b <=> $a} @solutions)[0]."\n";
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
