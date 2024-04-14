#!/usr/bin/env perl
use warnings;
use strict;
use Array::Transpose;

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

sub check_perfect {
    my ($m, $r0, $r1) = @_;
    my $count = $r1;
    my $pass = 1;
    while (1) {
        my $a = join('', @{$m->[$r0]});
        my $b = join('', @{$m->[$r1]});
        if ($a ne $b) {
            $pass = 0;
            print "\t^^ broke on $r0 <> $r1 -- ";
            if (&off_by_one($m->[$r0], $m->[$r1])) {
                print "smudge candidate\n";
            } else {
                print "\n";
            }
            print "\n";
            ++$r0; ++$r1;
            last;
        }
        else {
            if ($r0 > 0) {
                --$r0;
            } else {
                last;
            }
            if ($r1 < (scalar(@$m) - 1)) {
                ++$r1;
            } else {
                last;
            }
        }
    }
    if ($pass) {
        print "\t^^ succeeded ($count)\n\n";
        return $count; # row index is 1-based count
    }
    return 0;
}

sub findsym {
    my ($m) = @_;
    my @results;

    for (my $row = 1; $row < scalar(@$m); ++$row) {
        my $r0 = $row - 1;
        my $r1 = $row;
        my $a = join('', @{$m->[$r0]});
        my $b = join('', @{$m->[$r1]});
        if ($a eq $b) {
            printm($m, $r0);
            my $res = &check_perfect($m, $r0, $r1);
            push @results, $res if $res > 0;
        }
    }
    return @results;
}

sub off_by_one {
    my ($r0, $r1) = @_;
    my $diff = 0;
    my $pos = -1;
    #print "\t".join("", @$r0)."\n";
    #print "\t".join("", @$r1)."\n";
    for (my $i=0; $i < scalar(@$r0); ++$i) {
        if ($r0->[$i] ne $r1->[$i]) {
            ++$diff;
            $pos = $i;
        }
    }
    if ($diff == 1) {
        #print "\t\toff by one\n";
        return $pos;
    } else {
        return -1;
    }
}

sub find_potential_smudge_rows {
    my ($m) = @_;
    # find all rows off by one by expanding a walking cutline
    my $cutline = 1;
    my $found = 0;
    my @smudges;
    while ($cutline < scalar(@$m)) {
        my $r0 = $cutline - 1;
        my $r1 = $cutline;
        while (($r0 >= 0) && ($r1 < scalar(@$m))) {
            my $pos = &off_by_one($m->[$r0], $m->[$r1]);
            if ($pos >= 0) {
                push @smudges, [ $r0, $pos ];
            }
            --$r0;
            ++$r1;
        }
        ++$cutline;
    }
    return @smudges;
}

sub process2 {
    my ($m) = @_;

    my @org;
    my @smudges;
    my @new;

    @org = &findsym($m);
    die if @org > 1;
    @smudges = &find_potential_smudge_rows($m);

    print "\tFound ".scalar(@smudges)." smudges\n";
    foreach (@smudges) {
        printf "\t row %2d, col %2d\n", $_->[0], $_->[1];
    }
    print "\n";

    if (@smudges > 0) {
        foreach my $smudge (@smudges) {
            print "    Applying smudge (@$smudge)\n\n";
            my ($row, $col) = @$smudge;
            # Change
            $m->[$row]->[$col] = $m->[$row]->[$col] eq '.' ? '#' : '.';
            print "    SMUDGED\n\n";
            push @new, &findsym($m);
            # Restore
            $m->[$row]->[$col] = $m->[$row]->[$col] eq '.' ? '#' : '.';
        }
    }

    # Check which score is valid, original or new.
    my $f;
    if (@org > 0) {
        for (@new) {
            if ($org[0] == $_) {
                # skip
            } else {
                if (defined $f) {
                    die "$f was already defined but want $_\n";
                } else {
                    $f = $_;
                }
            }
        }
    } else {
        my %red;
        foreach (@new) {
            $red{$_} = $_;
        }
        @new = keys %red;
        if (@new > 1) {
            die "Expecting only one new score, got @new\n";
        }
        $f = $new[0];
    }
    $f = 0 if ! defined $f;

    print "\tSCORE $f\n";
    return $f;
}

sub process {
    my @m = @_;
    my @tm = transpose(\@m);
    print "\tORIGINAL\n\n";
    my $h = &process2(\@m);
    print "\tTRANSPOSED\n\n";
    my $v = &process2(\@tm);
    return (100 * $h + $v);
}

sub main {
    my $ln = 0;
    my @matrix;
    my $parse_flag = 0;
    my $total = 0;
    while (<>) {
        ++$ln;
        if (/^\s*$/) {
            if ($parse_flag) {
                $parse_flag = 0;
                print '-' x 40 . "\n";
                print "New pattern (line $ln)\n";
                print '-' x 40 . "\n\n";
                printm(\@matrix, -1);
                print "Begin.\n\n";
                my $score = &process(@matrix);
                print "Finish. Score: $score\n\n";
                $total += $score;
                undef @matrix;
            }
        } else {
            $parse_flag = 1;
            chomp;
            push @matrix, [ split('', $_) ];
        }
    }
    print "Total: $total\n";
}

main;
