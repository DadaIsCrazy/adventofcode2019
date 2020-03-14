#!/usr/bin/perl

package C25_1;

use strict;
use warnings;
use feature qw( say );
use List::Util qw( min max );

use Intcode;

# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;

# returns all the commands required to pick all items and go to the
# security checkpoint.
sub pick_all_items {
    my @cmds = (
        "south",
        "south",
        "south",
        "south",
        "west",
        "west",
        "south",
        "take easter egg",
        "north",
        "take jam",
        "north",
        "east",
        "east",
        "take festive hat",
        "north",
        "take fixed point",
        "north",
        "west",
        "north",
        "north",
        "take tambourine",
        "south",
        "south",
        "east",
        "north",
        "west",
        "south",
        "take antenna",
        "north",
        "west",
        "west",
        "take space heater",
        "west",
        "inv");
    return map { ord } map { split //, "$_\n" } @cmds;
}

sub generate_combinations {
    my @items = @_;

    if (@items == 0) { return [] }

    my $current = shift @items;
    my @subcombs = generate_combinations(@items);
    return (@subcombs, map { [$current, @$_] } @subcombs);
}

sub interactive_run {
    my @input = @_;

    my ($prog, $output) = Intcode::eval_intcode([@input], input => [pick_all_items]);

    my @inventory = ("antenna", "easter egg", "space heater", "jam",
                 "tambourine", "festive hat", "fixed point");
    my @combinations = generate_combinations(@inventory);

    for my $comb (@combinations) {
        my @input;
        for my $item (@inventory) {
            push @input, map { ord } split //, "drop $item\n";
        }
        for my $item (@$comb) {
            push @input, map { ord } split //, "take $item\n";
        }
        push @input, map { ord } split //, "west\n";
        ($prog, $output) = Intcode::restore_prog($prog, input => \@input);

        my $out_txt = join "", map { chr } @$output;

        if ($out_txt !~ /Security Checkpoint/) {
            say $out_txt;
            say "Items: @$comb";
            last;
        }
    }
}


sub main {
    open my $FH, '<', "input_25.txt" or die $!;
    my @inputs =  split /,/, <$FH>;
    chomp @inputs;

    interactive_run(@inputs);

}

1;
