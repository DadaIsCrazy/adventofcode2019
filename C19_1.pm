#!/usr/bin/perl

package C19_1;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( min max );

no warnings 'recursion';

use Intcode;

# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;

sub get_area {
    my ($prog) = @_;

    my $count = 0;
    for my $x (0 .. 59) {
        for my $y (0 .. 59) {
            my (undef, $output) = Intcode::eval_intcode([@$prog], input => [$x,$y]);
            print $output->[0] ? "#" : ".";
            $count += $output->[0] == 1;
        }
        print "\n";
    }
    return $count;
}


sub main {
    open my $FH, '<', "input_19.txt" or die $!;
    my @inputs =  split /,/, <$FH>;

    say get_area(\@inputs);

}

1;
