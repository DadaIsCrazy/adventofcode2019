#!/usr/bin/perl

package C13_2;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( min max sum );
use Time::HiRes qw(usleep);

use C13_1;
use Intcode;

# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;

sub print_state {
    my ($state) = @_;
    print "\033c";
    C13_1::print_tiles($state->{grid});
    say "score: ", $state->{score} // "undef";

}

sub update_grid {
    my ($state, $tile_codes) = @_;
    for (my $i = 0; $i < $#$tile_codes; $i += 3) {
        my ($x, $y, $id) = @{$tile_codes}[$i, $i+1, $i+2];
        if ($x == -1 && $y == 0) {
            $state->{score} = $id;
        } else {
            $state->{grid}->[$x][$y] = $id;
        }
    }
}

sub get_ball_and_paddle_line {
    my ($state) = @_;
    my ($ball_x, $paddle_x) = (0, 0);
    for my $x (0 .. $#{$state->{grid}}) {
        for my $y (0 .. $#{$state->{grid}->[$x]}) {
            if ($state->{grid}->[$x][$y] == 4) {
                $ball_x = $x;
            } elsif ($state->{grid}->[$x][$y] == 3) {
                $paddle_x = $x;
            }
        }
    }
    return ($ball_x, $paddle_x);
}

sub get_next_input {
    my ($state) = @_;
    my ($ball_x, $paddle_x) = get_ball_and_paddle_line($state);
    return 0  if $ball_x == $paddle_x;
    return 1  if $ball_x > $paddle_x;
    return -1 if $ball_x < $paddle_x;
}

sub run_interactive_game {
    my ($prog) = @_;

    ($prog, my $output) = Intcode::eval_intcode($prog, input => []);
    my $state = {};
    update_grid($state, $output);
    print_state($state);

    my $x = 0;
    while (ref $prog eq "HASH") {
        usleep(30000);
        my $input = get_next_input($state);
        ($prog, $output) = Intcode::restore_prog($prog, input => [$input]);
        update_grid($state, $output);
        print_state($state);
    }
}


sub main {
    open my $FH, '<', 'input_13.txt' or die $!;
    my @input = split /,/, <$FH>;
    $input[0] = 2;

    run_interactive_game(\@input);
}


1;
