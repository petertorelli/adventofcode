#!/usr/bin/env perl

use warnings;
use strict;

my $acc = 0;
my $b;
my @tok;
my $x;

while (<>) {
    chomp;
    my $org = $_;
    next if /^\s*$/;
    print "\n";
    print "$_:\n";
    @tok = ();
    # Forward
    while (m/(one|two|three|four|five|six|seven|eight|nine|[0-9])/og) {
        $x = $1;
        print "$x --> ";
        $x =~ s/one/1/g;
        $x =~ s/two/2/g;
        $x =~ s/three/3/g;
        $x =~ s/four/4/g;
        $x =~ s/five/5/g;
        $x =~ s/six/6/g;
        $x =~ s/seven/7/g;
        $x =~ s/eight/8/g;
        $x =~ s/nine/9/g;
        print "$x\n";
        push @tok, $x;
    }
    # Backward
    # isnt' there a way to make the regex parser start at the end???
    $_ = reverse($org);
    while (m/(enin|thgie|neves|xis|evif|ruof|eerht|owt|eno|[0-9])/og) {
        $x = $1;
        print "$x --> ";
        $x =~ s/eno/1/g;
        $x =~ s/owt/2/g;
        $x =~ s/eerht/3/g;
        $x =~ s/ruof/4/g;
        $x =~ s/evif/5/g;
        $x =~ s/xis/6/g;
        $x =~ s/neves/7/g;
        $x =~ s/thgie/8/g;
        $x =~ s/enin/9/g;
        print "LAST = $x\n";
        print "SWITCHEROO!\n" if $x != @tok[-1];
        push @tok, $x;
        last;
    }

    $b = $tok[0].$tok[-1];
    $acc += $b;
    print "X: $org --> @tok --> $b : $acc\n";
}
