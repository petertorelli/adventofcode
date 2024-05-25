#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;

sub renderline3d {
    my ($id, $rp0, $rp1, $space, $mx, $my, $mz) = @_;
    my (@p0) = split ',', $rp0;
    my (@p1) = split ',', $rp1;

    my $dx = $p1[0] - $p0[0];
    my $dy = $p1[1] - $p0[1];
    my $dz = $p1[2] - $p0[2];

    $dx = $dx / $dx if $dx;
    $dy = $dy / $dy if $dy;
    $dz = $dz / $dz if $dz;

    my $key;
    do {
        $mx = $p0[0] > $mx ? $p0[0] : $mx;
        $my = $p0[1] > $my ? $p0[1] : $my;
        $mz = $p0[2] > $mz ? $p0[2] : $mz;
        $key = "$p0[0],$p0[1],$p0[2]";
        $space->{$key} = $id;
        # for voxelizer
        $p0[0] += $dx;
        $p0[1] += $dy;
        $p0[2] += $dz;
    } while ($key ne $rp1);

    return ($mx, $my, $mz);
}

sub erase {
    my ($id, $bricks, $space) = @_;

    my ($rp0, $rp1) = split '~', $bricks->{$id};
    my (@p0) = split ',', $rp0;
    my (@p1) = split ',', $rp1;

    my $dx = $p1[0] - $p0[0];
    my $dy = $p1[1] - $p0[1];
    my $dz = $p1[2] - $p0[2];

    $dx = $dx / $dx if $dx;
    $dy = $dy / $dy if $dy;
    $dz = $dz / $dz if $dz;

    my $key;
    do {
        $key = "$p0[0],$p0[1],$p0[2]";
        $space->{$key} = undef;
        # for voxelizer
        $p0[0] += $dx;
        $p0[1] += $dy;
        $p0[2] += $dz;
    } while ($key ne $rp1);
}

sub place {
    my ($id, $bricks, $space) = @_;

    my ($rp0, $rp1) = split '~', $bricks->{$id};

    my (@p0) = split ',', $rp0;
    my (@p1) = split ',', $rp1;

    my $dx = $p1[0] - $p0[0];
    my $dy = $p1[1] - $p0[1];
    my $dz = $p1[2] - $p0[2];

    $dx = $dx / $dx if $dx;
    $dy = $dy / $dy if $dy;
    $dz = $dz / $dz if $dz;

    my $key;
    do {
        $key = "$p0[0],$p0[1],$p0[2]";
        $space->{$key} = $id;
        # for voxelizer
        $p0[0] += $dx;
        $p0[1] += $dy;
        $p0[2] += $dz;
    } while ($key ne $rp1);
}


sub relax {
    my ($bricks, $space) = @_;

    my @todo;
    my $cycles = 1;
    while (1) {
        foreach my $id (keys %$bricks) {
            my ($rp0, $rp1) = split '~', $bricks->{$id};

            my (@p0) = split ',', $rp0;
            my (@p1) = split ',', $rp1;

            my $dx = $p1[0] - $p0[0];
            my $dy = $p1[1] - $p0[1];
            my $dz = $p1[2] - $p0[2];

            $dx = $dx / $dx if $dx;
            $dy = $dy / $dy if $dy;
            $dz = $dz / $dz if $dz;

            my $key;
            my $floating = 1;
            next if $p0[2] == 1 || $p1[2] == 1;

            if (($p0[0] == $p1[0]) && ($p0[1] == $p1[1])) {
                my $z = $p0[2] < $p1[2] ? $p0[2] : $p1[2];
                my $below = join(',', $p1[0], $p1[1], $z - 1);
                if (defined $space->{$below}) {
                    $floating = 0;
                }
            } else {
                do {
                    $key = "$p0[0],$p0[1],$p0[2]";
                    my $below = join(',', $p0[0], $p0[1], $p0[2] - 1);
                    if (defined $space->{$below}) {
                        $floating = 0;
                    }
                    # for voxelizer
                    $p0[0] += $dx;
                    $p0[1] += $dy;
                    $p0[2] += $dz;
                } while ($key ne $rp1);
            }

            if ($floating) {
                push @todo, $id;
            }
        }
        last if @todo == 0;
        print "Cycle $cycles dropping ".scalar(@todo)." bricks\n";
        while (@todo) {
            my $dropid = shift @todo;
            my $pts = $bricks->{$dropid};
            #print " Dropping $dropid $pts\n";
            &erase($dropid, $bricks, $space);
            my ($rp0, $rp1) = split '~', $bricks->{$dropid};
            my (@p0) = split ',', $rp0;
            my (@p1) = split ',', $rp1;
            die "Already at bottom ($dropid) $pts" if $p0[2] == 1 || $p1[2] == 1;
            --$p0[2];
            --$p1[2];
            my $newloc = join('~', join(',', @p0), join(',', @p1));
            #print " ID [$dropid] went from $rp0~$rp1 to $newloc\n";
            $bricks->{$dropid} = $newloc;
            &place($dropid, $bricks, $space);
        }
        ++$cycles
    }
}

sub maketree {
    my ($space, $mx, $my, $mz) = (@_);
    my %supports;
    my %supportedby;
    # go through every voxel and build a support tree
    foreach my $voxel (keys %$space) {
        # Should probably clean the tree...
        my $id1 = $space->{$voxel};
        next if not defined $id1;
        my ($x, $y, $z) = split ',', $voxel;
        my $akey = join ',', $x, $y, $z + 1;
        my $id2 = $space->{$akey};
        if (defined $id2 and ($id1 ne $id2)) {
            $supports{$id1}{$id2} = 1;
            $supportedby{$id2}{$id1} = 1;
        }
    }
    return (\%supports, \%supportedby);
}

# 	BABYLON.MeshBuilder.CreateBox({size: 1}).position = new BABYLON.Vector3(-2,0.5,-2);
sub writebab {
    my ($lastbrickid, $space, $bricks, $disset) = @_;
    my $cid = "A";
    my %colors;
    srand(0);
    my $white = "1,1,1";
    my $grey = ".5,.5,.5";
    while ($lastbrickid--) {
        my $pts = $bricks->{$lastbrickid};
        my $rgb = join(',', rand(), rand(),rand());
        if (defined $disset) {
            if (defined $disset->{$lastbrickid}) {
                $rgb = $white;
            } else {
                $rgb = $grey
            }

            my ($rp0, $rp1) = split '~', $pts;
            my (@p0) = split ',', $rp0;
            my (@p1) = split ',', $rp1;
            if ($p0[0] == 0 && $p0[2] < 20 && $p0[2] > 15) {
                $rgb = "1,0,0";
                print "Brick == $lastbrickid $pts\n";
            }

        }
        $colors{$lastbrickid} = $rgb;
    }
    foreach my $pos (keys %$space) {
        next unless defined $space->{$pos};
        my $bid = $space->{$pos};
        my ($x, $y, $z) = split ',', $pos;
        my $rgb = $colors{$bid};
        if ($rgb eq "1,0,0") {
            printf "var $cid = BABYLON.MeshBuilder.CreateBox({size: 1});\n";
            printf "$cid.position = new BABYLON.Vector3($x,$z,$y);\n";
            printf "$cid.material = new BABYLON.StandardMaterial(\"$cid\");\n";
            printf "$cid.material.diffuseColor = new BABYLON.Color3($rgb);\n";
        }
        ++$cid;

    }

}

sub main {
    my $brickid = 0;
    my ($mx, $my, $mz) = (-1, -1, -1);
    my %space;
    my %bricks;
    my %dis;
    while (<>) {
        chomp;
        if (/^\s*$/) {
            print "MAX ($mx, $my, $mz)\n";
            #print Dumper(\%space);
            &relax(\%bricks, \%space);
            #&writebab($brickid, \%space);
            #print Dumper(\%space);
            my ($sup, $by) = &maketree(\%space, $mx, $my, $mz);
            #print Dumper($sup);
            #print Dumper($by);
            my $doit = 0;
            foreach $brickid (sort {$a <=> $b} keys %bricks) {
                my $disintegrate = 1;
                my @up = keys %{$sup->{$brickid}};
                my @dn = keys %{$by->{$brickid}};
                if (@up == 0) {
                    print "$brickid supports nothing, it can go\n";
                } else {
                    print "Brick:$brickid supports @up\n";
                    foreach my $upper (@up) {
                        my @hop = keys %{$by->{$upper}};
                        print "  is $upper supported by someoneother than $brickid (hint @hop)?  ... ";
                        my $ok = @hop > 1;
                        printf "%s\n", $ok ? "yes" : "no";
                        if (!$ok) {
                            $disintegrate = 0;
                        }
                    }
                }
                if ($disintegrate) {
                    print "$brickid can be disintegrated\n";
                    $dis{$brickid} = 1;
                    ++$doit;
                } else {
                    print "$brickid CAN NOT be disintegrated\n";
                }
            }
            print "$doit";
            # brick 700 supports a brick that is not supported by anything else supports 678
            &writebab($brickid, \%space, \%bricks, \%dis);
            return;
        } else {
            my ($brick, @extra) = split;
            my ($p0, $p1) = split '~', $brick;
            ($mx, $my, $mz) = &renderline3d($brickid, $p0, $p1, \%space, $mx, $my, $mz);
            $bricks{$brickid} = $brick;
            ++$brickid;
        }
    }
}

&main;
