#!/usr/bin/perl

package C08_1;

use strict;
use warnings;
use feature qw( say );

my $width = 25;
my $height = 6;
my $layer_size = $width * $height;


# Call main if script is ran directly (ie, not loaded by another script)
main() unless caller;


sub layerize_image {
    my @data = @_;

    my @layers = map { [ @data[$_ * $layer_size .. ($_+1) * $layer_size - 1] ] }
                 0 .. (@data / $layer_size)-1;

    return @layers;
}

sub get_1s_times_2s_when_minimal_0s {
    my @layers = @_;
    my ($min, $idx_min) = ($layer_size+1, -1);
    for my $i (0 .. $#layers) {
        my $zeros = grep { $_ == 0 } @{$layers[$i]};
        if ($zeros < $min) {
            ($min, $idx_min) = ($zeros, $i)
        }
    }
    my $ones = grep { $_ == 1 } @{$layers[$idx_min]};
    my $twos = grep { $_ == 2 } @{$layers[$idx_min]};
    return $ones * $twos;
}


sub main {
    # ($width, $height) = (3, 2);
    # my $data = "123456789012";

    ($width, $height) = (25, 6);
    open my $FH, '<', "input_08.txt" or die $!;
    my $data = do { local $/ = undef; <$FH> };

    my @layers = layerize_image(split //, $data);

    say get_1s_times_2s_when_minimal_0s(@layers);

}

1;
