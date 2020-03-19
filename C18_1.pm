#!/usr/bin/perl

# - precompute all path if doors are closed
#   -> graph is now much smaller...
# - represent keys with integers (much smaller than string) (since less than 32 keys)

package C18_1;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( min max );
no warnings 'recursion';
use Data::Printer;
use Heap::Simple;

my $all_keys = 0;

# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;

sub find_start {
    my ($map) = @_;
    for my $i (0 ..$#{$map}) {
        for my $j (0 .. $#{$map->[0]}) {
            if ($map->[$i][$j] eq "@") {
                return ($i, $j);
            }
        }
    }
    die "missing start...";
}

sub map_neighbors {
    my ($map, $x, $y) = @_;
    my @neighbors;
    for ([$x+1,$y],[$x-1,$y],[$x,$y+1],[$x,$y-1]) {
        my ($i,$j) = @$_;
        if ($i >= 0 && $i <= $#{$map} && $j >= 0 && $j <= $#{$map->[$i]} &&
            $map->[$i][$j] eq ".") {
            push @neighbors, [$i, $j];
        }
    }
    return @neighbors;
}

sub interesting_neighbors {
    my ($map, $x, $y) = @_;
    my @neighbors;
    for ([$x+1,$y],[$x-1,$y],[$x,$y+1],[$x,$y-1]) {
        my ($i,$j) = @$_;
        if ($i >= 0 && $i <= $#{$map} && $j >= 0 && $j <= $#{$map->[$i]}) {
            if  ($map->[$i][$j] =~ /([a-z])/) {
                push @neighbors, [$i, $j, 1 << (ord($1)-ord("a")), undef];
            } elsif  ($map->[$i][$j] =~ /([A-Z])/) {
                push @neighbors, [$i, $j, undef, 1 << (ord($1)-ord("A"))];
            }
        }
    }
    return @neighbors;
}

sub compute_shortest_paths {
    my ($map, $graph, $xi, $yi) = @_;

    my @costs = map { [ (10000000)x$#{$map->[$_]} ] } 0 .. $#$map;
    my $heap = Heap::Simple->new(elements => "Any");
    $heap->key_insert(0, [$xi, $yi, 0]);

    while ($heap->count) {
        my ($x, $y, $cost) = @{$heap->extract_top};
        next if $costs[$x][$y] <= $cost;
        $costs[$x][$y] = $cost;
        for my $neighbor (map_neighbors($map, $x, $y)) {
            my ($i, $j) = @$neighbor;
            next if $costs[$i][$j] <= $cost + 1;
            $heap->key_insert($cost+1, [$i, $j, $cost+1]);
        }
        for my $neighbor (interesting_neighbors($map, $x, $y)) {
            my ($i,$j,$key,$door) = @$neighbor;
            next if $i == $xi && $j == $yi;
            push @{$graph->{$xi}{$yi}}, [$i,$j,$cost+1,$key,$door];
        }
    }
}

sub build_graph {
    my (@map) = @_;

    my %graph;

    my ($xi,$yi) = find_start(\@map);
    $map[$xi][$yi] = ".";
    compute_shortest_paths(\@map, \%graph, $xi, $yi);

    for my $i (0 ..$#map) {
        for my $j (0 .. $#{$map[0]}) {
            if ($map[$i][$j] =~ /[a-zA-Z]/) {
                if ($map[$i][$j] =~ /([a-z])/) {
                    $all_keys |= (1 << (ord($1) - ord("a")));
                }
                compute_shortest_paths(\@map, \%graph, $i, $j);
            }
        }
    }
    return ($xi, $yi, \%graph);
}

# Kinda of a Dijkstra, except that costs are kept per key assortment
# per cell (instead of just per cell). It's an optimistic way to do
# it, since it could easily blow up memory, but I'm hoping it won't.
sub solve_dijkstra {
    my ($map, $graph, $xi, $yi) = @_;

    my @costs;

    my $heap = Heap::Simple->new(elements => "Any");
    $heap->key_insert(0, [$xi, $yi, 0, 0]);

    while ($heap->count) {
        my ($x, $y, $cost, $keys) = @{$heap->extract_top};
        next if exists $costs[$x][$y]{$keys} && $costs[$x][$y]{$keys} <= $cost;
        return $cost if $keys == $all_keys;
        $costs[$x][$y]{$keys} = $cost;
        for my $reachable (@{$graph->{$x}{$y}}) {
            my ($i, $j, $cost2, $key, $door) = @$reachable;
            next if $door && ! ($keys & $door);
            $heap->key_insert($cost+$cost2, [$i, $j, $cost+$cost2, $key ? ($keys | $key) : $keys]);
        }
    }
}

sub solve {
    my @map = @_;

    $all_keys = 0;

    my ($xi, $yi, $graph) = build_graph(@map);

    return solve_dijkstra(\@map, $graph, $xi, $yi);


    die "Failed...";
}


sub main {
    my @input1 = map { [split //] } split /\n/,
"#########
#b.A.@.a#
#########";

    my @input2 = map { [split //] } split /\n/,
"########################
#f.D.E.e.C.b.A.@.a.B.c.#
######################.#
#d.....................#
########################";

    my @input3 = map { [split //] } split /\n/,
"########################
#...............b.C.D.f#
#.######################
#.....@.a.B.c.d.A.e.F.g#
########################";

    my @input4 = map { [split //] } split /\n/,
"#################
#i.G..c...e..H.p#
########.########
#j.A..b...f..D.o#
########@########
#k.E..a...g..B.n#
########.########
#l.F..d...h..C.m#
#################";

    my @input5 = map { [split //] } split /\n/,
"########################
#@..............ac.GI.b#
###d#e#f################
###A#B#C################
###g#h#i################
########################";

    # die unless solve(@input1) == 8;
    # die unless solve(@input2) == 86;
    # die unless solve(@input3) == 132;
    # die unless solve(@input4) == 136;
    # die unless solve(@input5) == 81;

    open my $FH, '<', 'input_18.txt' or die $!;
    my @input6 = map { chomp; [split //] } <$FH>;

    say solve(@input6);

}

1;
