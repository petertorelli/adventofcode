#!/usr/bin/env perl
use warnings;
use strict;

my $XMAX;
my $YMAX;

my %dirbits = (
    'n' => 1,
    'e' => 2,
    's' => 4,
    'w' => 8,
);

my $depth = 0;

my @energy;

sub fill_energy {
    my $dots = 0 x $XMAX;
    for (my $y=0; $y<$YMAX; ++$y) {
        push @energy, [ split '', $dots ]
    }
}
sub printe {
    my ($m) = @_;
    my $count = 0;
    my $i=0;
    foreach my $row (@$m) {
        #printf "\t%02d: ", $i++;
        foreach my $col (@$row) {
            #printf "%x", $col;
            ++$count unless $col == 0;
        }
        #print "\n";
    }
    return $count;
}


sub printm {
    my ($m) = @_;
    my $i = 0;

    foreach my $row (@$m) {
        printf "\t%02d: ", $i++;
        print join('', @$row)."\n";
    }
    print "\n";
}

sub go {
    my ($m, $x, $y, $d) = @_;

    my $c = $m->[$y][$x];

    return if ! defined $c;
    #print "$depth [$x,$y]:$d -> $c\n";

    #printe(\@energy);
    if ($d eq 'n' && $y < 0) {
    } elsif ($d eq 's' && $y >= $YMAX) {
    } elsif ($d eq 'w' && $x < 0) {
    } elsif ($d eq 'e' && $x >= $XMAX) {
    } elsif ($c =~ m/[\\\/\|\-]/) {
        if ($c eq '|') {
            &splitter_ns($m, $x, $y, $d);
        } elsif ($c eq '-') {
            &splitter_ew($m, $x, $y, $d);
        } elsif ($c eq '/') {
            &mirror_swne($m, $x, $y, $d);
        } elsif ($c eq '\\') {
            &mirror_nwse($m, $x, $y, $d);
        }
    } else {
        $energy[$y]->[$x] |= $dirbits{$d};
        if ($d eq 'n') {
            --$y;
        } elsif ($d eq 'e') {
            ++$x;
        } elsif ($d eq 's') {
            ++$y;
        } elsif ($d eq 'w') {
            --$x;
        }
        &go($m, $x, $y, $d);
    }
    #print "\tdone [$x, $y]:$d\n";
}

# |
sub splitter_ns {
    my ($m, $x, $y, $d) = @_;
    ++$depth;
    if ($d eq 'n' || $d eq 's') {
        $energy[$y]->[$x] |= $dirbits{$d};
        if ($d eq 'n') {
            &go($m, $x, $y - 1, $d);
        } else {
            &go($m, $x, $y + 1, $d);
        }
    } else {
        if ($energy[$y]->[$x] & $dirbits{$d}) {
            #print "\t\t$depth: rejecting ns split @ [$x, $y]\n";
        } else {
            $energy[$y]->[$x] |= $dirbits{$d};
            #print "\t\t$depth: splitting n @ [$x, $y]\n";
            &go($m, $x, $y - 1, 'n');
            #print "\t\t$depth: splitting s @ [$x, $y]\n";
            &go($m, $x, $y + 1, 's');
        }
    }
    --$depth;
}

# -
sub splitter_ew {
    my ($m, $x, $y, $d) = @_;
    ++$depth;
    if ($d eq 'e' || $d eq 'w') {
        $energy[$y]->[$x] |= $dirbits{$d};
        if ($d eq 'e') {
            &go($m, $x + 1, $y, $d);
        } else {
            &go($m, $x - 1, $y, $d);
        }
    } else {
        if ($energy[$y]->[$x] & $dirbits{$d}) {
            #print "\t\t$depth: rejecting ew split @ [$x, $y]\n";
        } else {
            $energy[$y]->[$x] |= $dirbits{$d};
            #print "\t\t$depth: splitting e @ [$x, $y]\n";
            &go($m, $x + 1, $y, 'e');
            #print "\t\t$depth: splitting w @ [$x, $y]\n";
            &go($m, $x - 1, $y, 'w');
        }
    }
    --$depth;
}

# \
sub mirror_nwse {
    my ($m, $x, $y, $d) = @_;
    if ($d eq 'n') {
        if ($energy[$y]->[$x] & $dirbits{$d}) {
            #print "\t\tmirror_nwse rejecting w reflection at [$x, $y]\n";
        } else {
            $energy[$y]->[$x] |= $dirbits{$d};
            #print "\t\tmirror_nwse mirror w\n";
            &go($m, $x - 1, $y, 'w');
        }
    } elsif ($d eq 'e') {
        if ($energy[$y]->[$x] & $dirbits{$d}) {
            #print "\t\tmirror_nwse rejecting s reflection at [$x, $y]\n";
        } else {
            $energy[$y]->[$x] |= $dirbits{$d};
            #print "\t\tmirror_nwse mirror s\n";
            &go($m, $x, $y + 1, 's');
        }
    } elsif ($d eq 's') {
        if ($energy[$y]->[$x] & $dirbits{$d}) {
            #print "\t\tmirror_nwse rejecting e reflection at [$x, $y]\n";
        } else {
            $energy[$y]->[$x] |= $dirbits{$d};
            #print "\t\tmirror_nwse mirror e\n";
            &go($m, $x + 1, $y, 'e');
        }
    } elsif ($d eq 'w') {
        if ($energy[$y]->[$x] & $dirbits{$d}) {
            #print "\t\tmirror_nwse rejecting n reflection at [$x, $y]\n";
        } else {
            $energy[$y]->[$x] |= $dirbits{$d};
            #print "\t\tmirror_nwse mirror n\n";
            &go($m, $x, $y - 1, 'n');
        }
    }
}

# /
sub mirror_swne {
    my ($m, $x, $y, $d) = @_;
    if ($d eq 'n') {
        if ($energy[$y]->[$x] & $dirbits{$d}) {
        } else {
            $energy[$y]->[$x] |= $dirbits{$d};
            #print "\t\tmirror_swne mirror e\n";
            &go($m, $x + 1, $y, 'e');
        }
    } elsif ($d eq 'e') {
        if ($energy[$y]->[$x] & $dirbits{$d}) {
        } else {
            $energy[$y]->[$x] |= $dirbits{$d};
            #print "\t\tmirror_swne mirror n\n";
            &go($m, $x, $y - 1, 'n');
        }
    } elsif ($d eq 's') {
        if ($energy[$y]->[$x] & $dirbits{$d}) {
        } else {
            $energy[$y]->[$x] |= $dirbits{$d};
            #print "\t\tmirror_swne mirror w\n";
            &go($m, $x - 1, $y, 'w');
        }
    } elsif ($d eq 'w') {
        if ($energy[$y]->[$x] & $dirbits{$d}) {
        } else {
            $energy[$y]->[$x] |= $dirbits{$d};
            #print "\t\tmirror_swne mirror s\n";
            &go($m, $x, $y + 1, 's');
        }
    }
}

sub main {
    my $building = 0;
    my @matrix;
    my $max = -1;
    while (<>) {
        chomp;
        if (m/^[\|\.\-\\\/#]+$/) {
            push @matrix, [ split('', $_) ];
        } else {
            #printm(\@matrix);
            $YMAX = scalar @matrix;
            $XMAX = scalar @{$matrix[0]};
            #print "XMAX $XMAX, YMAX $YMAX\n";

            my $score = 0;
            my $x;
            my $y;
            for ($x=0; $x<$XMAX; ++$x) {
                undef @energy;
                &fill_energy();
                $y = 0;
                &go(\@matrix, $x, $y, 's');
                $score = printe(\@energy);
                print "score[$x,$y] $score\n";

                $max = $score > $max ? $score : $max;

                undef @energy;
                &fill_energy();
                $y = $YMAX - 1;
                &go(\@matrix, $x, $y, 'n');
                $score = printe(\@energy);
                print "score[$x,$y] $score\n";

                $max = $score > $max ? $score : $max;

            }
            for ($y=0; $y<$YMAX; ++$y) {
                undef @energy;
                &fill_energy();
                $x = 0;
                &go(\@matrix, $x, $y, 'e');
                $score = printe(\@energy);
                print "score[$x,$y] $score\n";
                $max = $score > $max ? $score : $max;

                undef @energy;
                &fill_energy();
                $x = $XMAX - 1;
                &go(\@matrix, $x, $y, 'w');
                $score = printe(\@energy);
                print "score[$x,$y] $score\n";
                $max = $score > $max ? $score : $max;

           }
            #print "\n";
            #printm(\@matrix);
            print "MAX $max\n";
        }
    }
}

&main();