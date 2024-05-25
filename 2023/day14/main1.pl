#!/usr/bin/env perl
use warnings;
use strict;
use Array::Transpose;
$| = 1;

# ./main1.pl test1.dat  1.30s user 0.01s system 99% cpu 1.318 total
# 10000

#1000
#./main1.pl input1.txt  14.89s user 0.04s system 99% cpu 14.958 total


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
    # bubble sortish
    #print "\tBEFORE :".join('', @$r)."\n";
    for (my $i = 0; $i < scalar(@$r); ++$i) {
        if ($r->[$i] eq 'O') {
            for (my $z = $i - 1; $z >= 0; --$z) {
                if ($r->[$z] eq '.') {
                    $r->[$z] = 'O';
                    $r->[$i] = '.';
                    #print "\tIGNORE :".join('', @$r)." (i=$i, z=$z)\n";
                    $i = $z;
                } elsif ($r->[$z] eq '#') {
                    last;
                }
            }
        }
    }
    #print "\tAFTORE :".join('', @$r)."\n";
    
}

sub roll_right {
    my ($r) = @_;
    # bubble sortish
    #print "\tBEFORE :".join('', @$r)."\n";
    for (my $i = scalar(@$r) - 1; $i >= 0; --$i) {
        if ($r->[$i] eq 'O') {
            for (my $z = $i + 1; $z < scalar(@$r); ++$z) {
                if ($r->[$z] eq '.') {
                    $r->[$z] = 'O';
                    $r->[$i] = '.';
                    #print "\tIGNORE :".join('', @$r)." (i=$i, z=$z)\n";
                    $i = $z;
                } elsif ($r->[$z] eq '#') {
                    last;
                }
            }
        }
    }
    #print "\tAFTORE :".join('', @$r)."\n";
    
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
    return transpose(\@tm);
}

sub tilt_south {
    my ($m) = @_;
    my @tm = transpose($m);
    &roll_by_row(\@tm, 1);
    return transpose(\@tm);
}

sub tilt_west {
    my ($m) = @_;
    &roll_by_row($m, 0);
    return @$m;
}

sub tilt_east {
    my ($m) = @_;
    &roll_by_row($m, 1);
    return @$m;
}

sub process {
    my @nm = @_;

#    my $cycles = 100 * 1000 * 1000;
    my $cycles = 1000;

   # while ($cycles--) {
    #    print "$cycles\n" if $cycles % 1000 == 0;
        @nm = &tilt_north(\@nm);
     #   @nm = &tilt_west(\@nm);
     #   @nm = &tilt_south(\@nm);
     #   @nm = &tilt_east(\@nm);
    #}



    printm(\@nm, -1);

    # Guessing load is based on tilt, but we'll check that in part 2 i bet
    # south beams:
    my $height = scalar(@nm);
    my $score = 0;
    foreach my $row (@nm) {
        foreach my $char (@$row) {
            $score += $height if $char eq 'O';
        }
        --$height;
    }
    return $score;
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
