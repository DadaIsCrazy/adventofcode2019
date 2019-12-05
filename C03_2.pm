#!/usr/bin/perl

# Note that this is all overly complicated, mostly because I wanted
# the ability to print the grid. Turns out this is not that much
# helpful, but whatever :)

package C03_1;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( min max sum );

# Call main if script is ran directly (eg, not loaded by another script)
main() unless caller;

sub print_grid {
    my ($grid) = @_;
    my $min_x = min keys %$grid;
    my $max_x = max keys %$grid;
    my $min_y = min map { keys %{$grid->{$_}} } keys %$grid;
    my $max_y = max map { keys %{$grid->{$_}} } keys %$grid;
    for my $y (reverse($min_y .. $max_y)) {
        for my $x ($min_x .. $max_x) {
            if ($grid->{$x}->{$y}) {
                my @arr = @{$grid->{$x}->{$y}};
                my %wires = map { ($_->[1] => 1) } @arr;
                if (keys %wires > 1) {
                    print "X";
                } else {
                    print $arr[-1][0];
                }
            } else {
                printf " ";
            }
        }
        print "\n";
    }
}

sub mark_cell {
    my ($grid, $x, $y, $dir, $num, $steps) = @_;
    push @{$grid->{$x}->{$y}}, [ ($dir =~ /R|L/ ? "-" : "|"), $num, $steps ];
}

sub compute_wire_grid {
    my @wires = @_;

    my %grid;
    $grid{0}{0} = [ [ "o", -1, 0 ] ];
    for (my $wire_num = 0; $wire_num < @wires; $wire_num++) {
        my $wire = $wires[$wire_num];
        my ($x, $y, $steps) = (0,0,0);
        for (@$wire) {
            my ($dir, $len) = /(R|L|U|D)(\d+)/;
            push @{$grid{$x}{$y}}, ["+", $wire_num, $steps] if $steps > 0;
            if ($dir eq "U") {
                mark_cell(\%grid, $x, $_, $dir, $wire_num, ++$steps)
                    for $y+1 .. $y+$len;
                $y += $len;
            } elsif ($dir eq "D") {
                mark_cell(\%grid, $x, $_, $dir, $wire_num, ++$steps)
                    for reverse($y-$len .. $y-1);
                $y -= $len;
            } elsif ($dir eq "R") {
                mark_cell(\%grid, $_, $y, $dir, $wire_num, ++$steps)
                    for $x+1 .. $x+$len;
                $x += $len;
            } elsif ($dir eq "L") {
                mark_cell(\%grid, $_, $y, $dir, $wire_num, ++$steps)
                    for reverse($x-$len .. $x-1);
                $x -= $len;
            } else {
                die "Unkwnown direction $dir";
            }
        }
    }

    return \%grid;
}

sub compute_port_distance {
    my ($grid) = @_;
    my $min_dst = 1e9;
    for my $x (keys %$grid) {
        for my $y (keys %{$grid->{$x}}) {
            if ($grid->{$x}->{$y}) {
                my @arr = @{$grid->{$x}->{$y}};
                my %wires;
                for (@arr) {
                    my ($wire, $steps) = ($_->[1],$_->[2]);
                    if (exists $wires{$wire}) {
                        $wires{$wire} = min($wires{$wire},$steps);
                    } else {
                        $wires{$wire} = $steps;
                    }
                }
                if (keys %wires > 1) {
                    my $dst = sum values %wires;
                    $min_dst = min($min_dst, $dst);
                }
            }
        }
    }
    return $min_dst;
}



sub main {
    # my $grid =
    #     compute_wire_grid(
    #         [split ",", "R8,U5,L5,D3"],
    #         [split ",", "U7,R6,D4,L4"]
    #     );
    # my $grid =
    #     compute_wire_grid(
    #         [split ",", "R75,D30,R83,U83,L12,D49,R71,U7,L72"],
    #         [split ",", "U62,R66,U55,R34,D71,R55,D58,R83"]
    #     );
    # my $grid =
    #     compute_wire_grid(
    #         [split ",", "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51"],
    #         [split ",", "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"]
    #     );

    @ARGV = "input_03.txt" unless @ARGV;
    my @input = map { [split ","] } <>;

    my $grid = compute_wire_grid(@input);
    # print_grid($grid);

    say compute_port_distance($grid);

}

1;
