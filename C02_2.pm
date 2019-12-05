#!/usr/bin/perl

package C02_2;

use strict;
use warnings;
use feature qw( say );

use C02_1;

# Call main if script is ran directly (eg, not loaded by another script)
main() unless caller;



sub main {
    @ARGV = "input_02.txt" unless @ARGV;
    my @input = split ",", <>;

    for my $noun (0 .. 100) {
        for my $verb (0 .. 100) {
            my @prog = @input;
            $prog[1] = $noun;
            $prog[2] = $verb;
            @prog = C02_1::eval_intcode(@prog);
            if ($prog[0] == 19690720) {
                say 100 * $noun + $verb;
                exit;
            }
        }
    }
    say "Not found...";
}


1;
