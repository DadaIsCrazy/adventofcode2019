#!/usr/bin/perl

package C16_1;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( min max );

# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;


sub build_pattern {
    my ($size, $n) = @_;
    my @pattern = ( (0)x$n, (1)x$n, (0)x$n, (-1)x$n ) x (1+ $size / 4 );
    shift @pattern;
    return @pattern;
}

sub build_patterns {
    my ($n) = @_;
    return map { [ build_pattern($n, $_) ] } 1 .. $n;
}


sub fft {
    my @digits = split //, $_[0];
    # Note: could probably have done without build all patterns using
    # just (0, 1, 0, -1) and some arithmetic, but this is easier.
    my @patterns = build_patterns(scalar @digits);

    for (1 .. $_[1]) {
        say;
        my @new_digits;
        for my $i (0 ..$#digits) {
            for my $j (0 .. $#digits) {
                # Alternative would be something like:
                # $new_digits[$i] += $digits[$j] * (0,1,0,-1)[(($j+1)/($i+1))%4];
                $new_digits[$i] += $digits[$j] * $patterns[$i][$j];
            }
            $new_digits[$i] = abs($new_digits[$i]) % 10;
        }
        @digits = @new_digits;
    }
    return substr join("", @digits), 0, 8;
}


sub main {
    # die unless fft('12345678', 4) == '01029498';
    # die unless fft('80871224585914546619083218645595', 100) == 24176176;
    # die unless fft('19617804207202209144916044189917', 100) == 73745418;
    # die unless fft('69317163492948606335995924319873', 100) == 52432133;

    open my $FH, '<', 'input_16.txt' or die $!;
    chomp(my $input = <$FH>);
    say fft($input, 100);
}

1;
