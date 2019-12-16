#!/usr/bin/perl

package C14_2;

use strict;
use warnings;
use feature qw( say );

use C14_1;

# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;

sub compute_fuel_max {
    my ($formulas, $total_ore) = @_;

    my ($prev, $guess) = (1, 1);

    my $fast_growth = 1;
    while (1) {
        my $amount_for = C14_1::get_amount_for($formulas, {}, 'FUEL', $guess, "");
        if ($amount_for < $total_ore) {
            my $saved = $guess;
            if ($fast_growth) {
                $guess *= 2;
            } else {
                $guess += $guess - $prev;
            }
            $prev = $saved;
        } elsif ($amount_for > $total_ore) {
            $guess = int(($prev + $guess) / 2);
            $fast_growth = 0;
        }
        return $guess if $guess == $prev;
    }

    return 11788286;
}

sub compute_fuel_max_manual {
    my ($formulas, $total_ore) = @_;

    my %available;
    # Should have wrote a program to do a binary search, but was a
    # little lazy, so I ended up binary searching by hand :x
    # EDIT: I wrote the code; see above.
    C14_1::get_amount_for($formulas, \%available, 'FUEL', 11788286, "");

    return 11788286;
}


sub main {

    my @input1 = split "\n",
qq(157 ORE => 5 NZVS
165 ORE => 6 DCFZ
44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
179 ORE => 7 PSHF
177 ORE => 5 HKGWZ
7 DCFZ, 7 PSHF => 2 XJWVT
165 ORE => 2 GPVTF
3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT);

    my @input2 = split "\n",
qq(2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
17 NVRVD, 3 JNWZP => 8 VPVL
53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
22 VJHF, 37 MNCFX => 5 FWMGM
139 ORE => 4 NVRVD
144 ORE => 7 JNWZP
5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
145 ORE => 6 MNCFX
1 NVRVD => 8 CXFTF
1 VJHF, 6 MNCFX => 4 RFSQX
176 ORE => 6 VJHF);

    my @input3 = split "\n",
qq(171 ORE => 8 CNZTR
7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
114 ORE => 4 BHXH
14 VRPVC => 6 BMBT
6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL
6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT
15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW
13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW
5 BMBT => 4 WPTQ
189 ORE => 9 KTJDG
1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP
12 VRPVC, 27 CNZTR => 2 XDBXC
15 KTJDG, 12 BHXH => 5 XCVML
3 BHXH, 2 VRPVC => 7 MZWV
121 ORE => 7 VRPVC
7 XCVML => 6 RJRHP
5 BHXH, 4 VRPVC => 5 LTCX);


    open my $FH, '<', 'input_14.txt' or die $!;
    my @input = <$FH>;

    my $formulas = C14_1::parse_input(@input);

    say compute_fuel_max($formulas, 1_000_000_000_000);
}

1;
