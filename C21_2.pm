#!/usr/bin/perl

# A really lame solution for a developper: I ran the program a few
# time a manually looked at the constraint. I then adjusted my input
# in order to get a good boolean formula. I'll probably come back to
# that one later.

package C21_2;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( min max );

use Intcode;

# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;


sub manual_explore {
    my @inputs = @_;

    my (undef, $out) = Intcode::eval_intcode(\@inputs, input =>
                                             [map { ord } split //,
"NOT B T
NOT C J
AND T J
AND D J
NOT B T
AND D T
OR T J
NOT C T
AND D T
AND H T
OR T J
NOT A T
OR T J
RUN
"
]);
    say $out->[-1];
}


sub main {
    open my $FH, '<', "input_21.txt" or die $!;
    my @inputs =  split /,/, <$FH>;

    manual_explore(@inputs);

}

1;

__END__

#####.###########  -> ~A
#####..#.########  -> ~B && ~C && D
#####...#########  -> ~A
#####.##.########  -> ~B && D
#####.#..########  -> ~C && D && G
#####.#.#..##.###  ->
#####.#...#.#.###  -> ~C && D

~A ||

(~B && ~C && D) ||

(~B && D)
