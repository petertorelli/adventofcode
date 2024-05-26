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

my $sum = 0;
foreach my $k (keys %tree) {
    my $size = $tree{$k}{totalsize};
    $sum += $size if $size <= 100e3;
}
print "$sum\n";
