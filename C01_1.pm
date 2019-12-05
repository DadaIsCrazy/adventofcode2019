#!/usr/bin/perl

package C01_1;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( sum );

# Call main if script is ran directly (eg, not loaded by another script)
main() unless caller;

sub get_fuel_for_mass {
    return int($_[0] / 3) - 2;
}

sub get_fuel_for_modules {
    return sum map get_fuel_for_mass($_), @{$_[0]};
}


sub main {
    @ARGV = "input_01.txt" unless @ARGV;

    say get_fuel_for_modules([<>]);
}

1;
