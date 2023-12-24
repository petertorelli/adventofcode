#!/usr/bin/env perl

use warnings;
use strict;

my $acc = 0;
my @stack = ();

# sluuurp
my @deck = <>;

my @todo = ();

# Start with the normal deck
@todo = (0 ... $#deck);

sub get_num_matches {
    my ($idx) = (@_);
    $_ = $deck[$idx];
    # preprocessing
    chomp;
    s/Card.*(\d+):\s*//;
    my $card = $1;
    s/\s+\|\s+/:/;
    my @first_split = split(/:/);
    my @winning = split(/\s+/, $first_split[0]);
    my @mine = split(/\s+/, $first_split[1]);
    # linear of linear? sure.
    my $matches = 0;
    for (my $i=0; $i<=$#winning; ++$i) {
        for (my $j=0; $j<=$#mine; ++$j) {
            if ($winning[$i] == $mine[$j]) {
                ++$matches;
            }
        }
    }
    return $matches;
}

my @scores;

# build initial cards won table

foreach my $idx (@todo) {
    my $nmatch = get_num_matches($idx);
    my @next = ();
    if ($nmatch > 0) {
        if ($nmatch > 1) {
            @next = (($idx + 1) ... ($idx + $nmatch)); 
        } else {
            @next = (($idx + 1));
        }
    }
    push @scores, \@next;
    printf("Card %4d wins %3d cards - @next\n", $idx, scalar(@next));
}

# create a total score for each card

my @total_cards_earned_by = ();

foreach (0 ... $#deck) {
    push @total_cards_earned_by, 0;
}

# compute scores backwards, waterfall what each score was...

for my $idx (reverse 0 ... $#deck) {
    my @wons = @{$scores[$idx]};
    my $score = 0;
    if (scalar @wons == 0) {
    } else {
        $score = scalar @wons;
        print "$idx won ".scalar(@wons)." cards, waterfalling...\n";
        foreach my $won (@wons) {
            my $add = $total_cards_earned_by[$won];
            print " Adding cards won by $won (which is $add)\n";
            $score += $total_cards_earned_by[$won];
        }
    }
    $total_cards_earned_by[$idx] = $score;
    print "$idx won total of $score cards\n";
}

# won cards
foreach (@total_cards_earned_by) {
    $acc += $_;
}
# plus the ORIGINAL cards, duh
$acc += scalar(@deck);
print "Score $acc\n";
