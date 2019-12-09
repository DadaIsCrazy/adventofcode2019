#!/usr/bin/perl

package C09_1;

use strict;
use warnings;
use feature qw( say );

use Intcode;

# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;


sub main {
    open my $FH, '<', "input_09.txt" or die $!;
    my @input = split /,/, <$FH>;

    #my @input = (109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99);
    #my @input = (1102,34915192,34915192,7,4,7,99,0);
    #my @input = (104,1125899906842624,99);


    my $output = Intcode::eval_intcode(\@input, input => [1]);
    say join ",", @$output;
}

1;
