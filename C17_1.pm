#!/usr/bin/perl

package C17_1;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( min max );

use Intcode;

# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;

sub count_score {
    my ($map) = @_;
    chomp $map;

    my @map = map { [ split // ] } split /\n/, $map;

    my $total = 0;
    for my $i (0 .. $#map) {
        for my $j (0 ..$#{$map[0]}) {
            if ($map[$i][$j] eq "O") {
                $total += $i * $j;
            }
        }
    }

    return $total;
}

sub mark_intersections {
    my ($map) = @_;

    $map =~ /.*/;
    my $len = $+[0]-1;

    1 while $map =~ s/#(.{$len})###/#$1#O#/s;

    return $map;
}

sub build_map {
    my ($prog) = @_;

    my $output = Intcode::eval_intcode($prog);

    return join "", map { chr } @$output;

}

sub main {
    open my $FH, '<', 'input_17.txt' or die $!;
    my @input = split ',', <$FH>;

    my $map = build_map(\@input);
    $map = mark_intersections($map);
# say count_score("..#..........
# ..#..........
# ##O####...###
# #.#...#...#.#
# ##O###O###O##
# ..#...#...#..
# ..#####...^..");
    say count_score($map);
}
