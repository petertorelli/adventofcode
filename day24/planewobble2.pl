#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;
use Storable 'dclone';
use Math::Trig;
use Math::Matrix;

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
    if (! defined $ulcx ||
        ! defined $ulcy ||
        ! defined $lrcx ||
        ! defined $lrcy)
    {
        return undef;
    } else {
        my $area = ($lrcx - $ulcx) * ($ulcy - $lrcy);
        #printf "BBOX [$ulcx, $ulcy] x [$lrcx, $lrcy] = %.9f\n", $area;
        return $area;
    }
}


sub main {
    my %lines;

    while (<>) {
        s/\s//g;
        my ($pos, $vel) = split '@';
        my ($px, $py, $pz) = split ',', $pos;
        my ($vx, $vy, $vz) = split ',', $vel;
        $lines{"$pos @ $vel"}{px} = $px;
        $lines{"$pos @ $vel"}{py} = $py;
        $lines{"$pos @ $vel"}{pz} = $pz;
        $lines{"$pos @ $vel"}{vx} = $vx;
        $lines{"$pos @ $vel"}{vy} = $vy;
        $lines{"$pos @ $vel"}{vz} = $vz;
        # Assuming they all have non infinite slope in X/Y for part 1.
        my $m2d = $vy / $vx;
        $lines{"$pos @ $vel"}{m2d} = ($vy) / ($vx);
        $lines{"$pos @ $vel"}{b2d} = ($py) - ($m2d * $px);
    }


    # this will be biased toward more sensitivity closer to to the radius
    # because small changes in theta are small changes in perspective
    # proably should use uniformly distributed vectors in a hemisphere?
    my ($th0, $th1) = (0, pi / 1.5);
    my ($ph0, $ph1) = (0, pi / 1.5);
    #$th0 = 0.84;
    #$th1 = $th0;
    #$ph0 = 0.05;
    #$ph1 = $ph0;
    my $eps = 0;
    #$eps = .1;
    for (my $exp = 1; $exp < 20; ++$exp) {
        my $inc = 1 * 10 ** (-$exp);
        my @scores;
        #for (my $theta = $th0 - $eps; $theta < ($th1 + $eps); $theta += $inc) {
        for (my $ti = 0; $ti <= 20; ++$ti) {
            my $theta = ($th0 - $eps) + ($ti * $inc);
            my $cth = cos($theta);
            my $sth = sin($theta);
            my $Ry = Math::Matrix->new(
                [  $cth,     0,  $sth ],
                [     0,     1,     0 ],
                [ -$sth,     0,  $cth ]
            );
            #for (my $phi = $ph0 - $eps; $phi <= ($ph1 + $eps) ; $phi += $inc) {
            for (my $pi = 0; $pi <= 20; ++$pi) {
                my $phi = ($ph0 - $eps) + ($pi * $inc);
                my $cph = cos($phi);
                my $sph = sin($phi);
                my $Rx = Math::Matrix->new(
                    [     1,     0,     0 ],
                    [     0,  $cph, -$sph ],
                    [     0,  $sph,  $cph ]
                );
    #            my $Rz = Math::Matrix->new(
    #                [  $cph, -$sph,     0 ],
    #                [  $sph,  $cph,     0 ],
    #                [     0,     0,     1 ]
    #            );
                my %n;
                my $turn1;
                my $turn2;
                my $rotv;
                my $rotp;
                foreach my $key (keys %lines) {
                    my $line = $lines{$key};
                    my $p = Math::Matrix->new([$line->{px}], [$line->{py}], [$line->{pz}]);
                    $turn1 = $Ry->multiply($p);
                    $turn2 = $Rx->multiply($turn1);
                    $rotp = $turn2->as_array();
                    my $v = Math::Matrix->new([$line->{vx}], [$line->{vy}], [$line->{vz}]);
                    $turn1 = $Ry->multiply($v);
                    $turn2 = $Rx->multiply($turn1);
                    $rotv = $turn2->as_array();
                    $n{$key}{px} = $rotp->[0]->[0];
                    $n{$key}{py} = $rotp->[1]->[0];
                    $n{$key}{pz} = $rotp->[2]->[0];
                    $n{$key}{vx} = $rotv->[0]->[0];
                    $n{$key}{vy} = $rotv->[1]->[0];
                    $n{$key}{vz} = $rotv->[2]->[0];
                    my $mag = sqrt($n{$key}{vx} ** 2 + $n{$key}{vy} ** 2 + $n{$key}{vz} **2);
                    $n{$key}{vx} /= $mag;
                    $n{$key}{vy} /= $mag;
                    $n{$key}{vz} /= $mag;
                    $n{$key}{m2d} = $n{$key}{vy} / $n{$key}{vx};
                    $n{$key}{b2d} = $n{$key}{py} - $n{$key}{m2d} * $n{$key}{px};  

                }
                my $area;

                $area = &find_intersections(\%n);
                #printf "theta=%5.3f phi=%5.3f area=%15.3f\n", $theta, $phi, $area;
                push @scores, [ $area, $theta, $phi ];
            }
            #print '-' x 20, "\n";

            ### no... we need to rotate abou thte new vector,
            ### otherwise we see the same projected bounding box on each phi
        }
        my @sorted = sort { $a->[0] <=> $b->[0] } @scores;
        #foreach (0 ... 5) {
        #    print join(", ", @{$sorted[$_]})."\n";
        #}
        printf "area=%10.10f theta=%.30f phi=%.30f\n", @{$sorted[0]};
        $th0 = $sorted[0]->[1];
        $th1 = $th0;
        $ph0 = $sorted[0]->[2];
        $ph1 = $ph0;
        $eps = $inc;
    }

}

&main;
