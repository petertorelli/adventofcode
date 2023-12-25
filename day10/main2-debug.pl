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
my %seen;

# [ n, e, s, w ]
my %exits = (
    '|' => ($N | $S),
    '-' => ($E | $W),
    'L' => ($N | $E),
    'J' => ($N | $W),
    '7' => ($W | $S),
    'F' => ($E | $S),
    '.' => 0,
    '│' => ($N | $S),
    '─' => ($E | $W),
    '└' => ($N | $E),
    '┘' => ($N | $W),
    '┐' => ($W | $S),
    '┌' => ($E | $S),
    '▒' => 0
);
my @data_main;
my @data_backup;
my $max_x;
my $max_y;

sub print_maze {
    my $data = shift @_;
    my @rows = @$data;
    for (my $y=0; $y<=$#rows; ++$y) {
        my @cols = @{$rows[$y]};
        print "\t".join("", @cols)."\n";
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
    my ($sx, $sy) = @_;
    my $dirs;
    $dirs |= $N if ($sy >      0) && ($exits{$rows[$sy - 1]->[$sx    ]} & $S);
    $dirs |= $E if ($sx < $max_x) && ($exits{$rows[$sy    ]->[$sx + 1]} & $W);
    $dirs |= $S if ($sy < $max_y) && ($exits{$rows[$sy + 1]->[$sx    ]} & $N);
    $dirs |= $W if ($sx >      0) && ($exits{$rows[$sy    ]->[$sx -1 ]} & $E);
    return $dirs;
}

sub build_graph {

    my $data = shift @_;
    my @rows = @$data;

    my ($depth, $sx, $sy, $dir) = @_;
    my $node = "$sx,$sy";
    my ($nx, $ny) = ($sx, $sy);
    $rows[$ny]->[$nx] = '*';#$depth;
    return if exists $seen{$node};
    $seen{$node} = $depth;
    my @todo;
    my $next;

    $rows[$ny]->[$nx] = '*';#$depth;
    
    #print_maze();
    #print "DEPTH $depth\n";
    #foreach my $dir (@dirs) {
        #printf "At ($nx, $ny) %04b  ($sx, $sy) [$max_x, $max_y]\n", $dir;
        if (($dir & $N) && ($sy > 0)) {
            #print "Check N\n";
            $ny = $sy - 1;
            $nx = $sx;
            $next = $rows[$ny]->[$nx];
            if (!$seen{"$nx,$ny"} && ($exits{$next} > 0)) {
                #print "Going N to $nx, $ny is $next\n";
                push @todo, { 'x' => $nx, 'y' => $ny, 'dir' => ($exits{$next} & ~$S) };
            }
        }
        if (($dir & $S) && ($sy < $max_y)) {
            #print "Check S\n";
            $ny = $sy + 1;
            $nx = $sx;
            $next = $rows[$ny]->[$nx];
            #print "Is NOT seen $nx,$ny? --> ".(!$seen{"$nx,$ny"})."\n";
            if (!$seen{"$nx,$ny"} && ($exits{$next} > 0)) {
                #print "Going S to $nx, $ny is $next\n";
                push @todo, { 'x' => $nx, 'y' => $ny, 'dir' => ($exits{$next} & ~$N) };
            }
        }
        if (($dir & $E) && ($sx < $max_x)) {
            #print "Check E\n";
            $ny = $sy;
            $nx = $sx + 1;
            $next = $rows[$ny]->[$nx];
            #print "Is NOT seen $nx,$ny? --> ".(!$seen{"$nx,$ny"})."\n";
            if (!$seen{"$nx,$ny"} && ($exits{$next} > 0)) {
                #print "Going E to $nx, $ny is $next\n";
                push @todo, { 'x' => $nx, 'y' => $ny, 'dir' => ($exits{$next} & ~$W) };
            }
        }
        if (($dir & $W) && ($sx > 0)) {
            #print "Check W\n";
            $ny = $sy;
            $nx = $sx - 1;
            $next = $rows[$ny]->[$nx];
            if (!$seen{"$nx,$ny"} && ($exits{$next} > 0)) {
                #print "Going W to $nx, $ny is $next\n";
                push @todo, { 'x' => $nx, 'y' => $ny, 'dir' => ($exits{$next} & ~$E) };
            }
        }
    #}
    #print "---> TODO = ".Dumper(\@todo);
    return @todo;
}





sub ascibox {
    my $data = shift @_;
    my @rows = @$data;
    for (my $y=0; $y<=$#rows; ++$y) {
        my @cols = @{$rows[$y]};
        for (my $x=0; $x<=$#cols; ++$x) {
            my $c = $rows[$y]->[$x];
            $c = '┐' if $c eq '7';
            $c = '└' if $c eq 'L';
            $c = '┘' if $c eq 'J';
            $c = '┌' if $c eq 'F';
            $c = '│' if $c eq '|';
            $c = '─' if $c eq '-';
            $c = '▒' if $c eq '.';
            $rows[$y]->[$x] = $c;
        }
    }
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

sub trace_edges {
    my $data = shift @_;
    my @rows = @$data;
    my ($sx, $sy, $dirs) = @_;
    my $depth = 0;
    my @todo = build_graph(\@rows, $depth, $sx, $sy, $dirs);
    do {
        my @newtodo;
        ++$depth;
        foreach my $step (@todo) {
            push @newtodo, build_graph(\@rows, $depth, $step->{'x'}, $step->{'y'}, $step->{'dir'});
        }
        @todo = @newtodo;
    } while scalar(@todo) > 0;
}

# Load the rows into tuples first...
while (<>) {
    chomp;
    my @els = split("");
    push @data_main, [ @els ];
    push @data_backup, [ @els ];
}
$max_y = scalar $#data_main;
$max_x = scalar $#{$data_main[0]};

print_maze(\@data_main);

print "------------\n";

my ($sx, $sy) = find_s(\@data_main);
my $dirs = find_s_dirs(\@data_main, $sx, $sy);

# S can only go in two dirs
if ($dirs == 0b1100) {
    $data_main[$sy]->[$sx] = 'L';
    $data_backup[$sy]->[$sx] = 'L';
}
elsif ($dirs == 0b1010) {
    $data_main[$sy]->[$sx] = '|';
    $data_backup[$sy]->[$sx] = '|';
}
elsif ($dirs == 0b1001) {
    $data_main[$sy]->[$sx] = 'J';
    $data_backup[$sy]->[$sx] = 'J';
}
elsif ($dirs == 0b0101) {
    $data_main[$sy]->[$sx] = '-';
    $data_backup[$sy]->[$sx] = '-';
}
elsif ($dirs == 0b0011) {
    $data_main[$sy]->[$sx] = '7';
    $data_backup[$sy]->[$sx] = '7';
}
elsif ($dirs == 0b0110) {
    $data_main[$sy]->[$sx] = 'F';
    $data_backup[$sy]->[$sx] = 'F';
}
print_maze(\@data_main);

trace_edges(\@data_main, $sx, $sy, $dirs);
print_maze(\@data_main);
print "------------\n";
# remove unused pipes
remove_unused(\@data_main, \@data_backup);


# Draw contour
#print_maze(\@data_backup);
#print "------------\n";
#ascibox(\@data_backup);
print_maze(\@data_backup);

print "------------\n";

# Ya know, each cell is actually 3x3 worth of information.
# If we just blew it up 3x the size, and then rendered each corner
# segment as asterisks, we could floodfill and divide by 3.
# I think there is also some information in F7 vs LJ etc. that can determine
# concavity, but I want to try this blow-up method.

my $new_max_x = $max_x * 3 + 3;
my $new_max_y = $max_y * 3 + 2; # HUH? XXX ???? why 2 and not 3?

my @big;
foreach (0 ... $new_max_y) {
    push @big, [ split("", '.' x $new_max_x)];
}


sub expand {
    $_ = shift @_;
    my @src = @$_;
    $_ = shift @_;
    my @dst = @$_;

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

sub floodfill {
    $_ = shift @_;
    my @src = @$_;
    my ($x, $y, $maxx, $maxy) = @_;
    return if $x < 0;
    return if $x > $maxx;
    return if $y < 0;
    return if $y > $maxy;
    die "Element not defined at $x $y" if (!defined $src[$y]) || (!defined $src[$y]->[$x]);
    return if $src[$y]->[$x] eq 'I';
    #return if $src[$y]->[$x] eq ' ';
    return if $src[$y]->[$x] eq '*';

    $src[$y]->[$x] = 'I';
    floodfill(\@src, $x + 1, $y, $maxx, $maxy);
    floodfill(\@src, $x - 1, $y, $maxx, $maxy);
    floodfill(\@src, $x, $y + 1, $maxx, $maxy);
    floodfill(\@src, $x, $y - 1, $maxx, $maxy);
}

sub count {
    $_ = shift @_;
    my @src = @$_;
    my $dots = 0;
    my $eyes = 0;
    foreach my $row (@src) {
        my @cols = @$row;
        foreach my $col (@cols) {
            ++$dots if $col eq '.';
            ++$eyes if $col eq 'I';
        }
    }
    printf("Eyes   %10.3f\n", $eyes);
    printf("Dots   %10.3f\n", $dots);
    printf("Eyes/3 %10.3f\n", $eyes/9);
    printf("Dots/3 %10.3f\n", $dots/9);
}

expand(\@data_backup, \@big);
# we know the input data has an empty corner so start at 0,0
floodfill(\@big, 0, 0, $max_x * 3 + 2, $max_y * 3 + 2);
print_maze(\@big);
count(\@big);