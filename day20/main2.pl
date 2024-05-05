#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;
$| = 1;

my %tree;

my %total_pulses;
my $pushes = 0;
my $TESTNODE = 'sg';
my $ITER = 1000000;

my %cur;

push @{$tree{button}{output}}, 'broadcaster';
$tree{button}{func} = sub {
    my ($stim, $from) = @_;
    return 0;
};


sub printstate {
    while (my ($k, $v) = each %tree) {
        if ($v->{op} && $v->{op} eq '%') {
            print $v->{state};
        }
    }
    print "\n";
}

sub printcur {
    foreach (sort keys %cur) {
        print $cur{$_};
    }
    print "\n";
}

sub printnode {
    my $node = shift @_;
    printf "$node :: %10d ", $pushes;
    foreach (@{$tree{$node}{input}}) {
        print $cur{$_};
    }
    if (defined ${tree{$node}{mem}}) {
        print " -> ";
        foreach (keys %{$tree{$node}{mem}}) {
            print $cur{$_};
        }
    }
    print " -> ";
    foreach (@{$tree{$node}{output}}) {
        print $cur{$_};
    }
    print "\n";
}

sub recurse {
    my ($events) = @_;
    my @update;
    
    #&printstate;

    if (not defined $events) {
        my $node = 'button';
        my $resp = $tree{$node}{func}->();
        push @update, [ $node, $resp ];
        foreach my $o (@{$tree{$node}{output}}) {
            $total_pulses{$resp} += 1;
#            print "$node -$resp-> $o\n";
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
                    &printnode($node) if $node eq $TESTNODE;
                    push @update, [ $node, $resp ];
                    foreach my $o (@{$tree{$node}{output}}) {
                        $total_pulses{$resp} += 1;
                        $cur{$o} = $resp;
#                        print "$node -$resp-> $o\n";
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
            foreach (1 ... $ITER) {
                ++$pushes;
                &recurse();
            }
            #print Dumper(\%total_pulses);
            #my $total = $total_pulses{0} * $total_pulses{1};
            #print "Total $total\n";
        } else {
            s/\s//g;
            m/^([%&])?(\S+)->(.*)$/;
            my ($op, $name, $rtargets) = ($1, $2, $3);
            my @targets = split(',', $rtargets);
            $tree{$name}{output} = \@targets;
            $cur{$name} = 0;
            $tree{$name}{name} = $name;
            foreach (@targets) {
                push @{$tree{$_}{input}}, $name;
                $tree{$_}{mem}{$name} = 0;
                $cur{$_} = 0;
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

__DATA__
petertorelli@Hipparchus day20 % ./main2.pl fract1.txt  | grep '1$'
lm ::       3851 0 -> 0 -> 1
lm ::       7702 0 -> 0 -> 1
lm ::      11553 0 -> 0 -> 1
lm ::      15404 0 -> 0 -> 1
lm ::      19255 0 -> 0 -> 1
lm ::      23106 0 -> 0 -> 1
lm ::      26957 0 -> 0 -> 1
lm ::      30808 0 -> 0 -> 1
lm ::      34659 0 -> 0 -> 1
petertorelli@Hipparchus day20 % ./main2.pl fract1.txt  | grep '1$'
dh ::       3889 0 -> 0 -> 1
dh ::       7778 0 -> 0 -> 1
dh ::      11667 0 -> 0 -> 1
dh ::      15556 0 -> 0 -> 1
dh ::      19445 0 -> 0 -> 1
dh ::      23334 0 -> 0 -> 1
dh ::      27223 0 -> 0 -> 1
dh ::      31112 0 -> 0 -> 1
petertorelli@Hipparchus day20 % ./main2.pl fract1.txt  | grep '1$'
db ::       4079 0 -> 0 -> 1
db ::       8158 0 -> 0 -> 1
db ::      12237 0 -> 0 -> 1
db ::      16316 0 -> 0 -> 1
db ::      20395 0 -> 0 -> 1
db ::      24474 0 -> 0 -> 1
db ::      28553 0 -> 0 -> 1
db ::      32632 0 -> 0 -> 1
petertorelli@Hipparchus day20 % ./main2.pl fract1.txt  | grep '1$'
sg ::       4027 0 -> 0 -> 1
sg ::       8054 0 -> 0 -> 1
sg ::      12081 0 -> 0 -> 1
sg ::      16108 0 -> 0 -> 1
sg ::      20135 0 -> 0 -> 1
sg ::      24162 0 -> 0 -> 1
sg ::      28189 0 -> 0 -> 1
246,006,621,493,687