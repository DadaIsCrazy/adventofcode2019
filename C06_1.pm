#!/usr/bin/perl

package C06_1;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( sum );

no warnings 'recursion';

# Call main if script is ran directly (eg, not loaded by another script)
main() unless caller;

sub build_orbits_relations {
    return map { reverse split /\)/ } @_;
}

sub count_orbits {
    my ($orbits, $o) = @_;
    if ($o eq 'COM') {
        return 0;
    } else {
        return 1 + count_orbits($orbits, $orbits->{$o});
    }
}

sub count_all_orbits {
    my ($orbits) = @_;
    return sum map { count_orbits($orbits, $_) } keys %$orbits;
}

sub main {
    open my $FH, '<', "input_06.txt" or die $!;
    chomp(my @orbits = <$FH>);

    # my @orbits = qw[COM)B
    #                 B)C
    #                 C)D
    #                 D)E
    #                 E)F
    #                 B)G
    #                 G)H
    #                 D)I
    #                 E)J
    #                 J)K
    #                 K)L];
    my %orbits = build_orbits_relations(@orbits);

    say count_all_orbits(\%orbits);

}

1;
