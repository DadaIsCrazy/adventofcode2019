#!/usr/bin/perl

package C20_2;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( min max );
use Heap::Simple;

no warnings 'recursion';


# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;


sub parse_string {
    my ($input) = @_;

    my @input = map { [ split // ] } split /\n/, $input;

    # Parsing maze only
    my @maze;
    for my $i (0 .. $#input) {
        for my $j (0 .. $#{$input[$i]}) {
            if ($input[$i][$j] eq '.') {
                $maze[$i][$j] = 1;
            } else {
                $maze[$i][$j] = 0;
            }
        }
    }

    # Parsing portals
    my %pre_portals;
    for my $i (0 .. $#input) {
        for my $j (0 .. $#{$input[$i]}) {
            if ($input[$i][$j] =~ /[A-Z]/) {
                if ($input[$i][$j+1] && ($input[$i][$j+1] =~ /[A-Z]/)) {
                    push @{$pre_portals{$input[$i][$j] . $input[$i][$j+1]}},
                        ($input[$i][$j+2] && $input[$i][$j+2] eq ".") ? [$i,$j+2] : [$i,$j-1];
                    $input[$i][$j] = " ";
                    $input[$i][$j+1] = " ";
                    $maze[$i][$j] = "2";
                    $maze[$i][$j+1] = "2";
                } elsif ($input[$i+1][$j] && ($input[$i+1][$j] =~ /[A-Z]/)) {
                    push @{$pre_portals{$input[$i][$j] . $input[$i+1][$j]}},
                        ($input[$i+2][$j] && $input[$i+2][$j] eq ".") ? [$i+2,$j] : [$i-1,$j];
                    $input[$i][$j] = " ";
                    $input[$i+1][$j] = " ";
                    $maze[$i][$j] = "2";
                    $maze[$i+1][$j] = "2";
                } else {
                    die "Invalid portal (input[$i][$j] = $input[$i][$j])";
                }
            }
        }
    }

    # Creating portal hash
    my %portals;
    for my $portal_name (keys %pre_portals) {
        next if $portal_name =~ /^(AA|ZZ)$/;
        my ($p1, $p2) = @{$pre_portals{$portal_name}};
        $portals{$p1->[0]}->{$p1->[1]} = 
            [$p2->[0],$p2->[1],
             ($p1->[0] == 2 || $p1->[0] == @maze-3 
              || $p1->[1] == 2 || $p1->[1] == @{$maze[0]}-3) ? -1 : 1,$portal_name];
        $portals{$p2->[0]}->{$p2->[1]} =
            [$p1->[0],$p1->[1],
             ($p2->[0] == 2 || $p2->[0] == @maze-3 
              || $p2->[1] == 2 || $p2->[1] == @{$maze[0]}-3) ? -1 : 1,$portal_name];
    }
    
    # Making sure that there are as many opening as closing portals
    my ($c1,$cm1) = (0,0);
    for my $i (keys %portals) {
        for my $j (keys %{$portals{$i}}) {
            $c1 += $portals{$i}{$j}[2] == 1;
            $cm1 += $portals{$i}{$j}[2] == -1;
        }
    }
    if ($c1 != $cm1) {
        die "Bad portal directions....";
    }

    return (\@maze, \%portals, $pre_portals{AA}[0], $pre_portals{ZZ}[0]);
}

sub backtrack_solution {
    my ($maze, $costs, $portals, $start, $end) = @_;

    my $level = 0;
    my ($x, $y) = @{$end};
    my $cost = $costs->{0}[$x][$y];

    outer:
    while (! ($x == $start->[0] && $y == $start->[1] && $level == 0) ) {
        say "[$x $y] cost=$cost -- lvl=$level";
        for ([$x+1,$y],[$x,$y+1],[$x-1,$y],[$x,$y-1]) {
            my ($nx,$ny) = @$_;
            if ($costs->{$level}[$nx][$ny] == $cost - 1) {
                $cost--;
                $x = $nx;
                $y = $ny;
                next outer;
            }
        }
        if (exists $portals->{$x}->{$y}) {
            my ($nx, $ny, $lvl_diff, $portal_name) = @{$portals->{$x}->{$y}};
            if ($costs->{$level+$lvl_diff}[$nx][$ny] != $cost - 1) {
                die "Impossible: ", $costs->{$level+$lvl_diff}[$nx][$ny];
            }
            say "  (through $portal_name)";
            $cost--;
            $level += $lvl_diff;
            $x = $nx;
            $y = $ny;
        }
    }
    
}

# Could optimize by starting from the end and the begining at the same
# time until they meet.
sub solve_maze {
    my ($maze, $portals, $start, $end) = @_;

    my %costs;
    for (0 .. 1000) {
        $costs{$_} = [ map { [ (10000000)x@{$maze->[0]} ] } 0 .. $#$maze ];
    }

    my $worklist = Heap::Simple->new(elements => "Any");
    $worklist->key_insert(0,[$start->[0],$start->[1],0,0]);

    my $best = 1000000;
    while ($worklist->count) {
        my ($x,$y,$cost,$level) = @{$worklist->extract_top};
        next if $costs{$level}[$x][$y] <= $cost;
        #say "[$x,$y] : $cost (level $level)";
        $costs{$level}[$x][$y] = $cost;
        if ($x == $end->[0] && $y == $end->[1] && $level == 0) {
            # backtrack_solution($maze, \%costs, $portals, $start, $end);
            return $cost;
        }
        for ([$x+1,$y],[$x,$y+1],[$x-1,$y],[$x,$y-1]) {
            my ($nx,$ny) = @$_;
            next if $costs{$level}[$nx][$ny] <= $cost;
            next unless $maze->[$nx][$ny] == 1;
            $worklist->key_insert($cost+1+$level, [$nx,$ny,$cost+1,$level]);
        }
        if (exists $portals->{$x}->{$y}) {
            my ($nx,$ny,$lvl_diff) = @{$portals->{$x}->{$y}};
            next if $level + $lvl_diff < 0;
            next if $costs{$level+$lvl_diff}[$nx][$ny] <= $cost;
            $worklist->key_insert($cost+1+$level, [$nx,$ny,$cost+1,$level+$lvl_diff]);
        }
    }

    die "Could not solve...";
}

sub main {
    my $test_input1 =
"         A         
         A         
  #######.#########
  #######.........#
  #######.#######.#
  #######.#######.#
  #######.#######.#
  #####  B    ###.#
BC...##  C    ###.#
  ##.##       ###.#
  ##...DE  F  ###.#
  #####    G  ###.#
  #########.#####.#
DE..#######...###.#
  #.#########.###.#
FG..#########.....#
  ###########.#####
             Z     
             Z     ";

    my $test_input2 =
"                   A               
                   A               
  #################.#############  
  #.#...#...................#.#.#  
  #.#.#.###.###.###.#########.#.#  
  #.#.#.......#...#.....#.#.#...#  
  #.#########.###.#####.#.#.###.#  
  #.............#.#.....#.......#  
  ###.###########.###.#####.#.#.#  
  #.....#        A   C    #.#.#.#  
  #######        S   P    #####.#  
  #.#...#                 #......VT
  #.#.#.#                 #.#####  
  #...#.#               YN....#.#  
  #.###.#                 #####.#  
DI....#.#                 #.....#  
  #####.#                 #.###.#  
ZZ......#               QG....#..AS
  ###.###                 #######  
JO..#.#.#                 #.....#  
  #.#.#.#                 ###.#.#  
  #...#..DI             BU....#..LF
  #####.#                 #.#####  
YN......#               VT..#....QG
  #.###.#                 #.###.#  
  #.#...#                 #.....#  
  ###.###    J L     J    #.#.###  
  #.....#    O F     P    #.#...#  
  #.###.#####.#.#####.#####.###.#  
  #...#.#.#...#.....#.....#.#...#  
  #.#####.###.###.#.#.#########.#  
  #...#.#.....#...#.#.#.#.....#.#  
  #.###.#####.###.###.#.#.#######  
  #.#.........#...#.............#  
  #########.###.###.#############  
           B   J   C               
           U   P   P               ";

my $test_input3 = 
"             Z L X W       C                 
             Z P Q B       K                 
  ###########.#.#.#.#######.###############  
  #...#.......#.#.......#.#.......#.#.#...#  
  ###.#.#.#.#.#.#.#.###.#.#.#######.#.#.###  
  #.#...#.#.#...#.#.#...#...#...#.#.......#  
  #.###.#######.###.###.#.###.###.#.#######  
  #...#.......#.#...#...#.............#...#  
  #.#########.#######.#.#######.#######.###  
  #...#.#    F       R I       Z    #.#.#.#  
  #.###.#    D       E C       H    #.#.#.#  
  #.#...#                           #...#.#  
  #.###.#                           #.###.#  
  #.#....OA                       WB..#.#..ZH
  #.###.#                           #.#.#.#  
CJ......#                           #.....#  
  #######                           #######  
  #.#....CK                         #......IC
  #.###.#                           #.###.#  
  #.....#                           #...#.#  
  ###.###                           #.#.#.#  
XF....#.#                         RF..#.#.#  
  #####.#                           #######  
  #......CJ                       NM..#...#  
  ###.#.#                           #.###.#  
RE....#.#                           #......RF
  ###.###        X   X       L      #.#.#.#  
  #.....#        F   Q       P      #.#.#.#  
  ###.###########.###.#######.#########.###  
  #.....#...#.....#.......#...#.....#.#...#  
  #####.#.###.#######.#######.###.###.#.#.#  
  #.......#.......#.#.#.#.#...#...#...#.#.#  
  #####.###.#####.#.#.#.#.###.###.#.###.###  
  #.......#.....#.#...#...............#...#  
  #############.#.#.###.###################  
               A O F   N                     
               A A D   M                     ";

  
    my $test_input4 =
"         A           
         A           
  #######.#########  
  #######.........#  
  #######.###.###.#  
  #######.###.###..XK
  #######.###.###.#  
  #####  B   X###.#  
BC...##  C   K#####  
  ##.##       ###.#  
  ##...DE  F  ###.#  
  #####    G  ###.#  
  #########.#####.#  
DE............###.#  
  #.#########.###.#  
FG..#########.....#  
  ###########.#####  
             Z       
             Z       "; 

    die "BAAAAH" unless solve_maze(parse_string($test_input1)) == 26;
    die "BAAAAH" unless solve_maze(parse_string($test_input3)) == 396;
    die "BAAAAH" unless solve_maze(parse_string($test_input4)) == 36;
    

    open my $FH, '<', 'input_20.txt' or die $!;
    my $input = do { local $/; <$FH> };
    chomp $input;
    my ($maze, $portals, $start, $end) = parse_string($input);
    say solve_maze($maze,$portals,$start,$end);

}

1;
