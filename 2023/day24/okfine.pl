#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;
use Storable 'dclone';
use Math::BigFloat;

Math::BigFloat->accuracy(25);
my $EPSILON = Math::BigFloat->new(1e-24);
#Math::BigFloat->precision(20);

sub readstdin {
    my ($pts) = @_;
    while (<>) {
        s/\s//g;
        my ($pos, $vel) = split '@';
        my ($px, $py, $pz) = split ',', $pos;
        my ($vx, $vy, $vz) = split ',', $vel;
        my $tx = Math::BigFloat->new($vx);
        push @$pts, [ 
            [
                Math::BigFloat->new($px),
                Math::BigFloat->new($py),
                Math::BigFloat->new($pz),
            ],
            [
                Math::BigFloat->new($vx),
                Math::BigFloat->new($vy),
                Math::BigFloat->new($vz),
            ]
        ];
    }
}


sub find_intersections {
    my ($list, $slopes, $yints) = @_;

    my $ulcx = Math::BigFloat->bnan();
    my $ulcy = Math::BigFloat->bnan();
    my $lrcx = Math::BigFloat->bnan();
    my $lrcy = Math::BigFloat->bnan();

    for (my $ii=0; $ii < @$list; ++$ii) {
        for (my $jj = $ii; $jj < @$list; ++$jj) {
            my $m1 = $slopes->[$ii];
            my $m2 = $slopes->[$jj];

            if ($m1 == $m2) {
                #print "$l1 is parallel to $l2\n";
                next;
            }

            my $b1 = $yints->[$ii];
            my $b2 = $yints->[$jj];
            my $dm = ($m2 - $m1);
            if (abs($dm) < $EPSILON) {
                next;
            }
            my $x = ($b1 - $b2) / $dm;
            my $y = $m2 * $x + $b2;

            #print "$l1 intersects $l2 at $x, $y\n";
            if ($ulcx->is_nan()) {
                $ulcx = $x;
            } else {
                $ulcx = $x < $ulcx ? $x : $ulcx;
            }
            if ($ulcy->is_nan()) {
                $ulcy = $y;
            } else {
                $ulcy = $y < $ulcy ? $ulcy : $y;
            }
            if ($lrcx->is_nan()) {
                $lrcx = $x;
            } else {
                $lrcx = $x > $lrcx ? $x : $lrcx;
            }
            if ($lrcy->is_nan()) {
                $lrcy = $y;
            } else {
                $lrcy = $y < $lrcy ? $y : $lrcy;
            }
        }
    }
    if ($ulcx->is_nan() ||
        $ulcy->is_nan() ||
        $lrcx->is_nan() ||
        $lrcy->is_nan())
    {
        die "shrugs";
    } else {
        my $area = ($lrcx - $ulcx) * ($ulcy - $lrcy);
        #printf "BBOX [$ulcx, $ulcy] x [$lrcx, $lrcy] = %.9f\n", $area;
        return $area;
    }
}

sub mulmat33mat33 {
    my ($m1, $m2) = @_;
    my ($tmp1, $tmp2, $tmp3);
    my (@row1, @row2, @row3);

    $tmp1 = $m1->[0][0] * $m2->[0][0];
    $tmp2 = $m1->[0][1] * $m2->[1][0];
    $tmp3 = $m1->[0][2] * $m2->[2][0];
    push @row1, ($tmp1 + $tmp2 + $tmp3);
    $tmp1 = $m1->[0][0] * $m2->[0][1];
    $tmp2 = $m1->[0][1] * $m2->[1][1];
    $tmp3 = $m1->[0][2] * $m2->[2][1];
    push @row1, ($tmp1 + $tmp2 + $tmp3);
    $tmp1 = $m1->[0][0] * $m2->[0][2];
    $tmp2 = $m1->[0][1] * $m2->[1][2];
    $tmp3 = $m1->[0][2] * $m2->[2][2];
    push @row1, ($tmp1 + $tmp2 + $tmp3);

    $tmp1 = $m1->[1][0] * $m2->[0][0];
    $tmp2 = $m1->[1][1] * $m2->[1][0];
    $tmp3 = $m1->[1][2] * $m2->[2][0];
    push @row2, ($tmp1 + $tmp2 + $tmp3);
    $tmp1 = $m1->[1][0] * $m2->[0][1];
    $tmp2 = $m1->[1][1] * $m2->[1][1];
    $tmp3 = $m1->[1][2] * $m2->[2][1];
    push @row2, ($tmp1 + $tmp2 + $tmp3);
    $tmp1 = $m1->[1][0] * $m2->[0][2];
    $tmp2 = $m1->[1][1] * $m2->[1][2];
    $tmp3 = $m1->[1][2] * $m2->[2][2];
    push @row2, ($tmp1 + $tmp2 + $tmp3);

    $tmp1 = $m1->[2][0] * $m2->[0][0];
    $tmp2 = $m1->[2][1] * $m2->[1][0];
    $tmp3 = $m1->[2][2] * $m2->[2][0];
    push @row3, ($tmp1 + $tmp2 + $tmp3);
    $tmp1 = $m1->[2][0] * $m2->[0][1];
    $tmp2 = $m1->[2][1] * $m2->[1][1];
    $tmp3 = $m1->[2][2] * $m2->[2][1];
    push @row3, ($tmp1 + $tmp2 + $tmp3);
    $tmp1 = $m1->[2][0] * $m2->[0][2];
    $tmp2 = $m1->[2][1] * $m2->[1][2];
    $tmp3 = $m1->[2][2] * $m2->[2][2];
    push @row3, ($tmp1 + $tmp2 + $tmp3);

    return [ \@row1, \@row2, \@row3 ];
}

sub mulmat33vec31 {
    my ($m, $v) = @_;

    my ($tmp1, $tmp2, $tmp3);
    my (@row1, @row2, @row3);

    $tmp1 = $m->[0][0] * $v->[0];
    $tmp2 = $m->[0][1] * $v->[1];
    $tmp3 = $m->[0][2] * $v->[2];
    push @row1, ($tmp1 + $tmp2 + $tmp3);
    $tmp1 = $m->[1][0] * $v->[0];
    $tmp2 = $m->[1][1] * $v->[1];
    $tmp3 = $m->[1][2] * $v->[2];
    push @row1, ($tmp1 + $tmp2 + $tmp3);
    $tmp1 = $m->[2][0] * $v->[0];
    $tmp2 = $m->[2][1] * $v->[1];
    $tmp3 = $m->[2][2] * $v->[2];
    push @row1, ($tmp1 + $tmp2 + $tmp3);

    return \@row1;
}

sub printm {
    my ($m) = @_;
    for (my $i=0; $i<3; ++$i) {
        for (my $j=0; $j<3; ++$j) {
            print $m->[$i][$j] . " ";
        }
        print "\n";
    }
    print "\n";
}

sub printv {
    my ($v) = @_;
    for (my $i=0; $i<3; ++$i) {
        print $v->[$i] . " ";
    }
    print "\n";
}

sub main {

    my @pts;
    
    &readstdin(\@pts);

    my $CPI = Math::BigFloat->bpi();

    my $th0;
    my $th1;
    my $ph0;
    my $ph1;
    my $exp;
    my $eps;
if (1) {
    $th0 = Math::BigFloat->new(0);
    $th1 = Math::BigFloat->new($CPI)->bdiv(1);
    $ph0 = Math::BigFloat->new(0);
    $ph1 = Math::BigFloat->new($CPI)->bdiv(1);
    $eps = Math::BigFloat->new(0);
    $exp = 1;
}
if (0) {
    $th0 = Math::BigFloat->new(0.84);
    $th1 = Math::BigFloat->new(0.84);
    $ph0 = Math::BigFloat->new(0.05);
    $ph1 = Math::BigFloat->new(0.05);
    $eps = Math::BigFloat->new(0.10);
    $exp = 2;
}
if (0) {
    $th0 = Math::BigFloat->new(1);
    $th1 = $th0;
    $ph0 = Math::BigFloat->new(3.4);
    $ph1 = $ph0;
    $eps = Math::BigFloat->new(0);
    $exp = 1;
}

print "$th1 $ph1\n";
    print "Start\n";
    for (; $exp < 20; ++$exp) {
        my $inc = Math::BigFloat->new(10)->bpow(-$exp);
        my @scores;
        for (my $theta = $th0 - $eps; $theta <= ($th1 + $eps); $theta += $inc) {
#        for (my $ti = 0; $ti <= 20; ++$ti) {
#            my $theta = ($th0 - $eps) + ($ti * $inc);
            my $cth = Math::BigFloat->new($theta)->bcos();
            my $sth = Math::BigFloat->new($theta)->bsin();
            my $Ry = [
                [ Math::BigFloat->new( $cth) , Math::BigFloat->new(0), Math::BigFloat->new($sth) ],
                [ Math::BigFloat->new(    0) , Math::BigFloat->new(1), Math::BigFloat->new(   0) ],
                [ Math::BigFloat->new(-$sth) , Math::BigFloat->new(0), Math::BigFloat->new($cth) ],
            ];
            for (my $phi = $ph0 - $eps; $phi <= ($ph1 + $eps) ; $phi += $inc) {
#            for (my $pi = 0; $pi <= 20; ++$pi) {
#                my $phi = ($ph0 - $eps) + ($pi * $inc);
                my $cph = Math::BigFloat->new($phi)->bcos();
                my $sph = Math::BigFloat->new($phi)->bsin();
                my $Rx = [
                    [ Math::BigFloat->new(1) , Math::BigFloat->new(   0), Math::BigFloat->new(    0) ],
                    [ Math::BigFloat->new(0) , Math::BigFloat->new($cph), Math::BigFloat->new(-$sph) ],
                    [ Math::BigFloat->new(0) , Math::BigFloat->new($sph), Math::BigFloat->new( $cph) ],
                ];
                my @n;
                my @slopes;
                my @yints;
                my $turn1p;
                my $turn2p;
                my $turn1v;
                my $turn2v;
                my $rotv;
                my $rotp;
                foreach my $pt (@pts) {

                    my $p = [ $pt->[0][0], $pt->[0][1], $pt->[0][2] ];
                    $turn1p = &mulmat33vec31($Rx, $p);
                    $turn2p = &mulmat33vec31($Ry, $turn1p);


                    my $v = [ $pt->[1][0], $pt->[1][1], $pt->[1][2] ];
                    $turn1v = &mulmat33vec31($Rx, $v);
                    $turn2v = &mulmat33vec31($Ry, $turn1v);

                    push @n, [ $turn2p, $turn2v ];
                    my $slope = ($turn2v->[1] / $turn2v->[0]);
                    push @slopes, $slope; 
                    push @yints, ($turn2p->[1] - $slope * $turn2p->[0]);
                }
                my $area = &find_intersections(\@n, \@slopes, \@yints);
                #print "Area=$area @ theta=$theta, phi=$phi\n";
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
        printf "area=%10.30f theta=%.30f phi=%.30f\n", @{$sorted[0]};
        $th0 = $sorted[0]->[1];
        $th1 = $th0;
        $ph0 = $sorted[0]->[2];
        $ph1 = $ph0;
        $eps = $inc;
    }

}

&main;

