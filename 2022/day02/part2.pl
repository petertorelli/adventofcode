#!/usr/bin/env perl

use warnings;
use strict;

my %symbols = (
    'A' => 'rock',
    'B' => 'paper',
    'C' => 'scissors',
    'X' => 'lose',
    'Y' => 'draw',
    'Z' => 'win',
    'rock' => 1,
    'paper' => 2,
    'scissors' =>3,
    'rockrock' => 3,
    'rockpaper' => 0,
    'rockscissors' => 6,
    'paperrock' => 6,
    'paperpaper' => 3,
    'paperscissors' => 0,
    'scissorsrock' => 0,
    'scissorspaper' => 6,
    'scissorsscissors' => 3,

    'win' => 6,
    'lose' => 0,
    'draw' => 3,
    'rockwin' => 'paper',
    'rocklose' => 'scissors',
    'rockdraw' => 'rock',
    'paperwin' => 'scissors',
    'paperlose' => 'rock',
    'paperdraw' => 'paper',
    'scissorswin' => 'rock',
    'scissorslose' => 'paper',
    'scissorsdraw' => 'scissors',
);

my $score = 0;

while (<>) {
    chomp;
    next if /^\s*$/;
    my ($them, $goal) = (split);
    $them = $symbols{$them};
    $goal = $symbols{$goal};
    my $me = $symbols{$them.$goal};
    $score += $symbols{$goal} + $symbols{$me};
}

print "$score\n";
