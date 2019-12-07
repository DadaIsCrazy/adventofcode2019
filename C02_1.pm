#!/usr/bin/perl

package C02_1;

use strict;
use warnings;
use feature qw( say );

use Intcode;

# Call main if script is ran directly (eg, not loaded by another script)
main() unless caller;


sub main {
    @ARGV = "input_02.txt" unless @ARGV;
    my @input = split ",", <>;
    $input[1] = 12;
    $input[2] = 2;

    Intcode::eval_intcode(\@input);
    say join ",", @input;
}

1;
