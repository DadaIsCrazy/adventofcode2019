#!/usr/bin/perl

package Intcode;

use strict;
use warnings;
use feature qw( say );

our $DEBUG = 0;
our $PRINT = 0;

sub eval_intcode {
    my $prog = shift;
    my %params = @_;

    my $input = $params{input};
    my $pc = $params{pc} || 0;

    my @output;
    my ($input_counter) = (0);

    while (1) {
        my ($modes, $opcode) = $prog->[$pc] =~ /^(.*?)(.?.)$/
            or die "Invalid instruction format";
        my @modes = (reverse(split //, $modes), (0)x4);

        #say "$pc: $prog->[$pc]  {$opcode: @modes}";

        # Add
        if ($opcode == 1) {
            say "Add ", join ",", map { "$prog->[$pc+1+$_]:$modes[$_]" } 0 .. 2 if $DEBUG;
            my $dst = $prog->[$pc+3];
            my ($src1, $src2) = map { convert_operand($prog, $modes[$_], $pc+1+$_) } 0, 1;
            say "  -> prog[$dst] = $src1 + $src2" if $DEBUG;
            $prog->[$dst] = $src1 + $src2;
            $pc += 4;
        }

        # Mult
        elsif ($opcode == 2) {
            say "Mul ", join ",", map { "$prog->[$pc+1+$_]:$modes[$_]" } 0 .. 2 if $DEBUG;
            my $dst = $prog->[$pc+3];
            my ($src1, $src2) = map { convert_operand($prog, $modes[$_], $pc+1+$_) } 0, 1;
            say "  -> prog[$dst] = $src1 * $src2" if $DEBUG;
            $prog->[$dst] = $src1 * $src2;
            $pc += 4;
        }

        # Input
        elsif ($opcode == 3) {
            say "Input $prog->[$pc+1]" if $DEBUG;
            my $dst = $prog->[$pc+1];
            if ($input && $input_counter >= @$input) {
                return (save_prog($prog, $pc), \@output);
            }
            my $in = $input ? $input->[$input_counter++] :
                <>;
            chomp($in);
            $prog->[$dst] = $in;
            say "  -> prog[$dst] = $in" if $DEBUG;
            $pc += 2;
        }

        # Output
        elsif ($opcode == 4) {
            say "Output ", join ",", map { "$prog->[$pc+1+$_]:$modes[$_]" } 0 if $DEBUG;
            my $src = convert_operand($prog,$modes[0],$pc+1);
            say $src if $PRINT;
            push @output, $src;
            $pc += 2;
        }

        # jump-if-true
        elsif ($opcode == 5) {
            say "Jmp-t ", join ",", map { "$prog->[$pc+1+$_]:$modes[$_]" } 0 .. 1 if $DEBUG;
            my ($src, $dst) = map { convert_operand($prog, $modes[$_], $pc+1+$_) } 0, 1;
            if ($src != 0) {
                $pc = $dst;
            } else {
                $pc += 3;
            }
        }

        # jump-if-false
        elsif ($opcode == 6) {
            say "Jmp-f ", join ",", map { "$prog->[$pc+1+$_]:$modes[$_]" } 0 .. 1 if $DEBUG;
            my ($src, $dst) = map { convert_operand($prog, $modes[$_], $pc+1+$_) } 0, 1;
            if ($src == 0) {
                $pc = $dst;
            } else {
                $pc += 3;
            }
        }

        # less than
        elsif ($opcode == 7) {
            say "lt ", join ",", map { "$prog->[$pc+1+$_]:$modes[$_]" } 0 .. 2 if $DEBUG;
            my ($src1, $src2) = map { convert_operand($prog, $modes[$_], $pc+1+$_) } 0, 1;
            my $dst = $prog->[$pc+3];
            $prog->[$dst] = $src1 < $src2 ? 1 : 0;
            $pc += 4;
        }

        # equals
        elsif ($opcode == 8) {
            say "eq ", join ",", map { "$prog->[$pc+1+$_]:$modes[$_]" } 0 .. 2 if $DEBUG;
            my ($src1, $src2) = map { convert_operand($prog, $modes[$_], $pc+1+$_) } 0, 1;
            my $dst = $prog->[$pc+3];
            $prog->[$dst] = $src1 == $src2 ? 1 : 0;
            $pc += 4;
        }

        # Halt
        elsif ($opcode == 99) {
            say "Halt" if $DEBUG;
            last;
        }

        # Unknown
        else {
            die "Unknown opcode: $prog->[$pc]";
        }
    }
    return ($prog, \@output);
}

sub save_prog {
    my ($prog, $pc) = @_;
    return { prog => $prog, pc => $pc };
}

sub restore_prog {
    my $prog_state = shift;
    return eval_intcode($prog_state->{prog}, pc => $prog_state->{pc}, @_);
}

sub convert_operand {
    my ($prog, $mode, $idx) = @_;
    if ($mode == 0) {
        return $prog->[$prog->[$idx]];
    } else {
        return $prog->[$idx];
    }
}

1;
