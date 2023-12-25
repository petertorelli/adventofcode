#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;

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
    '.' => 0
);
my @rows;
my $max_x;
my $max_y;

sub print_maze {
    for (my $y=0; $y<=$#rows; ++$y) {
        my @cols = @{$rows[$y]};
        print "\t".join("", @cols)."\n";
    }
}

sub find_s {
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
    my ($sx, $sy) = @_;
    my $dirs;
    $dirs |= $N if ($sy >      0) && ($exits{$rows[$sy - 1]->[$sx    ]} & $S);
    $dirs |= $E if ($sx < $max_x) && ($exits{$rows[$sy    ]->[$sx + 1]} & $W);
    $dirs |= $S if ($sy < $max_y) && ($exits{$rows[$sy + 1]->[$sx    ]} & $N);
    $dirs |= $W if ($sx >      0) && ($exits{$rows[$sy    ]->[$sx -1 ]} & $E);
    return $dirs;
}

my %seen;
sub get_next_steps {
    my ($depth, $sx, $sy, @dirs) = @_;
    my $node = "$sx,$sy";
    return if exists $seen{$node};
    $seen{$node} = $depth;
    my @todo;
    my $next;
    my ($nx, $ny) = ($sx, $sy);

    $rows[$ny]->[$nx] = '*';#$depth;
    
    #print_maze();
    print "DEPTH $depth\n";
    foreach my $dir (@dirs) {
        printf "At ($nx, $ny) %04b\n", $dir;
        if (($dir & $N) && ($sy > 0)) {
            print "Check N\n";
            $ny = $sy - 1;
            $nx = $sx;
            $next = $rows[$ny]->[$nx];
            if (!$seen{"$nx,$ny"} && ($exits{$next} > 0)) {
                print "Going N to $nx, $ny is $next\n";
                push @todo, { 'x' => $nx, 'y' => $ny, 'dir' => ($exits{$next} & ~$S) };
            }
        }
        if (($dir & $S) && ($sy < $max_y)) {
            print "Check S\n";
            $ny = $sy + 1;
            $nx = $sx;
            $next = $rows[$ny]->[$nx];
            print "Is NOT seen $nx,$ny? --> ".(!$seen{"$nx,$ny"})."\n";
            if (!$seen{"$nx,$ny"} && ($exits{$next} > 0)) {
                print "Going S to $nx, $ny is $next\n";
                push @todo, { 'x' => $nx, 'y' => $ny, 'dir' => ($exits{$next} & ~$N) };
            }
        }
        if (($dir & $E) && ($sx < $max_x)) {
            print "Check E\n";
            $ny = $sy;
            $nx = $sx + 1;
            $next = $rows[$ny]->[$nx];
            print "Is NOT seen $nx,$ny? --> ".(!$seen{"$nx,$ny"})."\n";
            if (!$seen{"$nx,$ny"} && ($exits{$next} > 0)) {
                print "Going E to $nx, $ny is $next\n";
                push @todo, { 'x' => $nx, 'y' => $ny, 'dir' => ($exits{$next} & ~$W) };
            }
        }
        if (($dir & $W) && ($sx > 0)) {
            print "Check W\n";
            $ny = $sy;
            $nx = $sx - 1;
            $next = $rows[$ny]->[$nx];
            if (!$seen{"$nx,$ny"} && ($exits{$next} > 0)) {
                print "Going W to $nx, $ny is $next\n";
                push @todo, { 'x' => $nx, 'y' => $ny, 'dir' => ($exits{$next} & ~$E) };
            }
        }
    }
    print "---> TODO = ".Dumper(\@todo);
    return @todo;
}




# Load the rows into tuples first...
while (<>) {
    chomp;
    my @els = split("");
    push @rows, [ @els ];
}

#print_maze();
#print "------------\n";


$max_y = scalar $#rows;
$max_x = scalar $#{$rows[0]};

my ($sx, $sy) = find_s();
my @dirs = find_s_dirs($sx, $sy);

my $depth = 0;
my @todo = get_next_steps($depth, $sx, $sy, @dirs);
do {
    my @newtodo;
    ++$depth;
    foreach my $step (@todo) {
        push @newtodo, get_next_steps($depth, $step->{'x'}, $step->{'y'}, $step->{'dir'});
    }
    @todo = @newtodo;
} while scalar(@todo) > 0;


