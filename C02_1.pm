#!/usr/bin/perl

package C02_1;

use strict;
use warnings;
use feature qw( say );

# Call main if script is ran directly (eg, not loaded by another script)
main() unless caller;

sub eval_intcode {
    # Don't want to use indirection always, so let's use an array
    # rather than an arrayref
    my @prog = @_;
    my $idx = 0;
    while (1) {
        if ($prog[$idx] == 1) {
            my ($src1, $src2, $dst) = @prog[$idx+1 .. $idx+3];
            $prog[$dst] = $prog[$src1] + $prog[$src2];
        } elsif ($prog[$idx] == 2) {
            my ($src1, $src2, $dst) = @prog[$idx+1 .. $idx+3];
            $prog[$dst] = $prog[$src1] * $prog[$src2];
        } elsif ($prog[$idx] == 99) {
            last;
        } else {
            die "Unknown opcode: $prog[$idx]";
        }
        $idx += 4;
    }
    return @prog;
}


sub main {
    @ARGV = "input_02.txt" unless @ARGV;
    my @input = split ",", <>;
    $input[1] = 12;
    $input[2] = 2;

    say join ",", eval_intcode(@input);
}

1;
