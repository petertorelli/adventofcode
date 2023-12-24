#!/usr/bin/env perl

while (<>) {
    chomp;
    s/[a-zA-Z]//g;
    @tok = split("");
    $b = @tok[0].@tok[-1];
    $acc += $b;
}

print "$acc\n";
