#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;
use Storable 'dclone';

my @mat4i = (
    [1, 0, 0, 0],
    [0, 1, 0, 0],
    [0, 0, 1, 0],
    [0, 0, 0, 1]
);

my @mat4z = (
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0]
);

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

sub matmul4x4 {
    my ($m1, $m2) = @_;
    my @result = @{ dclone \@mat4z };
    for (my $i=0; $i<3; ++$i) {
        for (my $j=0; $j<3; ++$j) {
            $result[$i][$j] = 0;
            for (my $k=0; $k<3; ++$k) {
                $result[$i][$j] += $m1->[$i][$k] * $m2->[$k][$j];
            }
        }
    }
    return @result;
}

sub rotn4x4 {
    my ($m, $angle, $v) = @_;

    my $c = cos($angle);
    my $s = sin($angle);

    my @axis = @{ dclone $v };

    my @temp = (
        (1 - $c) * $axis[0],
        (1 - $c) * $axis[1],
        (1 - $c) * $axis[2]
    );
    my @r = @{ dclone \@mat4z };

    $r[0][0] = $c + $temp[0] * $axis[0];
    $r[0][1] =  0 + $temp[0] * $axis[1] + $s * $axis[2];
    $r[0][2] =  0 + $temp[0] * $axis[2] - $s * $axis[1];

    $r[1][0] =  0 + $temp[1] * $axis[0] - $s * $axis[2];
    $r[1][1] = $c + $temp[1] * $axis[1];
    $r[1][2] =  0 + $temp[1] * $axis[2] + $s * $axis[0];

    $r[2][0] =  0 + $temp[2] * $axis[0] + $s * $axis[1];
    $r[2][1] =  0 + $temp[2] * $axis[1] - $s * $axis[0];
    $r[2][2] = $c + $temp[2] * $axis[2];

    return matmul4x4($m, \@r);
}

my $SCALE = 1;

sub apply4x4 {
    my ($m, $lines) = @_;
    my %n;
    foreach my $key (keys %$lines) {
        my $line = $lines->{$key};
        $n{$key}{px} = $line->{px} * $m->[0][0] + $line->{py} * $m->[0][1] + $line->{py} * $m->[0][2];
        $n{$key}{py} = $line->{px} * $m->[1][0] + $line->{py} * $m->[1][1] + $line->{py} * $m->[1][2];
        $n{$key}{px} = $line->{px} * $m->[2][0] + $line->{py} * $m->[2][1] + $line->{py} * $m->[2][2];
        $n{$key}{vx} = $line->{vx} * $m->[0][0] + $line->{vy} * $m->[0][1] + $line->{vy} * $m->[0][2];
        $n{$key}{vy} = $line->{vx} * $m->[1][0] + $line->{vy} * $m->[1][1] + $line->{vy} * $m->[1][2];
        $n{$key}{vx} = $line->{vx} * $m->[2][0] + $line->{vy} * $m->[2][1] + $line->{vy} * $m->[2][2];
        $n{$key}{m2d} = $n{$key}{vy} / $n{$key}{vx};
        $n{$key}{b2d} = $n{$key}{py} - $n{$key}{m2d} * $n{$key}{px};  
    }
    return %n;
}

sub wobble {
    my ($lines, $start_i, $end_i, $start_j, $end_j, $thr, $eps) = @_;

    my %rotated;
    my $area;

    print "[$start_i, $end_i] x [$start_j, $end_j], thr=$thr, eps=$eps\n";

    my @points;
    for (my $i=$start_i; $i<=$end_i; $i += $eps) {
        for (my $j=$start_j; $j<=$end_j; $j += $eps) {

            my @model_matrix = @{ dclone \@mat4i };
            my @rm_x = &rotn4x4(\@model_matrix, $i, [1, 0, 0]);
            my @rm_y = &rotn4x4(\@model_matrix, $j, [0, 1, 0]);
            my @m1 = &matmul4x4(\@rm_x, \@rm_y);
            my @rm = &matmul4x4(\@m1, \@model_matrix);
            %rotated = &apply4x4(\@rm, $lines);
            $area = &find_intersections(\%rotated);
            next if not defined $area;
            push @points, [ $area, [ $i, $j ]];
            printf "%10.5f %10.5f %20.9f\n", $i, $j, $area;
        }
    }
    @points = sort {$a->[0] <=> $b->[0]} @points;
    my $choice = shift @points;
    my ($newarea, $ij) = @$choice;
    my ($i, $j) = @$ij;
    return ($newarea, $i, $j);
}

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


    my $eps = 0.1;
    my $thr = 0;
    my ($start_i, $end_i) = (0 - $thr, 3.14159265 / 2 + $thr);
    my ($start_j, $end_j) = (0 - $thr, 3.14159265 / 2 + $thr);

    for (; $eps > 0.0001; $eps /= 10) {
        my ($a, $cx, $cy) = &wobble(\%lines, $start_i, $end_i, $start_j, $end_j, $thr, $eps);
        print "$eps ($thr) $a $cx $cy\n";
        $thr = $eps;
        $start_i = $cx - $thr;
        $end_i = $cx + $thr;
        $start_j = $cy - $thr;
        $end_j = $cy + $thr;
    }
}

&main;
