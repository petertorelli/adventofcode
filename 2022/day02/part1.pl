#!/usr/bin/env perl

use warnings;
use strict;

my %symbols = (
    'A' => 'rock',
    'B' => 'paper',
    'C' => 'scissors',
    'X' => 'rock',
    'Y' => 'paper',
    'Z' => 'scissors',
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
);

my $score = 0;

while (<>) {
    chomp;
    next if /^\s*$/;
    my ($them, $me) = (split);
    $me = $symbols{$me};
    $them = $symbols{$them};
    $score += $symbols{$me.$them} + $symbols{$me};
}

print "$score\n";
