#!/usr/bin/perl

# Two ideas to get this one to work
#  - if the answer is the 8 digits at index n, that all digits before
#    can be ignored as they don't impact those numbers.
#  - since the answer we are asked it as index 5.9 million, all
#    factors of the pattern are 1 and 0 (forming a triangular matrix).
#    hence we just have to do additions.

package C16_2;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( min max );

# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;



sub fft {
    # Note: could optimize @digits initialization; we are allocating a
    # lot of memory for nothing.
    my @digits = split //, $_[0];
    @digits = (@digits) x 10000;
    my @pattern = (0, 1, 0, -1);
    my $idx = substr($_[0],0,7);
    @digits = @digits[$idx .. $#digits];

    for (1 .. $_[1]) {
        my $sum = 0;
        my @new_digits;
        for my $i (reverse(0 ..$#digits)) {
            $sum = ($sum + $digits[$i]) % 10;
            $new_digits[$i] = $sum;
        }
        @digits = @new_digits;
    }
    return substr join("", @digits), 0, 8;
}

sub main {
    # die unless fft('03036732577212944063491565474664',100) == 84462026;
    # die unless fft('02935109699940807407585447034323',100) == 78725270;
    # die unless fft('03081770884921959731165446850517',100) == 53553731;

    open my $FH, '<', 'input_16.txt' or die $!;
    chomp(my $input = <$FH>);
    say fft($input, 100);
}

1;
