#!/usr/bin/perl

package C12_1;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( min max sum );

# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;


sub init_vel {
    return { x => 0, y => 0, z => 0 };
}

sub copy_moon {
    my ($moon) = @_;
    return { x => $moon->{x}, y => $moon->{y}, z => $moon->{z},
             vel => { x => $moon->{vel}->{x},
                      y => $moon->{vel}->{y},
                      z => $moon->{vel}->{z} } };
}

sub print_moon {
    my ($moon) = @_;
    say "<x=$moon->{x}, y=$moon->{y}, z=$moon->{z}>, ",
        "vel=<x=$moon->{vel}->{x}, y=$moon->{vel}->{y}, z=$moon->{vel}->{z}>";
}

sub step {
    my @moons = @_;
    my @new_moons;

    # Applying gravity
    for my $moon (@moons) {
        my $new_moon = copy_moon($moon);
        my ($x, $y, $z) = (0, 0, 0);

        for my $moon2 (@moons) {
            next if $moon eq $moon2;
            $x += $moon2->{x} <=> $moon->{x};
            $y += $moon2->{y} <=> $moon->{y};
            $z += $moon2->{z} <=> $moon->{z};
        }

        $new_moon->{vel}->{x} += $x;
        $new_moon->{vel}->{y} += $y;
        $new_moon->{vel}->{z} += $z;
        push @new_moons, $new_moon;
    }
    @moons = @new_moons;

    # Applying velocity
    for my $moon (@moons) {
        for (qw(x y z)) {
            $moon->{$_} += $moon->{vel}->{$_};
        }
    }
    return @moons;
}

sub simulate_velocities {
    my ($steps, @moons) = @_;

    # For each step
    for (1 .. $steps) {
        @moons = step(@moons);
    }

    return @moons;
}

sub compute_total_energy {
    my @moons = @_;

    my $total = 0;
    for my $moon (@moons) {
        my ($pot, $kin) = (0, 0);
        for (qw(x y z)) {
            $pot += abs($moon->{$_});
            $kin += abs($moon->{vel}->{$_});
        }
        $total += $pot * $kin;
    }

    return $total;
}



sub main {
    # my @inputs = ("<x=-1, y=0, z=2>",
    #               "<x=2, y=-10, z=-7>",
    #               "<x=4, y=-8, z=8>",
    #               "<x=3, y=5, z=-1>");
    # my @inputs = ("<x=-8, y=-10, z=0>",
    #               "<x=5, y=5, z=10>",
    #               "<x=2, y=-7, z=3>",
    #               "<x=9, y=-8, z=-3>");
    open my $FH, '<', "input_12.txt" or die $!;
    my @inputs =  <$FH>;

    my @moons = map { /<x=(.*?), y=(.*?), z=(.*?)>/;
                      { x => $1, y => $2, z => $3, vel => init_vel() } } @inputs;

    say compute_total_energy(simulate_velocities(1000, @moons));
}


1;
