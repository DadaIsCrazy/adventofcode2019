#!/usr/bin/perl

package C19_2;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( min max );

no warnings 'recursion';

use Intcode;

# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;

# This is a simple divide and conquer on the x coordinate.  For each
#  value x, we compute the size of the beam on this line. If it is
#  larger than |$min_width|, then we look if the line $square_size
#  later is filled enough for the square to be possible. If so, then
#  we adjust the upper bound for x. If not, we adjust the lower
#  bound. Once max = min, we have our value for x.
sub div_and_conquer {
    my ($prog) = @_;

    my $square_size = 100;
    my $min_width = 100;
    my $y_inc = 99;


    my ($min_x, $max_x) = (1, 10000);
    my $x = 1000;

    while (1) {
        say "$x  (min:$min_x; max:$max_x)";

        my $y = 1;
        # Searching for a value of |$y| such that |$y| is within the beam
        my (undef, $output) = Intcode::eval_intcode([@$prog], input => [$x,$y]);
        while (! $output->[0]) {
            $y += $y_inc;
            (undef, $output) = Intcode::eval_intcode([@$prog], input => [$x,$y]);
        }

        # Getting the start of the beam of the y line
        my $y_start = $y-1;
        (undef, $output) = Intcode::eval_intcode([@$prog], input => [$x,$y_start]);
        while ($output->[0]) {
            $y_start--;
            (undef, $output) = Intcode::eval_intcode([@$prog], input => [$x,$y_start]);
        }
        $y_start++;

        # Getting the end of the beam of the y line
        my $y_end = $y+1;
        (undef, $output) = Intcode::eval_intcode([@$prog], input => [$x,$y_end]);
        while ($output->[0]) {
            $y_end++;
            (undef, $output) = Intcode::eval_intcode([@$prog], input => [$x,$y_end]);
        }
        $y_end--;

        my $width = $y_end - $y_start + 1;

        if ($width >= $min_width) {
            # Checking whether the line |$x + $square_size|
            (undef, $output) = Intcode::eval_intcode([@$prog],
                                                     input => [$x+$square_size-1,
                                                               $y_end-$square_size+1]);
            if ($output->[0]) {
                $max_x = $x;
                if ($max_x == $min_x) {
                    return ($x, $y_end-$square_size+1);
                }
                $x = int(($min_x + $max_x) / 2);
            } else {
                $min_x = $x;
                if ($max_x == $min_x) {
                    die "Error max & min";
                }
                $x = int(($min_x + $max_x) / 2);
                if ($x == $min_x) {
                    $min_x++;
                    $x++;
                }
            }
        } else {
            $min_x = $x;
            $x = int(($min_x + $max_x) / 2);
        }

    }
}

sub main {
    open my $FH, '<', "input_19.txt" or die $!;
    my @inputs =  split /,/, <$FH>;

    my ($x,$y) = div_and_conquer(\@inputs);

    say "[$x,$y]";

    say $x * 10000 + $y;

}

1;
