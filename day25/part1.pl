#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;

sub readstdin {
    my ($graphbi, $graphuni) = @_;
    while (<>) {
        chomp;
        s/: /:/;
        s/ /:/g;
        my ($parent, @children) = split(':');
        foreach my $child (@children) {
            $graphuni->{$parent}{$child} = 1;

            $graphbi->{$parent}{$child} = 1;
            $graphbi->{$child}{$parent} = 1;
        }
    }
}

sub coalesce {
    my ($g) = @_;

    sub submerge {
        my ($g, $k1, $k2) = @_;
        foreach my $c1 (keys %{$g->{$k1}}) {
            if (defined $g->{$k2}{$c1}) {
                foreach my $add (keys %{$g->{$k2}}) {
                    $g->{$k1}{$add} = 1;
                }
                delete $g->{$k2};
                return;
            }
        }
    }

    foreach my $key1 (sort keys %$g) {
        foreach my $key2 (sort keys %$g) {
            next if $key1 eq $key2;
            # May have already been deleted...
            next unless defined $g->{$key1};
            next unless defined $g->{$key2};
            &submerge($g, $key1, $key2);
        }
    }
}

sub printdotty {
    my ($g) = @_;
    print "digraph G {\n";
    foreach my $k (keys %$g) {
        my $node = $g->{$k};
        foreach my $k2 (keys %$node) {
            print "\t$k -> $k2;\n";
        }
    }
    print "}\n";
}


sub printedges {
    my ($g) = @_;
    # convert nodes from ascii to integers
    my $index = 0;
    my %map;
    foreach my $k (keys %$g) {
        $map{$k} = $index++;
    }
    my $edges = 0;
    print "#$index\n";
    #foreach my $k (keys %$g) {
    #    my $node = $g->{$k};
    #    foreach my $k2 (keys %$node) {
    #        ++$edges;
    #    }
    #}
    #print "#$edges\n";
    foreach my $k (keys %$g) {
        my $node = $g->{$k};
        foreach my $k2 (keys %$node) {
            my $i1 = $map{$k};
            my $i2 = $map{$k2};
            print "$i1 $i2\n";
        }
    }
}
sub snip {
    my ($g, $a, $b) = @_;
    return unless defined $g->{$a};
    return unless defined $g->{$b};
    delete $g->{$a}{$b};
    delete $g->{$b}{$a};
}

sub main {
    my %graphbi;
    my %graphuni;
    &readstdin(\%graphbi, \%graphuni);
    #&printdotty(\%graphbi);
    &printedges(\%graphbi);
die;
    # Part 1 - Test Dataset

    if (0) {
        &snip(\%graphbi, 'hfx', 'pzl');
        &snip(\%graphbi, 'bvb', 'cmg');
        &snip(\%graphbi, 'nvd', 'jqt');
    }

    &coalesce(\%graphbi);

    my $t = 1;
    my $iter = 0;
    foreach my $key (sort keys %graphbi) {
        my $s = scalar keys %{$graphbi{$key}};
        print "Group #$iter size = $s\n";
        my $width = 0;
        ++$iter;
        print "\t";
        foreach my $n (sort keys %{$graphbi{$key}}) {
            print "$n ";
            ++$width; 
            if ($width > 19) {
                print "\n\t";
                $width = 0;
            }
        }
        $t *= $s;
        print "\n";
    }
    print "Total $t\n";
}

&main;
