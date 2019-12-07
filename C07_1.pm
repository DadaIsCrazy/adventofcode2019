#!/usr/bin/perl

package C07_1;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( max );

use Intcode;

# Call main if script is ran directly (eg, not loaded by another script)
main() unless caller;

# Suppose each element is unique
sub _generate_permutations {
    my ($elems) = @_;
    return [ keys %$elems ] if keys %$elems == 1;
    my @permuts;
    for my $e (keys %$elems) {
        delete $elems->{$e};
        push @permuts, map { [ @$_, $e ] } _generate_permutations($elems);
        $elems->{$e} = 1;
    }
    return @permuts;
}
sub generate_permutation {
    my %elems = map { $_ => 1 } @_;
    return _generate_permutations(\%elems);
}

sub find_best_sequence {
    my @prog = @_;
    my @permuts = generate_permutation(0, 1, 2, 3, 4);

    my $max = 0;
    for my $permut (@permuts) {
        my $input = 0;
        for my $phase (@$permut) {
            my @copy = @prog;
            my (undef, $output) = Intcode::eval_intcode(\@copy, input => [$phase, $input]);
            $input = $output->[0];
        }
        $max = max($input, $max);
    }

    return $max;
}

sub main {
    open my $FH, '<', "input_07.txt" or die $!;
    my @input = split ",", <$FH>;

    # my @input = (3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0);
    # my @input = (3,23,3,24,1002,24,10,24,1002,23,-1,23,
    #              101,5,23,23,1,24,23,23,4,23,99,0,0);
    # my @input = (3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,
    #              1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0);

    say find_best_sequence(@input);
}

1;
