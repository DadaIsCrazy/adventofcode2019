#!/usr/bin/perl

package C11_2;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( min max sum );

use C11_1;

# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;


sub print_grid {
    my ($grid, $x, $y, $dir) = @_;

    my $min_x = min (keys %$grid, $x);
    my $max_x = max (keys %$grid, $x);
    my ($min_y, $max_y) = (1000, 0);
    for (keys %$grid) {
        $min_y = min($min_y, $y, keys %{$grid->{$_}});
        $max_y = max($max_y, $y, keys %{$grid->{$_}});
    }

    for my $i ($min_x .. $max_x) {
        for my $j ($min_y .. $max_y) {
            if ($i == $x && $j == $y) {
                print $dir;
            } else {
                print $grid->{$i}{$j} ? "#" : ".";
            }
        }
        print "\n";
    }
}


sub main {
    open my $FH, '<', "input_11.txt" or die $!;
    my @input = split ",", <$FH>;

    # Below: the example from the puzzle's description
    # my @input = (3, 0,
    #              104, 1,
    #              104, 0,
    #              3, 0,
    #              104, 0,
    #              104, 0,
    #              3, 0,
    #              104, 1,
    #              104, 0,
    #              3, 0,
    #              104, 1,
    #              104, 0,
    #              3, 0,
    #              104, 0,
    #              104, 1,
    #              3, 0,
    #              104, 1,
    #              104, 0,
    #              3, 0,
    #              104, 1,
    #              104, 0,
    #              99);

    say print_grid(C11_1::paint(1,@input));
}

1;
