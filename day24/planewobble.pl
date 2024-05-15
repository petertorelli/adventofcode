#!/usr/bin/env perl

use warnings;
use strict;

sub find_intersections {
    my ($lines) = @_;

    my @keys = keys %$lines;

    my ($ulcx, $ulcy, $lrcx, $lrcy);

    while (@keys) {
        my $l1 = shift @keys;
        foreach my $l2 (@keys) {
            
            my $m1 = $lines->{$l1}{m2d};
            my $m2 = $lines->{$l2}{m2d};
            
            if ($m1 == $m2) {
                #print "$l1 is parallel to $l2\n";
                next;
            }

            my $b1 = $lines->{$l1}{b2d};
            my $b2 = $lines->{$l2}{b2d};
            my $x = ($b1 - $b2) / ($m2 - $m1);
            my $y = $m2 * $x +$b2;

            #print "$l1 intersects $l2 at $x, $y\n";
            if (defined $ulcx) {
                $ulcx = $x < $ulcx ? $x : $ulcx;
            } else {
                $ulcx = $x;
            }
            if (defined $ulcy) {
                $ulcy = $y < $ulcy ? $ulcy : $y;
            } else {
                $ulcy = $y;
            }
            if (defined $lrcx) {
                $lrcx = $x > $lrcx ? $x : $lrcx;
            } else {
                $lrcx = $x;
            }
            if (defined $lrcy) {
                $lrcy = $y < $lrcy ? $y : $lrcy;
            } else {
                $lrcy = $y;
            }
        }
    }
    my $area = ($lrcx - $ulcx) * ($ulcy - $lrcy);
    #printf "BBOX [$ulcx, $ulcy] x [$lrcx, $lrcy] = %.9f\n", $area;
    return $area;
}

sub rotate_x {
    my ($theta, $lines) = @_;
    my %n;
    my $ctheta = cos($theta);
    my $stheta = sin($theta);
    foreach my $key (keys %$lines) {
        my $line = $lines->{$key};
        $n{$key}{px} = $line->{px};
        $n{$key}{py} = $line->{py} * $ctheta - $line->{pz} * $stheta;
        $n{$key}{pz} = $line->{py} * $stheta + $line->{pz} * $ctheta;
        $n{$key}{vx} = $line->{vx};
        $n{$key}{vy} = $line->{vy} * $ctheta - $line->{vz} * $stheta;
        $n{$key}{vz} = $line->{vy} * $stheta + $line->{vz} * $ctheta;
        $n{$key}{m2d} = $n{$key}{vy} / $n{$key}{vx};
        $n{$key}{b2d} = $n{$key}{py} - $n{$key}{m2d} * $n{$key}{px};  
    }
    return %n;
}

sub rotate_y {
    my ($theta, $lines) = @_;
    my %n;
    my $ctheta = cos($theta);
    my $stheta = sin($theta);
    foreach my $key (keys %$lines) {
        my $line = $lines->{$key};
        $n{$key}{px} = $line->{px} * $ctheta + $line->{pz} * $stheta;
        $n{$key}{py} = $line->{py};
        $n{$key}{pz} = -1 * $line->{px} * $stheta + $line->{pz} * $ctheta;
        $n{$key}{vx} = $line->{vx} * $ctheta + $line->{vz} * $stheta;
        $n{$key}{vy} = $line->{vy};
        $n{$key}{vz} = -1 * $line->{vx} * $stheta + $line->{vz} * $ctheta;
        $n{$key}{m2d} = $n{$key}{vy} / $n{$key}{vx};
        $n{$key}{b2d} = $n{$key}{py} - $n{$key}{m2d} * $n{$key}{px};  
    }
    return %n;
}

#my $SCALE = 1;#1e17;
#my ($start_i, $end_i) = (0.983-0.001, 0.983+0.001);
#my ($start_j, $end_j) = (0.270-0.001, 0.270+0.001);
#my $eps = 0.00001;

my $SCALE = 1;
my $thr = 0.1;
my ($start_i, $end_i) = (0.96 - $thr, 0.96 + $thr);
my ($start_j, $end_j) = (0.31 - $thr, 0.31 + $thr);
my $eps = 0.001;

sub main {
    my %lines;
    while (<>) {
        s/\s//g;
        my ($pos, $vel) = split '@';
        my ($px, $py, $pz) = split ',', $pos;
        my ($vx, $vy, $vz) = split ',', $vel;
        # Assuming they all have non infinite slope in X/Y for part 1.
        my $m2d = ($vy) / ($vx);
        my $b2d = ($py) - ($m2d * $px);
        $lines{"$pos @ $vel"}{px} = $px / $SCALE;
        $lines{"$pos @ $vel"}{py} = $py / $SCALE;
        $lines{"$pos @ $vel"}{pz} = $pz / $SCALE;
        $lines{"$pos @ $vel"}{vx} = $vx;
        $lines{"$pos @ $vel"}{vy} = $vy;
        $lines{"$pos @ $vel"}{vz} = $vz;
        $lines{"$pos @ $vel"}{m2d} = $m2d;
        $lines{"$pos @ $vel"}{b2d} = $b2d;
    }


    my %tilted;
    %tilted = &rotate_y(0, \%lines);
    &find_intersections(\%tilted);
    my $area;

    
    for (my $i=$start_i; $i<=$end_i; $i += $eps) {
        for (my $j=$start_j; $j<=$end_j; $j += $eps) {
            %tilted = &rotate_y($i, \%lines);
            %tilted = &rotate_x($j, \%tilted);
            $area = &find_intersections(\%tilted);
            printf "%10.5f %10.5f %20.9f\n", $i, $j, $area;
        }
    }
    
}

&main;



