#!/usr/bin/perl

package C06_2;

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

sub build_orbits_list {
    my ($orbits, $o) = @_;
    if ($o eq 'COM') {
        return ();
    } else {
        return ($orbits->{$o} => $o, build_orbits_list($orbits, $orbits->{$o}));
    }
}

sub compute_total_hops {
    my ($san, $you) = @_;
    my %common;
    for (keys %$san) {
        $common{$_} = 1 if $you->{$_};
    }
    my ($first) = grep { $you->{$_} ne $san->{$_} } keys %common;
    return count_hops_to_start($you, $first) + count_hops_to_start($san, $first) - 2;
}

sub count_hops_to_start {
    my ($orbits, $o) = @_;
    return 0 if $o =~ /^SAN$|^YOU$/;
    return 1 + count_hops_to_start($orbits, $orbits->{$o});
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
    #                 K)L
    #                 K)YOU
    #                 I)SAN];
    my %orbits = build_orbits_relations(@orbits);

    my %san_orbits = build_orbits_list(\%orbits, 'SAN');
    my %you_orbits = build_orbits_list(\%orbits, 'YOU');

    say compute_total_hops(\%san_orbits, \%you_orbits);

}

1;
