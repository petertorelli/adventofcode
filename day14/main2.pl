#!/usr/bin/env perl
use warnings;
use strict;
use Array::Transpose;
use Data::Dumper;
$| = 1;

# used for deserializing
my $g_cols = -1;

sub printm {
    my ($m, $r0) = @_;
    my $i = 0;
    foreach my $row (@$m) {
        printf "\t%02d: ", $i++;
        print join('', @$row)."\n";
        if ($r0 >= 0 && ($i == $r0 + 1)) {
            print "\t------\n";
        }
    }
    print "\n";
}

sub roll_left {
    my ($r) = @_;
    for (my $i = 0; $i < scalar(@$r); ++$i) {
        if ($r->[$i] eq 'O') {
            for (my $z = $i - 1; $z >= 0; --$z) {
                if ($r->[$z] eq '.') {
                    $r->[$z] = 'O';
                    $r->[$i] = '.';
                    $i = $z;
                } elsif ($r->[$z] eq '#') {
                    last;
                }
            }
        }
    }
}

sub roll_right {
    my ($r) = @_;
    for (my $i = scalar(@$r) - 1; $i >= 0; --$i) {
        if ($r->[$i] eq 'O') {
            for (my $z = $i + 1; $z < scalar(@$r); ++$z) {
                if ($r->[$z] eq '.') {
                    $r->[$z] = 'O';
                    $r->[$i] = '.';
                    $i = $z;
                } elsif ($r->[$z] eq '#') {
                    last;
                }
            }
        }
    }
}

sub roll_row {
    my ($r, $dir) = @_;
    if ($dir) {
        &roll_right($r);
    } else {
        &roll_left($r);
    }
}

sub roll_by_row {
    my ($m, $dir) = @_;
    foreach my $row (@$m) {
        &roll_row($row, $dir);
    }
}

sub tilt_north {
    my ($m) = @_;
    my @tm = transpose($m);
    &roll_by_row(\@tm, 0);
    @tm = transpose(\@tm);
    return \@tm;
}


sub tilt_south {
    my ($m) = @_;
    my @tm = transpose($m);
    &roll_by_row(\@tm, 1);
    @tm = transpose(\@tm);
    return \@tm;
}

sub tilt_west {
    my ($m) = @_;
    &roll_by_row($m, 0);
    return $m;
}

sub tilt_east {
    my ($m) = @_;
    &roll_by_row($m, 1);
    return $m;    
}

sub cycle {
    my ($nm) = @_;
    $nm = &tilt_north($nm);
    $nm = &tilt_west($nm);
    $nm = &tilt_south($nm);
    $nm = &tilt_east($nm);
    return $nm;
}

sub serialize {
    my ($m) = @_;
    my $key = "";
    foreach my $r (@$m) {
        $key .= join('', @$r) . ":"
    }
    return $key;
}

sub deserialize {
    my ($x) = @_;
    my @m;
    my @y = split(':', $x);
    foreach (@y) {
        push @m, [ split('', $_) ];
    }
    return \@m;
}

sub north_beam_load {
    my ($nm) = @_;
    my $height = scalar(@$nm);
    my $score = 0;
    foreach my $row (@$nm) {
        foreach my $char (@$row) {
            $score += $height if $char eq 'O';
        }
        --$height;
    }
    return $score;
}

my %seen;

sub process {
    my ($nm) = @_;
    my $cycle = 1;
    while ($cycle < 150) {
        my $k1 = &serialize($nm);
        if ($seen{$k1}) {
            print "Cycle $cycle was seen before at cycle ".$seen{$k1}{'cycle'};
            my $v1 = $seen{$k1}{'next'};
            my $x = &deserialize($v1);
            $nm = $x;
        } else {
            print "Cycle $cycle was NOT seen";
            $nm = &cycle($nm);
            my $k2 = &serialize($nm);
            $seen{$k1}{'next'} = $k2;
            $seen{$k1}{'cycle'} = $cycle;
        }
        my $s = &north_beam_load($nm);
        print " -- score = $s\n";
        ++$cycle;
    }
    print "STOPPED ON CYCLE ".($cycle-1)."\n";
    printm($nm, -1);
    my $s = &north_beam_load($nm);
    print "$s\n";
}

sub main {
    my $ln = 0;
    my @matrix;
    my $parse_flag = 0;

    while (<>) {
        ++$ln;
        if (/^\s*$/) {
            if ($parse_flag) {
                $parse_flag = 0;
                print '-' x 40 . "\n";
                print "New pattern (line $ln)\n";
                print '-' x 40 . "\n\n";
                printm(\@matrix, -1);
                &process(\@matrix);
                undef @matrix;
            }
        } else {
            $parse_flag = 1;
            chomp;
            if ($g_cols == -1) {
                $g_cols = length $_;
                print "COLS: $g_cols\n";
            }
            push @matrix, [ split('', $_) ];
        }
    }
}

&main();
