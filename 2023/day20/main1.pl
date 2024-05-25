#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;
$| = 1;

my %tree;
my %total_pulses;

push @{$tree{button}{output}}, 'broadcaster';
$tree{button}{func} = sub {
    my ($stim, $from) = @_;
    return 0;
};

sub recurse {
    my ($events) = @_;
    my @update;

    if (not defined $events) {
        my $node = 'button';
        my $resp = $tree{$node}{func}->();
        push @update, [ $node, $resp ];
        foreach my $o (@{$tree{$node}{output}}) {
            $total_pulses{$resp} += 1;
            print "$node -$resp-> $o\n";
        }
        &recurse(\@update);
    } else {
        foreach my $event (@$events) {
            my ($from, $stim) = @$event;
            if (not defined $stim) {
                $stim = $tree{$from}{func}->();
            }
            foreach my $node (@{$tree{$from}{output}}) {
                next unless $tree{$node}{func};
                my $resp = $tree{$node}{func}->($stim, $from);
                if ($resp >= 0) {
                    push @update, [ $node, $resp ];
                    foreach my $o (@{$tree{$node}{output}}) {
                        $total_pulses{$resp} += 1;
                        print "$node -$resp-> $o\n";
                    }
                }
            }
        }
        if (@update) {
            &recurse(\@update);
        }
    }
}


sub main {
    while (<>) {
        if (/^\s*$/) {
            foreach (1 ... 1000) {
                &recurse();
            }
            print Dumper(\%total_pulses);
            my $total = $total_pulses{0} * $total_pulses{1};
            print "Total $total\n";
        } else {
            s/\s//g;
            m/^([%&])?(\S+)->(.*)$/;
            my ($op, $name, $rtargets) = ($1, $2, $3);
            my @targets = split(',', $rtargets);
            $tree{$name}{output} = \@targets;
            foreach (@targets) {
                push @{$tree{$_}{input}}, $name;
                $tree{$_}{mem}{$name} = 0;
            }
            die "Redefining func" if defined $tree{$name}{func};
            if ($op) {
                $tree{$name}{op} = $op;
                if ($op eq '&') {
                    $tree{$name}{func} = sub {
                        my ($stim, $from) = @_;
                        $tree{$name}{mem}{$from} = $stim;
                        my $resp = 1;
                        while (my ($k, $v) = each %{$tree{$name}{mem}}) {
                            $resp &= $v;
                        }
                        $resp = $resp == 0 ? 1 : 0;
                        return $resp;
                    }
                } elsif ($op eq '%') {
                    $tree{$name}{state} = 0;
                    $tree{$name}{func} = sub {
                        my ($stim, $from) = @_;
                        my $resp = -1;
                        if ($stim == 0) {
                            $resp = $tree{$name}{state} == 0 ? 1 : 0;
                            $tree{$name}{state} = $resp;
                        }
                        return $resp;
                    }
                }
            } elsif ($name eq 'broadcaster') {
                $tree{$name}{func} = sub {
                    my ($stim, $from) = @_;
                    return $stim;
                }
            }
        }
    }
}

&main;