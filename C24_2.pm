#!/usr/bin/perl

package C24_2;

use strict;
use warnings;
use feature qw( say );


# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;

sub count_bugs {
    my ($layers) = @_;
    my $tot = 0;
    for my $id (keys %$layers) {
        for my $i (0 .. $#{$layers->{$id}}) {
            for my $j (0 .. $#{$layers->{$id}[$i]}) {
                next if $i == 2 && $j == 2;
                $tot += $layers->{$id}[$i][$j];
            }
        }
    }
    return $tot;
}

sub make_empty_grid {
    return [ map { [ (0)x5 ] } 1 .. 5 ];
}

sub simulate {
    my @grid = @_;

    my %layers = (
        -1 => make_empty_grid(),
        0  => \@grid,
        1  => make_empty_grid());
    my ($min, $max) = (-1, 1);

    for (1 .. 200) {
        my %new;

        for my $id (keys %layers) {
            my $grid = $layers{$id};
            my @new;
            for my $i (0 .. $#$grid) {
                for my $j (0 .. $#{$grid->[$i]}) {
                    next if $i == 2 && $j == 2;
                    my $neighbors = 0;
                    for my $coord ([$i+1,$j],[$i-1,$j],
                                   [$i,$j+1],[$i,$j-1]) {
                        my ($x, $y) = @$coord;
                        if ($x < 0 && $id != $min) {
                            $neighbors += $layers{$id-1}[1][2];
                        } elsif ($x >= @$grid && $id != $min) {
                            $neighbors += $layers{$id-1}[3][2];
                        } elsif ($y < 0 && $id != $min) {
                            $neighbors += $layers{$id-1}[2][1];
                        } elsif ($y >= @{$grid->[$i]} && $id != $min) {
                            $neighbors += $layers{$id-1}[2][3];
                        } elsif ($x == 2 && $y == 2 && $id != $max) {
                            if ($i == 1 && $j == 2) {
                                $neighbors += grep { $_ == 1 } @{$layers{$id+1}[0]};
                            } elsif ($i == 3 && $j == 2) {
                                $neighbors += grep { $_ == 1 } @{$layers{$id+1}[-1]};
                            } elsif ($i == 2 && $j == 1) {
                                $neighbors += grep { $layers{$id+1}[$_][0] == 1 } 0 .. 4;
                            } elsif ($i == 2 && $j == 3) {
                                $neighbors += grep { $layers{$id+1}[$_][-1] == 1 } 0 .. 4;
                            } else {
                                die "Weird thing here";
                            }
                        } elsif ($x >= 0 && $x < @$grid && $y >= 0 && $y < @{$grid->[$i]} &&
                                 !($x == 2 && $y == 2)) {
                            $neighbors += $grid->[$x][$y];
                        } else {
                            if ($id != $min && $id != $max && !($x == 2 && $y == 2)) {
                                die "Unexpected... ($id, $x, $y)";
                            }
                        }
                    }
                    if ($grid->[$i][$j]) {
                        $new[$i][$j] = $neighbors == 1 ? 1 : 0;
                    } else {
                        $new[$i][$j] = ($neighbors == 1 || $neighbors == 2) ? 1 : 0;
                    }
                }
            }
            $new[2][2] = 0;
            $new{$id} = \@new;
        }

        my $c_min = grep { $_ != 0 } map { @$_ } @{$layers{$min}};
        if ($c_min != 0) {
            $new{--$min} = make_empty_grid();
        }
        my $c_max = grep { $_ != 0 } map { @$_ } @{$layers{$max}};
        if ($c_max != 0) {
            $new{++$max} = make_empty_grid();
        }

        %layers = %new;
    }

    # Printing for debug
    # for my $id (sort { $a <=> $b } keys %layers) {
    #     say "$id:";
    #     for my $i (0 .. 4) {
    #         for my $j (0 .. 4) {
    #             if ($i == 2 && $j == 2) {
    #                 print "?";
    #             } else {
    #                 print $layers{$id}[$i][$j] ? "#" : ".";
    #             }
    #         }
    #         print "\n";
    #     }
    #     say "";
    # }

    say count_bugs(\%layers);
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
