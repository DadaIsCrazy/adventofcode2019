#!/usr/bin/perl

package C11_1;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( min max sum );

use Intcode;

# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;

sub update_xy {
    my ($x,$y,$dir,$turn) = @_;
    my @dirs = qw(^ < v >);
    my %dirs;
    $dirs{$dirs[$_]} = $_ for 0 .. $#dirs;

    $turn = $turn == 0 ? 1 : -1;

    my $new_dir = $dirs[($dirs{$dir} + $turn) % @dirs];

    if ($new_dir eq "^") {
        $x = $x - 1;
    } elsif ($new_dir eq "<") {
        $y = $y - 1;
    } elsif ($new_dir eq "v") {
        $x = $x + 1;
    } elsif ($new_dir eq ">") {
        $y = $y + 1;
    } else {
        die "aaaargh";
    }

    return ($x, $y, $new_dir);
}

sub paint {
    my ($init_color,@prog) = @_;
    my (%grid);
    my ($x,$y,$dir) = (0,0,"^");

    my ($prog, $output) = Intcode::eval_intcode([@prog], input => [$init_color]);
    my ($color, $turn) = @$output;
    $grid{$x}{$y} = $color;
    ($x,$y, $dir) = update_xy($x,$y,$dir,$turn);
    while (ref $prog eq 'HASH') {
        ($prog, $output) = Intcode::restore_prog($prog, input => [ $grid{$x}{$y} //= 0 ]);
        ($color, $turn) = @$output;
        $grid{$x}{$y} = $color;
        ($x, $y, $dir) = update_xy($x, $y, $dir, $turn);
    }

    return (\%grid, $x, $y, $dir);

}

sub count_paint {
    my ($grid) = @_;
    return sum map { scalar keys %{$grid->{$_}} } keys %$grid;
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

    say count_paint(paint(0, @input));
}

1;
