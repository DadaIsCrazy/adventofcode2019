#!/usr/bin/perl

package C09_2;

use strict;
use warnings;
use feature qw( say );

use Intcode;

# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;


sub main {
    open my $FH, '<', "input_09.txt" or die $!;
    my @input = split /,/, <$FH>;

    my $output = Intcode::eval_intcode(\@input, input => [2]);
    say join ",", @$output;
}

1;
