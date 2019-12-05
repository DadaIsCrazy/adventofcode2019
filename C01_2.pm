#!/usr/bin/perl

package C01_2;

use strict;
use warnings;
use feature qw( say );

use C01_1;

# Call main if script is ran directly (eg, not loaded by another script)
main() unless caller;


sub get_fuel_for_modules_corrected {
    my $total = 0;
    for my $mass (@{$_[0]}) {
        my $fuel = C01_1::get_fuel_for_mass($mass);
        while ($fuel > 0) {
            $total += $fuel;
            $fuel = C01_1::get_fuel_for_mass($fuel);
        }
    }
    return $total;
}

# This would be the solution if we were to sum all the fuel first, and
# then only compute the additional fuel required by that fuel. (I'm
# pretty sure it doesn't work because of imprecision errors)
# sub get_fuel_for_modules_corrected {
#     my $fuel_total = C01_1::get_fuel_for_modules(@_);
#     my $to_correct = C01_1::get_fuel_for_mass($fuel_total);
#     while ($to_correct > 0) {
#         $fuel_total += $to_correct;
#         $to_correct = C01_1::get_fuel_for_mass($to_correct);
#     }
#     return $fuel_total;
# }

sub main {
    @ARGV = "input_01.txt" unless @ARGV;
    my @input = <>;

    say get_fuel_for_modules_corrected(\@input);
}


1;
