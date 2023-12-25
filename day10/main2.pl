#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;
# we're goin deep
no warnings 'recursion';
$| = 1;

my $N = 0b1000;
my $E = 0b0100;
my $S = 0b0010;
my $W = 0b0001;

# [ n, e, s, w ]
my %exits = (
    '|' => ($N | $S),
    '-' => ($E | $W),
    'L' => ($N | $E),
    'J' => ($N | $W),
    '7' => ($W | $S),
    'F' => ($E | $S),
    '.' => 0,
    '*' => 0,
);

sub print_maze {
    my $data = shift @_;
    my @rows = @$data;
    for (my $y=0; $y<=$#rows; ++$y) {
        my @cols = @{$rows[$y]};
        print join("", @cols)."\n";
    }
}

# Find S
sub find_s {
    my $data = shift @_;
    my @rows = @$data;
    my ($sx, $sy) = (-1, -1);
    OUTER: for (my $y=0; $y<=$#rows; ++$y) {
        my @cols = @{$rows[$y]};
        for (my $x=0; $x<=$#cols; ++$x) {
            if ($cols[$x] eq 'S') {
                ($sx, $sy) = ($x, $y);
                last OUTER;
            }
        }
    }
    return ($sx, $sy);
}

sub find_s_dirs {
    my $data = shift @_;
    my @rows = @$data;
    my ($sx, $sy, $maxx, $maxy) = @_;
    my $dirs;
    $dirs |= $N if ($sy >     0) && ($exits{$rows[$sy - 1]->[$sx    ]} & $S);
    $dirs |= $E if ($sx < $maxx) && ($exits{$rows[$sy    ]->[$sx + 1]} & $W);
    $dirs |= $S if ($sy < $maxy) && ($exits{$rows[$sy + 1]->[$sx    ]} & $N);
    $dirs |= $W if ($sx >     0) && ($exits{$rows[$sy    ]->[$sx -1 ]} & $E);
    return $dirs;
}

sub build_graph {

    my $data = shift @_;
    my @rows = @$data;

    my ($xseen, $depth, $sx, $sy, $dir, $maxx, $maxy) = @_;
    my %seen = %$xseen;
    my $node = "$sx,$sy";
    my ($nx, $ny) = ($sx, $sy);
    $rows[$ny]->[$nx] = '*';#$depth;
    return if exists $seen{$node};
    $seen{$node} = $depth;
    my @todo;
    my $next;

    $rows[$ny]->[$nx] = '*';#$depth;

    if (($dir & $N) && ($sy > 0)) {
        $ny = $sy - 1;
        $nx = $sx;
        $next = $rows[$ny]->[$nx];
        die "Bad exits lookup of '$next'" if not defined $exits{$next};
        if (!$seen{"$nx,$ny"} && ($exits{$next} > 0)) {
            push @todo, { 'x' => $nx, 'y' => $ny, 'dir' => ($exits{$next} & ~$S) };
        }
    }
    if (($dir & $S) && ($sy < $maxy)) {
        $ny = $sy + 1;
        $nx = $sx;
        $next = $rows[$ny]->[$nx];
        if (!$seen{"$nx,$ny"} && ($exits{$next} > 0)) {
            #print "Going S to $nx, $ny is $next\n";
            push @todo, { 'x' => $nx, 'y' => $ny, 'dir' => ($exits{$next} & ~$N) };
        }
    }
    if (($dir & $E) && ($sx < $maxx)) {
        $ny = $sy;
        $nx = $sx + 1;
        $next = $rows[$ny]->[$nx];
        if (!$seen{"$nx,$ny"} && ($exits{$next} > 0)) {
            push @todo, { 'x' => $nx, 'y' => $ny, 'dir' => ($exits{$next} & ~$W) };
        }
    }
    if (($dir & $W) && ($sx > 0)) {
        $ny = $sy;
        $nx = $sx - 1;
        $next = $rows[$ny]->[$nx];
        if (!$seen{"$nx,$ny"} && ($exits{$next} > 0)) {
            push @todo, { 'x' => $nx, 'y' => $ny, 'dir' => ($exits{$next} & ~$E) };
        }
    }
    return @todo;
}

sub remove_unused {
    my $data = shift @_;
    my @rows = @$data;
    $data = shift @_;
    my @backup = @$data;
    for (my $y=0; $y<=$#rows; ++$y) {
        my @cols = @{$rows[$y]};
        for (my $x=0; $x<=$#cols; ++$x) {
            my $c = $rows[$y]->[$x];
            if ($backup[$y]->[$x] eq $c) {
                $backup[$y]->[$x] = '.';
            }
        }
    }
}

# Need to do a BFS instead of a DFS, otherwise one side always wins
sub trace_edges {
    my $data = shift @_;
    my @rows = @$data;
    my ($sx, $sy, $dirs, $maxx, $maxy) = @_;
    my $depth = 0;
    my %seen;
    my @todo = build_graph(\@rows, \%seen, $depth, $sx, $sy, $dirs, $maxx, $maxy);
    do {
        my @newtodo;
        ++$depth;
        foreach my $step (@todo) {
            push @newtodo, build_graph(
                \@rows,
                \%seen,
                $depth,
                $step->{'x'},
                $step->{'y'},
                $step->{'dir'},
                $maxx, $maxy);
        }
        @todo = @newtodo;
    } while scalar(@todo) > 0;
}

sub replace_s {
    $_ = shift @_;
    my @src = @$_;
    my ($x, $y, $sval) = @_;
    my $c;
    if    ($sval == 0b1100) { $c = 'L'; }
    elsif ($sval == 0b1010) { $c = '|'; }
    elsif ($sval == 0b1001) { $c = 'J'; }
    elsif ($sval == 0b0101) { $c = '-'; }
    elsif ($sval == 0b0011) { $c = '7'; }
    elsif ($sval == 0b0110) { $c = 'F'; }
    else { die "Unknown S type: $sval"}
    $src[$y]->[$x] = $c;
}

# The graph is now 3x larger, so we can capture the essence of the tiles
# replace each tile with a 3x3 rendering, but use spaces, ' ', instead of
# dots so that we don't floodfill tiles that don't count.
sub expand {
    $_ = shift @_;
    my @src = @$_; # original maze
    $_ = shift @_;
    my @dst = @$_; # 3x maze

    for (my $y=0; $y<=$#src; ++$y) {
        my @cols = @{$src[$y]};
        for (my $x=0; $x<=$#cols; ++$x) {
            my $c = $src[$y]->[$x];
            if ($c eq '|') {
                $dst[(3 * $y) + 0]->[(3 * $x) + 0] = ' ';
                $dst[(3 * $y) + 0]->[(3 * $x) + 1] = '*';
                $dst[(3 * $y) + 0]->[(3 * $x) + 2] = ' ';

                $dst[(3 * $y) + 1]->[(3 * $x) + 0] = ' ';
                $dst[(3 * $y) + 1]->[(3 * $x) + 1] = '*';
                $dst[(3 * $y) + 1]->[(3 * $x) + 2] = ' ';

                $dst[(3 * $y) + 2]->[(3 * $x) + 0] = ' ';
                $dst[(3 * $y) + 2]->[(3 * $x) + 1] = '*';
                $dst[(3 * $y) + 2]->[(3 * $x) + 2] = ' ';
            }
            elsif ($c eq '-') {
                $dst[(3 * $y) + 0]->[(3 * $x) + 0] = ' ';
                $dst[(3 * $y) + 0]->[(3 * $x) + 1] = ' ';
                $dst[(3 * $y) + 0]->[(3 * $x) + 2] = ' ';

                $dst[(3 * $y) + 1]->[(3 * $x) + 0] = '*';
                $dst[(3 * $y) + 1]->[(3 * $x) + 1] = '*';
                $dst[(3 * $y) + 1]->[(3 * $x) + 2] = '*';

                $dst[(3 * $y) + 2]->[(3 * $x) + 0] = ' ';
                $dst[(3 * $y) + 2]->[(3 * $x) + 1] = ' ';
                $dst[(3 * $y) + 2]->[(3 * $x) + 2] = ' ';
            }
            elsif ($c eq 'F') {
                $dst[(3 * $y) + 0]->[(3 * $x) + 0] = ' ';
                $dst[(3 * $y) + 0]->[(3 * $x) + 1] = ' ';
                $dst[(3 * $y) + 0]->[(3 * $x) + 2] = ' ';

                $dst[(3 * $y) + 1]->[(3 * $x) + 0] = ' ';
                $dst[(3 * $y) + 1]->[(3 * $x) + 1] = '*';
                $dst[(3 * $y) + 1]->[(3 * $x) + 2] = '*';

                $dst[(3 * $y) + 2]->[(3 * $x) + 0] = ' ';
                $dst[(3 * $y) + 2]->[(3 * $x) + 1] = '*';
                $dst[(3 * $y) + 2]->[(3 * $x) + 2] = ' ';
            }
            elsif ($c eq '7') {
                $dst[(3 * $y) + 0]->[(3 * $x) + 0] = ' ';
                $dst[(3 * $y) + 0]->[(3 * $x) + 1] = ' ';
                $dst[(3 * $y) + 0]->[(3 * $x) + 2] = ' ';

                $dst[(3 * $y) + 1]->[(3 * $x) + 0] = '*';
                $dst[(3 * $y) + 1]->[(3 * $x) + 1] = '*';
                $dst[(3 * $y) + 1]->[(3 * $x) + 2] = ' ';

                $dst[(3 * $y) + 2]->[(3 * $x) + 0] = ' ';
                $dst[(3 * $y) + 2]->[(3 * $x) + 1] = '*';
                $dst[(3 * $y) + 2]->[(3 * $x) + 2] = ' ';
            }
            elsif ($c eq 'J') {
                $dst[(3 * $y) + 0]->[(3 * $x) + 0] = ' ';
                $dst[(3 * $y) + 0]->[(3 * $x) + 1] = '*';
                $dst[(3 * $y) + 0]->[(3 * $x) + 2] = ' ';

                $dst[(3 * $y) + 1]->[(3 * $x) + 0] = '*';
                $dst[(3 * $y) + 1]->[(3 * $x) + 1] = '*';
                $dst[(3 * $y) + 1]->[(3 * $x) + 2] = ' ';

                $dst[(3 * $y) + 2]->[(3 * $x) + 0] = ' ';
                $dst[(3 * $y) + 2]->[(3 * $x) + 1] = ' ';
                $dst[(3 * $y) + 2]->[(3 * $x) + 2] = ' ';
            }
            elsif ($c eq 'L') {
                $dst[(3 * $y) + 0]->[(3 * $x) + 0] = ' ';
                $dst[(3 * $y) + 0]->[(3 * $x) + 1] = '*';
                $dst[(3 * $y) + 0]->[(3 * $x) + 2] = ' ';

                $dst[(3 * $y) + 1]->[(3 * $x) + 0] = ' ';
                $dst[(3 * $y) + 1]->[(3 * $x) + 1] = '*';
                $dst[(3 * $y) + 1]->[(3 * $x) + 2] = '*';

                $dst[(3 * $y) + 2]->[(3 * $x) + 0] = ' ';
                $dst[(3 * $y) + 2]->[(3 * $x) + 1] = ' ';
                $dst[(3 * $y) + 2]->[(3 * $x) + 2] = ' ';
            }
        }
    }
}

# recursive floodfill will be slow on perl b/c it is very deep.
sub floodfill {
    $_ = shift @_;
    my @src = @$_;
    my ($x, $y, $maxx, $maxy) = @_;
    return if $x < 0;
    return if $x > $maxx;
    return if $y < 0;
    return if $y > $maxy;
    die "Element not defined at $x $y" if (!defined $src[$y]) || (!defined $src[$y]->[$x]);
    return if $src[$y]->[$x] eq 'O';
    # NOTE:
    # Move through but tag spaces, one of the two final counts will be wrong
    # because of this, so try a different OUTSIDE start point to make sure
    # you really are outside the maze.
    #return if $src[$y]->[$x] eq ' ';
    return if $src[$y]->[$x] eq '*';

    $src[$y]->[$x] = 'O';
    floodfill(\@src, $x + 1, $y, $maxx, $maxy);
    floodfill(\@src, $x - 1, $y, $maxx, $maxy);
    floodfill(\@src, $x, $y + 1, $maxx, $maxy);
    floodfill(\@src, $x, $y - 1, $maxx, $maxy);
}

sub count {
    $_ = shift @_;
    my @src = @$_;
    my $dots = 0;
    my $ohs = 0;
    foreach my $row (@src) {
        my @cols = @$row;
        foreach my $col (@cols) {
            ++$dots if $col eq '.';
            ++$ohs if $col eq 'O';
        }
    }
    printf("Ohs    %10.3f\n", $ohs);
    printf("Dots   %10.3f\n", $dots);
    printf("Ohs/3  %10.3f\n", $ohs/9);
    printf("Dots/3 %10.3f\n", $dots/9);
}

########### START ###############

sub main {
    my @data_main;
    my @data_backup;
    my $max_x;
    my $max_y;

    while (<>) {
        chomp;
        my @els = split("");
        push @data_main, [ @els ];
        push @data_backup, [ @els ];
    }
    $max_y = scalar $#data_main;
    $max_x = scalar $#{$data_main[0]};
    my ($sx, $sy) = find_s(\@data_main);
    my $dirs = find_s_dirs(\@data_main, $sx, $sy, $max_x, $max_y);

    print "------------ START MAZE\n";
    print_maze(\@data_main);

    # For floodfill we'll need a real edge tile
    print "------------ REPLACE START TILE\n";
    replace_s(\@data_main, $sx, $sy, $dirs);
    replace_s(\@data_backup, $sx, $sy, $dirs);
    print_maze(\@data_main);

    print "------------ EDGE MASKING\n";
    trace_edges(\@data_main, $sx, $sy, $dirs, $max_x, $max_y);
    print_maze(\@data_main);

    print "------------ UNUSED PIPE REMOVAL\n";
    remove_unused(\@data_main, \@data_backup);
    # Note we switch to the backup maze here
    print_maze(\@data_backup);

    #
    #
    #
    # Ya know, each cell is actually 3x3 worth of information.
    # If we just blew it up 3x the size, and then rendered each corner
    # segment as asterisks, we could floodfill and divide by 3.
    # I think there is also some information in F7 vs LJ etc. that can determine
    # concavity, but I want to try this blow-up method.
    #
    #

    my $new_max_x = $max_x * 3 + 3;
    # vvvvvvv I got a bug somewhere, but it works!
    my $new_max_y = $max_y * 3 + 2; # HUH? XXX ???? why 2 and not 3?
    my @big;
    foreach (0 ... $new_max_y) {
        push @big, [ split("", '.' x $new_max_x)];
    }

    expand(\@data_backup, \@big);
    # we know the input data has an empty corner so start at 0,0
    floodfill(\@big, 0, 0, $max_x * 3 + 2, $max_y * 3 + 2);

    print "------------ EXPANDED AND FILLED\n";
    print_maze(\@big);

    count(\@big);
}

main();