#!/usr/bin/perl

package C07_2;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( max );

use C07_1;
use Intcode;

# Call main if script is ran directly (eg, not loaded by another script)
main() unless caller;


sub find_best_sequence_feedback {
    my @prog = @_;
    my @permuts = C07_1::generate_permutation(5, 6, 7, 8, 9);

    my $max = 0;
    for my $permut (@permuts) {

        my @controllers = map { (Intcode::eval_intcode([@prog], input => [$_]))[0] } @$permut;

        my $input = 0;
      outer:
        while (1) {
            my $is_done = 0;
            for my $controller (@controllers) {
                my ($prog, $output) = Intcode::restore_prog($controller, input => [$input]);
                $input = $output->[0];

                if (ref $prog ne 'HASH') {
                    $is_done = 1;
                } else {
                    $controller = $prog;
                }
            }
            last if $is_done;
        }
        $max = max($input, $max);
    }

    return $max;
}

sub main {
    open my $FH, '<', "input_07.txt" or die $!;
    my @input = split ",", <$FH>;

    # my @input = (3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,
    #              27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5);
    # my @input = (3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,
    #              -5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,
    #              53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10);

    say find_best_sequence_feedback(@input);
}

1;
