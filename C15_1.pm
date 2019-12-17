#!/usr/bin/perl

package C15_1;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( min max );

no warnings 'recursion';

use Intcode;

my $calls = 0;

# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;

sub print_map {
    my ($map, $xr, $yr) = @_;

    my $min_x = min (keys %$map);
    my $max_x = max (keys %$map);
    my ($min_y, $max_y) = (1000, 0);
    for (keys %$map) {
        $min_y = min($min_y, keys %{$map->{$_}});
        $max_y = max($max_y, keys %{$map->{$_}});
    }

    for my $x ($min_x .. $max_x) {
        for my $y ($min_y .. $max_y) {
            if ($x == 0 && $y == 0) {
                print "O";
            } elsif ($x == $xr && $y == $yr) {
                print "D";
            } else {
                print $map->{$x}->{$y} // " ";
            }
        }
        print "\n";
    }

}

sub update_xy {
    my ($x, $y, $dir) = @_;
    if ($dir == 1)    { return ($x-1, $y) }
    elsif ($dir == 2) { return ($x+1, $y) }
    elsif ($dir == 3) { return ($x, $y-1) }
    elsif ($dir == 4) { return ($x, $y+1) }
    else { die "Bad dir $dir" }
}

sub get_legal_moves {
    my ($map, $x, $y) = @_;
    my @moves;
    if (! defined($map->{$x-1}->{$y})) { push @moves, 1 }
    if (! defined($map->{$x+1}->{$y})) { push @moves, 2 }
    if (! defined($map->{$x}->{$y-1})) { push @moves, 3 }
    if (! defined($map->{$x}->{$y+1})) { push @moves, 4 }
    return @moves;
}

# sub explore_map_rand {
    # my $c = 0;
    # while (1) {
    #     my $dir = 1 + int(rand(4));
    #     my ($prev_x, $prev_y) = ($x, $y);
    #     ($x, $y) = update_xy($x, $y, $dir);
    #     ($prog, my $output) = Intcode::restore_prog($prog, input => [$dir]);
    #     if ($output->[0] == 0)    {
    #         $map{$x}->{$y} = "#";
    #         ($x, $y) = ($prev_x, $prev_y);
    #     }
    #     elsif ($output->[0] == 1) {
    #         $map{$x}->{$y} = "."
    #     }
    #     elsif ($output->[0] == 2) {
    #         $map{$x}->{$y} = "X"
    #     }
    #     else { die "Bad output [@$output]" }
    #     last if $c++ == 20000;
    # }
# }

# Reccursivly explores the map. Stops once the map is fully
# explored. However, does not compute result.
# Depth-forst exploration.
sub explore_map {
    my ($prog, $map, $x, $y) = @_;
    return if $calls++ == 10000;

    for my $move (get_legal_moves($map, $x, $y)) {
        my $local_prog = Intcode::copy_prog($prog);
        ($local_prog, my $output) = Intcode::restore_prog($local_prog, input => [$move]);
        my ($xn, $yn) = update_xy($x, $y, $move);
        if ($output->[0] == 0)    {
            $map->{$xn}->{$yn} = "#";
        }
        elsif ($output->[0] == 1) {
            $map->{$xn}->{$yn} = ".";
            explore_map($local_prog, $map, $xn, $yn);
        }
        elsif ($output->[0] == 2) {
            $map->{$xn}->{$yn} = "X";
            explore_map($local_prog, $map, $xn, $yn);
        }
    }
}

# Explores the map recursively and stops once the oxygen system is
# reached.
# Breadth first exploration.
sub explore_map_imp {
    my ($prog_init, $map) = @_;

    my %done;
    my @todo = ( [$prog_init, 0, 0, 0] );

    while (@todo) {
        my $next = shift @todo;
        my ($prog, $x, $y, $cost) = @$next;
        next if $done{$x}{$y}++;

        for my $move (get_legal_moves($map, $x, $y)) {
            my $prog_local = Intcode::copy_prog($prog);
            ($prog_local, my $output) = Intcode::restore_prog($prog_local, input => [$move]);
            my ($xn, $yn) = update_xy($x, $y, $move);
            if ($output->[0] == 0)    {
                $map->{$xn}->{$yn} = "#";
            } elsif ($output->[0] == 1) {
                $map->{$xn}->{$yn} = ".";
                push @todo, [$prog_local, $xn, $yn, $cost+1];
            } elsif ($output->[0] == 2) {
                $map->{$xn}->{$yn} = "X";
                return $cost+1;
                #push @todo, [$local_prog, $xn, $yn, $cost+1];
            }
        }
    }
}

sub solve {
    my ($prog) = @_;

    my %map;
    my ($x, $y) = (0, 0);

    ($prog) = Intcode::eval_intcode($prog, input => []);

    #explore_map($prog, \%map, $x, $y);
    say explore_map_imp($prog, \%map);


    print_map(\%map, $x, $y);

}

sub main {
    open my $FH, '<', "input_15.txt" or die $!;
    my @inputs =  split /,/, <$FH>;

    solve(\@inputs);

}

1;
