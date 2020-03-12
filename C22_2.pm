#!/usr/bin/perl

=head 1

The idea of this script is to:

  - reduce a single shuffle to an affine (modular) function: f(x) = ax + b % d

  - compute f(f(f(...f(x)))) by reducing it using the idea that
      f(f(x)) = f(ax + b) = a(ax+b)+b = aax + ab + b

In more details:

  - |simpl_formula| reduces on full shuffle (backward) to an affine
    function. A few comments document the reductions.

  - |compute| computes f(x) iterated |$count| times (where count =
     101741582076661). To compute f^n(x), it computes f^k(g(x)) where
     g(x) = f^(n-k)(x), with n-k a power of 2. Power of 2 because our
     simplification works by remplacing f(f(x)) by f2(x), then
     f2(f2(x)) by f3(x), and so on.

=cut

package C22_1;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( min max );

use bigint lib => 'GMP';
use DDP;

no warnings 'recursion';


# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;

sub simpl_formula {
    my ($instrs, $deck_size) = @_;

    my ($A, $B, $D) = (1, 0, $deck_size);
    # f(x) = ax + b % d

    for my $instr (reverse @$instrs) {
        if ($instr =~ /^deal into new stack/) {
            # f(x) = d - 1 - x = d - 1 - (ax + b) = d - 1 - b - ax
            $B = ($D - 1 - $B) % $D;
            $A = (-$A) % $D;
        } elsif ($instr =~ /^cut (-?\d+)/) {
            # f(x) = x + c = ax + b + c
            my $C = $1;
            $B = ($B + $C) % $D;
        } elsif ($instr =~ /^deal with increment (\d+)/) {
            # f(x) = cx = (ax + b) / c = (ax + b) * (1/c) = ax * (1/c) + b * (1/c)
            my $C = $1;
            my $modinv = Math::BigInt->new($C)->bmodinv($D);
            $A = ($A * $modinv) % $D;
            $B = ($B * $modinv) % $D;
        }
    }

    return ($A, $B);
}

sub compute {
    my ($Ai, $Bi, $D, $count, $val) = @_;

    while ($count > 0) {
        my ($A, $B) = ($Ai, $Bi);

        my $i = 1;
        while ($i*2 < $count) {
            ($A, $B) = (($A*$A) % $D, ($A*$B + $B) % $D);
            $i *= 2;
        }
        $count -= $i;
        $val = ($A * $val + $B) % $D;
    }

    return $val;
}


# Not used, but was useful to get to the current solution.
sub shuffle_backward {
    my ($instrs, $idx, $deck_size) = @_;

    for my $instr (reverse @$instrs) {
        if ($instr =~ /^deal into new stack/) {
            $idx = $deck_size - 1 - $idx;
        } elsif ($instr =~ /^cut (-?\d+)/) {
            $idx = ($idx + $1) % $deck_size;
        } elsif ($instr =~ /^deal with increment (\d+)/) {
            my $count = Math::BigInt->new($1);
            $idx = ($idx * $count->bmodinv($deck_size)) % $deck_size;
        }
    }

    return $idx;
}

sub main {
    my $input1 = "deal with increment 7
deal into new stack
deal into new stack";

    my $input2 = "cut 6
deal with increment 7
deal into new stack";

    my $input3 = "deal with increment 7
deal with increment 9
cut -2";

    my $input4 = "deal into new stack
cut -2
deal with increment 7
cut 8
cut -4
deal with increment 7
cut 3
deal with increment 9
deal with increment 3
cut -1";

    my $input = do { open my $FH, '<', 'input_22.txt' or die $!;
                     local $/;
                     <$FH>; };
    my $start = 2020;
    my $deck_size = 119315717514047;
    my $repeat = 101741582076661;

    my ($A, $B) = simpl_formula([split /\n/, $input], $deck_size);
    say compute($A, $B, $deck_size, $repeat, $start);
}
