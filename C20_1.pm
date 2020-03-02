#!/usr/bin/perl

package C20_1;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( min max );

no warnings 'recursion';


# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;


sub parse_string {
    my ($input) = @_;
    my (@maze, %portals);

    my @input = map { [ split // ] } split /\n/, $input;

    # Parsing maze only
    for my $i (2 .. $#input-2) {
        for my $j (2 .. $#{$input[$i]}-2) {
            if ($input[$i][$j] eq '.') {
                $maze[$i-2][$j-2] = 1;
            } else {
                $maze[$i-2][$j-2] = 0;
            }
        }
    }

    # Parsing portals
    for my $i (0 .. $#input) {
        for my $j (0 .. $#{$input[$i]}) {
            if ($input[$i][$j] =~ /[A-Z]/) {

            }
        }
    }

}

sub main {
    my $test_input1 =
"         A
         A
  #######.#########
  #######.........#
  #######.#######.#
  #######.#######.#
  #######.#######.#
  #####  B    ###.#
BC...##  C    ###.#
  ##.##       ###.#
  ##...DE  F  ###.#
  #####    G  ###.#
  #########.#####.#
DE..#######...###.#
  #.#########.###.#
FG..#########.....#
  ###########.#####
             Z
             Z     ";

    my $maze = parse_string($test_input1);

#    open my $FH, '<', "input_19.txt" or die $!;
#    my @inputs =  split /,/, <$FH>;


}

1;
