#!/usr/bin/perl

package C10_2;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( min max );

use C10_1;

# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;

sub sort_slopes {
    return 0 if $a eq $b;
    return -1 if $a =~ /u/ && $b =~ /b/;
    return 1 if  $a =~ /b/ && $b =~ /u/;
    no warnings;
    return $a <=> $b if $a =~ /u/;
    return $a <=> $b if $a =~ /b/;
}

sub compute_200th {
    my ($xo, $yo, @map) = @_;

    my $counter = 0;
    while (1) {
        my %slopes;
        for my $x2 (0 .. $#map) {
            for my $y2 (0 .. $#{$map[0]}) {
                next unless $map[$x2][$y2];
                next if $x2 == $xo && $y2 == $yo;
                my $key;
                if ($x2 == $xo) {
                    $key = 0 . ($yo > $y2 ? "b" : "u");
                } elsif ($yo == $y2) {
                    $key = "-inf" . ($xo > $x2 ? "u" : "b");
                } else {
                    my $slope = ($xo - $x2) / ($yo - $y2);
                    $key = $slope . ($y2 > $yo ? "u" : "b");
                }
                my $new_dst = sqrt(($xo-$x2)**2 + ($yo-$y2)**2);
                if (exists $slopes{$key}) {
                    my $old_dst = $slopes{$key}->[0];
                    if ($new_dst < $old_dst) {
                        $slopes{$key} = [$new_dst, $x2, $y2];
                    }
                } else {
                    $slopes{$key} = [$new_dst, $x2, $y2];
                }
            }
        }

        my @slopes = map { $slopes{$_} } sort sort_slopes keys %slopes;

        for (@slopes) {
            my (undef, $x, $y) = @$_;
            $map[$x][$y] = 0;
            if (++$counter == 200) {
                return @$_;
            }
        }
    }

}


sub main {
    open my $FH, '<', "input_10.txt" or die $!;
    my @input = map { chomp; [split //, y/.#/01/r ] } <$FH>;

    my @input1 = map { [ split //, y/.#/01/r ] }
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

    my $station = C10_1::compute_best_spot(@input);
    my (undef, $y, $x) = compute_200th($station->[0], $station->[1], @input);
    say $x * 100 + $y;
}

1;
