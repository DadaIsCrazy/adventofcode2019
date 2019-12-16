#!/usr/bin/perl

package C13_1;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( min max sum );
use Time::HiRes qw(usleep);

use Intcode;

# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;

sub print_tiles {
    my ($grid) = @_;
    my $max_x = $#$grid;
    my $max_y = 0;
    $max_y = max($max_y, $#$_) for @$grid;

    # ($max_x, $max_y) = (37, 20);

    for my $x (0 .. $max_x) {
        for my $y (0 .. $max_y-1) {
            my $cell = $grid->[$x][$y];
            print $cell ?
                $cell == 0 ? " " :
                $cell == 1 ? "#" :
                $cell == 2 ? "@" :
                $cell == 3 ? "|" :
                $cell == 4 ? "o" :
                die "Unkown id $cell"
                : " ";
        }
        print "#\n";
    }
}

sub count_blocks {
    my ($grid) = @_;
    my $total = 0;
    for my $x (0 .. $#$grid) {
        for my $y (0 .. $#{$grid->[$x]}) {
            $total += $grid->[$x][$y] == 2;
        }
    }
    return $total;
}

sub build_grid {
    my ($tile_codes) = @_;

    my @grid;
    for (my $i = 0; $i < $#$tile_codes; $i += 3) {
        my ($x, $y, $id) = @{$tile_codes}[$i, $i+1, $i+2];
        $grid[$x][$y] = $id;
        # print "\033c";
        # print_tiles(\@grid);
        # usleep(30000);
    }


    return \@grid;
}

sub run_game {
    my ($prog) = @_;

    my (undef, $output) = Intcode::eval_intcode($prog);

    return count_blocks(build_grid($output));

}


sub main {
    open my $FH, '<', 'input_13.txt' or die $!;
    my @input = split /,/, <$FH>;

    say run_game(\@input);
}

1;
