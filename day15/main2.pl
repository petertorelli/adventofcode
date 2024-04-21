#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;
$_ = <>;

my @chunks = split ',';


my $sum = 0;

my %boxes;

foreach my $chunk (@chunks) {
    print "Chunk $chunk\n";
    my $boxnum = 0;
    my @chars = split '', $chunk;
    my $c;
    my $pos = -1;
    my $label = '';
    while (@chars) {
        $c = shift @chars;
        if ($c eq '=') {
            $pos = shift @chars;
            if (defined $boxes{$boxnum}) {
                my $tmp = $boxes{$boxnum};
                my $found = 0;
                for (my $j=0; $j<@$tmp; ++$j) {
                    if ($tmp->[$j][0] eq $label) {
                        $tmp->[$j][1] = $pos;
                        $found = 1;
                        last;
                    }
                }
                if ($found) {
                    $boxes{$boxnum} = $tmp;
                } else {
                    push @{$boxes{$boxnum}}, [ $label, $pos ];
                }
            } else {
                push @{$boxes{$boxnum}}, [ $label, $pos ];
            }
        } elsif ($c eq '-') {
            print "Clear label $label\n";
            if (defined $boxes{$boxnum}) {
                my $tmp = $boxes{$boxnum};
                my $idx = -1;
                for (my $j=0; $j<@$tmp; ++$j) {
                    if ($tmp->[$j][0] eq $label) {
                        $idx = $j;
                        last;
                    }
                }
                if ($idx >= 0) {
                    splice @$tmp, $idx, 1;
                }
                $boxes{$boxnum} = $tmp;
            }
        } else {
            $label .= $c;
            $boxnum += ord($c);
            $boxnum *= 17;
            $boxnum %= 256;
        }
    }
    print "\t$chunk = $boxnum --> lens $pos\n";
    $boxnum = 0;
    $label = '';
}
print Dumper(\%boxes);

foreach my $box (sort {$a <=> $b} keys %boxes) {
    print "Box: $box\n";
    my $n = $box + 1;
    for (my $i=0; $i<@{$boxes{$box}}; ++$i) {
        my $m = $i + 1;
        my $label = $boxes{$box}->[$i][0];
        my $val = $boxes{$box}->[$i][1];
        my $tally = $n * $m * $val;
        print "\t$label : $n $m $val -> $tally\n";
        $sum += $tally;
    }
}
print "sum = $sum\n";

