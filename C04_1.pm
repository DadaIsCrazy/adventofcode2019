#!/usr/bin/perl

package C04_1;

use strict;
use warnings;
use feature qw( say );

# Call main if script is ran directly (eg, not loaded by another script)
main() unless caller;

# Note that this function does not do range-checking: if $min and $max
# are both in the range, this would be useless.
sub compute_passwords {
    my ($min, $max) = @_;
    $max //= $min; # if $max is not supplied, then use $min (this
                   # allows this function to check if a single
                   # password is valid)

    my $total = 0;
    outer:
    for my $n ($min .. $max) {
        next unless $n =~ /(.)\1/;
        my @digits = $n =~ /./g;
        for (1 .. $#digits) {
            next outer if $digits[$_-1] > $digits[$_];
        }
        $total++;
    }
    return $total;
}

sub main {
    # Super exhaustive testing
    die unless compute_passwords(111111);
    die if     compute_passwords(223450);
    die if     compute_passwords(123789);

    # The real thing
    say compute_passwords(183564, 657474);
}

1;
