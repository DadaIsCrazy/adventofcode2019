#!/usr/bin/perl

# A really lame solution for a developper: I ran the program a few
# time a manually looked at the constraint. I then adjusted my input
# in order to get a good boolean formula. I'll probably come back to
# that one later.

package C21_1;

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
"NOT C T
AND A T
AND D T
NOT A J
AND C J
AND D J
OR T J
NOT B T
AND D T
OR T J
WALK
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

#####.###########   -> ~A || ~B || ~C
#####...#########   -> ~A
#####..#.########   -> ~B && ~C && D
#####.##.########   -> ~B && D

(!A && B && C && D) ||
(A && !B && C && D) ||
(A && B && !C && D) ||

(!A && !B && !C) ||

(!B && !C)


NOT B J  # j = !b
NOT C T  # t = !c
AND J T  # t = !b && !c
NOT D J  # j = !d
NOT J J  # j = d
AND J T  # t = (!b && !c) && d
NOT A J  # j = !a
OR T J   # j = !a || (!b && !c && d)
WALK



(!A && B && C && D) ||
(A && !B && C && D) ||
(A && B && !C && D) ||

(!A && !B && !C && D) ||

(!B && !C && D) ||

(!B && D)
