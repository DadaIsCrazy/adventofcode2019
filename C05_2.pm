#!/usr/bin/perl

package C05_2;

use strict;
use warnings;
use feature qw( say );

use Intcode;

# Call main if script is ran directly (eg, not loaded by another script)
main() unless caller;


sub main {
    open my $FH, '<', "input_05.txt" or die $!;
    my @input = split ",", <$FH>;

    $Intcode::PRINT = 1;
    Intcode::eval_intcode(\@input, input => [5]);
}

1;
