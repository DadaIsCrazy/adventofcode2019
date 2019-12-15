#!/usr/bin/perl

package C12_2;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( min max sum );

use C12_1;

# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;

sub gcd {
    my($l, $s) = @_ ;
    my $r = $l % $s;
    while ($r != 0) {
        $l = $s;
        $s = $r;
        $r = $l % $s;
    }
    return $s;
}

sub lcm {
    my ($l, $s) = @_;
    return ($l * $s) / gcd($l,$s);
}

sub moon_to_str {
    my ($moon) = @_;
    return "<x=$moon->{x}, y=$moon->{y}, z=$moon->{z}>, " .
        "vel=<x=$moon->{vel}->{x}, y=$moon->{vel}->{y}, z=$moon->{vel}->{z}>";
}
sub moons_to_str {
    return join "\n", map { moon_to_str($_) } @_;
}

sub step {
    my ($axis, @moons) = @_;
    my @new_moons;

    # Applying gravity
    for my $moon (@moons) {
        my $new_moon = C12_1::copy_moon($moon);
        my $v = 0;

        for my $moon2 (@moons) {
            next if $moon eq $moon2;
            $v += $moon2->{$axis} <=> $moon->{$axis};
        }

        $new_moon->{vel}->{$axis} += $v;
        push @new_moons, $new_moon;
    }
    @moons = @new_moons;

    # Applying velocity
    for my $moon (@moons) {
        $moon->{$axis} += $moon->{vel}->{$axis};
    }
    return @moons;
}

sub find_period {
    my ($axis, @moons) = @_;

    my %seen = (moons_to_str(@moons) => 0);
    for (my $step = 1; ; $step++) {
        @moons = step($axis, @moons);
        my $key = moons_to_str(@moons);
        if (exists $seen{$key}) {
            return ($seen{$key}, $step - $seen{$key});
        }
        $seen{$key} = $step;
    }

}

sub simulate_universe {
    my @moons = @_;

    my ($init_x, $x) = find_period("x", @moons);
    my ($init_y, $y) = find_period("y", @moons);
    my ($init_z, $z) = find_period("z", @moons);

    die unless $init_x == $init_y && $init_x == $init_z;

    return lcm(lcm($x,$y),$z);
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
                      { x => $1, y => $2, z => $3, vel => C12_1::init_vel() } } @inputs;

    say join " ", simulate_universe(@moons);
}


1;
