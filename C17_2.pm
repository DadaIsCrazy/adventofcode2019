#!/usr/bin/perl

package C17_2;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( min max );

use Intcode;
use C17_1;

# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;

sub print_grid {
    my ($grid) = @_;
    for my $i (0 .. $#{$grid}) {
        say join "", @{$grid->[$i]};
    }
}

sub turn_right {
    my $i = 0;
    my @dirs = qw(^ < v >);
    my %dirs = map { $_ => $i++ } @dirs;
    return $dirs[($dirs{$_[0]}-1)%4];
}

sub turn_left {
    my $i = 0;
    my @dirs = qw(^ < v >);
    my %dirs = map { $_ => $i++ } @dirs;
    return $dirs[($dirs{$_[0]}+1)%4];
}

sub match_dir {
    my ($grid, $x, $y, $dir) = @_;

    my $max_x = $#{$grid};
    my $max_y = $#{$grid->[0]};

    my ($next_x, $next_y);
    # Finding where next '#' is.
    for my $pos ([$x+1,$y], [$x-1,$y], [$x,$y+1], [$x,$y-1]) {
        my ($i, $j) = @$pos;
        next unless $i >= 0 && $i <= $max_x && $j >= 0 && $j <= $max_y;
        if ($grid->[$i][$j] eq "#") {
            ($next_x, $next_y) = ($i, $j);
        }
    }
    return unless defined($next_x) && defined($next_y);

    # Finding what turn to do
    my $turn;
    if ($dir eq "^") {
        if ($next_x == $x-1)    { $turn = ""  }
        elsif ($next_y == $y-1) { $turn = "L" }
        elsif ($next_y == $y+1) { $turn = "R" }
    } elsif ($dir eq "<") {
        if ($next_x == $x-1)    { $turn = "R" }
        elsif ($next_x == $x+1) { $turn = "L" }
        elsif ($next_y == $y-1) { $turn = ""  }
    } elsif ($dir eq "v") {
        if ($next_x == $x+1)    { $turn = ""  }
        elsif ($next_y == $y+1) { $turn = "L" }
        elsif ($next_y == $y-1) { $turn = "R" }
    } elsif ($dir eq ">") {
        if ($next_x == $x+1)    { $turn = "R" }
        elsif ($next_x == $x-1) { $turn = "L" }
        elsif ($next_y == $y+1) { $turn = ""  }
    }

    # Finding new direction
    my $new_dir;
    if ($next_x == $x-1)    { $new_dir = "^" }
    elsif ($next_x == $x+1) { $new_dir = "v" }
    elsif ($next_y == $y-1) { $new_dir = "<" }
    else                    { $new_dir = ">" }

    return ($turn, $new_dir);
}

sub solve {
    my ($prog) = @_;

    my $map = C17_1::build_map([@$prog]);

    my @grid = map { [split // ] } split /\n/, $map;

    # Getting initial coordinates
    my ($x, $y, $dir);
    for my $i (0 .. $#grid) {
        for my $j (0 .. $#{$grid[0]}) {
            if ($grid[$i][$j] eq ">" || $grid[$i][$j] eq "^" ||
                $grid[$i][$j] eq "<" || $grid[$i][$j] eq "v") {
                ($x, $y, $dir) = ($i, $j, $grid[$i][$j]);
            }
        }
    }

    # Computing moves
    my @moves;
    while (1) {
        # Find correct orientation
        (my $dir_change, $dir) = match_dir(\@grid,$x,$y,$dir);
        last unless defined($dir_change) && defined($dir);
        $grid[$x][$y] = "#";
        my ($move, $prev_x, $prev_y) = (0,$x,$y);
        while ($grid[$x][$y] eq "#" || $grid[$x][$y] eq "@") {
            ($prev_x, $prev_y) = ($x,$y);
            $grid[$x][$y] = "@";
            if ($dir eq ">")    { $y = $y+1 }
            elsif ($dir eq "<") { $y = $y-1 }
            elsif ($dir eq "v") { $x = $x+1 }
            elsif ($dir eq "^") { $x = $x-1 }
            $move++;
            last unless $x >= 0 && $x <= $#grid && $y >= 0 && $y <= $#{$grid[0]};
        }
        ($x,$y) = ($prev_x, $prev_y);
        $grid[$x][$y] = $dir;
        push @moves, $dir_change if $dir_change;
        push @moves, $move-1;
    }

    my $moves = join "", @moves;
    # That "15" is somewhat arbitrary, but does the job
    my ($A, $B, $C) = $moves =~ /^(\w{1,15})(?:\1)*(\w{1,15})(?:\1|\2)*(\w{1,15})(\1|\2|\3)*$/;
    die unless $A && $B && $C;

    # Generating main
    my @main;
    while ($moves) {
        if ($moves =~ s/^$A//) { push @main, "A" }
        if ($moves =~ s/^$B//) { push @main, "B" }
        if ($moves =~ s/^$C//) { push @main, "C" }
    }

    # Generating prog input
    my @input;
    @input = map { (ord($_), ord(",")) } @main;
    $input[-1] = ord("\n");
    for my $routine ($A, $B, $C) {
        for my $instr ($routine =~ /[A-Z]+|\d+/g) {
            for ($instr =~ /./g) {
                push @input, ord;
            }
            push @input, ord(",");
        }
        $input[-1] = ord("\n");
    }
    push @input, ord("n"), ord("\n");
    $prog->[0] = 2;

    my $output = Intcode::eval_intcode($prog, input => [@input]);
    say $output->[-1];
}

sub main {
    open my $FH, '<', 'input_17.txt' or die $!;
    my @input = split ',', <$FH>;

    my @moves = solve(\@input);

}

1;
