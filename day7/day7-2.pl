#!/usr/bin/env perl
use warnings;
use strict;

my %c2bf = (
    '2' => (1 << 2),
    '3' => (1 << 3),
    '4' => (1 << 4),
    '5' => (1 << 5),
    '6' => (1 << 6),
    '7' => (1 << 7),
    '8' => (1 << 8),
    '9' => (1 << 9),
    'T' => (1 << 10),
    'J' => 65535,
    'Q' => (1 << 12),
    'K' => (1 << 13),
    'A' => (1 << 14)
);

sub encode_hand {
    my $hand = shift @_;
    my @cards = split("", $hand);
    my @bcards = ();
    foreach my $card (@cards) {
        my $bval = $c2bf{$card};
        push @bcards, $bval;
    }
    return @bcards;
}

sub five_of_a_kind {
    my @bcards = @_;
    my $and = 
        $bcards[0] &
        $bcards[1] & 
        $bcards[2] &
        $bcards[3] &
        $bcards[4];
    return $and;
}

use Data::Dumper;

sub four_of_a_kind {
    my @bcards = @_;
    my @sets = (
        [0, 1, 2, 3],
        [0, 1, 2, 4],
        [0, 1, 3, 4],
        [0, 2, 3, 4],
        [1, 2, 3, 4]
    );

    foreach my $set (@sets) {
        my $match =
            $bcards[$set->[0]] &
            $bcards[$set->[1]] &
            $bcards[$set->[2]] &
            $bcards[$set->[3]];
        return 1 if $match;
    }
    return 0;
}


sub full_house {
    my @bcards = @_;
    my @sets = (
        [ [0, 1, 2], [3, 4] ],
        [ [0, 1, 4], [2, 3] ],
        [ [0, 3, 4], [1, 2] ],
        [ [2, 3, 4], [0, 1] ],

        [ [0, 1, 3], [2, 4] ],
        [ [0, 2, 4], [1, 3] ],
        [ [1, 3, 4], [0, 2] ],

        [ [0, 2, 3], [1, 4] ],
        [ [1, 2, 4], [0, 3] ],

        [ [1, 2, 3], [0, 4] ]
    );

    foreach my $set (@sets) {
        my $seta = $set->[0];
        my $setb = $set->[1];
        my $match =
            ($bcards[$seta->[0]] & $bcards[$seta->[1]] & $bcards[$seta->[2]]) &&
            ($bcards[$setb->[0]] & $bcards[$setb->[1]]);
        return 1 if $match;
    }
    return 0;
}

sub three_of_a_kind {
    my @bcards = @_;
    my @sets = (
        [ 0, 1, 2],
        [ 0, 1, 4],
        [ 0, 3, 4],
        [ 2, 3, 4],

        [ 0, 1, 3],
        [ 0, 2, 4],
        [ 1, 3, 4],

        [ 0, 2, 3],
        [ 1, 2, 4],

        [ 1, 2, 3]
    );

    foreach my $set (@sets) {
        my $match =
            $bcards[$set->[0]] &
            $bcards[$set->[1]] &
            $bcards[$set->[2]];
        return 1 if $match;
    }
    return 0;

}

sub two_pair {
    my @bcards = @_;
    my @sets = (
        [ [ 0, 1          ], [       2, 3    ] ],
        [ [ 0, 1          ], [          3, 4 ] ],
        [ [ 0, 1          ], [       2,    4 ] ],
        [ [ 0,    2       ], [    1,    3    ] ],
        [ [ 0,    2       ], [    1,       4 ] ],
        [ [ 0,    2       ], [          3, 4 ] ],
        [ [ 0,       3    ], [    1, 2       ] ],
        [ [ 0,       3    ], [    1,       4 ] ],
        [ [ 0,       3    ], [       2,    4 ] ],
        [ [ 0,          4 ], [    1, 2       ] ],
        [ [ 0,          4 ], [    1,    3    ] ],
        [ [ 0,          4 ], [       2, 3    ] ],
        [ [    1, 2       ], [          3, 4 ] ],
        [ [    1,    3    ], [       2,    4 ] ],
        [ [    1,       4 ], [       2, 3    ] ]
    );

    foreach my $set (@sets) {
        my $seta = $set->[0];
        my $setb = $set->[1];
        my $match =
            ($bcards[$seta->[0]] & $bcards[$seta->[1]]) &&
            ($bcards[$setb->[0]] & $bcards[$setb->[1]]);
        return 1 if $match;
    }
    return 0;
}

sub one_pair {
    my @bcards = @_;
    my @sets = (
        [ 0, 1 ],
        [ 0, 2 ],
        [ 0, 3 ],
        [ 0, 4 ],
        [ 1, 2 ],
        [ 1, 3 ],
        [ 1, 4 ],
        [ 2, 3 ],
        [ 2, 4 ],
        [ 3, 4 ]
    );

    foreach my $set (@sets) {
        my $match =
            $bcards[$set->[0]] &
            $bcards[$set->[1]];
        return 1 if $match;
    }
    return 0;
}

sub high_card {
    my @bcards = @_;
    my $or = $bcards[0] | $bcards[1] | $bcards[2] | $bcards[3] | $bcards[4];
    my $sum1s = 0;
    while ($or > 0) {
        if ($or & 1) {
            ++$sum1s;
        }
        $or >>= 1;
    }
    return $sum1s == 5 ? 1 : 0;
}

sub score {
    my @bcards = @_;
    if (five_of_a_kind(@bcards)) {
        return 7;
    }
    elsif (four_of_a_kind(@bcards)) {
        return 6;
    }
    elsif (full_house(@bcards)) {
        return 5;
    }
    elsif (three_of_a_kind(@bcards)) {
        return 4;
    }
    elsif (two_pair(@bcards)) {
        return 3;
    }
    elsif (one_pair(@bcards)) {
        return 2;
    }
    elsif (high_card(@bcards)) {
        return 1;
    }
    else {
        die "can't score cards (".join("-", @bcards)."";
    }
}

my @scores = ();

while (<>) {
    chomp;
    my ($hand, $bid) = split;
    my @bcards = encode_hand($hand);

    my $handpts = score(@bcards);

    push @scores, [ $hand, $handpts, $bid ];
}


@scores = sort {
    if ($a->[1] > $b->[1]) {
        return 1;
    }
    elsif ($a->[1] < $b->[1]) {
        return -1;
    }
    else {
        my @ac = split("", $a->[0]);
        my @bc = split("", $b->[0]);
        for (my $i=0; $i<5; ++$i) {
            my $ax = $c2bf{$ac[$i]};
            my $bx = $c2bf{$bc[$i]};
            $ax = $ac[$i] eq 'J' ? (1 << 1) : $ax;
            $bx = $bc[$i] eq 'J' ? (1 << 1) : $bx;

            if ($ax > $bx) {
                return 1;
            }
            elsif ($ax < $bx) {
                return -1;
            }
            else {
            }
        }
    }
} @scores;

my $total_winnings = 0;

for (my $i=0; $i<=$#scores; ++$i) {
    my $rank = $i + 1;
    my $winnings = $scores[$i]->[2] * $rank;
    printf "%s %4d %4d %4d %10d\n", $scores[$i]->[0], $scores[$i]->[2], $scores[$i]->[1], $rank, $winnings;
    $total_winnings += $winnings;
}

print "Total winnings: $total_winnings\n";
