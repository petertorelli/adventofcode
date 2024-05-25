#!/usr/bin/env perl
use warnings;
use strict;
use Array::Transpose;
use Data::Dumper;

# was failing part 1 because needed a blank line at the end of the file!

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
            ++$r0; ++$r1;
            print "\t^^ broke on [$r0, $r1]\n\n";
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
}

sub findsym {
    my $m = \@_;
    my $score = 0;
    for (my $row = 1; $row < scalar(@$m); ++$row) {
        my $r0 = $row - 1;
        my $r1 = $row;
        my $a = join('', @{$m->[$r0]});
        my $b = join('', @{$m->[$r1]});
        if ($a eq $b) {
            printm($m, $r0);
            my $res = &check_perfect($m, $r0, $r1);
            if ($res > 0) {
                die "Multiple solutions found" if $score > 0;
                $score += $res;
            }
        }
    }
    print "\t^^ nothing here\n\n" if $score == 0;
    return $score;
}

sub process {
    my $h = 0;
    my $v = 0;

    print "\t--PROPER--\n\n";
    $h = &findsym(@_);
    print "\t--TRANSPOSE--\n\n";
    $v = &findsym(transpose(\@_));
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
                print "Finsh. Score: $score\n\n";
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
