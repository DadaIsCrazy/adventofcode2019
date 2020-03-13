#!/usr/bin/perl

package C23_1;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( min max );

use Intcode;

# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;


sub dispatch_output {
    my ($computers, $output, $id) = @_;
    return if @$output == 0;
    for (my $i = 0; $i < $#$output; $i += 3) {
        my ($dst, $x, $y) = @$output[$i .. $i + 2];
        if ($dst == 255) {
            say $y;
            exit;
        }
        push @{$computers->[$dst]->{input}}, $x, $y;
    }
}

sub run_computers {
    my @input = @_;

    my @computers;
    for my $id (0 .. 49) {
        my ($prog, undef) = Intcode::eval_intcode([@input], input => []);
        $computers[$id] = { id => $id, prog => $prog, input => [ $id, -1 ] };
    }

    while (1) {
        for my $computer (@computers) {
            my $input = $computer->{input};
            $computer->{input} = [-1];
            my @old = (@{$computer->{prog}->{prog}}, $computer->{prog}->{pc});
            my ($prog, $output) = Intcode::restore_prog($computer->{prog},
                                                        input => $input);
            dispatch_output(\@computers, $output, $computer->{id});
            $computer->{prog} = $prog;
        }
    }
}


sub main {
    open my $FH, '<', "input_23.txt" or die $!;
    my @inputs =  split /,/, <$FH>;
    chomp @inputs;

    run_computers(@inputs);

}

1;
