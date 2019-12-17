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

    my $input    = $params{input};
    my $pc       = $params{pc} || 0;
    my $rel_base = $params{rel_base} || 0;

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
            my ($src1, $src2) = map { convert_operand($prog, $rel_base, $modes[$_], $pc+1+$_) } 0, 1;
            write_val($prog, $rel_base, $modes[2], $pc+3, $src1 + $src2);
            $pc += 4;
        }

        # Mult
        elsif ($opcode == 2) {
            say "Mul ", join ",", map { "$prog->[$pc+1+$_]:$modes[$_]" } 0 .. 2 if $DEBUG;
            my ($src1, $src2) = map { convert_operand($prog, $rel_base, $modes[$_], $pc+1+$_) } 0, 1;
            write_val($prog, $rel_base, $modes[2], $pc+3, $src1 * $src2);
            $pc += 4;
        }

        # Input
        elsif ($opcode == 3) {
            say "Input $prog->[$pc+1]:$modes[0]" if $DEBUG;
            if ($input && $input_counter >= @$input) {
                return (save_prog($prog, $pc, $rel_base), \@output);
            }
            my $in = $input ? $input->[$input_counter++] :
                <>;
            chomp($in);
            write_val($prog, $rel_base, $modes[0], $pc+1, $in);
            $pc += 2;
        }

        # Output
        elsif ($opcode == 4) {
            say "Output ", join ",", map { "$prog->[$pc+1+$_]:$modes[$_]" } 0 if $DEBUG;
            my $src = convert_operand($prog,$rel_base,$modes[0],$pc+1);
            say $src if $PRINT;
            push @output, $src;
            $pc += 2;
        }

        # jump-if-true
        elsif ($opcode == 5) {
            say "Jmp-t ", join ",", map { "$prog->[$pc+1+$_]:$modes[$_]" } 0 .. 1 if $DEBUG;
            my ($src, $dst) = map { convert_operand($prog, $rel_base, $modes[$_], $pc+1+$_) } 0, 1;
            say "  -> $src -> ", ($src != 0 ? "" : "no"), " jump $dst" if $DEBUG;
            if ($src != 0) {
                $pc = $dst;
            } else {
                $pc += 3;
            }
        }

        # jump-if-false
        elsif ($opcode == 6) {
            say "Jmp-f ", join ",", map { "$prog->[$pc+1+$_]:$modes[$_]" } 0 .. 1 if $DEBUG;
            my ($src, $dst) = map { convert_operand($prog, $rel_base, $modes[$_], $pc+1+$_) } 0, 1;
            say "  -> $src -> ", ($src == 0 ? "" : "no"), " jump $dst" if $DEBUG;
            if ($src == 0) {
                $pc = $dst;
            } else {
                $pc += 3;
            }
        }

        # less than
        elsif ($opcode == 7) {
            say "lt ", join ",", map { "$prog->[$pc+1+$_]:$modes[$_]" } 0 .. 2 if $DEBUG;
            my ($src1, $src2) = map { convert_operand($prog, $rel_base, $modes[$_], $pc+1+$_) } 0, 1;
            say "  -> $src1 <? $src2" if $DEBUG;
            write_val($prog, $rel_base, $modes[2], $pc+3, $src1 < $src2 ? 1 : 0);
            $pc += 4;
        }

        # equals
        elsif ($opcode == 8) {
            say "eq ", join ",", map { "$prog->[$pc+1+$_]:$modes[$_]" } 0 .. 2 if $DEBUG;
            my ($src1, $src2) = map { convert_operand($prog, $rel_base, $modes[$_], $pc+1+$_) } 0, 1;
            say "  -> $src1 =? $src2" if $DEBUG;
            write_val($prog, $rel_base, $modes[2], $pc+3, $src1 == $src2 ? 1 : 0);
            $pc += 4;
        }

        # relative base offset
        elsif ($opcode == 9) {
            say "relbase ", join ",", map { "$prog->[$pc+1+$_]:$modes[$_]" } 0 if $DEBUG;
            my $src = convert_operand($prog, $rel_base, $modes[0], $pc+1);
            say "  -> rel_base = $rel_base + $src = ", $rel_base + $src if $DEBUG;
            $rel_base += $src;
            $pc += 2;
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

sub save_prog ($$$) {
    my ($prog, $pc, $rel_base) = @_;
    return { prog => $prog, pc => $pc, rel_base => $rel_base };
}

sub restore_prog {
    my $prog_state = shift;
    return eval_intcode($prog_state->{prog}, pc => $prog_state->{pc},
                        rel_base => $prog_state->{rel_base},
                        @_);
}

sub copy_prog {
    my $prog_state = shift;
    return { prog => [ @{$prog_state->{prog}} ], pc => $prog_state->{pc},
             rel_base => $prog_state->{rel_base} };
}

sub convert_operand ($$$$) {
    my ($prog, $rel_base, $mode, $idx) = @_;
    if ($mode == 0) {
        return $prog->[$prog->[$idx]] // 0;
    } elsif ($mode == 1) {
        return $prog->[$idx] // 0;
    } elsif ($mode == 2) {
        return $prog->[$rel_base + $prog->[$idx]] // 0;
    } else {
        die "Unknown mode: $mode.";
    }
}

sub write_val ($$$$$) {
    my ($prog, $rel_base, $mode, $idx, $val) = @_;
    if ($mode == 0) {
        $prog->[$prog->[$idx]] = $val;
        say "  -> prog->[$prog->[$idx]] = $val" if $DEBUG;
    } elsif ($mode == 1) {
        die "Cannot write in immediate mode";
    } elsif ($mode == 2) {
        $prog->[$rel_base + $prog->[$idx]] = $val;
        say "  -> prog->[",$rel_base+$prog->[$idx], "] = $val" if $DEBUG;
    } else {
        die "Unknown mode: $mode.";
    }
}

1;
