#!/usr/bin/perl

package C15_2;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( min max );
use Time::HiRes qw(usleep);

no warnings 'recursion';

use C15_1;

# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;

sub map_to_str {
    my ($map, $xr, $yr) = @_;

    my $min_x = min (keys %$map);
    my $max_x = max (keys %$map);
    my ($min_y, $max_y) = (1000, 0);
    for (keys %$map) {
        $min_y = min($min_y, keys %{$map->{$_}});
        $max_y = max($max_y, keys %{$map->{$_}});
    }

    my $str = "";
    for my $x ($min_x .. $max_x) {
        for my $y ($min_y .. $max_y) {
            if ($x == 0 && $y == 0) {
                $str .= ".";
            } elsif ($x == $xr && $y == $yr) {
                $str .= ".";
            } else {
                $str .= $map->{$x}->{$y} // " ";
            }
        }
        $str .= "\n";
    }

    return $str;
}

sub fill_oxygen {
    # Careful: here map is a string
    my ($map) = @_;
    my $count = 0;
    $map =~ /.*/;
    my $len = $+[0];

    while (1) {
        no warnings 'uninitialized';
        # Regexes inspired by https://codegolf.stackexchange.com/questions/98156/animate-adve-the-adventurer/98200#98200
        1 while $map =~ s/X(.{$len})?\./X$1B/s;
        1 while $map =~ s/\.(.{$len})?X/B$1X/s;
        last unless $map =~ /B/;
        $count++;
        $map =~ s/B/X/g;
    }

    return $count;
}

sub solve {
    my ($prog) = @_;

    my %map;
    ($prog) = Intcode::eval_intcode($prog, input => []);
    C15_1::explore_map($prog, \%map, 0, 0);

    say fill_oxygen(map_to_str(\%map, 0, 0));
}


sub main {
    open my $FH, '<', "input_15.txt" or die $!;
    my @inputs =  split /,/, <$FH>;

    solve(\@inputs);

}

1;
