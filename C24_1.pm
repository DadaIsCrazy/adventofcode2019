#!/usr/bin/perl

package C24_1;

use strict;
use warnings;
use feature qw( say );


# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;

sub count_points {
    my @grid = @_;

    my ($tot,$v) = (0,1);
    for my $i (0 .. $#grid) {
        for my $j (0 .. $#{$grid[$i]}) {
            $tot += $grid[$i][$j] * $v;
            $v *= 2;
        }
    }

    return $tot;
}

sub simulate {
    my @grid = @_;

    my %seen;

    while (1) {
        my @new;

        my $str_grid = join "", map { join "", @$_ } @grid;
        last if $seen{$str_grid}++;

        for my $i (0 .. $#grid) {
            for my $j (0 .. $#{$grid[$i]}) {
                my $neighbors = 0;
                for my $coord ([$i+1,$j],[$i-1,$j],
                               [$i,$j+1],[$i,$j-1]) {
                    my ($x, $y) = @$coord;
                    next unless $x >= 0 && $x < @grid && $y >= 0 && $y < @{$grid[$i]};
                    $neighbors += $grid[$x][$y];
                }
                if ($grid[$i][$j]) {
                    $new[$i][$j] = $neighbors == 1 ? 1 : 0;
                } else {
                    $new[$i][$j] = ($neighbors == 1 || $neighbors == 2) ? 1 : 0;
                }
            }
        }

        @grid = @new;
    }

    say count_points(@grid);
}

sub parse_input {
    my ($input) = @_;
    return map { [ split '' ] } split /\n/, ($input =~ y/.#/01/r);
}


sub main {
#     my $input = "....#
# #..#.
# #..##
# ..#..
# #....";

    my $input = do { local $/;
                     open my $FH, '<', 'input_24.txt' or die $!;
                     <$FH> };
    chomp $input;

    my @grid = parse_input($input);

    simulate(@grid);
}
