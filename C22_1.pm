#!/usr/bin/perl

package C22_1;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( min max );

no warnings 'recursion';


# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;

# Shuffles the whole deck. Good enough for part one; not even remotely
# reasonable for part 2.
sub shuffle {
    my ($instrs, $deck_size) = @_;

    my @deck = (0 .. $deck_size-1);

    for my $instr (@$instrs) {
        if ($instr =~ /^deal into new stack/) {
            @deck = reverse @deck;
        } elsif ($instr =~ /^cut (-?\d+)/) {
            if ($1 >= 0) {
                @deck = @deck[$1..$#deck,0..$1-1];
            } else {
                @deck = @deck[@deck+$1..$#deck,0..@deck+$1-1];
            }
        } elsif ($instr =~ /^deal with increment (\d+)/) {
            my $count = $1;
            my @new_deck;
            my $i = 0;
            for my $j (0 .. $#deck) {
                $new_deck[$i] = $deck[$j];
                $i = ($i + $count) % @deck;
            }
            @deck = @new_deck;
        }
    }

    return @deck;
}


# Just keeps track of the card |$idx|.
sub shuffle_fast {
    my ($instrs, $idx, $deck_size) = @_;

    for my $instr (@$instrs) {
        if ($instr =~ /^deal into new stack/) {
            $idx = $deck_size - 1 - $idx;
        } elsif ($instr =~ /^cut (-?\d+)/) {
            $idx = ($deck_size - $1 + $idx) % $deck_size;
        } elsif ($instr =~ /^deal with increment (\d+)/) {
            my $count = $1;
            $idx = ($idx * $count) % $deck_size;
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

    # say join " ", shuffle(["deal into new stack"],10);
    # say join " ", shuffle(["cut 3"],10);
    # say join " ", shuffle(["cut -4"],10);
    # say join " ", shuffle(["deal with increment 3"],10);

    # say join " ", shuffle([split /\n/, $input1], 10);
    # say join " ", shuffle([(split /\n/, $input1)x2], 10);
    # say join " ", shuffle([(split /\n/, $input1)x3], 10);
    # say join " ", shuffle([(split /\n/, $input1)x4], 10);
    # say join " ", shuffle([split /\n/, $input2], 10);
    # say join " ", shuffle([split /\n/, $input3], 10);
    # say join " ", shuffle([split /\n/, $input4], 10);

    my $input = do { open my $FH, '<', 'input_22.txt' or die $!;
                     local $/;
                     <$FH>; };
    # my @deck = shuffle([split /\n/, $input], 10007);
    # my ($idx) = grep { $deck[$_] == 2019 } 0 .. $#deck;
    # say $idx;
    say shuffle_fast([split /\n/, $input], 2019, 10007);
}
