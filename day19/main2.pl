#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;
use Storable 'dclone';
my %rules;

while (<>) {
    chomp;
    last if /^\s*$/;
    /^(\S+?)\{(.+?)\}$/;
    my $rule = $1;
    my $rsteps = $2;
    my @steps = (split(/,/, $rsteps));
    my @criteria;
    foreach my $step (@steps) {
        if ($step =~ /^(.)(.)(.+?):(.+)$/) {
            my ($var, $mag, $val, $next) = ($1, $2, $3, $4);
            push @criteria, [ $var, $mag, $val, $next ];
        } else {
            push @criteria, [ undef, undef, undef, $step ];
        }
    }
    $rules{$rule} = \@criteria;
}

sub pstate {
    my ($state) = @_;
    my $acc = 1;
    foreach (sort keys %$state) {
        my ($x, $y) = @{$state->{$_}};
        print "$_ [ $x, $y ] ";
        $acc *= ($y - $x) + 1;
    };
    print " = $acc\n";
}

sub evaluate {
    my ($state) = @_;
    my $score = 1;
    foreach (sort values %$state) {
        my ($x, $y) = @{$_};
        $score *= ($y - $x) + 1;
    };
    return $score;
}

my $total = 0;

sub recurse {
    my ($node, $depth, $state, @path) = @_;
    my $Q = sprintf("%02d(% 5s)", $depth, $node) . "    " x $depth;

    if ($node eq 'R') {
        print "$Q $node REJECTED\n";
        return;
    }
    if ($node eq 'A') {
        my $score = &evaluate($state);
    print "$Q Bucket = ";
    &pstate($state);
        print "$Q $node ACCEPTED, evaluate = $score (@path)\n";
        $total += $score;
        return;
    }
    foreach my $next (@{$rules{$node}}) {
        my ($var, $mag, $val, $next) = @$next;
        if (defined $var) {
            # test
            if ($mag eq '<') {
                my $copy = dclone $state;
    print "$Q Bucket = ";
    &pstate($state);
                my ($x, $y) = @{$state->{$var}};
                $y = $val < $y ? $val - 1 : $y;
                print "$Q FILTER T $var$mag$val in [ $x, $y ] * -> $next\n";
                @{$state->{$var}} = ($x, $y);
                &recurse($next, $depth + 1, $state, (@path, "T $var$mag$val -> $next"));
                push @path, "F $var$mag$val,";
                $state = dclone $copy;
    print "$Q Bucket = ";
    &pstate($state);
                ($x, $y) = @{$state->{$var}};
                # doh, off by one!
                $x = $val > $x ? $val : $x;
                @{$state->{$var}} = ($x, $y);
                print "$Q FILTER F $var$mag$val in [ $x, $y ] * step\n";
            } else {
                my $copy = dclone $state;
    print "$Q Bucket = ";
    &pstate($state);
                my ($x, $y) = @{$state->{$var}};
                $x = $val > $x ? $val + 1 : $x;
                @{$state->{$var}} = ($x, $y);
                print "$Q FILTER T $var$mag$val in [ $x, $y ] * -> $next\n";
                &recurse($next, $depth + 1, $state, (@path, "T $var$mag$val -> $next"));
                push @path, "F $var$mag$val,";
                $state = dclone $copy;
    print "$Q Bucket = ";
    &pstate($state);
                ($x, $y) = @{$state->{$var}};
                # doh, off by one!
                $y = $val < $y ? $val : $y;
                @{$state->{$var}} = ($x, $y);
                print "$Q FILTER F $var$mag$val in [ $x, $y ] * step\n";
            }
        } else {
            # no test, let all through
    print "$Q Bucket = ";
    &pstate($state);
            print "$Q FILTER T * -> $next\n";
            &recurse($next, $depth + 1, $state, (@path, "T -> $next"));
        }
    }
}

my %state = (
    'x' => [1, 4000],
    'm' => [1, 4000],
    'a' => [1, 4000],
    's' => [1, 4000]
);

&recurse('in', 0, \%state, ('in'));

print "Total $total\n";
__DATA__

167 409 079 868 000

px{a<2006:qkq,m>2090:A,rfg}
T X X X
F T X X
F F X X
        2006  * [  4000         +   4000 + 4000 ] -> qkq
(4000 - 2006) *   (4000 - 2090) * [ 4000 + 4000 ] -> A
(4000 - 2006) *           2090  * [ 4000 + 4000 ] -> rfg

xz{s<2053:nn,m<819:jbc,m<1387:rrq,zl}
T X X X
F T X X
F F T X
F F F X


a<5,b>3,q max 10

total # is 10 * 10 * 10 or 1000

[1, 4] (4) ,          x , x, x = 4000
[5,10] (6) , [4,10] (7) , x, x = 4200
[5,10] (6) , [1, 2] (2) , x, x = 1200


    my @steps = (split(/,/, $rsteps));
    foreach my $i (0 .. $#steps) {
        my @C = ( 4000, 4000, 4000, 4000);
        foreach my $j (0 .. $#steps) {
            $steps[$j] =~ m/^(.)(.)(.+?):(.+?)$/;
            my ($var, $t, $val, $next) = ($1, $2, $3, $4);   
            if ($j == $i && $i != $#steps) {
                # print "T ";
                $C[$j] = $t eq "<" ? $val * 1 : 4000 - $val;
            } elsif ($j < $i) {
                # print "F ";
                $C[$j] = $t eq "<" ? 4000 - $val : $val * 1;
            } else {
                # print "X ";
            }
        }
        my $cost = $C[0] * $C[1] * $C[2] * $C[3];
        print "$cost\n";
    }




pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}



    my @criteria;
    foreach my $step (@steps) {
        if ($step =~ /^(.)(.)(.+?):(.+)$/) {
            my ($var, $mag, $val, $next) = ($1, $2, $3, $4);
            push @criteria, {
                'var' => $var,
                'val' => $val,
                'mag' => $mag,
                'child' => $next
            };
        } else {
            push @criteria, {
                'child' => $step
            };
        }
    }
    $rules{$rule} = \@criteria;


03(    A)          A ACCEPTED, evaluate = 8259731689662 (in T s<1351 -> px F a<2006 F m>2090 T -> rfg F s<537 F x>2440 T -> A)

s[1,1350]
a[2007, 4000]
m[1, 2089]
s[538, 1350]
x[1, 2439]
