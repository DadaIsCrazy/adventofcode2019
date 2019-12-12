#!/usr/bin/perl

package C10_1;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( min max );


# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;


sub compute_best_spot {
    my @map = @_;

    my ($max, $best) = (0);
    for my $xo (0 .. $#map) {
        for my $yo (0 .. $#{$map[0]}) {
            next unless $map[$xo][$yo];

            my %slopes;
            for my $x2 (0 .. $#map) {
                for my $y2 (0 .. $#{$map[0]}) {
                    next unless $map[$x2][$y2];
                    next if $x2 == $xo && $y2 == $yo;
                    my $key;
                    if ($x2 == $xo) {
                        $key = "h" . ($yo > $y2 ? 1 : -1);
                    } elsif ($yo == $y2) {
                        $key = "v" . ($xo > $x2 ? 1 : -1);
                    } else {
                        my $slope = ($y2 - $yo) / ($x2 - $xo);
                        $key = $slope . ($yo > $y2 ? "u" : "b");
                    }
                    push @{$slopes{$key}}, [$x2, $y2];
                }
            }
            my $total = keys %slopes;

            # Old code:
            #
            # For each cell $x2-$y2, compute a line equation from
            # $xo-$yo to this cell. Then, for each point on this line,
            # check if it corresponds to a cell on the map. If yes,
            # then check if this cell contains an asteroid, and if so,
            # ignore the current cell.
            #
            # Doesn't work for some reason. Maybe because of floating
            # point imprecision?

            # my @tmp;
            # my $total = 0;
            # for my $x2 (0 .. $#map) {
            #     outer:
            #     for my $y2 (0 .. $#{$map[0]}) {
            #         next if $x2 == $xo && $y2 == $yo;
            #         $tmp[$x2][$y2] = " ";
            #         next unless $map[$x2][$y2];

            #         if ($x2 == $xo) {
            #             for my $y (1+min($yo,$y2) .. max($yo,$y2)-1) {
            #                 next outer if $map[$xo][$y];
            #             }
            #         }
            #         elsif ($y2 == $yo) {
            #             for my $x (1+min($xo,$x2) .. max($xo,$x2)-1) {
            #                 next outer if $map[$x][$yo];
            #             }
            #         }
            #         else {
            #             my $m = ($y2 - $yo) / ($x2 - $xo);
            #             my $b = $yo - ($m * $xo);
            #             my $other_b = $y2 - ($m * $x2);
            #             # next unless $b == $other_b;
            #             # if ($b != $other_b) {
            #             #     die "$x2:$y2  ->  $b vs $other_b";
            #             # }

            #             for my $x (1+min($xo,$x2) .. max($xo,$x2)-1) {
            #                 my $y = $m * $x + $b;
            #                 next unless $y == int($y);
            #                 next outer if $map[$x][$y];
            #             }
            #         }
            #         $tmp[$x2][$y2] = "X";
            #         $total++;
            #     }
            # }
            # say join "\n", map { join "", @$_ } @tmp;
            # say "$xo - $yo: $total";

            if ($total > $max) {
                $max = $total;
                $best = [$xo, $yo, $total];
            }
        }
    }

    return $best;
}


sub main {
    open my $FH, '<', "input_10.txt" or die $!;
    my @input = map { chomp; [split //, y/.#/01/r ] } <$FH>;

    my @input1 = map { [ split //, y/.#/01/r ] }
".#..#",
".....",
"#####",
"....#",
"...##";

    my @input2 = map { [ split //, y/.#/01/r ] }
"......#.#.",
"#..#.#....",
"..#######.",
".#.#.###..",
".#..#.....",
"..#....#.#",
"#..#....#.",
".##.#..###",
"##...#..#.",
".#....####";

    my @input3 = map { [ split //, y/.#/01/r ] }
"#.#...#.#.",
".###....#.",
".#....#...",
"##.#.#.#.#",
"....#.#.#.",
".##..###.#",
"..#...##..",
"..##....##",
"......#...",
".####.###.";

    my @input4 = map { [ split //, y/.#/01/r ] }
".#..#..###",
"####.###.#",
"....###.#.",
"..###.##.#",
"##.##.#.#.",
"....###..#",
"..#.#..#.#",
"#..#.#.###",
".##...##.#",
".....#.#..";

    my @input5 = map { [ split //, y/.#/01/r ] }
".#..##.###...#######",
"##.############..##.",
".#.######.########.#",
".###.#######.####.#.",
"#####.##.#.##.###.##",
"..#####..#.#########",
"####################",
"#.####....###.#.#.##",
"##.#################",
"#####.##.###..####..",
"..######..##.#######",
"####.##.####...##..#",
".#####..#.######.###",
"##...#.##########...",
"#.##########.#######",
".####.#.###.###.#.##",
"....##.##.###..#####",
".#.#.###########.###",
"#.#.#.#####.####.###",
"###.##.####.##.#..##";

    die unless (compute_best_spot(@input1))[0][2] == 8;
    die unless (compute_best_spot(@input2))[0][2] == 33;
    die unless (compute_best_spot(@input3))[0][2] == 35;
    die unless (compute_best_spot(@input4))[0][2] == 41;
    die unless (compute_best_spot(@input5))[0][2] == 210;

    my $res = compute_best_spot(@input);
    say "$res->[1]:$res->[0]  --  $res->[2]";
}

1;
