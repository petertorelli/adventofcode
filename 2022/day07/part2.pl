#!/usr/bin/env perl

use warnings;
use strict;

my $curnode;
my @curpath;
my %tree;

while (<>) {
    if (/^\$ (\S+)( (\S+))?/) {
        my ($cmd, $arg) = ($1, $3);
        if ($cmd eq 'cd') {
            if ($arg eq '..') {
                pop @curpath;
            } else {
                push @curpath, $arg;
            }
            $curnode = join(' ', @curpath);
        } elsif ($cmd eq 'ls') {
        } else {
            die "Bad command '$cmd'\n";
        }
    } elsif (/^dir (\S+)/) {
        push @{$tree{$curnode}{dirs}}, join(' ', @curpath, $1);
    } elsif (/^(\d+) (\S+)/) {
        $tree{$curnode}{files}{$2} = $1;
    } else {
        last;
    }
}

sub recurse {
    my ($cur, $rtree) = @_;
    my $size = 0;
    foreach (values %{$rtree->{$cur}{files}}) {
        $size += $_;
    }
    foreach (@{$rtree->{$cur}{dirs}}) {
        $size += &recurse($_, $rtree);
    }
    $rtree->{$cur}{totalsize} = $size;
    return $size;
}

&recurse('/', \%tree);

my $max = 70000000;
my $min = 30000000;
my $free = $max - $tree{'/'}{totalsize};
my $mindir = $max;
foreach (keys %tree) {
    my $size = $tree{$_}{totalsize};
    if (($size + $free) >= $min) {
        $mindir = $size < $mindir ? $size : $mindir;
    } 
}
print "$mindir\n";
