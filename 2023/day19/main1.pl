#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;

my %rules;


while (<>) {
    chomp;
    last if /^\s*$/;
    /^(\S+?)\{(.+?)\}$/;
    my $rule = $1;
    my $rsteps = $2;
    my @steps = (split(/,/, $rsteps));
    my $final;
    my @criteria;
    foreach my $step (@steps) {
        if ($step =~ /^(.)(.)(.+?):(.+)$/) {
            my ($var, $mag, $val, $next) = ($1, $2, $3, $4);
            push @criteria, sub {
                my ($a) = @_;
                if ($mag eq '>') {
                    #print "$a->{$var} $var > $val\n";
                    return $a->{$var} > $val ? $next : "fail";
                } else {
                    #print "$a->{$var} $var < $val\n";
                    return $a->{$var} < $val ? $next : "fail";
                }
            };
        } else {
            push @criteria, sub {
                return $step;
            }
        }
    }
    $rules{$rule} = \@criteria;
}
#print Dumper(\%rules);

my $score = 0;

while (<>) {
    chomp;
    last if /^s*$/;
    s/[{}]//g;
    s/.=//g;
    my @args = split /,/;
    my %hargs = (
        'x' => $args[0],
        'm' => $args[1],
        'a' => $args[2],
        's' => $args[3],
    );
    my $this_score = $args[0] + $args[1] + $args[2] + $args[3];
    sub run_rule {
        my ($key, $args) = @_;
        foreach my $rule (@{$rules{$key}}) {
            my $res = $rule->($args);
            unless ($res eq "fail") {
                return $res;
            }
        }
    }
    my $next = 'in';
    my $sum = 0;
    for (my $i=0; $i<10; ++$i) {
        print "$next -> ";
        $next = &run_rule($next, \%hargs);
        last if $next eq 'R' || $next eq 'A';
    }
    print "$next";
    if ($next eq 'A') {
        print " = $this_score\n";
        $score += $this_score;
    } else {
        print " ... rejected\n";
    }
}

print "Score $score\n";