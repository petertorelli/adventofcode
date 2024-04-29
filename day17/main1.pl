#!/usr/bin/env perl
use warnings;
use strict;

my $XMAX;
my $YMAX;
my $MAX = 10;
my $MIN = 4;

my @NORTH = ( 0, -1);
my @SOUTH = ( 0,  1);
my @EAST =  ( 1,  0);
my @WEST =  (-1,  0);

my @DIRS = ( \@NORTH, \@SOUTH, \@EAST, \@WEST  );

sub printm {
    my ($m) = @_;
    my $i = 0;
    foreach my $row (@$m) {
        printf "\t\t%03d: ", $i++;
        print join('', @$row)."\n";
    }
    print "\n";
}

sub serialize {
    my ($n) = @_;
    return sprintf("%dx%d:%dx%d:%d", 
        $n->{pt}[0],
        $n->{pt}[1],
        $n->{dir}[0],
        $n->{dir}[1],
        $n->{c}
    );
}

sub search {
    my ($m, $rstart, $rgoal) = @_;

    # Nodes to consider
    my @todo;
    # Nodes we've seen
    my %seen;

    # Since this scenario requires more than just [x, y] coordinate, but also
    # the direction of approach AND the number of steps in the same direciton,
    # we need to encode a lot more data into the current state. We also cannot
    # rely on the traditional %parent tree to reconstruct the winning path,
    # instead every item on the heap has to store its own path.
    push @todo, { cost => 0, pt => $rstart, dir => \@NORTH, c => 1, path => [ $rstart ]};
    push @todo, { cost => 0, pt => $rstart, dir => \@SOUTH, c => 1, path => [ $rstart ]};
    push @todo, { cost => 0, pt => $rstart, dir => \@EAST , c => 1, path => [ $rstart ]};
    push @todo, { cost => 0, pt => $rstart, dir => \@WEST , c => 1, path => [ $rstart ]};

    while (@todo) {
        # Linear sort, can we make this faster? Sorted insert maybe?
        @todo = sort {
            $a->{'cost'} <=> $b->{'cost'}
        } @todo;
        my $cur = shift @todo;

        my $key = &serialize($cur);
        next if $seen{$key};
        $seen{$key} = 1;

        my ($x0, $y0) = @{$cur->{'pt'}};
        my ($dx, $dy) = @{$cur->{'dir'}};
        my ($x1, $y1)= ($x0 + $dx, $y0 + $dy);

        next if ($x1 < 0 || $x1 > ($XMAX - 1));
        next if ($y1 < 0 || $y1 > ($YMAX - 1));

        if ($x0 == $rgoal->[0] && $y0 == $rgoal->[1]) {
            if (($cur->{'c'} <= $MAX)) {
                return &reconstruct($m, $cur);
            }
        }

        my $ncost = $cur->{'cost'} + $m->[$y1][$x1];

        foreach my $ndir (@DIRS) {
            my ($ndx, $ndy) = @$ndir;

            next if ($ndx == -$dx) && ($ndy == -$dy);

            my $nc = ($dx == $ndx) && ($dy == $ndy) ? ($cur->{'c'} + 1) : 1;

            # Part 1
            next if $nc > $MAX;
            # Part 2
            next if (($dx != $ndx) || ($dy != $ndy)) && ($cur->{'c'} < $MIN);

            my $nxt = {
                cost => $ncost,
                pt => [ $x1, $y1 ],
                dir => [ $ndx, $ndy ],
                c => $nc,
                path => [ @{$cur->{'path'}}, [ $x1, $y1 ] ]
            };
            my $nkey = &serialize($nxt);
            push @todo, $nxt if not defined $seen{$nkey};
        }
    }
    die "Failed to find a solution";
}

sub main {
    my @grid;

    while (<>) {
        chomp;
        if (/^\s*$/) {
            $YMAX = scalar @grid;
            $XMAX = scalar @{$grid[0]};
            my $score = &search(\@grid, [0, 0], [$XMAX - 1, $YMAX - 1]);
            print "$score\n";
            last;
            #&a_star(\@grid, [0, 0], [2, 1]);
        } else {
            push @grid, [ split '' ];
        }
    }
}

sub reconstruct {
    my ($m, $el) = @_;
    my @copy;
    for (my $y=0;$y<$YMAX;++$y) {
        for (my $x=0;$x<$XMAX;++$x) {
            $copy[$y][$x] = $m->[$y][$x];
        }
    }
    my $path = $el->{'path'};
    my $e = 0;
    shift @$path; # this screwed me up!
    foreach my $pt (@$path) {
        my ($x, $y) = @$pt;
        my $val = $m->[$y][$x];
        $e += $val;
        $copy[$y][$x] = "\033[101;97m$val\033[0m";
    }
    &printm(\@copy);
    print "$e\n";
    return $e;
}


&main;
